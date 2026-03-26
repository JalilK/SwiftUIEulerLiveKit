#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
MAX_CHARS="${MAX_CHARS:-120000}"
MAX_FILE_CHARS="${MAX_FILE_CHARS:-12000}"
MAX_FILES="${MAX_FILES:-120}"

exclude_dirs=(
  .git
  .build
  DerivedData
  .swiftpm
  node_modules
  .venv
  venv
  __pycache__
  .mypy_cache
  .pytest_cache
  .idea
  .vscode
)

python3 - "$ROOT" "$MAX_CHARS" "$MAX_FILE_CHARS" "$MAX_FILES" <<'PY'
import os
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
max_chars = int(sys.argv[2])
max_file_chars = int(sys.argv[3])
max_files = int(sys.argv[4])

exclude_dirs = {
    ".git", ".build", "DerivedData", ".swiftpm", "node_modules", ".venv", "venv",
    "__pycache__", ".mypy_cache", ".pytest_cache", ".idea", ".vscode"
}
exclude_suffixes = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".heic", ".mp4", ".mov", ".avi",
    ".mp3", ".wav", ".m4a", ".aiff", ".pdf", ".zip", ".tar", ".gz", ".tgz",
    ".xcuserstate", ".pbxuser", ".mode1v3", ".mode2v3", ".perspectivev3",
    ".pyc", ".pyo", ".o", ".a", ".dylib", ".so", ".framework"
}
preferred_suffixes = {
    ".swift", ".md", ".txt", ".yml", ".yaml", ".json", ".plist", ".sh", ".py",
    ".toml", ".cfg", ".conf", ".env", ".gitignore"
}

def excluded(path: Path) -> bool:
    return any(part in exclude_dirs for part in path.parts)

def is_text_file(path: Path) -> bool:
    if path.suffix.lower() in preferred_suffixes:
        return True
    try:
        data = path.read_bytes()[:2048]
        if b"\x00" in data:
            return False
        data.decode("utf-8")
        return True
    except Exception:
        return False

files = []
for p in sorted(root.rglob("*")):
    if p.is_file() and not excluded(p) and p.suffix.lower() not in exclude_suffixes and is_text_file(p):
        files.append(p)

print("===== PROJECT TREE =====")
print()
for p in files[:max_files]:
    print(f"./{p.relative_to(root).as_posix()}")

print()
print("===== FULL PROJECT DUMP START =====")
print()

printed_chars = 0
printed_files = 0

for p in files:
    if printed_files >= max_files:
        print(f"===== STOPPED AFTER MAX_FILES {max_files} =====")
        break

    try:
        text = p.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        text = p.read_text(encoding="utf-8", errors="replace")

    if len(text) > max_file_chars:
        header = f"===== ./{p.relative_to(root).as_posix()} ====="
        body = f"[SKIPPED: file exceeds MAX_FILE_CHARS {max_file_chars}, actual {len(text)}]"
        chunk = f"{header}\n\n{body}\n\n"
    else:
        header = f"===== ./{p.relative_to(root).as_posix()} ====="
        chunk = f"{header}\n\n{text.rstrip()}\n\n"

    if printed_chars + len(chunk) > max_chars:
        print(f"===== STOPPED AT MAX_CHARS {max_chars} =====")
        break

    print(chunk, end="")
    printed_chars += len(chunk)
    printed_files += 1

print("===== FULL PROJECT DUMP END =====")
PY
