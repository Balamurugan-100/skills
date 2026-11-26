#!/usr/bin/env bash
# Reset installed skills and AGENTS.md for Codex, Antigravity, and OpenCode,
# then re-run install.sh from this repo so no stale or dead skills remain.
set -euo pipefail

SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:?HOME is not set}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME_DIR/.config}"

AGENTS=(codex antigravity opencode)
SCOPE="global"
PROJECT_DIR="$PWD"
DRY_RUN=0
SELECTED=()

usage() {
  cat <<'EOF'
Usage: ./reset.sh [options]

Remove existing installed skills and AGENTS.md for the selected agents,
then re-run ./install.sh to create a clean setup.

Options:
  --agent <name>   Reset one agent: codex, antigravity, opencode.
                   Repeatable. Defaults to all three.
  --scope <scope>  global (default) or project.
  --project <dir>  Project root for --scope project (default: current dir).
  --dry-run        Print what would happen without changing anything.
  -h, --help       Show this help.
EOF
}

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

while (($#)); do
  case "$1" in
    --agent)
      (($# >= 2)) || die "--agent needs a value"
      case "$2" in
        codex|antigravity|opencode) SELECTED+=("$2") ;;
        *) die "unknown agent: $2" ;;
      esac
      shift 2
      ;;
    --scope)
      (($# >= 2)) || die "--scope needs a value"
      case "$2" in
        global|project) SCOPE="$2" ;;
        *) die "unknown scope: $2" ;;
      esac
      shift 2
      ;;
    --project)
      (($# >= 2)) || die "--project needs a value"
      PROJECT_DIR="$2"
      shift 2
      ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
done

((${#SELECTED[@]})) || SELECTED=("${AGENTS[@]}")
[ -d "$PROJECT_DIR" ] || die "project directory not found: $PROJECT_DIR"
PROJECT_DIR="$(cd -- "$PROJECT_DIR" && pwd)"

skills_dir_for() {
  case "$1" in
    codex)       printf '%s' "$HOME_DIR/.agents/skills" ;;
    antigravity) printf '%s' "$HOME_DIR/.gemini/config/skills" ;;
    opencode)    printf '%s' "$CONFIG_HOME/opencode/skills" ;;
  esac
}

agents_file_for() {
  case "$1" in
    codex)       printf '%s' "$HOME_DIR/.codex/AGENTS.md" ;;
    antigravity) printf '%s' "$HOME_DIR/.gemini/AGENTS.md" ;;
    opencode)    printf '%s' "$CONFIG_HOME/opencode/AGENTS.md" ;;
  esac
}

clear_dir() {
  local dir="$1" removed=0 entry
  printf '\n==> Resetting %s\n' "$dir"
  [ -d "$dir" ] || { printf '    (not present)\n'; return; }

  shopt -s nullglob dotglob
  for entry in "$dir"/*; do
    if [ "$DRY_RUN" -eq 0 ]; then
      rm -rf -- "$entry"
    fi
    printf '    - %s\n' "$(basename -- "$entry")"
    removed=$((removed + 1))
  done
  shopt -u nullglob dotglob
  printf '    %d removed\n' "$removed"
}

clear_agents_file() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$DRY_RUN" -eq 0 ]; then
      rm -f -- "$target"
    fi
    printf '    - %s\n' "$target"
  fi
}

if [ "$SCOPE" = project ]; then
  clear_dir "$PROJECT_DIR/.agents/skills"
else
  for agent in "${SELECTED[@]}"; do
    clear_dir "$(skills_dir_for "$agent")"
    clear_agents_file "$(agents_file_for "$agent")"
  done
fi

install_args=(--scope "$SCOPE" --project "$PROJECT_DIR" --force)
for agent in "${SELECTED[@]}"; do
  install_args+=(--agent "$agent")
done
[ "$DRY_RUN" -eq 1 ] && install_args+=(--dry-run)

exec "$SRC_DIR/install.sh" "${install_args[@]}"
