# Python — NLP & ML (Instruções para o LLM)

Contexto: PyTorch, Transformers, treinamento reproduzível, MLflow.

## Objetivo do assistant

- Gerar código ML reproduzível: seeds, dataloaders, training loops, eval.
- Integrar tracking (MLflow), processamento eficiente (polars).

## Estrutura esperada

### Reprodutibilidade (seed fixing)

```python
# utils/seed.py
import random
import numpy as np
import torch


def set_seed(seed: int = 42) -> None:
    """
    Fix seeds para reprodutibilidade completa.

    Args:
        seed: Seed para todos os RNGs
    """
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)

    # Garante determinismo (pode reduzir performance)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

    # Para operações no DataLoader
    import os
    os.environ["PYTHONHASHSEED"] = str(seed)
```

### Dataset preparation (polars)

```python
# data/preprocessing.py
from pathlib import Path
from typing import List
import polars as pl
from transformers import AutoTokenizer


def load_and_preprocess(
    data_path: Path,
    tokenizer_name: str = "bert-base-uncased",
    max_length: int = 128,
    test_size: float = 0.2,
) -> tuple[pl.DataFrame, pl.DataFrame]:
    """
    Carrega e preprocessa dataset.

    Args:
        data_path: Caminho para CSV/Parquet
        tokenizer_name: Nome do tokenizer
        max_length: Comprimento máximo de tokens
        test_size: Proporção do test set

    Returns:
        (train_df, test_df)
    """
    # Load with polars (mais rápido que pandas)
    df = pl.read_csv(data_path)

    # Basic cleaning
    df = df.filter(pl.col("text").str.len_chars() > 10)
    df = df.drop_nulls()

    # Tokenization
    tokenizer = AutoTokenizer.from_pretrained(tokenizer_name)

    def tokenize_batch(texts: List[str]) -> dict:
        return tokenizer(
            texts,
            padding="max_length",
            truncation=True,
            max_length=max_length,
            return_tensors="pt",
        )

    # Split train/test
    df = df.with_row_count("index")
    test_df = df.sample(fraction=test_size, seed=42)
    train_df = df.filter(~pl.col("index").is_in(test_df["index"]))

    return train_df, test_df
```

### Custom Dataset (PyTorch)

```python
# data/dataset.py
from typing import List
import torch
from torch.utils.data import Dataset
from transformers import PreTrainedTokenizer


class TextClassificationDataset(Dataset):
    """Dataset para classificação de texto."""

    def __init__(
        self,
        texts: List[str],
        labels: List[int],
        tokenizer: PreTrainedTokenizer,
        max_length: int = 128,
    ):
        """
        Args:
            texts: Lista de textos
            labels: Lista de labels (int)
            tokenizer: Tokenizer pré-treinado
            max_length: Comprimento máximo
        """
        self.texts = texts
        self.labels = labels
        self.tokenizer = tokenizer
        self.max_length = max_length

    def __len__(self) -> int:
        return len(self.texts)

    def __getitem__(self, idx: int) -> dict[str, torch.Tensor]:
        text = self.texts[idx]
        label = self.labels[idx]

        encoding = self.tokenizer(
            text,
            max_length=self.max_length,
            padding="max_length",
            truncation=True,
            return_tensors="pt",
        )

        return {
            "input_ids": encoding["input_ids"].flatten(),
            "attention_mask": encoding["attention_mask"].flatten(),
            "label": torch.tensor(label, dtype=torch.long),
        }
```

### Model definition

```python
# models/classifier.py
import torch
import torch.nn as nn
from transformers import AutoModel


class TextClassifier(nn.Module):
    """Classificador baseado em BERT."""

    def __init__(
        self,
        model_name: str = "bert-base-uncased",
        num_classes: int = 2,
        dropout: float = 0.3,
    ):
        """
        Args:
            model_name: Nome do modelo HuggingFace
            num_classes: Número de classes
            dropout: Dropout rate
        """
        super().__init__()
        self.bert = AutoModel.from_pretrained(model_name)
        self.dropout = nn.Dropout(dropout)
        self.classifier = nn.Linear(
            self.bert.config.hidden_size, num_classes
        )

    def forward(
        self, input_ids: torch.Tensor, attention_mask: torch.Tensor
    ) -> torch.Tensor:
        """
        Forward pass.

        Args:
            input_ids: [batch_size, seq_len]
            attention_mask: [batch_size, seq_len]

        Returns:
            logits: [batch_size, num_classes]
        """
        outputs = self.bert(
            input_ids=input_ids, attention_mask=attention_mask
        )

        # [CLS] token representation
        pooled = outputs.last_hidden_state[:, 0]  # [batch_size, hidden_size]
        pooled = self.dropout(pooled)
        logits = self.classifier(pooled)  # [batch_size, num_classes]

        return logits
```

