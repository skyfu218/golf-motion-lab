#!/bin/zsh
set -e

SCRIPT_DIR="${0:A:h}"
PORT="8766"

cd "$SCRIPT_DIR"

if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
else
  echo "找不到 Python 3，請先安裝或使用其他本機網頁伺服器。"
  read -k 1 "?按任意鍵結束..."
  exit 1
fi

open "http://127.0.0.1:${PORT}/"
exec "$PYTHON_BIN" -m http.server "$PORT" --bind 127.0.0.1
