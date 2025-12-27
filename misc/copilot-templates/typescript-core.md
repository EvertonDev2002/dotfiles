# TypeScript Core — Instruções para o LLM

Contexto: typing, validation, error handling em TypeScript puro.

## Objetivo do assistant

- Gerar código type-safe com Zod validation e error handling robusto.
- Usar recursos modernos (satisfies, as const, type narrowing).

## Estrutura esperada

### Validation com Zod

```typescript
// config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z
    .enum(['development', 'production', 'test'])
    .default('development'),
  PORT: z.string().transform(Number).pipe(z.number().min(1).max(65535)),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z
    .string()
    .regex(/^\d+[smhd]$/)
    .default('1d'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

export const env = envSchema.parse(process.env);

export type Env = z.infer<typeof envSchema>;
```

### Custom Error Classes

```typescript
// errors/AppError.ts
export class AppError extends Error {
  constructor(
    public readonly statusCode: number,
    message: string,
    public readonly isOperational = true,
    public readonly context?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, context?: Record<string, unknown>) {
    super(400, message, true, context);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string | number) {
    super(404, `${resource} with id ${id} not found`, true, { resource, id });
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(401, message, true);
  }
}
```

### Type narrowing com satisfies

```typescript
// types/user.ts
export type UserRole = 'admin' | 'user' | 'guest';

export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  metadata: Record<string, unknown>;
}

// Using satisfies for type checking while preserving literal types
export const DEFAULT_PERMISSIONS = {
  admin: ['read', 'write', 'delete'],
  user: ['read', 'write'],
  guest: ['read'],
} as const satisfies Record<UserRole, readonly string[]>;

// Type is inferred as:
// { readonly admin: readonly ['read', 'write', 'delete'], ... }
```

### Result type pattern

```typescript
// types/result.ts
export type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

export function success<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

export function failure<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

// Usage example
import type { User } from './user';

async function fetchUser(id: string): Promise<Result<User>> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      return failure(new NotFoundError('User', id));
    }
    const user = await response.json();
    return success(user);
  } catch (error) {
    return failure(error as Error);
  }
}

// Consuming
const result = await fetchUser('123');
if (result.ok) {
  console.log(result.value.name); // Type-safe access
} else {
  console.error(result.error.message);
}
```

### Type guards

```typescript
// utils/guards.ts
export function isString(value: unknown): value is string {
  return typeof value === 'string';
}

export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

export function hasProperty<K extends string>(
  obj: unknown,
  key: K
): obj is Record<K, unknown> {
  return isRecord(obj) && key in obj;
}

// Usage
function processData(data: unknown) {
  if (!isRecord(data)) {
    throw new ValidationError('Data must be an object');
  }

  if (!hasProperty(data, 'id') || !isString(data.id)) {
    throw new ValidationError('Data must have a string id');
  }

  // Now data.id is type-safe (string)
  console.log(data.id.toUpperCase());
}
```

### tsconfig.json (strict)

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022"],
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "noEmit": true,

    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noImplicitOverride": true,

    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

## Restrições

- **Strict mode**: sempre habilitado
- **any**: proibido, use `unknown` e narrowing
- **Type assertions**: evite, prefira type guards
- **Enums**: prefira union types ou `as const`
- **noUncheckedIndexedAccess**: sempre habilitado
- **Indentação**: 2 espaços

## Comandos

```bash
# Type check
pnpm exec tsc --noEmit

# Run with type checking
pnpm exec tsx src/main.ts
```

## Saída esperada

1. Zod schemas para validation
2. Custom error classes estendendo Error
3. Type guards para runtime checks
4. satisfies para preservar literal types
5. tsconfig.json strict configurado
