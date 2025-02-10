# Technical Specification

## System Overview
The `mc_dashboard` system is a multi-platform application built using Flutter, designed to provide a comprehensive dashboard for managing various business operations. The system integrates Firebase for authentication and data storage, Hive for local storage, and external APIs for data retrieval. The main components include the frontend (Flutter UI), backend services (Firebase, external APIs), local storage (Hive), and utility functions for text processing and similarity calculations.

## Core Functionality

### 1. Authentication and User Management
**Importance Score: 95**
- **Files**: `lib/domain/services/auth_service.dart`, `lib/presentation/login_screen/login_view_model.dart`
- **Primary Functions**:
  - `signIn(email, password)` - Handles user sign-in.
  - `register(email, password)` - Handles user registration.
  - `resetPassword(email)` - Handles password reset.
- **Core Data Models**:
  - `User` - Represents a user with properties like `email`, `uid`.
- **Main Connection Points**:
  - Interacts with Firebase Auth for authentication.
  - `LoginViewModel` manages UI states and user interactions.

### 2. Data Retrieval and Management
**Importance Score: 90**
- **Files**: `lib/domain/services/detailed_orders_service.dart`, `lib/infrastructure/api/detailed_orders.dart`
- **Primary Functions**:
  - `fetchDetailedOrders(params)` - Retrieves detailed order data.
- **Core Data Models**:
  - `DetailedOrder` - Represents an order with properties like `orderId`, `products`, `total`.
- **Main Connection Points**:
  - Interacts with external APIs via `DetailedOrdersApiClient`.

### 3. Local Storage and State Management
**Importance Score: 85**
- **Files**: `lib/core/base_classes/view_model_base_class.dart`, `lib/infrastructure/repositories/local_storage.dart`
- **Primary Functions**:
  - `saveData(key, value)` - Saves data to local storage.
  - `getData(key)` - Retrieves data from local storage.
- **Core Data Models**:
  - `LocalStorageItem` - Represents an item stored locally with properties like `key`, `value`.
- **Main Connection Points**:
  - Utilizes Hive for local data storage.

### 4. Text Similarity Calculation
**Importance Score: 80**
- **Files**: `lib/core/utils/similarity.dart`
- **Primary Functions**:
  - `calculateCosineSimilarity(text1, text2)` - Computes cosine similarity between two texts.
- **Core Data Models**:
  - N/A
- **Main Connection Points**:
  - Used in features requiring text comparison.

### 5. Dependency Injection
**Importance Score: 85**
- **Files**: `lib/di/di_container.dart`
- **Primary Functions**:
  - `register<T>(T instance)` - Registers a service or repository.
  - `resolve<T>()` - Resolves a registered service or repository.
- **Core Data Models**:
  - N/A
- **Main Connection Points**:
  - Manages the lifecycle and provision of services and repositories.

## Architecture

### Data Flow Patterns
**Importance Score: 90**
- Describes how data flows through the system for key functionalities like authentication, data retrieval, local storage, and text similarity.
- Data enters the system through user interactions (e.g., login, data requests) and external APIs.
- It is processed by services (e.g., `AuthService`, `DetailedOrdersService`) and stored locally using Hive.
- The processed data is then used to update the UI and provide feedback to the user.

### Component Interaction
**Importance Score: 85**
- Details how different components (Frontend, Backend Services, Local Storage, External APIs) interact to provide the system's core functionalities.
- The frontend components (Flutter UI) interact with backend services (Firebase, external APIs) to fetch and display data.
- Local storage (Hive) is used to cache data and provide offline capabilities.
- Utility functions (e.g., text similarity calculations) are used to enhance the functionality of the system.