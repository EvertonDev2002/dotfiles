# Instruções - Projeto Java/Spring Boot

Este arquivo foi dividido em um template mais conciso para LLMs:

- `java-core.md` — records para DTOs, constructor injection, ProblemDetails e exemplos de testes (JUnit 5).

Gere instruções com:

```bash
./scripts/tools/generate.sh java-core
```

O `java-core.md` contém exemplos mínimos, restrições e a saída esperada para respostas do LLM.

### Configuração do Ambiente

```bash
# Instalar Java com mise
mise use java@21

# Criar projeto Spring Boot (usando Spring Initializr)
curl https://start.spring.io/starter.zip \
  -d dependencies=web,data-jpa,validation,h2,lombok,devtools \
  -d type=maven-project \
  -d language=java \
  -d bootVersion=3.2.0 \
  -d baseDir=my-app \
  -d groupId=com.example \
  -d artifactId=my-app \
  -o my-app.zip && unzip my-app.zip

# Ou usar Gradle
mise use java@21
gradle init --type java-application
```

## Estrutura de Projeto

### Clean Architecture (Hexagonal)

```
src/
├── main/
│   ├── java/
│   │   └── com/example/app/
│   │       ├── domain/              # Camada de domínio (regras de negócio)
│   │       │   ├── model/           # Entidades de domínio
│   │       │   ├── repository/      # Interfaces de repositório (ports)
│   │       │   ├── service/         # Serviços de domínio
│   │       │   └── exception/       # Exceções de negócio
│   │       ├── application/         # Camada de aplicação (casos de uso)
│   │       │   ├── usecase/         # Casos de uso
│   │       │   └── dto/             # DTOs de entrada/saída
│   │       └── infrastructure/      # Camada de infraestrutura (adapters)
│   │           ├── config/          # Configurações Spring
│   │           ├── persistence/     # Implementação JPA
│   │           │   ├── entity/      # Entidades JPA
│   │           │   └── repository/  # Repositórios JPA
│   │           ├── web/             # Controllers REST
│   │           │   ├── controller/
│   │           │   ├── request/     # Request DTOs
│   │           │   ├── response/    # Response DTOs
│   │           │   └── mapper/      # Mapeadores
│   │           └── exception/       # Exception handlers
│   └── resources/
│       ├── application.yml          # Configuração principal
│       ├── application-dev.yml      # Profile dev
│       ├── application-prod.yml     # Profile prod
│       └── db/migration/            # Flyway migrations
└── test/
    ├── java/
    │   └── com/example/app/
    │       ├── domain/              # Testes de domínio
    │       ├── application/         # Testes de casos de uso
    │       └── infrastructure/      # Testes de integração
    └── resources/
        └── application-test.yml     # Configuração de testes
```

### Estrutura Tradicional (MVC)

```
src/
├── main/
│   ├── java/
│   │   └── com/example/app/
│   │       ├── model/               # Entidades JPA
│   │       ├── repository/          # Repositórios Spring Data
│   │       ├── service/             # Serviços de negócio
│   │       ├── controller/          # Controllers REST
│   │       ├── dto/                 # DTOs
│   │       ├── mapper/              # Mapeadores (MapStruct)
│   │       ├── config/              # Configurações
│   │       └── exception/           # Exceções e handlers
│   └── resources/
└── test/
```

## Configuração Maven (pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>my-app</artifactId>
    <version>0.1.0</version>
    <name>My Application</name>

    <properties>
        <java.version>21</java.version>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Database -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>test</scope>
        </dependency>

        <!-- Utilities -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

## Boas Práticas Java/Spring Boot

### Entidade de Domínio (Domain Model)

```java
package com.example.app.domain.model;

import java.time.LocalDateTime;
import java.util.UUID;

public class User {
    private final UUID id;
    private String name;
    private String email;
    private final LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructor for new users
    public User(String name, String email) {
        this.id = UUID.randomUUID();
        this.name = name;
        this.email = email;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor for existing users (from repository)
    public User(UUID id, String name, String email,
                LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public void updateName(String name) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Name cannot be empty");
        }
        this.name = name;
        this.updatedAt = LocalDateTime.now();
    }

    public void updateEmail(String email) {
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            throw new IllegalArgumentException("Invalid email");
        }
        this.email = email;
        this.updatedAt = LocalDateTime.now();
    }

    // Getters
    public UUID getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
```

