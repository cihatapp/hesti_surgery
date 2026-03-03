# Flutter Clean Architecture Boilerplate

Production-ready Flutter boilerplate with Clean Architecture, BLoC state management, and best practices.

---

## 📑 Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the App](#running-the-app)
- [Architecture](#architecture)
  - [What is Clean Architecture?](#what-is-clean-architecture)
  - [Layer Diagram](#layer-diagram)
  - [Data Flow](#data-flow)
  - [Why This Architecture?](#why-this-architecture)
- [Project Structure](#project-structure)
  - [Root Level Files](#root-level-files)
  - [Core Module](#core-module)
  - [Features Module](#features-module)
- [Core Modules Explained](#core-modules-explained)
  - [Error Handling](#1-error-handling)
  - [Network Layer (Dio)](#2-network-layer-dio)
  - [Cache Layer (SharedPreferences)](#3-cache-layer-sharedpreferences)
  - [Theme System](#4-theme-system)
  - [Localization (Multi-language)](#5-localization-multi-language)
  - [Navigation](#6-navigation)
  - [Widgets](#7-reusable-widgets)
  - [Offline-First Architecture](#8-offline-first-architecture)
- [Features](#features)
  - [Auth Feature (Example)](#auth-feature-example)
  - [Other Features](#other-features)
- [How to Add a New Feature](#how-to-add-a-new-feature)
  - [Step 1: Create Folder Structure](#step-1-create-folder-structure)
  - [Step 2: Create Domain Layer](#step-2-create-domain-layer)
  - [Step 3: Create Data Layer](#step-3-create-data-layer)
  - [Step 4: Create Presentation Layer](#step-4-create-presentation-layer)
  - [Step 5: Register Dependencies](#step-5-register-dependencies)
  - [Step 6: Add Route](#step-6-add-route)
- [State Management (BLoC)](#state-management-bloc)
  - [Events](#events)
  - [States](#states)
  - [BLoC Class](#bloc-class)
  - [Using in UI](#using-in-ui)
- [Dependency Injection (GetIt)](#dependency-injection-getit)
  - [Registration Types](#registration-types)
  - [How to Use](#how-to-use)
- [Testing](#testing)
  - [Test Structure](#test-structure)
  - [Writing Tests](#writing-tests)
  - [Running Tests](#running-tests)
- [Commands Reference](#commands-reference)
- [Customization Guide](#customization-guide)
  - [Change App Name](#change-app-name)
  - [Change API URL](#change-api-url)
  - [Change Colors](#change-colors)
  - [Add New Translation](#add-new-translation)
- [FAQ](#faq)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## Overview

| Component | Technology | Purpose |
|-----------|------------|---------|
| Architecture | Clean Architecture | Separation of concerns |
| State Management | BLoC / Cubit | Predictable state changes |
| Dependency Injection | GetIt | Service locator pattern |
| Routing | Auto Route | Type-safe navigation |
| HTTP Client | Dio | API requests with interceptors |
| Local Storage | SharedPreferences | Key-value cache |
| **Offline Database** | **Hive CE** | **Offline-first data persistence** |
| **Connectivity** | **Connectivity Plus** | **Network status monitoring** |
| Localization | Easy Localization | Multi-language support |
| Code Generation | Freezed, JSON Serializable | Immutable models |

---

## Getting Started

### Prerequisites

Make sure you have these installed:

| Tool | Version | Check Command |
|------|---------|---------------|
| Flutter | 3.10+ | `flutter --version` |
| Dart | 3.0+ | `dart --version` |
| IDE | VS Code or Android Studio | - |

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/flutter_app_boilerplate.git

# 2. Navigate to project
cd flutter_app_boilerplate

# 3. Install dependencies
flutter pub get

# 4. Generate code (Freezed, Auto Route, etc.)
dart run build_runner build --delete-conflicting-outputs
```

### Running the App

```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device_id>
```

---

## Architecture

### What is Clean Architecture?

Clean Architecture separates your code into **3 layers**, each with a specific responsibility:

| Layer | Responsibility | Contains |
|-------|---------------|----------|
| **Presentation** | UI & State Management | Pages, Widgets, BLoCs |
| **Domain** | Business Logic | Entities, UseCases, Repository Interfaces |
| **Data** | Data Operations | Models, DataSources, Repository Implementations |

### Layer Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION                              │
│                      (UI & State)                                │
│                                                                  │
│   ┌──────────┐      ┌──────────┐      ┌──────────┐              │
│   │  Pages   │      │   BLoC   │      │ Widgets  │              │
│   │  (UI)    │ ───▶ │ (State)  │      │  (UI)    │              │
│   └──────────┘      └────┬─────┘      └──────────┘              │
│                          │                                       │
├──────────────────────────┼───────────────────────────────────────┤
│                     DOMAIN                                       │
│               (Business Logic)                                   │
│                          │                                       │
│                          ▼                                       │
│   ┌──────────┐      ┌──────────┐      ┌──────────┐              │
│   │ Entities │      │ UseCases │      │  Repos   │ (interface)  │
│   │ (Models) │      │ (Logic)  │      │ (Contract)│              │
│   └──────────┘      └────┬─────┘      └────┬─────┘              │
│                          │                 │                     │
├──────────────────────────┼─────────────────┼─────────────────────┤
│                       DATA                 │                     │
│                 (Data Access)              │                     │
│                          │                 │                     │
│                          ▼                 ▼                     │
│   ┌──────────┐      ┌──────────┐      ┌──────────┐              │
│   │  Models  │      │  Repos   │      │DataSources│             │
│   │(Freezed) │      │  (impl)  │      │ (API/DB) │              │
│   └──────────┘      └──────────┘      └──────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

When user taps "Login" button:

```
1. User taps Login
        │
        ▼
┌───────────────┐
│  LoginPage    │  ──▶  Sends LoginRequested event
└───────┬───────┘
        │
        ▼
┌───────────────┐
│   AuthBloc    │  ──▶  Calls LoginUser usecase
└───────┬───────┘
        │
        ▼
┌───────────────┐
│  LoginUser    │  ──▶  Calls AuthRepository.login()
│  (UseCase)    │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│AuthRepository │  ──▶  Calls RemoteDataSource
│    (impl)     │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│RemoteDataSrc  │  ──▶  Makes API call via Dio
└───────┬───────┘
        │
        ▼
     Response flows back up the chain
```

### Why This Architecture?

| Benefit | Explanation |
|---------|-------------|
| **Testable** | Each layer can be tested independently |
| **Maintainable** | Changes in one layer don't affect others |
| **Scalable** | Easy to add new features |
| **Readable** | Clear separation makes code easy to understand |

---

## Project Structure

### Root Level Files

```
lib/
├── main.dart              # App entry point with error handling
├── app.dart               # Root widget with providers
└── injection_container.dart   # Dependency injection setup
```

### Core Module

Shared code used across all features:

```
lib/core/
│
├── cache/                    # Local storage
│   ├── cache_keys.dart       # Enum of all cache keys
│   ├── cache_manager.dart    # SharedPreferences wrapper
│   └── cacheable_base_model.dart
│
├── constants/                # App-wide constants
│   ├── api_constants.dart    # Base URL, endpoints
│   ├── app_assets.dart       # Asset paths
│   ├── app_durations.dart    # Animation durations
│   └── app_spacing.dart      # Spacing values (4, 8, 16...)
│
├── error/                    # Error handling
│   ├── exceptions.dart       # ServerException, CacheException
│   └── failures.dart         # ServerFailure, CacheFailure
│
├── extensions/               # Dart extensions
│   ├── context_extensions.dart
│   ├── datetime_extensions.dart
│   └── string_extensions.dart
│
├── localization/             # Multi-language
│   ├── locale_keys.dart      # Translation keys
│   ├── localization_manager.dart
│   └── supported_locales.dart
│
├── navigation/               # Navigation helpers
│   └── navigation_manager.dart
│
├── network/                  # HTTP client
│   └── dio_client.dart       # Dio singleton with interceptors
│
├── theme/                    # App themes
│   ├── app_theme.dart        # Base theme interface
│   ├── light/                # Light theme files
│   │   ├── light_theme.dart
│   │   ├── color_scheme_light.dart
│   │   └── text_theme_light.dart
│   └── dark/                 # Dark theme files
│       ├── dark_theme.dart
│       ├── color_scheme_dark.dart
│       └── text_theme_dark.dart
│
├── usecases/                 # Base UseCase
│   └── usecase.dart
│
├── database/                 # Local database (Hive)
│   ├── hive_manager.dart     # Hive initialization
│   └── hive_boxes.dart       # Box name constants
│
├── offline/                  # Offline-first infrastructure
│   ├── connectivity_service.dart  # Network monitoring
│   ├── sync_queue.dart       # Pending operations queue
│   ├── sync_operation.dart   # Sync operation model
│   ├── sync_status.dart      # Status enums
│   ├── offline_manager.dart  # Orchestrates offline behavior
│   └── connectivity_cubit.dart # UI state management
│
└── widgets/                  # Reusable widgets
    ├── app_button.dart
    ├── app_text_field.dart
    ├── app_cached_image.dart
    ├── loading_indicator.dart
    ├── error_widget.dart
    └── offline_indicator.dart # Offline status widgets
```

### Features Module

Each feature follows the same structure:

```
lib/features/
│
├── auth/                     # Authentication feature
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   └── presentation/
│       ├── bloc/
│       ├── pages/
│       └── widgets/
│
├── home/                     # Home feature
├── onboarding/               # Onboarding feature
├── settings/                 # Settings feature
├── splash/                   # Splash screen
└── main_navigation/          # Bottom navigation
```

---

## Core Modules Explained

### 1. Error Handling

Two types of errors:

| Type | Used In | Purpose |
|------|---------|---------|
| `Exception` | DataSource | Low-level errors (API errors) |
| `Failure` | BLoC/UI | High-level errors (user-facing) |

**How it works:**

```dart
// 1. DataSource throws Exception
class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password) async {
    final response = await dio.post('/login', data: {...});

    if (response.statusCode != 200) {
      throw ServerException(
        message: 'Login failed',
        statusCode: response.statusCode,
      );
    }

    return UserModel.fromJson(response.data);
  }
}

// 2. Repository catches Exception, returns Failure
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, User>> login(...) async {
    try {
      final user = await remoteDataSource.login(...);
      return Right(user);  // Success
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));  // Failure
    }
  }
}

// 3. BLoC handles Failure
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Future<void> _onLogin(...) async {
    final result = await loginUser(params);

    result.fold(
      (failure) => emit(AuthError(failure.message)),  // Handle failure
      (user) => emit(AuthAuthenticated(user)),        // Handle success
    );
  }
}
```

### 2. Network Layer (Dio)

Singleton HTTP client with automatic token handling:

```dart
// Make GET request
final response = await DioClient.instance.get('/users');

// Make POST request
final response = await DioClient.instance.post(
  '/login',
  data: {'email': email, 'password': password},
);

// Set auth token (after login)
DioClient.instance.setAuthToken('your-jwt-token');

// Clear auth token (after logout)
DioClient.instance.clearAuthToken();
```

**Built-in Interceptors:**

| Interceptor | Function |
|-------------|----------|
| Logging | Logs requests/responses in debug mode |
| Error Handling | Detects 401 errors for auto-logout |

### 3. Cache Layer (SharedPreferences)

Type-safe local storage:

```dart
// Save string
await CacheManager.instance.setString(CacheKeys.accessToken, 'token123');

// Get string
final token = CacheManager.instance.getString(CacheKeys.accessToken);

// Save boolean
await CacheManager.instance.setBool(CacheKeys.onboardingCompleted, value: true);

// Get boolean
final completed = CacheManager.instance.getBool(CacheKeys.onboardingCompleted);

// Save object (must implement CacheableModel)
await CacheManager.instance.setObject(CacheKeys.user, userModel);

// Get object
final user = CacheManager.instance.getObject(
  CacheKeys.user,
  UserModel.fromJson,
);

// Save list
await CacheManager.instance.setList(CacheKeys.favorites, items);

// Clear all
await CacheManager.instance.clear();
```

### 4. Theme System

**Access theme in widgets:**

```dart
// Using Theme.of
final colors = Theme.of(context).colorScheme;
final text = Theme.of(context).textTheme;

// Using extensions (cleaner)
context.colorScheme.primary
context.textTheme.headlineLarge
```

**Toggle theme:**

```dart
// Toggle between light/dark
context.read<ThemeCubit>().toggleTheme();

// Set specific theme
context.read<ThemeCubit>().setTheme(ThemeMode.dark);
context.read<ThemeCubit>().setTheme(ThemeMode.light);
context.read<ThemeCubit>().setTheme(ThemeMode.system);
```

**Customize colors:**

Edit these files:
- Light: `lib/core/theme/light/color_scheme_light.dart`
- Dark: `lib/core/theme/dark/color_scheme_dark.dart`

### 5. Localization (Multi-language)

**Use translations:**

```dart
// Basic
Text(LocaleKeys.authLogin.tr())

// With named arguments
Text(LocaleKeys.homeWelcome.tr(namedArgs: {'name': 'John'}))
// Translation: "welcome": "Welcome, {name}!"
```

**Change language:**

```dart
context.read<LocaleCubit>().setLocale(context, SupportedLocale.turkish);
context.read<LocaleCubit>().setLocale(context, SupportedLocale.english);
```

**Add new language:**

1. Create translation file: `assets/translations/xx.json`
2. Add to `SupportedLocale` enum in `supported_locales.dart`:

```dart
newLanguage(
  locale: Locale('xx'),
  languageCode: 'xx',
  name: 'Language Name',
  nativeName: 'Native Name',
  flag: '🏳️',
),
```

3. Add to `main.dart` supportedLocales list

### 6. Navigation

**Using NavigationManager:**

```dart
// Push new screen
NavigationManager.instance.push(NavigationRoute.home);

// Replace current screen
NavigationManager.instance.replace(NavigationRoute.login);

// Pop current screen
NavigationManager.instance.pop();

// Replace all screens
NavigationManager.instance.replaceAll([NavigationRoute.home]);
```

**Using Auto Route directly:**

```dart
// Push
context.router.push(const HomeRoute());

// Replace
context.router.replace(const LoginRoute());

// Replace all
context.router.replaceAll([const HomeRoute()]);

// Pop
context.router.pop();
```

### 7. Reusable Widgets

| Widget | Purpose | Location |
|--------|---------|----------|
| `AppButton` | Primary/Secondary buttons | `core/widgets/app_button.dart` |
| `AppTextField` | Styled text input | `core/widgets/app_text_field.dart` |
| `AppCachedImage` | Image with caching | `core/widgets/app_cached_image.dart` |
| `LoadingIndicator` | Loading spinner | `core/widgets/loading_indicator.dart` |
| `AppErrorWidget` | Error display | `core/widgets/error_widget.dart` |

### 8. Offline-First Architecture

The app is designed to work seamlessly offline with automatic sync when back online.

#### Offline-First Principles

| Principle | Description |
|-----------|-------------|
| **Local First** | Hive database is the primary data source |
| **Eventual Consistency** | Changes sync to server when online |
| **Queue Operations** | All writes are queued when offline |
| **Graceful Degradation** | App remains fully functional offline |

#### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     OFFLINE-FIRST FLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   User Action                                                    │
│        │                                                         │
│        ▼                                                         │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│   │  Repository │───▶│    Hive     │    │   API       │         │
│   │  (Local 1st)│    │  (Primary)  │    │ (Secondary) │         │
│   └──────┬──────┘    └─────────────┘    └──────▲──────┘         │
│          │                                      │                │
│          ▼                                      │                │
│   ┌─────────────┐    Online?    ┌─────────────┐│                │
│   │  SyncQueue  │──────────────▶│   Process   ├┘                │
│   │  (Pending)  │      Yes      │   Queue     │                 │
│   └─────────────┘               └─────────────┘                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

#### Core Components

**1. ConnectivityService** - Network monitoring:

```dart
// Check if online
if (ConnectivityService.instance.isOnline) {
  // Make API call
}

// Listen to changes
ConnectivityService.instance.onStatusChanged.listen((status) {
  if (status == ConnectivityStatus.online) {
    print('Back online!');
  }
});
```

**2. HiveManager** - Database initialization:

```dart
// Initialize at app startup (done in injection_container.dart)
await HiveManager.instance.init();

// Access boxes
final syncBox = HiveManager.instance.getSyncQueueBox();
final settingsBox = HiveManager.instance.getSettingsBox();

// Clear all data (on logout)
await HiveManager.instance.clearAll();
```

**3. SyncQueue** - Queue offline operations:

```dart
// Add operation to queue
await SyncQueue.instance.addOperation(
  operationType: SyncOperationType.create,
  entityType: 'product',
  entityId: 'product-123',
  data: {'name': 'New Product', 'price': 29.99},
  endpoint: '/api/products',
);

// Get pending count
final pending = SyncQueue.instance.pendingCount;

// Process queue when online
final result = await SyncQueue.instance.processQueue();
print('Synced: ${result.succeeded}/${result.processed}');
```

**4. OfflineManager** - Orchestrates everything:

```dart
// Queue and auto-sync
await OfflineManager.instance.queueOperation(
  operationType: SyncOperationType.update,
  entityType: 'user',
  entityId: 'user-1',
  data: {'name': 'John Doe'},
  endpoint: '/api/users/user-1',
);

// Manual sync
await OfflineManager.instance.processQueue();

// Listen to status changes
OfflineManager.instance.onStatusChanged.listen((status) {
  print('Online: ${status.isOnline}, Pending: ${status.pendingCount}');
});
```

#### UI Widgets

**OfflineBanner** - Shows when offline:

```dart
Scaffold(
  body: Column(
    children: [
      const OfflineBanner(),  // Shows only when offline
      Expanded(child: content),
    ],
  ),
)
```

**OfflineIndicatorDot** - Status dot for app bar:

```dart
AppBar(
  title: Text('My App'),
  actions: [
    const OfflineIndicatorDot(),  // Green/Red/Blue dot
  ],
)
```

**OfflineAwareButton** - Disable actions when offline:

```dart
OfflineAwareButton(
  onPressed: () => submitForm(),
  offlineMessage: 'You must be online to submit',
  child: ElevatedButton(
    child: Text('Submit'),
  ),
)
```

**ConnectivityListener** - Snackbar notifications:

```dart
// Already added in App widget
ConnectivityListener(
  showOnlineMessage: true,
  showOfflineMessage: true,
  child: MaterialApp(...),
)
```

#### Using ConnectivityCubit in UI

```dart
// Check state in widget
BlocBuilder<ConnectivityCubit, ConnectivityState>(
  builder: (context, state) {
    if (state.isOffline) {
      return Text('Working offline');
    }
    if (state.isSyncing) {
      return Text('Syncing ${state.pendingOperations} items...');
    }
    return Text('Online');
  },
)

// Trigger manual sync
context.read<ConnectivityCubit>().sync();

// Retry failed operations
context.read<ConnectivityCubit>().retryFailed();
```

#### Implementing Offline-First in Repository

```dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final HiveManager hiveManager;
  final OfflineManager offlineManager;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    // 1. Try local first
    final localProducts = _getLocalProducts();

    // 2. Return local if offline
    if (offlineManager.isOffline) {
      return Right(localProducts);
    }

    // 3. Fetch from remote if online
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      await _saveToLocal(remoteProducts);  // Update local
      return Right(remoteProducts);
    } catch (e) {
      // Fallback to local on error
      return Right(localProducts);
    }
  }

  @override
  Future<Either<Failure, void>> createProduct(Product product) async {
    // 1. Save locally first
    await _saveToLocal([product]);

    // 2. Queue for sync
    await offlineManager.queueOperation(
      operationType: SyncOperationType.create,
      entityType: 'product',
      entityId: product.id,
      data: product.toJson(),
      endpoint: '/api/products',
    );

    return const Right(null);  // Success (will sync later)
  }
}
```

#### Best Practices

| Practice | Description |
|----------|-------------|
| **Local-first reads** | Always read from Hive first for instant UI |
| **Queue all writes** | Queue writes even when online for resilience |
| **Conflict resolution** | Use timestamps or version numbers |
| **Stale data cleanup** | Remove old pending operations (7+ days) |
| **User feedback** | Always show sync status in UI |

---

## Features

### Auth Feature (Example)

Complete authentication implementation:

```
features/auth/
│
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart   # API calls
│   │   └── auth_local_datasource.dart    # Cache operations
│   ├── models/
│   │   └── user_model.dart               # Freezed model
│   └── repositories/
│       └── auth_repository_impl.dart     # Repository implementation
│
├── domain/
│   ├── entities/
│   │   └── user.dart                     # User entity
│   ├── repositories/
│   │   └── auth_repository.dart          # Repository interface
│   └── usecases/
│       ├── login_user.dart               # Login logic
│       ├── register_user.dart            # Register logic
│       ├── logout_user.dart              # Logout logic
│       └── get_current_user.dart         # Get cached user
│
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart                # State management
    │   ├── auth_event.dart               # Events
    │   └── auth_state.dart               # States
    ├── pages/
    │   ├── login_page.dart               # Login UI
    │   └── register_page.dart            # Register UI
    └── widgets/
        └── auth_form.dart                # Shared form widget
```

### Other Features

| Feature | Description |
|---------|-------------|
| `splash` | Splash screen with initialization |
| `onboarding` | First-time user onboarding |
| `home` | Main home screen |
| `settings` | Theme and language settings |
| `main_navigation` | Bottom navigation wrapper |

---

## How to Add a New Feature

Let's add a "Products" feature step by step:

### Step 1: Create Folder Structure

```bash
mkdir -p lib/features/products/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}
```

This creates:

```
lib/features/products/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

### Step 2: Create Domain Layer

**2.1 Entity** (`domain/entities/product.dart`):

```dart
class Product {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });
}
```

**2.2 Repository Interface** (`domain/repositories/product_repository.dart`):

```dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(String id);
}
```

**2.3 UseCase** (`domain/usecases/get_products.dart`):

```dart
class GetProducts implements UseCase<List<Product>, NoParams> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) {
    return repository.getProducts();
  }
}
```

### Step 3: Create Data Layer

**3.1 Model** (`data/models/product_model.dart`):

```dart
@freezed
class ProductModel with _$ProductModel implements CacheableModel {
  const factory ProductModel({
    required String id,
    required String name,
    required double price,
    String? imageUrl,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  // Convert to entity
  Product toEntity() => Product(
    id: id,
    name: name,
    price: price,
    imageUrl: imageUrl,
  );
}
```

**3.2 DataSource** (`data/datasources/product_remote_datasource.dart`):

```dart
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;

  ProductRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await dioClient.get('/products');
    return (response.data as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }
}
```

**3.3 Repository Implementation** (`data/repositories/product_repository_impl.dart`):

```dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final models = await remoteDataSource.getProducts();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
```

### Step 4: Create Presentation Layer

**4.1 Events** (`presentation/bloc/product_event.dart`):

```dart
abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}
```

**4.2 States** (`presentation/bloc/product_state.dart`):

```dart
abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
}
class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
```

**4.3 BLoC** (`presentation/bloc/product_bloc.dart`):

```dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;

  ProductBloc({required this.getProducts}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProducts(NoParams());

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products)),
    );
  }
}
```

**4.4 Page** (`presentation/pages/products_page.dart`):

```dart
@RoutePage()
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(LoadProducts()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Products')),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const LoadingIndicator();
            }
            if (state is ProductError) {
              return AppErrorWidget(message: state.message);
            }
            if (state is ProductLoaded) {
              return ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('\$${product.price}'),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
```

### Step 5: Register Dependencies

Add to `injection_container.dart`:

```dart
Future<void> _initProducts() async {
  // BLoC
  sl.registerFactory<ProductBloc>(
    () => ProductBloc(getProducts: sl()),
  );

  // UseCases
  sl.registerLazySingleton<GetProducts>(
    () => GetProducts(sl()),
  );

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSource
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dioClient: sl()),
  );
}
```

Call it in `initDependencies()`:

```dart
Future<void> initDependencies() async {
  // ... existing code
  await _initProducts();
}
```

### Step 6: Add Route

In `app_router.dart`:

```dart
@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
    // ... existing routes
    AutoRoute(page: ProductsRoute.page),
  ];
}
```

**Don't forget to generate code:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## State Management (BLoC)

### Events

Events are **inputs** that trigger state changes:

```dart
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
```

### States

States are **outputs** that represent UI state:

```dart
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### BLoC Class

BLoC connects events to states:

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final LogoutUser logoutUser;

  AuthBloc({
    required this.loginUser,
    required this.logoutUser,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUser(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUser(NoParams());
    emit(const AuthUnauthenticated());
  }
}
```

### Using in UI

**Trigger an event:**

```dart
// On button press
ElevatedButton(
  onPressed: () {
    context.read<AuthBloc>().add(
      LoginRequested(email: email, password: password),
    );
  },
  child: Text('Login'),
)
```

**Listen to state changes:**

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return const LoadingIndicator();
    }
    if (state is AuthError) {
      return Text(state.message);
    }
    if (state is AuthAuthenticated) {
      return Text('Welcome, ${state.user.name}');
    }
    return const LoginForm();
  },
)
```

**React to state changes (navigation, snackbar):**

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      context.router.replaceAll([const HomeRoute()]);
    }
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: LoginForm(),
)
```

---

## Dependency Injection (GetIt)

### Registration Types

| Type | Method | When Created | Use Case |
|------|--------|--------------|----------|
| Factory | `registerFactory` | Every time | BLoCs, Cubits |
| Lazy Singleton | `registerLazySingleton` | First access | UseCases, Repositories |
| Singleton | `registerSingleton` | Immediately | Core services |

### How to Use

**Registering:**

```dart
// Factory - new instance each time
sl.registerFactory<AuthBloc>(() => AuthBloc(
  loginUser: sl(),
  logoutUser: sl(),
));

// Lazy Singleton - one instance, created when first needed
sl.registerLazySingleton<LoginUser>(() => LoginUser(sl()));

// Singleton - one instance, created immediately
sl.registerSingleton<DioClient>(DioClient.instance);
```

**Accessing:**

```dart
// Get instance
final authBloc = sl<AuthBloc>();
final loginUser = sl<LoginUser>();

// In BlocProvider
BlocProvider(
  create: (_) => sl<AuthBloc>(),
  child: LoginPage(),
)
```

**Registration Order:**

Dependencies must be registered before their dependents:

```dart
// ✅ Correct order
sl.registerLazySingleton<DioClient>(() => DioClient.instance);
sl.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(dioClient: sl()),  // sl() gets DioClient
);

// ❌ Wrong order - DioClient not registered yet
sl.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(dioClient: sl()),  // Error!
);
sl.registerLazySingleton<DioClient>(() => DioClient.instance);
```

---

## Testing

### Test Structure

```
test/
├── fixtures/                    # Test data (JSON files)
│   ├── user.json
│   └── products.json
│
├── helpers/                     # Test utilities
│   ├── pump_app.dart            # Widget test helper
│   └── test_helpers.dart        # Test data factory
│
├── mocks/                       # Mock classes
│   └── mocks.dart               # Mocktail mocks
│
└── features/                    # Feature tests
    └── auth/
        ├── data/
        │   ├── datasources/
        │   └── repositories/
        ├── domain/
        │   └── usecases/
        │       └── login_user_test.dart
        └── presentation/
            └── bloc/
                └── auth_bloc_test.dart
```

### Writing Tests

**UseCase Test:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUser usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUser(mockRepository);
  });

  final testUser = User(id: '1', email: 'test@test.com', name: 'Test');

  test('should return User when login is successful', () async {
    // Arrange
    when(() => mockRepository.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => Right(testUser));

    // Act
    final result = await usecase(LoginParams(
      email: 'test@test.com',
      password: 'password123',
    ));

    // Assert
    expect(result, Right(testUser));
    verify(() => mockRepository.login(
      email: 'test@test.com',
      password: 'password123',
    )).called(1);
  });

  test('should return Failure when login fails', () async {
    // Arrange
    when(() => mockRepository.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => Left(ServerFailure(message: 'Error')));

    // Act
    final result = await usecase(LoginParams(
      email: 'test@test.com',
      password: 'wrong',
    ));

    // Assert
    expect(result, Left(ServerFailure(message: 'Error')));
  });
}
```

**BLoC Test:**

```dart
import 'package:bloc_test/bloc_test.dart';

void main() {
  late AuthBloc bloc;
  late MockLoginUser mockLoginUser;

  setUp(() {
    mockLoginUser = MockLoginUser();
    bloc = AuthBloc(loginUser: mockLoginUser);
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when login succeeds',
    build: () {
      when(() => mockLoginUser(any()))
          .thenAnswer((_) async => Right(testUser));
      return bloc;
    },
    act: (bloc) => bloc.add(LoginRequested(
      email: 'test@test.com',
      password: 'password',
    )),
    expect: () => [
      const AuthLoading(),
      AuthAuthenticated(testUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when login fails',
    build: () {
      when(() => mockLoginUser(any()))
          .thenAnswer((_) async => Left(ServerFailure(message: 'Error')));
      return bloc;
    },
    act: (bloc) => bloc.add(LoginRequested(
      email: 'test@test.com',
      password: 'wrong',
    )),
    expect: () => [
      const AuthLoading(),
      const AuthError('Error'),
    ],
  );
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/domain/usecases/login_user_test.dart

# Run with coverage
flutter test --coverage

# Run with verbose output
flutter test --reporter expanded
```

---

## Commands Reference

### Development

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run app in debug mode |
| `flutter run --release` | Run app in release mode |
| `flutter run -d <device>` | Run on specific device |

### Code Generation

| Command | Description |
|---------|-------------|
| `dart run build_runner build --delete-conflicting-outputs` | Generate code once |
| `dart run build_runner watch --delete-conflicting-outputs` | Generate code continuously |

### Testing

| Command | Description |
|---------|-------------|
| `flutter test` | Run all tests |
| `flutter test --coverage` | Run tests with coverage |
| `flutter test test/path/to/test.dart` | Run specific test |

### Analysis

| Command | Description |
|---------|-------------|
| `flutter analyze` | Analyze code for issues |
| `dart format .` | Format all Dart files |
| `flutter clean` | Clean build artifacts |

### Build

| Command | Description |
|---------|-------------|
| `flutter build apk` | Build Android APK |
| `flutter build appbundle` | Build Android App Bundle |
| `flutter build ios` | Build iOS |
| `flutter build web` | Build Web |

---

## Customization Guide

### Change App Name

1. **pubspec.yaml:**
   ```yaml
   name: your_app_name
   ```

2. **lib/app.dart:**
   ```dart
   MaterialApp(
     title: 'Your App Name',
     ...
   )
   ```

3. **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <application android:label="Your App Name" ...>
   ```

4. **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>CFBundleDisplayName</key>
   <string>Your App Name</string>
   ```

### Change API URL

Edit `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-api.com/api/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### Change Colors

**Light theme:** `lib/core/theme/light/color_scheme_light.dart`

```dart
class ColorSchemeLight {
  final Color primary = const Color(0xFF6200EE);      // Your primary color
  final Color secondary = const Color(0xFF03DAC6);    // Your secondary color
  final Color background = const Color(0xFFFFFFFF);
  final Color surface = const Color(0xFFFAFAFA);
  final Color error = const Color(0xFFB00020);
  // ... more colors
}
```

**Dark theme:** `lib/core/theme/dark/color_scheme_dark.dart`

### Add New Translation

1. Create translation file: `assets/translations/xx.json`
   ```json
   {
     "auth": {
       "login": "Login",
       "register": "Register"
     },
     "home": {
       "welcome": "Welcome, {name}!"
     }
   }
   ```

2. Add to `lib/core/localization/supported_locales.dart`:
   ```dart
   enum SupportedLocale {
     english(...),
     turkish(...),
     newLanguage(
       locale: Locale('xx'),
       languageCode: 'xx',
       name: 'Language Name',
       nativeName: 'Native Name',
       flag: '🏳️',
     ),
   }
   ```

3. Add to `main.dart` supportedLocales

---

## FAQ

**Q: Why Clean Architecture?**
> It provides clear separation of concerns, making the code testable, maintainable, and scalable. Each layer can be modified independently without affecting others.

**Q: When should I use BLoC vs Cubit?**
> Use **Cubit** for simple state (theme toggle, counter). Use **BLoC** for complex state with event-driven logic (authentication, forms with validation).

**Q: Why GetIt for dependency injection?**
> Simple API, no code generation required, supports all registration types. For larger projects, consider Injectable for code generation.

**Q: Why Freezed for models?**
> Generates immutable data classes with `copyWith`, `==`, `hashCode`, `toString`, and JSON serialization. Reduces boilerplate significantly.

**Q: How do I handle authentication guards?**
> Add guards in `app_router.dart`:
```dart
AutoRoute(
  page: HomeRoute.page,
  guards: [AuthGuard()],
)
```

**Q: How do I add global error handling?**
> Errors are already handled in `main.dart` using `runZonedGuarded`. Add custom logic there.

---

## Troubleshooting

### Common Issues

**1. Code generation not working**

```bash
# Clean and regenerate
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**2. "Could not find the correct Provider"**

Make sure the BLoC is provided above the widget that uses it:

```dart
BlocProvider(
  create: (_) => sl<AuthBloc>(),
  child: LoginPage(),  // AuthBloc available here
)
```

**3. Dependency not registered**

Check `injection_container.dart` for:
- Correct registration order
- All dependencies registered
- `initDependencies()` called in `main.dart`

**4. Route not found**

After adding new routes:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**5. Translation key not found**

Check:
- Key exists in all JSON files
- Key path matches `LocaleKeys` constant
- App restarted after adding new keys

---

## License

MIT License - see [LICENSE](LICENSE) file.

---

Made with ❤️ for Flutter developers
