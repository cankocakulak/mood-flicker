#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild is required to run tests."
  exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
  echo "xcrun is required to run simulator tests."
  exit 1
fi

./Scripts/generate_project.sh

resolve_simulator_id() {
  local candidates=(
    "iPhone 17 Pro"
    "iPhone 17"
    "iPhone 16 Pro Max"
    "iPhone 16 Plus"
    "iPhone 16e"
    "iPad (A16)"
  )

  for name in "${candidates[@]}"; do
    local device_line
    device_line=$(xcrun simctl list devices available | grep -F "$name" | head -n 1 || true)
    if [ -n "$device_line" ]; then
      local device_id
      device_id=$(echo "$device_line" | sed -n 's/.*(\([A-F0-9-]\{36\}\)).*/\1/p')
      if [ -n "$device_id" ]; then
        echo "$device_id"
        return 0
      fi
    fi
  done

  return 1
}

SIMULATOR_ID=$(resolve_simulator_id)

if [ -z "$SIMULATOR_ID" ]; then
  echo "No supported simulator found."
  exit 1
fi

xcodebuild test \
  -project ios-boilerplate.xcodeproj \
  -scheme TemplateApp \
  -destination "id=$SIMULATOR_ID" \
  CODE_SIGNING_ALLOWED=NO
