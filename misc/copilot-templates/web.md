# Instruções - Projeto Web

Este arquivo foi dividido em templates menores e mais focados para o LLM:

- `fastapi.md` — endpoints, schemas e testes (Pydantic v2 preferred).
- `react.md` — componentes TypeScript, hooks e testes (Vitest + Testing Library).
- `typescript-core.md` — regras de tipagem, validação com Zod e tsconfig exemplos.

Use o gerador para combinar templates curtos e objetivos:

```bash
./scripts/tools/generate.sh fastapi react typescript-core
```

Esses arquivos contêm instruções concisas para o LLM (exemplos mínimos, restrições e saída esperada).

```
backend/
├── src/
│   ├── routes/
│   │   ├── users.ts
│   │   └── auth.ts
│   ├── controllers/
│   │   ├── userController.ts
│   │   └── authController.ts
│   ├── models/
│   │   └── User.ts
│   ├── services/
│   │   └── userService.ts
│   ├── middleware/
│   │   ├── auth.ts
│   │   ├── errorHandler.ts
│   │   └── validation.ts
│   ├── config/
│   │   ├── database.ts
│   │   └── env.ts
│   ├── types/
│   │   └── index.ts
│   └── app.ts
├── tests/
│   ├── setup.ts
│   ├── users.test.ts
│   └── auth.test.ts
├── package.json
├── tsconfig.json
├── .env.example
└── README.md
```

## Configuração TypeScript

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

## Boas Práticas Backend

### FastAPI - API REST com Validação

```python
# schemas/user.py
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    name: Optional[str] = Field(None, min_length=1, max_length=100)

class UserResponse(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

# models/user.py
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from .base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

# services/user_service.py
from sqlalchemy.orm import Session
from typing import Optional
from ..models.user import User
from ..schemas.user import UserCreate, UserUpdate
from ..core.security import get_password_hash

class UserService:
    @staticmethod
    def create(db: Session, user: UserCreate) -> User:
        hashed_password = get_password_hash(user.password)
        db_user = User(
            email=user.email,
            name=user.name,
            hashed_password=hashed_password
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user

    @staticmethod
    def get_by_email(db: Session, email: str) -> Optional[User]:
        return db.query(User).filter(User.email == email).first()

    @staticmethod
    def get_by_id(db: Session, user_id: int) -> Optional[User]:
        return db.query(User).filter(User.id == user_id).first()

    @staticmethod
    def update(db: Session, user_id: int, user_update: UserUpdate) -> Optional[User]:
        db_user = db.query(User).filter(User.id == user_id).first()
        if not db_user:
            return None

        update_data = user_update.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_user, field, value)

        db.commit()
        db.refresh(db_user)
        return db_user

# api/routes/users.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ...core.database import get_db
from ...schemas.user import UserCreate, UserResponse, UserUpdate
from ...services.user_service import UserService

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    """Create new user."""
    existing_user = UserService.get_by_email(db, user.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    return UserService.create(db, user)

@router.get("/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    """Get user by ID."""
    user = UserService.get_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

@router.patch("/{user_id}", response_model=UserResponse)
def update_user(
    user_id: int,
    user_update: UserUpdate,
    db: Session = Depends(get_db)
):
    """Update user."""
    user = UserService.update(db, user_id, user_update)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

# core/config.py
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    app_name: str = "MyAPI"
    debug: bool = False
    database_url: str
    secret_key: str
    access_token_expire_minutes: int = 30

    class Config:
        env_file = ".env"

settings = Settings()
```

### Express/TypeScript - API REST

