#!/usr/bin/env bash
# Serves output/ at localhost:8000/ucpressebooks/ (matching the deployed URL structure)
# Usage: ./serve.sh
#        ./serve.sh 9000   # optional port

set -euo pipefail

PORT="${1:-8000}"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SERVE_DIR="$(mktemp -d)"

ln -s "${REPO_ROOT}/output" "${SERVE_DIR}/ucpressebooks"
trap 'rm -rf "${SERVE_DIR}"' EXIT

echo "Serving at http://localhost:${PORT}/ucpressebooks/"
echo "Press Ctrl-C to stop."
cd "${SERVE_DIR}" && python3 -m http.server "${PORT}"
