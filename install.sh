#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION=$(tr -d '\n' < "$SCRIPT_DIR/VERSION")
TODAY=$(date +%Y-%m-%d)

usage() {
    cat <<EOF
Usage: install.sh <target-directory> [options]

Initialize a new Praxis knowledge base instance.

Arguments:
  target-directory    Path to the new Praxis instance (created if absent)

Options:
  --init-git          Initialize a git repository after setup
  --help              Show this message

Framework version: $VERSION
EOF
    exit 0
}

# ── argument parsing ──────────────────────────────────────────

[[ $# -lt 1 ]] && { usage; }
TARGET_DIR="${1%/}"
shift

INIT_GIT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --init-git) INIT_GIT=true; shift ;;
        --help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# ── safety guards ──────────────────────────────────────────────

if [[ "$(realpath "$TARGET_DIR" 2>/dev/null || readlink -f "$TARGET_DIR")" == "$(realpath "$SCRIPT_DIR" 2>/dev/null || readlink -f "$SCRIPT_DIR")" ]]; then
    echo "Error: target directory cannot be the framework repository itself"
    exit 1
fi

if [[ -f "$TARGET_DIR/.praxis-version" ]]; then
    echo "Error: $TARGET_DIR already contains a Praxis instance (.praxis-version found)"
    echo "Use update.sh to update an existing instance."
    exit 1
fi

# ── create directory skeleton ──────────────────────────────────

echo "==> Creating directory structure …"
mkdir -p "$TARGET_DIR/00-inbox"
mkdir -p "$TARGET_DIR/01-problems"
mkdir -p "$TARGET_DIR/02-projects"
mkdir -p "$TARGET_DIR/03-knowledge/concepts"
mkdir -p "$TARGET_DIR/03-knowledge/models"
mkdir -p "$TARGET_DIR/03-knowledge/methods"
mkdir -p "$TARGET_DIR/03-knowledge/references"
mkdir -p "$TARGET_DIR/03-knowledge/failures"
mkdir -p "$TARGET_DIR/04-assets"
mkdir -p "$TARGET_DIR/core"
mkdir -p "$TARGET_DIR/.agent-sessions"

# ── install framework internals (always synced by update.sh) ───

echo "==> Installing framework internals …"
cp -r "$SCRIPT_DIR/.agents"  "$TARGET_DIR/"
cp -r "$SCRIPT_DIR/.praxis"  "$TARGET_DIR/"
cp -r "$SCRIPT_DIR/.obsidian" "$TARGET_DIR/"

# ── install track-agent-sessions (external skill) ─────────────

echo "==> Installing track-agent-sessions skill …"
TAS_REPO="https://github.com/changhorizon/track-agent-sessions.git"
TAS_TMP=$(mktemp -d)
if git clone --depth 1 "$TAS_REPO" "$TAS_TMP" 2>/dev/null; then
    python3 "$TAS_TMP/scripts/install_skill.py" --target "$TARGET_DIR"
    rm -rf "$TAS_TMP"
else
    rm -rf "$TAS_TMP"
    echo "Warning: could not fetch track-agent-sessions (no network?)"
    echo "  Install manually: git clone $TAS_REPO .agents/skills/track-agent-sessions"
fi

# ── install user templates (copy once, user edits) ─────────────

echo "==> Installing user templates …"
while IFS= read -r -d '' src; do
    rel="${src#$SCRIPT_DIR/templates/}"
    dst="$TARGET_DIR/$rel"

    if [[ -d "$src" ]]; then
        mkdir -p "$dst"
    else
        mkdir -p "$(dirname "$dst")"
        # Substitute {{date}} with today
        sed "s/{{date}}/$TODAY/g" "$src" > "$dst"
    fi
done < <(find "$SCRIPT_DIR/templates" -mindepth 1 -print0)

# ── version stamp ──────────────────────────────────────────────

echo "$VERSION" > "$TARGET_DIR/.praxis-version"

# ── optional git init ──────────────────────────────────────────

if $INIT_GIT; then
    if git -C "$TARGET_DIR" rev-parse --git-dir >/dev/null 2>&1; then
        echo "Warning: $TARGET_DIR is already inside a git repository"
        echo "Skipping git init."
    else
        echo "==> Initializing git repository …"
        git -C "$TARGET_DIR" init
        git -C "$TARGET_DIR" add -A
        git -C "$TARGET_DIR" commit -m "chore: init Praxis knowledge base v$VERSION"
    fi
fi

# ── done ───────────────────────────────────────────────────────

cat <<EOF

Done. Praxis v$VERSION initialized at
  $TARGET_DIR

Next steps:
  1. Edit core/identity.md  — who you are, how you think
  2. Edit core/goals.md     — what you want to achieve
  3. Start writing in 00-inbox/ — anything:灵感、感受、事件
  4. From there, agent will help you grow the knowledge base
EOF