### Repository Interface (Port)

```java
package com.example.app.domain.repository;

import com.example.app.domain.model.User;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository {
    User save(User user);
    Optional<User> findById(UUID id);
    Optional<User> findByEmail(String email);
    List<User> findAll();
    void deleteById(UUID id);
    boolean existsByEmail(String email);
}
```

### Service (Use Case)

```java
package com.example.app.application.usecase;

import com.example.app.domain.model.User;
import com.example.app.domain.repository.UserRepository;
import com.example.app.application.dto.CreateUserRequest;
import com.example.app.application.dto.UserResponse;
import com.example.app.domain.exception.UserAlreadyExistsException;
import com.example.app.domain.exception.UserNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new UserAlreadyExistsException(request.email());
        }

        var user = new User(request.name(), request.email());
        var savedUser = userRepository.save(user);

        return UserResponse.fromDomain(savedUser);
    }

    @Transactional(readOnly = true)
    public UserResponse getUserById(UUID id) {
        return userRepository.findById(id)
            .map(UserResponse::fromDomain)
            .orElseThrow(() -> new UserNotFoundException(id));
    }

    @Transactional
    public UserResponse updateUser(UUID id, CreateUserRequest request) {
        var user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));

        user.updateName(request.name());
        user.updateEmail(request.email());

        var updatedUser = userRepository.save(user);
        return UserResponse.fromDomain(updatedUser);
    }

    @Transactional
    public void deleteUser(UUID id) {
        if (!userRepository.findById(id).isPresent()) {
            throw new UserNotFoundException(id);
        }
        userRepository.deleteById(id);
    }
}
```

### DTOs com Records

```java
package com.example.app.application.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record CreateUserRequest(
    @NotBlank(message = "Name is required")
    String name,

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    String email
) {}
```

```java
package com.example.app.application.dto;

import com.example.app.domain.model.User;
import java.time.LocalDateTime;
import java.util.UUID;

public record UserResponse(
    UUID id,
    String name,
    String email,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
    public static UserResponse fromDomain(User user) {
        return new UserResponse(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.getCreatedAt(),
            user.getUpdatedAt()
        );
    }
}
```

### REST Controller

```java
package com.example.app.infrastructure.web.controller;

import com.example.app.application.dto.CreateUserRequest;
import com.example.app.application.dto.UserResponse;
import com.example.app.application.usecase.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<UserResponse> createUser(
            @Valid @RequestBody CreateUserRequest request) {
        var user = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable UUID id) {
        var user = userService.getUserById(id);
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable UUID id,
            @Valid @RequestBody CreateUserRequest request) {
        var user = userService.updateUser(id, request);
        return ResponseEntity.ok(user);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable UUID id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }
}
```

### JPA Entity (Adapter)

```java
package com.example.app.infrastructure.persistence.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, unique = true, length = 255)
    private String email;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
}
```

### JPA Repository Implementation

```java
package com.example.app.infrastructure.persistence.repository;

import com.example.app.infrastructure.persistence.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface JpaUserRepository extends JpaRepository<UserEntity, UUID> {
    Optional<UserEntity> findByEmail(String email);
    boolean existsByEmail(String email);
}
```

### Repository Adapter

```java
package com.example.app.infrastructure.persistence.repository;

import com.example.app.domain.model.User;
import com.example.app.domain.repository.UserRepository;
import com.example.app.infrastructure.persistence.entity.UserEntity;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Component
public class UserRepositoryAdapter implements UserRepository {
    private final JpaUserRepository jpaRepository;

    public UserRepositoryAdapter(JpaUserRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    @Override
    public User save(User user) {
        var entity = toEntity(user);
        var savedEntity = jpaRepository.save(entity);
        return toDomain(savedEntity);
    }

    @Override
    public Optional<User> findById(UUID id) {
        return jpaRepository.findById(id).map(this::toDomain);
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return jpaRepository.findByEmail(email).map(this::toDomain);
    }

    @Override
    public List<User> findAll() {
        return jpaRepository.findAll().stream()
            .map(this::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public void deleteById(UUID id) {
        jpaRepository.deleteById(id);
    }

    @Override
    public boolean existsByEmail(String email) {
        return jpaRepository.existsByEmail(email);
    }

    private UserEntity toEntity(User user) {
        return new UserEntity(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.getCreatedAt(),
            user.getUpdatedAt()
        );
    }

    private User toDomain(UserEntity entity) {
        return new User(
            entity.getId(),
            entity.getName(),
            entity.getEmail(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
}
```

