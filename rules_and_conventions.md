# Project Development Guidelines

This document outlines the essential principles all contributors must follow when adding or modifying features in the project.

## 1. Overview of Layers

The project is divided into several layers, each with a distinct responsibility:

  1. **core**
  2. **di** (Dependency Injection)
  3. **infrastructure**
  4. **domain**
  5. **presentation**
  6. **routes**
  7. **theme**
  8. **widgets**
Each layer operates within specific boundaries. **No layer** is allowed to violate the architectural constraints described below.

 


## 2. `core` Layer


  - **Purpose**:

    - Holds constants in a dedicated `constants` folder.
    - Contains shared base classes (e.g., base ViewModels) that other layers can extend or inherit, stored in a dedicated `base_classes` folder.

  - **Rules**:

    - All constants (such as image paths, token names, box names for Hive, etc.) must reside in `core/constants`, in appropriately named files.
    - No additional business logic belongs here—only fundamental project-level definitions or base classes.


 


## 3. `di` Layer (Dependency Injection)


  - **Purpose**:

    - Central location for instantiating and providing dependencies (ViewModels, Services, Repositories, API clients, etc.) to the application.

  - **Rules**:

    - Absolutely **all** dependencies are registered and built in one place (e.g., `di_container.dart`).
    - Other layers must never directly instantiate or manage dependencies; they must request them from the DI layer.
    - If you create a new Screen, Service, Repository, or API client, it **must** be added to the DI configuration so that the rest of the app can receive the correct instance.


 


## 4. `infrastructure` Layer


  - **Purpose**:

    - Contains **concrete** implementations for external data sources (e.g., third-party APIs, databases, secure storage).

  - **Structure**:

    - Typically divided into `api` (for external API clients) and `repository` (for local data sources like a database or secure storage).

  - **Rules**:

    - Each API client or repository **implements** an interface (abstract class) defined in `domain/services`.
    - The rest of the application only references these abstractions from `domain`, not the concrete classes in `infrastructure`.
    - If you add a new API client, you first create an abstract interface in `domain/services` (naming it appropriately). Then implement that interface here in `infrastructure/api`.
    - **A new repository should only be created if**:
      - It is necessary to store **user-related data** (e.g., `access_token`, user settings, cached user content).
      - A new type of storage is required (e.g., integrating a database, secure storage, or a new caching mechanism).
      - The task explicitly states that a new repository must be added.


 


## 5. `domain` Layer


  - **Purpose**:

    - Holds the **business logic** of the application in the form of abstract services and domain entities.

  - **Subfolders**:

    a. `entities`: Domain models and data structures used throughout the app.
    b. `services`: Abstract classes (interfaces) that define the behaviors needed by higher layers.

  - **Rules**:

    - Services in `domain` are typically written as interfaces (or abstract classes).
    - If you must add a new “Service” or “API Client” interface, do it here. Then you implement it in the `infrastructure` layer.
    - A domain service may use or combine data from multiple repositories or API clients, but it doesn’t tie itself to any specific implementation—only their interfaces.


 


## 6. `presentation` Layer


  - **Purpose**:

    - Contains the **UI logic** and any classes that directly interact with the UI (e.g., ViewModels).

  - **Rules**:

    - **Screens** are the visual widgets the user interacts with. They do not contain business logic; they only pass user actions to the ViewModel.
    - **ViewModels** communicate with **Services** (from `domain`) to execute business logic, fetch or update data, and store state.
    - A ViewModel class typically extends the base ViewModel found in `core`, handling loading states, errors, and other lifecycle tasks.


 


## 7. `routes` Layer


  - **Purpose**:

    - Defines and manages navigation throughout the app.

  - **Typical Files**:

    - A file listing named routes, such as `main_navigation_route_names.dart`.
    - A file managing route generation, such as `main_navigation.dart`.

  - **Rules**:

    - The navigation logic constructs or requests new screens from a `ScreenFactory`.
    - Each route name must be listed as a constant.
    - If you add a new screen, also create a method in your `ScreenFactory` for building that screen and register a route for it here.


 


## 8. `theme` Layer


  - **Purpose**:

    - Central location for design-related definitions (colors, typography, shapes, themes).

  - **Rules**:

    - All theme or style definitions live here; do not spread them throughout other layers.
    - If you add new colors or styles, keep them in dedicated theme files for consistency.


 


## 9. `widgets` Layer


  - **Purpose**:

    - Contains **reusable** or “shared” widgets that can be used across multiple screens.

  - **Rules**:

    - If a widget is used by multiple screens, abstract it into this folder.
    - Keep widgets self-contained and presentational (no business logic).


 


## 10. Naming Conventions


  1. **Screens**

    - `EntityScreen` (e.g., `ProductScreen`, `ProductCardScreen`).

  2. **ViewModels**

    - `EntityViewModel` (e.g., `ProductViewModel`, `ProductCardViewModel`).

  3. **Services**

    - Follow the pattern `[Entity + Service]` (e.g., `OzonProductDimensionsService`).
    - If the service depends on an API client, name the interface in `domain/services` in a way that indicates its usage (e.g., `WbProductsServiceApiClient`).

  4. **Repositories**

    - `[Entity + Repo]` (e.g., `OzonProductDimensionsRepo`).

  5. **ApiClients**

    - `[Entity + ApiClient]` (e.g., `OzonProductDimensionsApiClient`).

  6. **Abstract Classes**

    - Typically `[Entity + ServiceApiClient]` or `[Entity + Repo]` with “abstract” or “interface” style naming. The important point is the **interface** lives in `domain/services`, the **implementation** in `infrastructure`.


 


