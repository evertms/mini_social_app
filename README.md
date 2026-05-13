# Mini Social App - Arquitectura Limpia (Clean Architecture)

## Visión General

Aplicación Flutter para listar, crear y marcar posts como favoritos.  
Stack tecnológico: Clean Architecture + State Management (BLoC) + Drift DB + Dio API

---

## Contrato Base (Domain Layer)

### Entity: Post
**Ubicación**: `lib/features/post/domain/entities/post.dart`

Campos requeridos:
- `int id` - Identificador único
- `String title` - Título del post
- `String body` - Cuerpo del post
- `int userId` - ID del usuario que creó el post
- `DateTime timestamp` - Fecha/hora de creación
- `bool isFavorite` - Indica si está marcado como favorito (default: false)

Métodos: Constructor con parámetros nombrados requeridos.

### Repository Interface: PostRepository
**Ubicación**: `lib/features/post/domain/repositories/post_repository.dart`

Métodos abstractos:
- `Future<List<Post>> getPosts()` - Obtiene posts (API + DB)
- `Future<Post> createPost(Post post)` - Crea un post en API
- `Future<List<Post>> getFavorites()` - Obtiene posts favoritos
- `Future<void> toggleFavorite(Post post)` - Alterna estado de favorito

Reglas importantes:
- getPosts() y getFavorites() retornan lista ordenada por timestamp DESC (más recientes primero)
- Todos los posts en la respuesta deben tener isFavorite actualizado según estado local
- createPost() retorna el Post creado (con id asignado por API)

---

## API Integration Guide (Para Henrry - Data Layer)

### Origen de datos: JSONPlaceholder
- Base URL: https://jsonplaceholder.typicode.com
- GET /posts - Retorna ~100 posts
- POST /posts - Acepta {title, body, userId}, retorna el post creado (sin persistencia real en servidor)

### Respuesta JSON de API
La API retorna objetos con: id, title, body, userId

Importante: NO incluye timestamp ni isFavorite. Henrry debe agregarlos durante la transformación.

---

## Estructura de Data Layer (Responsabilidad de Henrry)

### 1. Model (DTO) - PostModel
**Ubicación**: `lib/features/post/data/models/post_model.dart`

**Propósito**: Transformar JSON de API a objetos internos de la app.

**Campos**: Iguales a Post entity (id, title, body, userId, timestamp, isFavorite)

**Métodos requeridos**:
- `factory PostModel.fromJson(Map<String, dynamic> json)` - Convierte JSON API a PostModel. IMPORTANTE: Aquí se asigna timestamp con DateTime.now() e isFavorite = false
- `Map<String, dynamic> toJson()` - Convierte PostModel a JSON para enviar a API (solo los campos que API acepta: id, title, body, userId)
- `PostModel copyWith({...})` - Copia objeto con campos opcionales modificados (útil para actualizar isFavorite)
- `Post toEntity()` - Convierte PostModel a Post entity

**Patrón de diseño**: DTO (Data Transfer Object) + Factory Pattern

### 2. Remote DataSource - PostRemoteDataSource
**Ubicación**: `lib/features/post/data/datasources/post_remote_datasource.dart`

**Interfaz abstracta** con métodos:
- `Future<List<PostModel>> fetchPosts()` - GET /posts, retorna lista de PostModel
- `Future<PostModel> createPost(PostModel post)` - POST /posts, retorna el post creado

**Implementación concreta**:
- Inyectar Dio cliente como dependencia
- Usar GET y POST de Dio
- Capturar excepciones y lanzarlas como errores informados

**Mockeo**: Para testing, crear mock que retorna lista hardcodeada o fixture de JSON

### 3. Local DataSource - PostLocalDataSource
**Ubicación**: `lib/features/post/data/datasources/post_local_datasource.dart`

**Interfaz abstracta** con métodos:
- `Future<List<PostModel>> getAllPosts()` - Retorna todos los posts de DB local (ordenados por timestamp DESC)
- `Future<void> insertPost(PostModel post)` - Inserta o reemplaza un post en BD
- `Future<void> updateFavorite(int postId, bool isFavorite)` - Actualiza solo el campo isFavorite de un post

**Implementación**: Usa Drift como ORM. Necesita tabla Posts con campos:
- id (PRIMARY KEY)
- title
- body
- userId
- timestamp
- isFavorite

