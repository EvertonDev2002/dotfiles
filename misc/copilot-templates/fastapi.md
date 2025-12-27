# FastAPI — Instruções para o LLM

Contexto: APIs backend com FastAPI.

## Objetivo do assistant

- Gerar rotas, Pydantic models (Pydantic v2), dependências e testes (TestClient/pytest).
- Garantir endpoints de health, documentação OpenAPI e tratamento de erros.

## Estrutura esperada

### Schema (Pydantic v2)

```python
from pydantic import BaseModel, EmailStr, Field, ConfigDict
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
```

### Route com validação

```python
from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy.orm import Session

router = APIRouter(prefix="/users", tags=["users"])

@router.post(
    "/",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED
)
def create_user(
    user: UserCreate,
    db: Session = Depends(get_db)
):
    """Create new user with validation."""
    existing = db.query(User).filter(
        User.email == user.email
    ).first()

    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    db_user = User(**user.model_dump(exclude={"password"}))
    db_user.hashed_password = hash_password(user.password)

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return db_user

@router.get("/health")
def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}
```

### Teste com TestClient

```python
from fastapi.testclient import TestClient
import pytest

def test_create_user(client: TestClient):
    """Test user creation."""
    response = client.post(
        "/users/",
        json={
            "email": "test@example.com",
            "name": "Test User",
            "password": "securepass123"
        }
    )

    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "id" in data
    assert "password" not in data

def test_create_user_duplicate_email(client: TestClient):
    """Test duplicate email validation."""
    user_data = {
        "email": "dup@example.com",
        "name": "User",
        "password": "pass123"
    }

    client.post("/users/", json=user_data)
    response = client.post("/users/", json=user_data)

    assert response.status_code == 400
    assert "already registered" in response.json()["detail"]
```

### Fixture conftest.py

```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

@pytest.fixture
def db():
    """Create test database."""
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False}
    )
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine)

    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@pytest.fixture
def client(db):
    """Create test client."""
    def override_get_db():
        try:
            yield db
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
    app.dependency_overrides.clear()
```

## Restrições

- **Validação**: sempre use Pydantic models para input/output
- **Errors**: HTTPException com status code apropriado e detail message
- **DB**: use fixtures com sqlite in-memory para testes
- **Docs**: endpoints devem ter docstrings para OpenAPI
- **Health**: sempre inclua endpoint `/health`

## Comandos

```bash
# Run server
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Run tests
pytest tests/ -v --cov=app

# Docs
# http://localhost:8000/docs
```

## Saída esperada

1. Schema Pydantic (v2 style com `model_config`)
2. Route com validação e error handling
3. Teste com TestClient e fixture
4. Comando uvicorn para executar
