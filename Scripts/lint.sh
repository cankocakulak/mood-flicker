#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v swiftformat >/dev/null 2>&1; then
  echo "swiftformat is required for linting. Install it with: brew install swiftformat"
  exit 1
fi

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "swiftlint is required for linting. Install it with: brew install swiftlint"
  exit 1
fi

swiftformat App Tests UITests --lint --cache ignore
swiftlint lint --config .swiftlint.yml --no-cache