**Mockeo**: Crear mock con lista en memoria que simule operaciones CRUD

### 4. Drift Configuration - AppDatabase
**Ubicación**: `lib/shared/database/app_database.dart`

**Configuración**:
- Crear clase AppDatabase que extienda de GeneratedDatabase
- Definir tabla Posts (ver especificación en PostLocalDataSource)
- Generar DAOs automáticos con Drift
- Ejecutar `flutter pub run build_runner build` para generar código

### 5. Repository Implementation - PostRepositoryImpl
**Ubicación**: `lib/features/post/data/repositories/post_repository_impl.dart`

**Implementa PostRepository** con inyección de dependencias:
- PostRemoteDataSource
- PostLocalDataSource

**Métodos**:
- **getPosts()**: Estrategia Network-First + Fallback:
  1. Intenta obtener de API remota
  2. Guarda resultado en DB local
  3. Retorna como Post entities
  4. Si falla (sin conexión): retorna de DB local
  
- **createPost()**: Crea en API y guarda en DB, retorna Post entity

- **getFavorites()**: Obtiene todos de DB local, filtra por isFavorite=true, ordena DESC por timestamp

- **toggleFavorite()**: Actualiza isFavorite en DB local llamando a PostLocalDataSource

**Patrones**: Repository Pattern + Dependency Injection

### 6. Dio Client - DioClient
**Ubicación**: `lib/core/network/dio_client.dart`

**Patrón**: Singleton

**Responsabilidad**: Centralizar configuración de Dio y ser reutilizado en toda la app

**Propiedades**:
- Base URL: https://jsonplaceholder.typicode.com
- Timeout configurado
- Interceptores para manejo de errores (opcional pero recomendado)

---

## Ramas por Equipo

### Rafael: feat/integrate-posts-list
**Objetivo**: Listar posts con estados básicos y navegación lista.

| Tarea | Descripción                                                                                          |
|-------|------------------------------------------------------------------------------------------------------|
| 1.1   | Crear `PostListBloc` (BLoC) con `fetchPosts()`, estados `isLoading`, `posts`, `error` |
| 1.2   | Armar `PostListPage` + `PostCard` básico (título, cuerpo, botón ❤ placeholder)                      |
| 1.3   | Conectar BLoC a `PostRepository` interface (usar mock si data layer no está listo)                   |
| 1.4   | Agregar `RefreshIndicator` y mostrar `Text` simple si hay error o lista vacía                        |

**Recomendaciones**:
- Crear mock de PostRepository que retorna lista hardcodeada de Posts si Henrry aún no termina
- El PostCard debe ser stateless (Evert lo enriquecerá)
- Mostrar campos: título, body (truncado), userId, timestamp con formato legible
- Orden: posts más recientes primero (ya maneja Repository)
- El BLoC debe emitir estados (loading, loaded, error) que la UI observa

---

### Jonathan: feat/create-post-module
**Objetivo**: Formulario para crear posts.

| Tarea | Descripción                                                                                                |
|-------|-----------------------------------------------------------------------------------------------------------|
| 2.1   | Crear `CreatePostPage` con 2 `TextFormField` (título, cuerpo) + validación básica (`required`)             |
| 2.2   | Crear `CreatePostUseCase` (interfaz abstracta con método execute(Post post) que llama a repo.createPost())  |
| 2.3   | Implementar `CreatePostBloc`: llama al UseCase, emite estados (loading, success, error) + dispara evento de éxito |
| 2.4   | Asegurar que al volver a la lista, esta se refresca automáticamente                                        |

**Recomendaciones**:
- El userId puede ser hardcodeado (ej: 1)
- El timestamp se genera en data layer
- Validar que title y body no estén vacíos (required)
- Mock del UseCase: crear versión que simula creación sin llamar a API
- Al crear Post, no asignar id (la API lo genera)
- BLoC debe emitir estado de éxito; desde la UI escuchar ese estado para pop y refrescar lista

---

### Evert: feat/favorites-management
**Objetivo**: Favoritos con SharedPreferences + cambio de tema.