### Training loop

```python
# train/trainer.py
from pathlib import Path
import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from tqdm import tqdm
from sklearn.metrics import accuracy_score, f1_score
import mlflow


def train_epoch(
    model: nn.Module,
    dataloader: DataLoader,
    optimizer: torch.optim.Optimizer,
    criterion: nn.Module,
    device: torch.device,
) -> tuple[float, float]:
    """
    Treina por uma época.

    Args:
        model: Modelo PyTorch
        dataloader: DataLoader de treino
        optimizer: Otimizador
        criterion: Loss function
        device: Device (cuda/cpu)

    Returns:
        (avg_loss, accuracy)
    """
    model.train()
    total_loss = 0
    all_preds = []
    all_labels = []

    for batch in tqdm(dataloader, desc="Training"):
        input_ids = batch["input_ids"].to(device)
        attention_mask = batch["attention_mask"].to(device)
        labels = batch["label"].to(device)

        # Forward
        optimizer.zero_grad()
        logits = model(input_ids, attention_mask)
        loss = criterion(logits, labels)

        # Backward
        loss.backward()

        # Gradient clipping para estabilidade
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)

        optimizer.step()

        # Metrics
        total_loss += loss.item()
        preds = torch.argmax(logits, dim=1).cpu().numpy()
        all_preds.extend(preds)
        all_labels.extend(labels.cpu().numpy())

    avg_loss = total_loss / len(dataloader)
    accuracy = accuracy_score(all_labels, all_preds)

    return avg_loss, accuracy


@torch.no_grad()
def evaluate(
    model: nn.Module,
    dataloader: DataLoader,
    criterion: nn.Module,
    device: torch.device,
) -> dict[str, float]:
    """
    Avalia modelo.

    Args:
        model: Modelo PyTorch
        dataloader: DataLoader de validação
        criterion: Loss function
        device: Device

    Returns:
        Dicionário com métricas
    """
    model.eval()
    total_loss = 0
    all_preds = []
    all_labels = []

    for batch in tqdm(dataloader, desc="Evaluating"):
        input_ids = batch["input_ids"].to(device)
        attention_mask = batch["attention_mask"].to(device)
        labels = batch["label"].to(device)

        logits = model(input_ids, attention_mask)
        loss = criterion(logits, labels)

        total_loss += loss.item()
        preds = torch.argmax(logits, dim=1).cpu().numpy()
        all_preds.extend(preds)
        all_labels.extend(labels.cpu().numpy())

    avg_loss = total_loss / len(dataloader)
    accuracy = accuracy_score(all_labels, all_preds)
    f1 = f1_score(all_labels, all_preds, average="weighted")

    return {"loss": avg_loss, "accuracy": accuracy, "f1": f1}


def train_with_mlflow(
    model: nn.Module,
    train_loader: DataLoader,
    val_loader: DataLoader,
    config: dict,
    device: torch.device,
) -> None:
    """
    Training loop completo com MLflow tracking.

    Args:
        model: Modelo a treinar
        train_loader: DataLoader treino
        val_loader: DataLoader validação
        config: Dict com hyperparameters
        device: Device
    """
    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.AdamW(
        model.parameters(),
        lr=config["learning_rate"],
        weight_decay=config.get("weight_decay", 0.01),
    )

    # MLflow tracking
    mlflow.set_experiment(config["experiment_name"])

    with mlflow.start_run(run_name=config["run_name"]):
        # Log hyperparameters
        mlflow.log_params(
            {
                "model": config["model_name"],
                "learning_rate": config["learning_rate"],
                "batch_size": config["batch_size"],
                "epochs": config["epochs"],
                "max_length": config["max_length"],
            }
        )

        best_f1 = 0.0

        for epoch in range(config["epochs"]):
            print(f"\nEpoch {epoch + 1}/{config['epochs']}")

            # Train
            train_loss, train_acc = train_epoch(
                model, train_loader, optimizer, criterion, device
            )

            # Evaluate
            val_metrics = evaluate(model, val_loader, criterion, device)

            # Log metrics
            mlflow.log_metrics(
                {
                    "train_loss": train_loss,
                    "train_accuracy": train_acc,
                    "val_loss": val_metrics["loss"],
                    "val_accuracy": val_metrics["accuracy"],
                    "val_f1": val_metrics["f1"],
                },
                step=epoch,
            )

            print(f"Train Loss: {train_loss:.4f} | Train Acc: {train_acc:.4f}")
            print(
                f"Val Loss: {val_metrics['loss']:.4f} | "
                f"Val Acc: {val_metrics['accuracy']:.4f} | "
                f"Val F1: {val_metrics['f1']:.4f}"
            )

            # Save best model
            if val_metrics["f1"] > best_f1:
                best_f1 = val_metrics["f1"]
                save_path = Path(config["output_dir"]) / "best_model.pt"
                save_path.parent.mkdir(parents=True, exist_ok=True)
                torch.save(model.state_dict(), save_path)
                mlflow.log_artifact(str(save_path))

        # Log final model
        mlflow.pytorch.log_model(model, "model")
```