## 11. Dependency Flow


  1. **Screens** → **ViewModels**
  2. **ViewModels** → **Services** (from `domain`)
  3. **Services** → **Repositories / API Clients** (in `infrastructure`)
  4. **Repositories / API Clients** → Implementation details for external data

 


## 12. Additional Guidelines


  - **Do not** write direct logic for API calls in Screens or ViewModels. Keep them in Services and their corresponding API client interfaces.
  - All new constants should be placed in `core/constants`, in a file name matching their purpose.
  - When adding new classes, ensure they are **registered** in `di_container.dart` (or a related dependency injection file).
  - Any external libraries or packages must be **web-compatible** and integrated according to the architecture (for example, networking libraries only in the `infrastructure/api` layer).
  - If you need a new data source (e.g., local database), create a new repository in `infrastructure/repository` implementing an appropriate interface in `domain/services`.
  - When creating a new entity (whether it is a Service, Repository, API Client, ViewModel, or any other component), it is mandatory to follow the Single Responsibility Principle (SRP). Each class should have one clearly defined responsibility and should not perform tasks outside its designated scope. Services should only contain business logic and interact with repositories or API clients—not handle UI logic or state management. ViewModels should only manage UI state and interact with services—never with API clients or repositories directly. Repositories and API Clients should focus exclusively on data fetching and storage, without any business logic. UI Components (Screens, Widgets) should focus only on rendering and handling user interactions. If a class appears to be handling multiple concerns, consider splitting it into separate, more focused classes to improve maintainability and testability.


13. UI/UX Guidelines for Responsive Design

    Consistency Across Devices
        The UI should look and function consistently across platforms (Web, iOS, Android).
        Use adaptive components and MediaQuery to detect screen sizes.

    Adaptive Layouts
        Use Flex, Expanded, Wrap, and GridView instead of fixed dimensions.
        Apply LayoutBuilder and MediaQuery to dynamically adjust elements.
        Support both portrait and landscape orientations.

    Breakpoints
        Small Screens (≤600px, mobile) → Compact UI, primarily vertical layout.
        Medium Screens (600px–1200px, tablets) → Combination of horizontal and vertical elements.
        Large Screens (≥1200px, desktop) → Multi-column layout with optimized spacing.

    Touch-Friendly Interactions
        Minimum touch target size: 48x48 dp (Google Material Guidelines).
        Use hover effects for Web and ripple effects for mobile.
        Implement drag-and-drop interactions where necessary.

    Keyboard & Navigation Accessibility
        Support keyboard navigation using Tab/Arrow keys (Web).
        Ensure the on-screen keyboard does not obstruct important UI elements on mobile.
        Use FocusNode to manage keyboard interactions.

    Performance Optimization
        Implement lazy loading for images (CachedNetworkImage).
        Use ListView.builder instead of ListView for long lists.
        Minimize complex animations, especially on low-performance devices.

    Dark & Light Theme
        Support both light and dark themes using ThemeMode.system.
        Ensure contrast meets WCAG 2.0 (AA) standards.

    Progressive Enhancement
        Implement PWA features (if the Web version should work like an app).
        Handle scenarios where a feature is not supported on certain devices.

    Offline & Loading States
        Display skeletons (Shimmer) or CircularProgressIndicator for loading states.
        Provide error handling mechanisms (SnackBar or Dialog) for offline scenarios.

    Modal Bottom Sheets & Dialogs
        On mobile, use BottomSheet instead of pop-up dialogs.
        On Web, prefer dialogs (AlertDialog).

    Animations & Microinteractions
        Use Flutter animations (AnimatedContainer, Hero) for smooth transitions.
        Avoid excessive animations on low-end devices.

    Internationalization (i18n) & RTL Support
        Use Intl and flutter_localizations.
        Ensure support for Right-To-Left (RTL) languages like Arabic/Hebrew.

    Form Validation & User Input Handling
        Implement validation using Form & TextFormField.
        Provide instant feedback instead of waiting for form submission.

    Floating Action Buttons (FAB)
        Use FAB only when appropriate (e.g., creating a new item).
        For Web, prefer navigation bar icons over FAB.

    Navigation Best Practices
        Implement Adaptive Navigation (BottomNav for mobile, SideNav for Web).
        Use GoRouter for deep linking and navigation control.

## Summary

By adhering to these rules:

  - You maintain a clear separation of concerns.
  - Each layer depends on abstractions from the layer below it, preventing “hard” coupling to concrete classes.
  - You can easily swap out implementations (for example, changing an API client) without modifying higher-level layers.
Always rely on **existing code** to see how classes and folders are structured. If something seems unclear, refer back to this document and follow the established conventions.

 

Agents must treat this **as the definitive guide** for the project architecture. Every change or addition should align with the rules above.