```typescript
// types/index.ts
export interface User {
  id: number;
  email: string;
  name: string;
  createdAt: Date;
}

export interface CreateUserDto {
  email: string;
  name: string;
  password: string;
}

export interface UpdateUserDto {
  email?: string;
  name?: string;
}

// config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z
    .enum(['development', 'production', 'test'])
    .default('development'),
  PORT: z.string().transform(Number).default('3000'),
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string(),
  JWT_EXPIRES_IN: z.string().default('1d'),
});

export const env = envSchema.parse(process.env);

// middleware/validation.ts
import { Request, Response, NextFunction } from 'express';
import { z, ZodSchema } from 'zod';

export function validateBody<T extends ZodSchema>(schema: T) {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      req.body = await schema.parseAsync(req.body);
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          error: 'Validation failed',
          details: error.errors,
        });
      }
      next(error);
    }
  };
}

// middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      status: 'error',
      message: err.message,
    });
  }

  console.error('ERROR 💥', err);
  return res.status(500).json({
    status: 'error',
    message: 'Internal server error',
  });
}

// services/userService.ts
import { PrismaClient } from '@prisma/client';
import { hash } from 'bcrypt';
import type { CreateUserDto, UpdateUserDto, User } from '../types';
import { AppError } from '../middleware/errorHandler';

const prisma = new PrismaClient();

export class UserService {
  static async create(data: CreateUserDto): Promise<User> {
    const existingUser = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existingUser) {
      throw new AppError(400, 'Email already registered');
    }

    const hashedPassword = await hash(data.password, 10);

    return prisma.user.create({
      data: {
        email: data.email,
        name: data.name,
        password: hashedPassword,
      },
    });
  }

  static async findById(id: number): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  }

  static async update(id: number, data: UpdateUserDto): Promise<User> {
    const user = await prisma.user.findUnique({ where: { id } });

    if (!user) {
      throw new AppError(404, 'User not found');
    }

    return prisma.user.update({
      where: { id },
      data,
    });
  }
}

// routes/users.ts
import { Router } from 'express';
import { z } from 'zod';
import { UserService } from '../services/userService';
import { validateBody } from '../middleware/validation';
import { AppError } from '../middleware/errorHandler';

const router = Router();

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  password: z.string().min(8),
});

const updateUserSchema = z.object({
  email: z.string().email().optional(),
  name: z.string().min(1).max(100).optional(),
});

router.post('/', validateBody(createUserSchema), async (req, res, next) => {
  try {
    const user = await UserService.create(req.body);
    const { password, ...userWithoutPassword } = user;
    res.status(201).json(userWithoutPassword);
  } catch (error) {
    next(error);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const id = parseInt(req.params.id);
    const user = await UserService.findById(id);

    if (!user) {
      throw new AppError(404, 'User not found');
    }

    const { password, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
  } catch (error) {
    next(error);
  }
});

router.patch('/:id', validateBody(updateUserSchema), async (req, res, next) => {
  try {
    const id = parseInt(req.params.id);
    const user = await UserService.update(id, req.body);
    const { password, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
  } catch (error) {
    next(error);
  }
});

export default router;
```

### Backend Testing

**FastAPI + pytest:**

```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from src.main import app
from src.models.base import Base
from src.core.database import get_db

SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture
def db():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture
def client(db):
    def override_get_db():
        try:
            yield db
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
    app.dependency_overrides.clear()

# tests/test_users.py
import pytest
from fastapi import status

def test_create_user(client):
    response = client.post(
        "/users/",
        json={
            "email": "test@example.com",
            "name": "Test User",
            "password": "securepassword123"
        }
    )
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["email"] == "test@example.com"
    assert data["name"] == "Test User"
    assert "id" in data
    assert "password" not in data

def test_create_user_duplicate_email(client):
    # Create first user
    client.post(
        "/users/",
        json={
            "email": "test@example.com",
            "name": "Test User",
            "password": "password123"
        }
    )

    # Try to create duplicate
    response = client.post(
        "/users/",
        json={
            "email": "test@example.com",
            "name": "Another User",
            "password": "password456"
        }
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST

def test_get_user(client):
    # Create user
    create_response = client.post(
        "/users/",
        json={
            "email": "test@example.com",
            "name": "Test User",
            "password": "password123"
        }
    )
    user_id = create_response.json()["id"]

    # Get user
    response = client.get(f"/users/{user_id}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == user_id
    assert data["email"] == "test@example.com"

def test_get_user_not_found(client):
    response = client.get("/users/999")
    assert response.status_code == status.HTTP_404_NOT_FOUND
```

