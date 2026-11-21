#!/usr/bin/env bash
# Install the skills in this repo for Codex, Antigravity and OpenCode.
set -euo pipefail

SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:?HOME is not set}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME_DIR/.config}"

AGENTS=(codex antigravity opencode)
SCOPE="global"
PROJECT_DIR="$PWD"
DRY_RUN=0
FORCE=0
SELECTED=()

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Install the skills from this repo for Codex, Antigravity and OpenCode.

Options:
  --agent <name>   Install for one agent: codex, antigravity, opencode.
                   Repeatable. Defaults to all three.
  --scope <scope>  global (default) or project.
  --project <dir>  Project root for --scope project (default: current dir).
  --force          Replace existing entries that are not already linked here.
  --dry-run        Print what would happen without changing anything.
  -h, --help       Show this help.

Global destinations:
  codex        ~/.agents/skills
  antigravity  ~/.gemini/config/skills
  opencode     ~/.config/opencode/skills
               (this repo is also added to opencode.json's skills array,
                because explicit config entries take precedence)

Project destination (shared by all three):
  <project>/.agents/skills
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
    --force) FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
done

((${#SELECTED[@]})) || SELECTED=("${AGENTS[@]}")

[ -d "$SRC_DIR" ] || die "source directory not found: $SRC_DIR"
[ -d "$PROJECT_DIR" ] || die "project directory not found: $PROJECT_DIR"
PROJECT_DIR="$(cd -- "$PROJECT_DIR" && pwd)"

skill_dirs=()
for dir in "$SRC_DIR"/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  skill_dirs+=("$dir")
done
((${#skill_dirs[@]})) || die "no SKILL.md skills found in $SRC_DIR"

same_path() {
  local a b
  a="$(realpath "$1" 2>/dev/null || printf '%s' "$1")"
  b="$(realpath "$2" 2>/dev/null || printf '%s' "$2")"
  [ "$a" = "$b" ]
}

install_to() {
  local target="$1" installed=0 skipped=0
  printf '\n==> %s\n' "$target"
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p -- "$target"
  fi

  local dir name dest
  for dir in "${skill_dirs[@]}"; do
    name="$(basename -- "${dir%/}")"
    dest="$target/$name"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
      if same_path "$dest" "$dir"; then
        printf '    = %s (already from this repo)\n' "$name"
        skipped=$((skipped + 1))
        continue
      fi
      if [ "$FORCE" -eq 0 ]; then
        printf '    ! %s exists elsewhere (use --force to replace)\n' "$name" >&2
        skipped=$((skipped + 1))
        continue
      fi
      if [ "$DRY_RUN" -eq 0 ]; then
        rm -rf -- "$dest"
      fi
    fi

    if [ "$DRY_RUN" -eq 0 ]; then
      ln -s -- "$dir" "$dest"
    fi
    printf '    + %s\n' "$name"
    installed=$((installed + 1))
  done

  printf '    %d installed, %d skipped\n' "$installed" "$skipped"
}

target_for() {
  case "$1" in
    codex)       printf '%s' "$HOME_DIR/.agents/skills" ;;
    antigravity) printf '%s' "$HOME_DIR/.gemini/config/skills" ;;
    opencode)    printf '%s' "$CONFIG_HOME/opencode/skills" ;;
  esac
}

# OpenCode gives explicit `skills` config entries the highest precedence, so
# creating its default skills dir alone would lose to any already-configured
# source with the same skill IDs. Append this repo to that array instead.
register_opencode_source() {
  local config=""
  local candidate
  for candidate in "$CONFIG_HOME/opencode/opencode.json" "$CONFIG_HOME/opencode/opencode.jsonc"; do
    if [ -f "$candidate" ]; then
      config="$candidate"
      break
    fi
  done

  if [ -z "$config" ]; then
    printf '\n==> OpenCode config: none found at %s/opencode/opencode.json; skipping registration\n' "$CONFIG_HOME"
    return
  fi

  if ! command -v node >/dev/null 2>&1; then
    printf '\n!! node not found: add "%s" to the skills array in %s\n' "$SRC_DIR" "$config" >&2
    return
  fi

  printf '\n==> Registering this repo in %s\n' "$config"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '    + skills: ["%s"]\n' "$SRC_DIR"
    return
  fi

  if ! node - "$config" "$SRC_DIR" <<'NODE'
const fs = require('fs');
const path = require('path');
const os = require('os');
const [configArg, source] = process.argv.slice(2);

let cfg;
try {
  cfg = JSON.parse(fs.readFileSync(configArg, 'utf8'));
} catch (e) {
  console.error('  ! config is not plain JSON: add the path manually');
  process.exit(1);
}

const normalize = (p) => {
  if (typeof p !== 'string') return p;
  if (p.startsWith('~/')) return path.join(os.homedir(), p.slice(2));
  if (/^https?:\/\//.test(p)) return p;
  return path.resolve(p);
};

const skills = Array.isArray(cfg.skills) ? [...cfg.skills] : [];
if (skills.some((s) => normalize(s) === normalize(source))) {
  console.log('    = already registered');
  process.exit(0);
}
skills.push(source);
cfg.skills = skills;

const real = fs.realpathSync(configArg);
const backup = real + '.bak';
if (!fs.existsSync(backup)) fs.copyFileSync(real, backup);
const tmp = real + '.tmp-' + process.pid;
fs.writeFileSync(tmp, JSON.stringify(cfg, null, 2) + '\n', 'utf8');
fs.renameSync(tmp, real);
console.log('    + added to skills array (backup: ' + backup + ')');
NODE
  then
    printf '  ! could not update automatically; add "%s" to the skills array in %s\n' "$SRC_DIR" "$config" >&2
  fi
}

printf 'Source: %s\nScope: %s%s\n' \
  "$SRC_DIR" "$SCOPE" "$([ "$DRY_RUN" -eq 1 ] && printf ' (dry run)')"

if [ "$SCOPE" = project ]; then
  install_to "$PROJECT_DIR/.agents/skills"
else
  for agent in "${SELECTED[@]}"; do
    install_to "$(target_for "$agent")"
  done
  for agent in "${SELECTED[@]}"; do
    if [ "$agent" = opencode ]; then
      register_opencode_source
    fi
  done
fi

printf '\nDone. Restart Codex / Antigravity / OpenCode to pick up the skills.\n'