| Tarea | Descripción                                                                                                              |
|-------|--------------------------------------------------------------------------------------------------------------------------|
| 3.1   | Crear `PrefsService` (wrapper de `SharedPreferences`) con métodos: `getFavIds()`, `toggleFavId(int)`, `getTheme()`, `setTheme(bool)` |
| 3.2   | Crear `FavoritesPage` que lee IDs de prefs, pide posts al repo, filtra y ordena LIFO (DESC por timestamp)              |
| 3.3   | Agregar `IconButton` (❤) en `PostCard` que dispara evento a `FavoritesBloc` y notifica cambios                         |
| 3.4   | Implementar toggle de tema (light/dark) usando `PrefsService` + `ThemeMode` en `MaterialApp`                             |

**Recomendaciones**:
- PrefsService: almacenar solo IDs en SharedPreferences, nunca Posts completos
- El estado isFavorite se sincroniza entre PostCard y Repository
- FavoritesBloc debe escuchar cambios y emitir nuevos estados cuando se alterne favorito
- Orden en FavoritesPage: DESC por timestamp (más recientes primero)
- Tema: guardar como boolean (true=dark, false=light) o usar enum
- Mock de PrefsService: usar Map<String, dynamic> en memoria para testing

---

### Henrry: feat/data-layer-implementation
**Objetivo**: API + DB local + Repository funcional.

| Tarea | Descripción                                                                                                                               |
|-------|-------------------------------------------------------------------------------------------------------------------------------------------|
| 4.1   | Configurar `DioClient` singleton con baseUrl: https://jsonplaceholder.typicode.com                                                      |
| 4.2   | Crear `PostRemoteDataSource` + `PostModel` con factory fromJson (especificaciones en "API Integration Guide")                             |
| 4.3   | Configurar Drift: tabla `Posts` con campos: id (PK), title, body, userId, timestamp, isFavorite                                          |
| 4.4   | Crear `PostLocalDataSource` con métodos CRUD (insert, getAll, updateFavorite)                                                            |
| 4.5   | Implementar `PostRepositoryImpl` con estrategia Network-First + Fallback: API → DB → retorna; si falla → retorna de DB               |

**Patrones de diseño obligatorios**:
- Factory Pattern (PostModel.fromJson())
- DTO Pattern (PostModel ≠ Post entity)
- Repository Pattern (abstracción de datasources)
- Singleton Pattern (DioClient)

**Recomendaciones**:
- El timestamp se asigna en PostModel.fromJson() con DateTime.now()
- isFavorite siempre inicia como false (Evert maneja los cambios)
- Network-First: intenta API primero, captura excepciones y retorna DB
- Todos los posts obtenidos de API se guardan en DB cada vez (para offline)
- Mock RemoteDataSource: fixture JSON hardcodeada
- Mock LocalDataSource: lista en memoria con operaciones CRUD simuladas
- Testing: crear tests unitarios para Repository con mocks de ambos datasources

---

## Estructura de Directorios

```
lib/
├── core/
│   ├── network/
│   │   └── dio_client.dart              (Henrry)
│   ├── utils/
│   └── theme/
│       ├── app_theme.dart
│       └── colors.dart
├── features/
│   └── post/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── post_remote_datasource.dart    (Henrry)
│       │   │   └── post_local_datasource.dart     (Henrry)
│       │   ├── models/
│       │   │   └── post_model.dart                (Henrry)
│       │   └── repositories/
│       │       └── post_repository_impl.dart      (Henrry)
│       ├── domain/
│       │   ├── entities/
│       │   │   └── post.dart                      (Contrato base)
│       │   ├── repositories/
│       │   │   └── post_repository.dart           (Contrato base)
│       │   └── usecases/
│       │       ├── get_posts_usecase.dart         (Rafael/Jonathan/Evert)
│       │       └── create_post_usecase.dart       (Jonathan)
│       └── presentation/
│           ├── pages/
│           │   ├── post_list_page.dart            (Rafael)
│           │   ├── create_post_page.dart          (Jonathan)
│           │   └── favorites_page.dart            (Evert)
│           ├── widgets/
│           │   └── post_card.dart                 (Rafael + Evert)
│           └── blocs/
│               ├── post_list_bloc.dart            (Rafael)
│               ├── create_post_bloc.dart          (Jonathan)
│               ├── post_list_event.dart           (Rafael)
│               ├── post_list_state.dart           (Rafael)
│               ├── create_post_event.dart         (Jonathan)
│               ├── create_post_state.dart         (Jonathan)
│               ├── favorites_bloc.dart            (Evert)
│               ├── favorites_event.dart           (Evert)
│               └── favorites_state.dart           (Evert)
├── shared/
│   ├── preferences/
│   │   └── prefs_service.dart                     (Evert)
│   └── database/
│       └── app_database.dart                      (Henrry)
├── app.dart                                       (GoRouter setup)
└── main.dart
```

