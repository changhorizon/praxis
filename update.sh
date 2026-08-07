#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEW_VERSION=$(tr -d '\n' < "$SCRIPT_DIR/VERSION")

usage() {
    cat <<EOF
Usage: update.sh <instance-directory>

Update the framework internals of an existing Praxis instance.
Does NOT touch user-customized files (core/, AGENTS.md, +.md, .gitignore).

Arguments:
  instance-directory    Path to the Praxis instance to update

Framework version: $NEW_VERSION
EOF
    exit 0
}

# ── argument parsing ──────────────────────────────────────────

[[ $# -lt 1 || "$1" == "--help" ]] && { usage; }
INSTANCE_DIR="${1%/}"

# ── sanity checks ──────────────────────────────────────────────

if [[ ! -d "$INSTANCE_DIR" ]]; then
    echo "Error: $INSTANCE_DIR does not exist"
    exit 1
fi

if [[ ! -f "$INSTANCE_DIR/.praxis-version" ]]; then
    echo "Error: $INSTANCE_DIR is not a Praxis instance (missing .praxis-version)"
    exit 1
fi

CURRENT_VERSION=$(tr -d '\n' < "$INSTANCE_DIR/.praxis-version")

echo "Praxis instance : $INSTANCE_DIR"
echo "Current version : $CURRENT_VERSION"
echo "Latest version  : $NEW_VERSION"
echo ""

if [[ "$CURRENT_VERSION" == "$NEW_VERSION" ]]; then
    echo "Already up to date."
    exit 0
fi

# ── update framework internals ─────────────────────────────────

echo "==> Updating framework internals …"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cp -r "$SCRIPT_DIR/.agents" "$tmpdir/.agents"
cp -r "$SCRIPT_DIR/.praxis" "$tmpdir/.praxis"

rm -rf "$INSTANCE_DIR/.agents"
rm -rf "$INSTANCE_DIR/.praxis"
mv "$tmpdir/.agents" "$INSTANCE_DIR/"
mv "$tmpdir/.praxis" "$INSTANCE_DIR/"

# ── refresh track-agent-sessions (external skill) ──────────────

echo "==> Refreshing track-agent-sessions skill …"
TAS_REPO="https://github.com/changhorizon/track-agent-sessions.git"
TAS_TMP=$(mktemp -d)
if git clone --depth 1 "$TAS_REPO" "$TAS_TMP" 2>/dev/null; then
    python3 "$TAS_TMP/scripts/install_skill.py" --target "$INSTANCE_DIR" --upgrade
    rm -rf "$TAS_TMP"
else
    rm -rf "$TAS_TMP"
    echo "Warning: could not fetch track-agent-sessions (no network?)"
fi

echo "==> Updating .obsidian/ (default config only) …"
mkdir -p "$INSTANCE_DIR/.obsidian"
for f in app.json appearance.json core-plugins.json; do
    if [[ -f "$SCRIPT_DIR/.obsidian/$f" ]]; then
        cp "$SCRIPT_DIR/.obsidian/$f" "$INSTANCE_DIR/.obsidian/"
    fi
done

# ── warn about user-customized files ───────────────────────────

echo ""
echo "==> These files are user-customized and NOT auto-updated:"
for f in \
    AGENTS.md \
    +.md \
    .gitignore \
    core/identity.md \
    core/goals.md \
    core/principles.md \
    core/agent-state.md; do
    echo "    $f"
done
echo ""
echo "    To see what changed, diff against:  $SCRIPT_DIR/templates/"
echo ""

# ── stamp new version ──────────────────────────────────────────

echo "$NEW_VERSION" > "$INSTANCE_DIR/.praxis-version"
echo "Updated to v$NEW_VERSION."
