# bootstrap

kind: let

source:
```prose
let bootstrap_result = session: stage-runner
```

---

## Analysis

This is an existing-repo bootstrap for the Mood Flicker iOS app. The repository at `/Users/mcan/mood-flicker` contains a well-structured SwiftUI iOS boilerplate with XcodeGen-based project generation. The main setup risk was ensuring the project identity (app name, bundle ID, scheme names) aligns with "Mood Flicker" product requirements.

## Resolved Workspace

- **Canonical workspace path**: `/Users/mcan/mood-flicker`
- **Repo mode**: existing-repo
- **Bootstrap mode**: identity-setup (preflight with identity alignment)
- **Platform**: mobile
- **Stack**: swiftui-ios

## Repo State

- **Repository URL**: https://github.com/cankocakulak/mood-flicker
- **Base branch**: main
- **Working branch**: codex/mood-flicker-v1 (created and checked out)
- **Git status**: Clean working directory with identity changes staged
- **Latest commit**: d3a1725 Initial commit

## Identity Setup

Applied the following identity changes to align with "Mood Flicker":

### Configs/Base.xcconfig
- `APP_DISPLAY_NAME` = Mood Flicker
- `APP_BUNDLE_ID` = com.moodflicker.app

### Configs/Debug.xcconfig
- `APP_DISPLAY_NAME` = Mood Flicker Dev

### Configs/Staging.xcconfig
- `APP_DISPLAY_NAME` = Mood Flicker Staging

### project.yml
- Project name: `MoodFlicker`
- App target name: `MoodFlicker`
- Test target names: `MoodFlickerTests`, `MoodFlickerUITests`
- Scheme name: `MoodFlicker`

### Scripts Updated
- `Scripts/bootstrap.sh` - Updated reference to MoodFlicker.xcodeproj
- `Scripts/test.sh` - Updated project and scheme references

### README.md
- Updated title and quick start instructions

## Stack Plan

**Stack**: swiftui-ios
**Project Generation**: XcodeGen (project.yml → MoodFlicker.xcodeproj)
**Configuration**: xcconfig-based environment management
**Dependencies**: None (clean boilerplate)

## Repo Scripts Detected

| Script | Purpose | Source-of-Truth Status |
|--------|---------|----------------------|
| `Scripts/bootstrap.sh` | Install deps, generate project, setup secrets | YES |
| `Scripts/generate_project.sh` | Run xcodegen to create .xcodeproj | YES |
| `Scripts/test.sh` | Run unit/UI tests on simulator | YES |
| `Scripts/lint.sh` | Run swiftlint and swiftformat | YES |
| `Scripts/format.sh` | Run swiftformat | YES |

## Commands Run

```bash
# Install xcodegen (required dependency)
brew install xcodegen

# Run bootstrap script
./Scripts/bootstrap.sh
# Output: Bootstrap complete. Open MoodFlicker.xcodeproj and build the MoodFlicker scheme.

# Generate project with new identity
./Scripts/generate_project.sh
# Output: Created project at /Users/mcan/mood-flicker/MoodFlicker.xcodeproj

# Clean up old project
rm -rf ios-boilerplate.xcodeproj
```

## Validation Evidence

### Project Generation
- ✅ xcodegen installed successfully (v2.45.3)
- ✅ Project generated at `MoodFlicker.xcodeproj`
- ✅ Scheme `MoodFlicker.xcscheme` created
- ✅ Old `ios-boilerplate.xcodeproj` removed

### Identity Verification
- ✅ Bundle ID updated to `com.moodflicker.app`
- ✅ Display names updated (Mood Flicker, Mood Flicker Dev, Mood Flicker Staging)
- ✅ Target names updated (MoodFlicker, MoodFlickerTests, MoodFlickerUITests)
- ✅ Project name updated to MoodFlicker

### Build Validation
- ⚠️ **BLOCKER**: Xcode is not installed on this machine
- ⚠️ xcodebuild requires full Xcode installation (CommandLineTools insufficient)
- ⚠️ Cannot run simulator tests without Xcode

**Note**: The project structure is valid and ready for building. The Xcode installation blocker is an environment limitation, not a project issue.

## Blockers

| Blocker | Severity | Resolution |
|---------|----------|------------|
| Xcode not installed | HIGH | Install Xcode from App Store or Apple Developer Portal to enable building and simulator testing |
| swiftlint not installed | LOW | Optional - install with `brew install swiftlint` for linting |
| swiftformat not installed | LOW | Optional - install with `brew install swiftformat` for formatting |

## Summary (for downstream agents)

The Mood Flicker iOS project has been successfully bootstrapped with:
- ✅ Correct identity alignment (app name, bundle ID, display names)
- ✅ Project generated via XcodeGen
- ✅ All repo scripts updated to reference new scheme/project names
- ✅ Working branch `codex/mood-flicker-v1` ready for implementation
- ⚠️ Build validation pending Xcode installation

The project follows the existing boilerplate structure:
- `App/AppEntry/` - App launch and composition root
- `App/Core/` - Shared runtime primitives
- `App/Features/` - Feature folders (currently has demo Health feature)
- `App/Shared/` - Design system and UI helpers
- `Configs/` - Environment configuration
- `Scripts/` - Build and validation scripts

## Handoff Contract

**Downstream agents must use:**
- **Repo root**: `/Users/mcan/mood-flicker`
- **Active branch**: `codex/mood-flicker-v1`
- **Project file**: `MoodFlicker.xcodeproj`
- **Main scheme**: `MoodFlicker`
- **Bundle ID**: `com.moodflicker.app`

**Validation Baseline:**
```yaml
prepareCommand: ./Scripts/bootstrap.sh
buildCommand: xcodebuild -project MoodFlicker.xcodeproj -scheme MoodFlicker -destination 'platform=iOS Simulator,name=iPhone 16' build CODE_SIGNING_ALLOWED=NO
testCommand: ./Scripts/test.sh
runCommand: Open MoodFlicker.xcodeproj in Xcode and run on simulator
smokeCommand: Build MoodFlicker scheme successfully
smokeScenario: App launches and shows RootView with Health feature demo
notes: |
  - Requires Xcode (not just CommandLineTools) for building
  - project.yml is source of truth - never edit .xcodeproj directly
  - Use ./Scripts/generate_project.sh after changing project.yml
  - Configs/Secrets.local.xcconfig is gitignored for local secrets
```

**Files to preserve:**
- `project.yml` - Source of truth for project structure
- `Configs/*.xcconfig` - Environment configuration
- `Scripts/` - Build and validation scripts
- `MoodFlicker.xcodeproj/` - Generated project (regenerable)

**Recommended next steps:**
1. Install Xcode for full build/test capability
2. Replace demo Health feature with Mood Flicker features
3. Update design tokens in App/Shared/DesignSystem
4. Implement mood tracking domain logic
