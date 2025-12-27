# Python Core — Instruções para o LLM

Contexto: projeto Python (biblioteca ou aplicação). Siga padrões de qualidade e gere código seguro e testável.

## Objetivo do assistant

- Fornecer código compatível com Python >=3.12, seguindo PEP8 e type hints.
- Criar ou sugerir testes com pytest para cada mudança funcional.
- Gerar `pyproject.toml` snippets e comandos de instalação/venv quando necessário.

## Restrições e estilo

- **Line length**: 79 caracteres (hard limit)
- **Indentação**: 4 espaços (nunca tabs)
- **Imports**: ordem stdlib → third-party → local, use `isort` ou `ruff`
- **Type hints**: obrigatórios em funções públicas, use `from __future__ import annotations` quando necessário
- **Docstrings**: Google style, primeira linha descritiva, Args/Returns/Raises quando aplicável
- **Pathlib**: use `Path` ao invés de `os.path`
- **F-strings**: prefira sobre `.format()` ou `%`
- **Exceptions**: específicas, nunca `except Exception:` sem re-raise

## Estrutura esperada

### Função típica

```python
from pathlib import Path
from typing import TypedDict

class Config(TypedDict):
    """Configuration dictionary structure."""
    host: str
    port: int
    debug: bool

def load_config(path: Path) -> Config:
    """Load configuration from TOML file.

    Args:
        path: Path to configuration file

    Returns:
        Parsed configuration dictionary

    Raises:
        FileNotFoundError: Config file doesn't exist
        ValueError: Invalid configuration format
    """
    if not path.exists():
        raise FileNotFoundError(f"Config not found: {path}")

    import tomllib
    with path.open("rb") as f:
        data = tomllib.load(f)

    return Config(
        host=data["host"],
        port=data["port"],
        debug=data.get("debug", False)
    )
```

### Teste correspondente

```python
import pytest
from pathlib import Path

def test_load_config_success(tmp_path: Path):
    """Test successful config loading."""
    config_file = tmp_path / "config.toml"
    config_file.write_text('[app]\nhost = "localhost"\nport = 8000')

    config = load_config(config_file)

    assert config["host"] == "localhost"
    assert config["port"] == 8000
    assert config["debug"] is False

def test_load_config_missing_file():
    """Test config loading with missing file."""
    with pytest.raises(FileNotFoundError, match="Config not found"):
        load_config(Path("nonexistent.toml"))
```

## pyproject.toml snippet

```toml
[project]
name = "myproject"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-cov>=4.1",
    "ruff>=0.1",
]

[tool.ruff]
line-length = 79
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP", "B", "PL", "PT"]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --cov=src"
```

## Comandos de execução

```bash
# Setup
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"

# Run tests
pytest

# Format/lint
ruff format .
ruff check --fix .
```

## Saída esperada do LLM

Para cada request, forneça:

1. Código da função com type hints e docstring
2. Teste unitário (pytest) com fixture se necessário
3. Comando de execução (1 linha)

Exemplo: "Função `parse_url` implementada, teste em `test_parser.py`, execute com `pytest tests/test_parser.py -v`"
