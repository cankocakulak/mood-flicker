# Architecture

## Purpose

This repository is a thin iOS app starter that demonstrates a clean path from build configuration to backend call to UI state.

## Main Flow

1. `Configs/*.xcconfig` define environment values such as display name, bundle identifier, API base URL, and WebSocket URL.
2. `project.yml` maps those values into generated Info.plist keys.
3. `AppEnvironment` reads those keys from the app bundle at runtime.
4. `AppContainer` creates live dependencies using that environment.
5. Feature APIs depend on `NetworkClient`, not on `URLSession` directly.
6. View models depend on feature APIs and loggers.
7. SwiftUI views render view model state and trigger async loads.

## Directory Roles

- `App/AppEntry/`: launch and dependency wiring
- `App/Config/`: build configuration and environment loading
- `App/Core/`: reusable infrastructure
- `App/Features/`: vertical slices for product code
- `App/Shared/`: design tokens and shared UI helpers
- `Tests/`: unit coverage and mocks
- `UITests/`: launch and interaction smoke coverage

## Dependency Direction

Allowed direction:
- `AppEntry` -> `Config`, `Core`, `Features`, `Shared`
- `Features/Presentation` -> `Features/Data`, `Features/Domain`, `Core`
- `Features/Data` -> `Core`, `Features/Domain`
- `Core` should not depend on `Features`

## What To Preserve In Derived Apps

- config-driven environments
- injectable network/auth boundaries
- feature-oriented folders
- explicit test targets and scripts
- script and CI symmetry

## What To Replace Early

- demo `Health` feature
- placeholder app identity and bundle identifier
- static auth provider
- placeholder backend endpoints
