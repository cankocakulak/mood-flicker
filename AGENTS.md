# AGENTS.md

This repository is a reusable iOS starter, not a product app. Keep changes generic unless a derived app has already claimed a concrete direction.

## Source Of Truth

- Treat `project.yml` as the source of truth for targets, schemes, and build settings.
- Regenerate the Xcode project with `./Scripts/generate_project.sh` after editing `project.yml`.
- Do not hardcode secrets, API keys, or backend URLs in Swift files.
- Keep local-only values in `Configs/Secrets.local.xcconfig`.

## Code Organization

- `App/AppEntry/`: app launch, dependency composition, root navigation.
- `App/Core/`: reusable runtime primitives such as networking, auth, persistence, and logging.
- `App/Features/<Feature>/Domain`: models and feature-facing contracts.
- `App/Features/<Feature>/Data`: repositories and API adapters.
- `App/Features/<Feature>/Presentation`: view models and SwiftUI views.
- `App/Shared/`: design system and cross-feature UI utilities.

## Architecture Rules

- Prefer dependency injection through `AppContainer` or feature initializers.
- Avoid new global singletons unless there is a strong runtime reason.
- Keep view models feature-scoped and testable with protocol-based dependencies.
- Use `AppEnvironment` for environment-driven values.
- Keep demo code isolated so derived apps can replace it cleanly.

## Testing Rules

- Add or update unit tests for new view models, config parsing, and network request mapping.
- Add or update at least one smoke UI test when app launch or primary flows change.
- Run `./Scripts/lint.sh` and `./Scripts/test.sh` before handing work off.
- If a feature depends on backend state, provide mocks or launch arguments so UI tests stay deterministic.

## Template Maintenance

- Preserve `Docs/NEW_PROJECT_CHECKLIST.md` and `Docs/ARCHITECTURE.md` unless replaced with equivalent docs.
- Keep README focused on template usage, not on one derived product.
- When a derived app replaces the demo `Health` feature, remove its leftover tests and references in the same change.
