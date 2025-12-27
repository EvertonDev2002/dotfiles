# Instruções - Projeto Python

Este arquivo foi dividido em templates menores para uso do LLM.
Use os arquivos específicos:

- `python-core.md` — regras de estilo, typing, testes, `pyproject.toml` snippets.
- `python-nlp-ml.md` — orientações para NLP/ML: treino reprodutível, seed, métricas e device handling.

Para gerar instruções objetivas do Copilot, execute:

```bash
./scripts/tools/generate.sh python-core
./scripts/tools/generate.sh python-nlp-ml
```

Esses arquivos são curtos, direcionados ao LLM e contêm exemplos mínimos e saídas esperadas.

        return {
            "input_ids": encoding["input_ids"].flatten(),
            "attention_mask": encoding["attention_mask"].flatten(),
            "label": torch.tensor(label, dtype=torch.long)
        }

class TextClassifier(nn.Module):
"""󰚩 Classificador baseado em BERT."""

    def __init__(
        self,
        model_name: str = "bert-base-uncased",
        num_classes: int = 2,
        dropout: float = 0.3
    ):
        super().__init__()
        self.bert = AutoModel.from_pretrained(model_name)
        self.dropout = nn.Dropout(dropout)
        self.classifier = nn.Linear(
            self.bert.config.hidden_size,
            num_classes
        )

    def forward(
        self,
        input_ids: torch.Tensor,
        attention_mask: torch.Tensor
    ) -> torch.Tensor:
        """Forward pass."""
        outputs = self.bert(
            input_ids=input_ids,
            attention_mask=attention_mask
        )

        # 󰋗 Usa [CLS] token representation
        pooled = outputs.last_hidden_state[:, 0]
        pooled = self.dropout(pooled)
        logits = self.classifier(pooled)

        return logits

def train_epoch(
model: nn.Module,
dataloader: DataLoader,
optimizer: torch.optim.Optimizer,
criterion: nn.Module,
device: torch.device
) -> Tuple[float, float]:
"""󰚩 Treina por uma época."""
model.train()
total_loss = 0
correct = 0
total = 0

    for batch in dataloader:
        input_ids = batch["input_ids"].to(device)
        attention_mask = batch["attention_mask"].to(device)
        labels = batch["label"].to(device)

        # Forward
        optimizer.zero_grad()
        logits = model(input_ids, attention_mask)
        loss = criterion(logits, labels)

        # Backward
        loss.backward()

        # 󰄬 Gradient clipping para estabilidade
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)

        optimizer.step()

        # Metrics
        total_loss += loss.item()
        predictions = torch.argmax(logits, dim=1)
        correct += (predictions == labels).sum().item()
        total += labels.size(0)

    return total_loss / len(dataloader), correct / total

````

### Experiment Tracking (MLflow)

```python
import mlflow
import mlflow.pytorch

# 󰋗 Configure tracking server
mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment("sentiment-analysis")

def train_with_tracking(config: dict):
    """󰚩 Treina modelo com tracking completo."""

    with mlflow.start_run(run_name=config["run_name"]):
        # 󰄬 Log parameters
        mlflow.log_params({
            "model": config["model_name"],
            "learning_rate": config["lr"],
            "batch_size": config["batch_size"],
            "epochs": config["epochs"],
        })

        # 󰚩 Train
        model = train_model(config)

        # 󰄬 Log metrics
        mlflow.log_metrics({
            "accuracy": accuracy,
            "f1_score": f1,
            "loss": loss
        })

        # 󰄬 Log artifacts
        mlflow.log_artifact("confusion_matrix.png")
        mlflow.log_artifact("config.yaml")

        # 󰄬 Log model
        mlflow.pytorch.log_model(
            model,
            "model",
            registered_model_name="sentiment-classifier"
        )
````

### Model Serving (FastAPI)

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import torch
from typing import List

app = FastAPI(title="NLP Model API")

class ModelState:
    """󰋗 Global model state."""
    model = None
    tokenizer = None
    device = None

state = ModelState()

class PredictionRequest(BaseModel):
    texts: List[str]

class PredictionResponse(BaseModel):
    predictions: List[int]
    probabilities: List[List[float]]

@app.on_event("startup")
async def load_model():
    """󰚩 Lazy loading do modelo na inicialização."""
    state.device = torch.device(
        "cuda" if torch.cuda.is_available() else "cpu"
    )

    from transformers import AutoTokenizer
    state.tokenizer = AutoTokenizer.from_pretrained("models/tokenizer")
    state.model = torch.load("models/model.pt", map_location=state.device)
    state.model.eval()

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    """󰚩 Endpoint de predição."""
    if state.model is None:
        raise HTTPException(503, "Model not loaded")

    try:
        encodings = state.tokenizer(
            request.texts,
            padding=True,
            truncation=True,
            max_length=128,
            return_tensors="pt"
        ).to(state.device)

        with torch.no_grad():
            logits = state.model(**encodings)
            probs = torch.softmax(logits, dim=1)
            preds = torch.argmax(probs, dim=1)

        return PredictionResponse(
            predictions=preds.cpu().tolist(),
            probabilities=probs.cpu().tolist()
        )
    except Exception as e:
        raise HTTPException(500, str(e))

@app.get("/health")
async def health():
    """󰄬 Health check."""
    return {
        "status": "healthy",
        "model_loaded": state.model is not None
    }
```

