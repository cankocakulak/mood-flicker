# New Project Checklist

Use this list after creating a new repository from the template.

## Identity

1. Update `name` in `project.yml` if you want a new `.xcodeproj` file name.
2. Rename the default targets in `project.yml` from `TemplateApp`, `TemplateAppTests`, and `TemplateAppUITests` to your real app name.
3. Run `./Scripts/generate_project.sh`.
4. Search for `TemplateApp` and replace remaining module, scheme, and test references.

## Build Settings

1. Update `APP_BUNDLE_ID` in `Configs/Base.xcconfig`.
2. Update display names in `Configs/Base.xcconfig`, `Configs/Debug.xcconfig`, `Configs/Staging.xcconfig`, and `Configs/Release.xcconfig`.
3. Replace placeholder API and WebSocket URLs.
4. Fill `Configs/Secrets.local.xcconfig` with real local-only values.

## Product Cleanup

1. Replace the demo `Health` feature with your first real feature.
2. Replace `StaticTokenAuthProvider` with your real auth implementation.
3. Update design tokens in `App/Shared/DesignSystem/Theme.swift`.
4. Replace placeholder copy in the root screen.

## Verification

1. Run `./Scripts/lint.sh`.
2. Run `./Scripts/test.sh`.
3. Build and launch the app in Xcode.
4. Confirm Debug, Staging, and Release values resolve correctly.