### Exception Handling

```java
package com.example.app.infrastructure.exception;

import com.example.app.domain.exception.UserAlreadyExistsException;
import com.example.app.domain.exception.UserNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(UserNotFoundException ex) {
        var error = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            ex.getMessage(),
            LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(UserAlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handleUserAlreadyExists(UserAlreadyExistsException ex) {
        var error = new ErrorResponse(
            HttpStatus.CONFLICT.value(),
            ex.getMessage(),
            LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationErrors(
            MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        return ResponseEntity.badRequest().body(errors);
    }

    record ErrorResponse(int status, String message, LocalDateTime timestamp) {}
}
```

## Testing

### Unit Test (Service)

```java
package com.example.app.application.usecase;

import com.example.app.domain.model.User;
import com.example.app.domain.repository.UserRepository;
import com.example.app.application.dto.CreateUserRequest;
import com.example.app.domain.exception.UserAlreadyExistsException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void shouldCreateUserSuccessfully() {
        // Given
        var request = new CreateUserRequest("John Doe", "john@example.com");
        var user = new User(request.name(), request.email());

        when(userRepository.existsByEmail(request.email())).thenReturn(false);
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        var result = userService.createUser(request);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.name()).isEqualTo(request.name());
        assertThat(result.email()).isEqualTo(request.email());

        verify(userRepository).existsByEmail(request.email());
        verify(userRepository).save(any(User.class));
    }

    @Test
    void shouldThrowExceptionWhenEmailAlreadyExists() {
        // Given
        var request = new CreateUserRequest("John Doe", "john@example.com");
        when(userRepository.existsByEmail(request.email())).thenReturn(true);

        // When / Then
        assertThatThrownBy(() -> userService.createUser(request))
            .isInstanceOf(UserAlreadyExistsException.class)
            .hasMessageContaining(request.email());

        verify(userRepository).existsByEmail(request.email());
        verify(userRepository, never()).save(any(User.class));
    }
}
```

### Integration Test

```java
package com.example.app.infrastructure.web.controller;

import com.example.app.application.dto.CreateUserRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class UserControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void shouldCreateUserSuccessfully() throws Exception {
        var request = new CreateUserRequest("John Doe", "john@test.com");

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value(request.name()))
            .andExpect(jsonPath("$.email").value(request.email()))
            .andExpect(jsonPath("$.id").exists());
    }

    @Test
    void shouldReturnBadRequestWhenInvalidEmail() throws Exception {
        var request = new CreateUserRequest("John Doe", "invalid-email");

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.email").exists());
    }
}
```

## Configuração (application.yml)

```yaml
spring:
  application:
    name: my-app

  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: ${DB_USERNAME:postgres}
    password: ${DB_PASSWORD:postgres}
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        format_sql: true
        dialect: org.hibernate.dialect.PostgreSQLDialect

  flyway:
    enabled: true
    locations: classpath:db/migration

server:
  port: 8080
  error:
    include-message: always
    include-binding-errors: always

logging:
  level:
    root: INFO
    com.example.app: DEBUG
```

## Referências Java/Spring

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Spring Framework Documentation](https://docs.spring.io/spring-framework/reference/)
- [Spring Data JPA](https://docs.spring.io/spring-data/jpa/docs/current/reference/html/)
- [Java SE Documentation](https://docs.oracle.com/en/java/javase/21/)
- [JUnit 5 Documentation](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Effective Java (Joshua Bloch)](https://www.oreilly.com/library/view/effective-java/9780134686097/)
