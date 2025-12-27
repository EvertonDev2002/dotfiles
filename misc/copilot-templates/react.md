# React (TypeScript) — Instruções para o LLM

Contexto: componentes UI com TypeScript e Vite.

## Objetivo do assistant

- Gerar componentes tipados, hooks e testes (Vitest + Testing Library).
- Fornecer prop types precisos e evitar `any`.

## Estrutura esperada

### Componente com props tipadas

```typescript
// components/UserCard.tsx
interface User {
  id: string;
  name: string;
  email: string;
}

interface UserCardProps {
  user: User;
  onEdit?: (user: User) => void;
  onDelete?: (id: string) => void;
}

export function UserCard({ user, onEdit, onDelete }: UserCardProps) {
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <div className="actions">
        {onEdit && <button onClick={() => onEdit(user)}>Edit</button>}
        {onDelete && <button onClick={() => onDelete(user.id)}>Delete</button>}
      </div>
    </div>
  );
}
```

### Custom Hook

```typescript
// hooks/useApi.ts
import { useState, useEffect } from 'react';

interface UseApiResult<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
  refetch: () => void;
}

export function useApi<T>(url: string): UseApiResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      const response = await fetch(url);
      if (!response.ok) throw new Error(response.statusText);
      const json = await response.json();
      setData(json);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [url]);

  return { data, loading, error, refetch: fetchData };
}
```

### Teste com Testing Library

```typescript
// components/UserCard.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { UserCard } from './UserCard';

describe('UserCard', () => {
  const mockUser = {
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

### vitest.config.ts

```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
  },
});
```

### test/setup.ts

```typescript
import '@testing-library/jest-dom';
```

## Restrições

- **Indentação**: 2 espaços
- **Props**: sempre use interface, nunca type para props
- **Exports**: named exports, não default
- **Hooks**: extraia lógica complexa em custom hooks
- **Size**: componentes máx 30 linhas de JSX
- **Types**: evite `any`, use `unknown` se necessário
- **Events**: prefixo `handle` para handlers (handleClick, handleSubmit)

## Comandos

```bash
# Run dev
pnpm dev

# Run tests
pnpm test

# Run tests watch mode
pnpm test --watch
```

## Saída esperada

1. Componente com interface de props
2. Teste com render e user interactions
3. Custom hook se lógica > 5 linhas
4. Comando de execução