**Express + Vitest + Supertest:**

```typescript
// tests/setup.ts
import { beforeAll, afterAll, beforeEach } from 'vitest';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

beforeAll(async () => {
  // Setup test database
});

afterAll(async () => {
  await prisma.$disconnect();
});

beforeEach(async () => {
  // Clean database before each test
  await prisma.user.deleteMany();
});

// tests/users.test.ts
import { describe, it, expect } from 'vitest';
import request from 'supertest';
import app from '../src/app';

describe('POST /users', () => {
  it('should create a new user', async () => {
    const response = await request(app).post('/users').send({
      email: 'test@example.com',
      name: 'Test User',
      password: 'securepassword123',
    });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');
    expect(response.body.email).toBe('test@example.com');
    expect(response.body).not.toHaveProperty('password');
  });

  it('should return 400 for invalid email', async () => {
    const response = await request(app).post('/users').send({
      email: 'invalid-email',
      name: 'Test User',
      password: 'password123',
    });

    expect(response.status).toBe(400);
    expect(response.body).toHaveProperty('error');
  });

  it('should return 400 for duplicate email', async () => {
    const userData = {
      email: 'test@example.com',
      name: 'Test User',
      password: 'password123',
    };

    await request(app).post('/users').send(userData);
    const response = await request(app).post('/users').send(userData);

    expect(response.status).toBe(400);
    expect(response.body.message).toContain('already registered');
  });
});

describe('GET /users/:id', () => {
  it('should get user by id', async () => {
    const createResponse = await request(app).post('/users').send({
      email: 'test@example.com',
      name: 'Test User',
      password: 'password123',
    });

    const userId = createResponse.body.id;

    const response = await request(app).get(`/users/${userId}`);

    expect(response.status).toBe(200);
    expect(response.body.id).toBe(userId);
    expect(response.body).not.toHaveProperty('password');
  });

  it('should return 404 for non-existent user', async () => {
    const response = await request(app).get('/users/999');

    expect(response.status).toBe(404);
  });
});
```

## Boas Práticas TypeScript/React

### Componentes Tipados

```typescript
// types/user.ts
export interface User {
  id: string;
  name: string;
  email: string;
}

// components/UserCard.tsx
import type { User } from '@/types/user';

interface UserCardProps {
  user: User;
  onEdit?: (user: User) => void;
}

export function UserCard({ user, onEdit }: UserCardProps) {
  return (
    <div>
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      {onEdit && <button onClick={() => onEdit(user)}>Edit</button>}
    </div>
  );
}
```

### Custom Hooks

```typescript
import { useState, useEffect } from 'react';

interface UseApiOptions<T> {
  url: string;
  initialData?: T;
}

export function useApi<T>({ url, initialData }: UseApiOptions<T>) {
  const [data, setData] = useState<T | undefined>(initialData);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await fetch(url);
        const json = await response.json();
        setData(json);
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [url]);

  return { data, loading, error };
}

// Uso
function UserList() {
  const {
    data: users,
    loading,
    error,
  } = useApi<User[]>({
    url: '/api/users',
  });

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      {users?.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}
```

### Services/API Layer

```typescript
// services/api.ts
class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

async function request<T>(url: string, options?: RequestInit): Promise<T> {
  const response = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
  });

  if (!response.ok) {
    throw new ApiError(response.status, response.statusText);
  }

  return response.json();
}

// services/users.ts
import type { User } from '@/types/user';

export const userService = {
  getAll: () => request<User[]>('/api/users'),
  getById: (id: string) => request<User>(`/api/users/${id}`),
  create: (user: Omit<User, 'id'>) =>
    request<User>('/api/users', {
      method: 'POST',
      body: JSON.stringify(user),
    }),
  update: (id: string, user: Partial<User>) =>
    request<User>(`/api/users/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(user),
    }),
  delete: (id: string) =>
    request<void>(`/api/users/${id}`, { method: 'DELETE' }),
};
```

### State Management (Zustand)

```typescript
import { create } from 'zustand';
import type { User } from '@/types/user';

interface UserStore {
  users: User[];
  loading: boolean;
  error: Error | null;
  fetchUsers: () => Promise<void>;
  addUser: (user: Omit<User, 'id'>) => Promise<void>;
  removeUser: (id: string) => Promise<void>;
}

export const useUserStore = create<UserStore>((set) => ({
  users: [],
  loading: false,
  error: null,

  fetchUsers: async () => {
    set({ loading: true, error: null });
    try {
      const users = await userService.getAll();
      set({ users, loading: false });
    } catch (error) {
      set({ error: error as Error, loading: false });
    }
  },

  addUser: async (user) => {
    try {
      const newUser = await userService.create(user);
      set((state) => ({ users: [...state.users, newUser] }));
    } catch (error) {
      set({ error: error as Error });
    }
  },

  removeUser: async (id) => {
    try {
      await userService.delete(id);
      set((state) => ({
        users: state.users.filter((u) => u.id !== id),
      }));
    } catch (error) {
      set({ error: error as Error });
    }
  },
}));
```

## Testing

### Component Tests (Vitest + Testing Library)

```typescript
// UserCard.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { UserCard } from './UserCard';
import type { User } from '@/types/user';

describe('UserCard', () => {
  const mockUser: User = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
  };

  it('renders user information', () => {
    render(<UserCard user={mockUser} />);

    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('calls onEdit when edit button is clicked', () => {
    const onEdit = vi.fn();
    render(<UserCard user={mockUser} onEdit={onEdit} />);

    fireEvent.click(screen.getByText('Edit'));

    expect(onEdit).toHaveBeenCalledWith(mockUser);
  });

  it('does not render edit button when onEdit is not provided', () => {
    render(<UserCard user={mockUser} />);

    expect(screen.queryByText('Edit')).not.toBeInTheDocument();
  });
});
```

### API Tests

```typescript
// services/users.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { userService } from './users';

global.fetch = vi.fn();

describe('userService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('fetches all users', async () => {
    const mockUsers = [{ id: '1', name: 'John', email: 'john@test.com' }];

    (global.fetch as any).mockResolvedValueOnce({
      ok: true,
      json: async () => mockUsers,
    });

    const users = await userService.getAll();

    expect(users).toEqual(mockUsers);
    expect(global.fetch).toHaveBeenCalledWith('/api/users', expect.any(Object));
  });
});
```

## Configuração package.json

```json
{
  "name": "my-app",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "lint": "eslint . --ext ts,tsx",
    "format": "prettier --write \"src/**/*.{ts,tsx,json,css}\""
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.2.0",
    "typescript": "^5.3.0",
    "vite": "^5.0.0",
    "vitest": "^1.1.0",
    "@testing-library/react": "^14.1.0",
    "eslint": "^8.56.0",
    "prettier": "^3.1.0"
  }
}
```

## Referências Web

### Frontend

- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [PNPM Documentation](https://pnpm.io/)
- [Vitest Documentation](https://vitest.dev/)
- [Testing Library](https://testing-library.com/react)
- [MDN Web Docs](https://developer.mozilla.org/)

### Backend

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Express.js Documentation](https://expressjs.com/)
- [Fastify Documentation](https://www.fastify.io/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [Zod Documentation](https://zod.dev/)
- [Supertest Documentation](https://github.com/ladjs/supertest)