---

## Setup Inicial

**Paso 1: Clonar y setup**
```bash
git clone github.com/evertms/mini_social_app.git
cd mini_social_app
flutter pub get
```

**Paso 2: Generar archivos compilados (Drift)**
```bash
flutter pub run build_runner build
```

**Paso 3: Crear rama de features**
```bash
git switch develop
git pull origin develop
git switch -c feat/mi-feature
```

---

## Convenciones de Git

**Ramas**:
- `main`: Producción (tags de release)
- `develop`: Integración de todas las features
- `feat/nombre-feature`: Rama de desarrollo (de develop)

**Commits**:
Formato: <type>(<scope>): <subject>

Ejemplos válidos:
- `git commit -m "feat(post-list): add refresh indicator"`
- `git commit -m "feat(post-model): implement factory fromJson"`
- `git commit -m "refactor(post-datasource): separate remote and local"`
- `git commit -m "fix(theme-toggle): persist theme correctly"`

Tipos: feat, fix, refactor, test, docs, style, chore

**Pull Requests**:
1. Crear PR de feat/... → develop
2. Descripción incluye:
   - Qué se hizo (resumen)
   - Tarea(s) completada(s) (1.1, 2.3, etc.)
   - Checks manuales
3. Revisar + mergear a develop

---

## Checklist de Entrega

**Funcionalidades**:
- [ ] Consumo API REST (GET /posts, POST /posts)
- [ ] Base de datos local (Drift) operacional
- [ ] State Management (BLoC)
- [ ] SharedPreferences para favoritos + tema
- [ ] Clean Architecture implementada (data/domain/presentation)
- [ ] Posts listados con orden DESC (más recientes primero)
- [ ] Crear Post → refresca lista automáticamente
- [ ] Favoritos persistentes y ordenados DESC
- [ ] Cambio de tema guardado

**Código**:
- [ ] Patrones implementados: Factory, DTO, Repository, Singleton
- [ ] Manejo de errores (try-catch + graceful fallback)
- [ ] Sin warnings en flutter analyze
- [ ] Commits atómicos y descriptivos

**Testing (Bonus)**:
- [ ] Pruebas unitarias para ViewModels
- [ ] Pruebas para Repository (mock datasources)

---

## Claves Importantes

**Para Henrry (Data Layer)**:
- PostModel es distinto a Post entity: Model es DTO + serialización; Entity es objeto puro de negocio
- Factory.fromJson transforma JSON API → PostModel: agrega timestamp con DateTime.now() y isFavorite = false
- Network-First + Fallback: primero intenta API, guarda en Drift, si API falla → retorna data local (graceful)
- DioClient: singleton reutilizado en toda la app; opcional agregar interceptores para errores centralizados

**Para Rafael (Post List)**:
- El BLoC obtiene posts del Repository; crear MockRepository para testing antes que Henrry termine
- PostCard es stateless; será enriquecido por Evert con botón de favorito funcional
- Mostrar posts ordenados DESC por timestamp (el Repository ya lo garantiza)
- El BLoC maneja estados de carga, éxito y error que la UI consume

**Para Jonathan (Create Post)**:
- CreatePostUseCase es interfaz que llama a repository.createPost()
- CreatePostBloc emite estados que permiten controlar navegación (éxito → pop, error → mostrar snack)
- Validación básica: campos required
- Mock del UseCase: simular creación exitosa sin llamar a API

**Para Evert (Favorites)**:
- PrefsService: wrapper de SharedPreferences; almacena solo IDs, nunca Posts completos
- FavoritesBloc maneja toggleFavorite() (llama a repository) + emite nuevos estados
- Orden DESC por timestamp en FavoritesPage
- Tema: light/dark, guardado en prefs; sincronizar con MaterialApp.themeMode

---

## Probando Localmente

```bash
# Lint
flutter analyze

# Tests (cuando existan)
flutter test

# Run en dispositivo
flutter run
```

---

## Referencias

- JSONPlaceholder API: https://jsonplaceholder.typicode.com
- Drift Docs: https://drift.simonbinder.eu
- Clean Architecture: https://resocoder.com/clean-architecture-flutter
- Flutter ChangeNotifier: https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple
