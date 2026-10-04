#!/usr/bin/env bash
set -euo pipefail

# Commit this static release so Pages can deploy without installing Flutter.
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root/mobile"
flutter build web --release --base-href /hackyeah/ --no-web-resources-cdn

mkdir -p "$project_root/github-pages"
rsync -a --delete build/web/ "$project_root/github-pages/"
touch "$project_root/github-pages/.nojekyll"
