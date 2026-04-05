# iOS Boilerplate

A template-ready SwiftUI starter for teams that want a clean composition root, backend-friendly boundaries, and working test/tooling setup from day one.

## What This Repo Is

This repository is not a product app. It is a reusable starting point.

Keep these parts in derived apps:
- `project.yml` and the XcodeGen workflow
- `Configs/` environment and secret handling
- `Scripts/` local and CI commands
- `App/Core/` shared runtime primitives
- `Tests/` and `UITests/` testing setup

Replace these parts in derived apps:
- the demo `Health` feature
- app name, bundle identifier, and display names
- backend URLs and auth implementation
- design tokens in `App/Shared/DesignSystem`

## Philosophy

The template stays intentionally narrow. It gives you:
- deterministic project generation via `XcodeGen`
- config-driven backend environments via `xcconfig`
- injectable networking and auth boundaries
- unit and UI smoke tests from the start
- CI-friendly scripts that match local workflows

It does not try to choose your full product architecture for you.

## Structure

- `project.yml`: XcodeGen source of truth
- `Configs/`: build settings, environments, local secrets
- `App/AppEntry/`: app launch and dependency composition
- `App/Core/`: shared runtime primitives
- `App/Features/`: feature folders using `Domain/Data/Presentation`
- `App/Shared/`: design system and cross-feature UI helpers
- `Tests/`: unit tests and test doubles
- `UITests/`: launch and smoke coverage
- `Docs/`: template usage and architecture notes
- `Scripts/`: local bootstrap, lint, format, and test commands

## Quick Start

1. Run `./Scripts/bootstrap.sh`
2. Open `ios-boilerplate.xcodeproj`
3. Build the `TemplateApp` scheme
4. Run `./Scripts/test.sh`

## Using It As A GitHub Template

1. Push this repository to GitHub
2. Enable `Template repository` in GitHub repository settings
3. Create new apps with `Use this template`
4. Follow [Docs/NEW_PROJECT_CHECKLIST.md](/Users/mcan/ios-boilerplate/Docs/NEW_PROJECT_CHECKLIST.md) in the new repository

## Local Commands

```bash
./Scripts/bootstrap.sh
./Scripts/generate_project.sh
./Scripts/lint.sh
./Scripts/format.sh
./Scripts/test.sh
```

## Working Rules

- Treat `project.yml` as the source of truth, not the generated `.xcodeproj`
- Never commit `Configs/Secrets.local.xcconfig`
- Never hardcode secrets or backend URLs in Swift
- Keep shared primitives in `Core/`, product flows in `Features/`
- Add or update tests whenever feature behavior changes

## Docs

- [Architecture](/Users/mcan/ios-boilerplate/Docs/ARCHITECTURE.md)
- [New Project Checklist](/Users/mcan/ios-boilerplate/Docs/NEW_PROJECT_CHECKLIST.md)
- [Agent Guidance](/Users/mcan/ios-boilerplate/AGENTS.md)