### Quantização de Modelos

**Para ambientes de desenvolvimento local ou recursos limitados:**

```python
# 󰄬 Quantização com bitsandbytes (8-bit/4-bit)
from transformers import AutoModelForCausalLM, BitsAndBytesConfig
import torch

# 4-bit quantization
quantization_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.float16,
    bnb_4bit_use_double_quant=True,
    bnb_4bit_quant_type="nf4"
)

model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-7b-hf",
    quantization_config=quantization_config,
    device_map="auto"
)

# 󰋗 Reduz uso de memória em ~75% (32-bit → 4-bit)
```

**Conversão para GGUF (llama.cpp):**

```bash
# 󰄬 Converter modelo PyTorch para GGUF
python convert.py --model-name meta-llama/Llama-2-7b-hf \
  --outfile llama-2-7b.gguf \
  --outtype q4_0  # 4-bit quantization

# 󰋗 Quantização disponíveis: q4_0, q4_1, q5_0, q5_1, q8_0
# Menor número = menor tamanho, maior perda de qualidade
```

**ONNX Runtime Quantização:**

```python
from optimum.onnxruntime import ORTModelForSequenceClassification
from optimum.onnxruntime.configuration import AutoQuantizationConfig

# 󰄬 Dynamic quantization
quantization_config = AutoQuantizationConfig.avx512_vnni(is_static=False)

model = ORTModelForSequenceClassification.from_pretrained(
    "bert-base-uncased",
    export=True
)

model.quantize(
    quantization_config=quantization_config,
    save_directory="./quantized_model"
)

# 󰋗 Inferência 2-4x mais rápida em CPU
```

**Quando usar quantização:**

- 󰄬 Desenvolvimento local com GPU limitada (< 16GB VRAM)
- 󰄬 Deploy em edge devices ou ambientes de baixo custo
- 󰄬 Prototipagem rápida com modelos grandes
- 󰌢 Sempre avalie impacto na qualidade (perplexity, F1, etc.)

### Checklist NLP

Antes de finalizar projeto NLP:

- [ ] 󰄬 Seeds fixadas para reprodutibilidade
- [ ] 󰄬 Tokenizer verificado (vocab size, special tokens)
- [ ] 󰄬 Dataset balanceado ou estratégia de sampling definida
- [ ] 󰄬 Métricas adequadas (accuracy, F1, ROC-AUC)
- [ ] 󰄬 Experiment tracking configurado (MLflow/W&B)
- [ ] 󰄬 Model serving com health checks
- [ ] 󰌢 Validação de inputs de API
- [ ] 󰄬 Logs estruturados com contexto
- [ ] 󰋗 Quantização avaliada para ambientes de recursos limitados

## Referências Python

- [Python Official Documentation](https://docs.python.org/3/)
- [PEP 8 Style Guide](https://peps.python.org/pep-0008/)
- [UV Documentation](https://docs.astral.sh/uv/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Pytest Documentation](https://docs.pytest.org/)
- [Typer Documentation](https://typer.tiangolo.com/)
- [Python Type Hints](https://docs.python.org/3/library/typing.html)

### NLP/ML Específico

- [Hugging Face Transformers](https://huggingface.co/docs/transformers/)
- [PyTorch Tutorials](https://pytorch.org/tutorials/)
- [spaCy Documentation](https://spacy.io/usage)
- [LangChain Documentation](https://python.langchain.com/)
- [MLflow Documentation](https://mlflow.org/docs/latest/)
- [Polars Documentation](https://pola-rs.github.io/polars/)
