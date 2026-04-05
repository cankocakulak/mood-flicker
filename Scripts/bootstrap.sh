#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1"
    echo "Install it with: $2"
    exit 1
  fi
}

warn_optional_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Optional command not found: $1"
    echo "Install it with: $2"
  fi
}

require_command xcodegen "brew install xcodegen"
warn_optional_command swiftlint "brew install swiftlint"
warn_optional_command swiftformat "brew install swiftformat"

if [ ! -f Configs/Secrets.local.xcconfig ]; then
  cp Configs/Secrets.example.xcconfig Configs/Secrets.local.xcconfig
fi

./Scripts/generate_project.sh

echo "Bootstrap complete. Open ios-boilerplate.xcodeproj and build the TemplateApp scheme."