### Main script

```python
# main.py
from pathlib import Path
import torch
from torch.utils.data import DataLoader
from transformers import AutoTokenizer

from utils.seed import set_seed
from data.dataset import TextClassificationDataset
from models.classifier import TextClassifier
from train.trainer import train_with_mlflow


def main():
    # Config
    config = {
        "experiment_name": "text-classification",
        "run_name": "bert-base-experiment-1",
        "model_name": "bert-base-uncased",
        "num_classes": 2,
        "max_length": 128,
        "batch_size": 32,
        "learning_rate": 2e-5,
        "weight_decay": 0.01,
        "epochs": 3,
        "output_dir": "outputs",
        "seed": 42,
    }

    # Set seed
    set_seed(config["seed"])

    # Device
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")

    # Load data (placeholder - replace with real data)
    tokenizer = AutoTokenizer.from_pretrained(config["model_name"])

    train_texts = ["Example text 1", "Example text 2"]
    train_labels = [0, 1]
    val_texts = ["Example val 1"]
    val_labels = [0]

    # Create datasets
    train_dataset = TextClassificationDataset(
        train_texts, train_labels, tokenizer, config["max_length"]
    )
    val_dataset = TextClassificationDataset(
        val_texts, val_labels, tokenizer, config["max_length"]
    )

    # Create dataloaders
    train_loader = DataLoader(
        train_dataset, batch_size=config["batch_size"], shuffle=True
    )
    val_loader = DataLoader(
        val_dataset, batch_size=config["batch_size"], shuffle=False
    )

    # Initialize model
    model = TextClassifier(
        model_name=config["model_name"], num_classes=config["num_classes"]
    ).to(device)

    # Train
    train_with_mlflow(model, train_loader, val_loader, config, device)


if __name__ == "__main__":
    main()
```

### Inference

```python
# inference.py
import torch
from transformers import AutoTokenizer
from models.classifier import TextClassifier


@torch.no_grad()
def predict(
    text: str, model: TextClassifier, tokenizer, device: torch.device
) -> tuple[int, float]:
    """
    Predição de um único texto.

    Args:
        text: Texto para classificar
        model: Modelo treinado
        tokenizer: Tokenizer
        device: Device

    Returns:
        (predicted_class, confidence)
    """
    model.eval()

    encoding = tokenizer(
        text, max_length=128, padding="max_length", truncation=True, return_tensors="pt"
    )

    input_ids = encoding["input_ids"].to(device)
    attention_mask = encoding["attention_mask"].to(device)

    logits = model(input_ids, attention_mask)
    probs = torch.softmax(logits, dim=1)
    pred_class = torch.argmax(probs, dim=1).item()
    confidence = probs[0, pred_class].item()

    return pred_class, confidence
```

## Restrições

- **Seeds**: SEMPRE fixe para reprodutibilidade
- **Device**: detecte cuda/cpu automaticamente
- **Gradient clipping**: use max_norm=1.0 para estabilidade
- **eval()**: SEMPRE use antes de inferência
- **torch.no_grad()**: SEMPRE em eval/inference
- **Shapes**: documente shapes nos docstrings
- **polars**: prefira sobre pandas para datasets grandes
- **MLflow**: track experiments, params e metrics
- **Type hints**: obrigatório em todas as funções

## Comandos

```bash
# Install dependencies
uv pip install torch transformers polars mlflow scikit-learn tqdm

# Train
python main.py

# MLflow UI
mlflow ui --port 5000

# Inference
python inference.py
```

## Saída esperada

1. Seed fixing function
2. Dataset com tokenization
3. Model com forward documentado (shapes)
4. Training loop com gradient clipping
5. Evaluation com torch.no_grad()
6. MLflow tracking integration
7. Inference script com eval mode
8. Comandos de execução
