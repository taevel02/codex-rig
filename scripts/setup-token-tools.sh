#!/usr/bin/env bash
# Codex Rig: install Caveman without Codex SessionStart hooks and Ponytail with native hooks.
set -euo pipefail

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run|-d) DRY_RUN=true ;;
    *) echo "Unsupported option: $arg" >&2; exit 2 ;;
  esac
done

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CAVEMAN_REF="${CAVEMAN_REF:-v4.0.1}"

say_cmd() { printf '  +'; printf ' %q' "$@"; printf '\n'; }

if [[ "$DRY_RUN" == true ]]; then
  echo '[DRY-RUN] Token tools (no files or settings will be changed):'
  say_cmd npm install -g @caveman-ai/cli@latest
  say_cmd caveman telemetry off
  say_cmd caveman off routing --yes
  say_cmd caveman disable codex
  say_cmd npx -y "github:JuliusBrussee/caveman#${CAVEMAN_REF}" -- --only codex --no-hooks --non-interactive
  echo '  + remove only the old Caveman SessionStart handler (backup hooks.json first)'
  say_cmd codex plugin marketplace add DietrichGebert/ponytail
  say_cmd codex plugin add ponytail@ponytail
  echo '  ! Codex /hooks: trust Ponytail hooks manually after install'
  exit 0
fi

for cmd in codex node npm npx; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "[ERROR] Missing: $cmd" >&2; exit 1; }
done

# The CLI (proxy) requires Node 22.13+. Ponytail's plugin hooks also require Node.
node -e 'const [major,minor]=process.versions.node.split(".").map(Number); process.exit(major>22 || (major===22 && minor>=13) ? 0 : 1)' \
  || { echo '[ERROR] Caveman CLI requires Node.js 22.13 or later.' >&2; exit 1; }

if ! command -v caveman >/dev/null 2>&1; then
  npm install -g @caveman-ai/cli@latest
fi

# Opt out before invoking other Caveman CLI commands.
caveman telemetry off
# Keep model-selection requests away from Caveman Cloud unless separately enabled.
if ! caveman off routing --yes; then
  echo '[ERROR] Could not disable Caveman Auto routing; setup aborted. Run: caveman off routing --yes' >&2
  exit 1
fi
# Remove any existing Caveman-native Codex integration; the opt-in proxy launch remains available.
if ! caveman disable codex; then
  echo '[WARN] Could not disable the existing Caveman-native Codex integration; inspect caveman status.' >&2
fi

# Install skills without the Codex SessionStart hook.
if [[ ! -f "$HOME/.agents/skills/caveman/SKILL.md" && ! -f "$CODEX_HOME/skills/caveman/SKILL.md" ]]; then
  npx -y "github:JuliusBrussee/caveman#${CAVEMAN_REF}" -- --only codex --no-hooks --non-interactive
else
  echo '[SKIP] Caveman skill already present.'
fi

# --no-hooks does NOT remove a previously installed hook. Remove only the known
# Caveman installer SessionStart command, preserving all unrelated hooks.
HOOKS_JSON="$CODEX_HOME/hooks.json" node <<'JS'
const fs = require('fs');
const file = process.env.HOOKS_JSON;
if (!fs.existsSync(file)) process.exit(0);
const original = fs.readFileSync(file, 'utf8');
let config;
try { config = JSON.parse(original); }
catch (e) { console.error(`[ERROR] Invalid JSON in ${file}; hook cleanup aborted: ${e.message}`); process.exit(1); }
const groups = config?.hooks?.SessionStart;
if (!Array.isArray(groups)) process.exit(0);
let removed = 0;
const isCaveman = h => typeof h?.command === 'string' &&
  /caveman[\\/]hooks[\\/]codex-sessionstart\.js/.test(h.command);
const kept = groups.map(group => {
  if (!Array.isArray(group?.hooks)) return group;
  const hooks = group.hooks.filter(h => {
    if (isCaveman(h)) { removed++; return false; }
    return true;
  });
  return { ...group, hooks };
}).filter(group => !Array.isArray(group?.hooks) || group.hooks.length > 0);
if (removed) {
  config.hooks.SessionStart = kept;
  if (!kept.length) delete config.hooks.SessionStart;
  if (!Object.keys(config.hooks).length) delete config.hooks;
  const backup = file + '.before-codex-rig-token-tools.bak';
  if (!fs.existsSync(backup)) fs.writeFileSync(backup, original, { flag:'wx' });
  fs.writeFileSync(file, JSON.stringify(config, null, 2) + '\n');
  console.log(`[OK] Removed ${removed} Caveman SessionStart hook(s); backup: ${backup}`);
}
JS

# Official Codex plugin owns Ponytail's lifecycle hooks; do not copy hooks JSON.
if ! codex plugin marketplace list 2>/dev/null | grep -i 'ponytail' >/dev/null; then
  codex plugin marketplace add DietrichGebert/ponytail
else
  echo '[SKIP] Ponytail marketplace already registered.'
fi
if ! codex plugin list 2>/dev/null | grep -i 'ponytail' >/dev/null; then
  codex plugin add ponytail@ponytail
else
  echo '[SKIP] Ponytail plugin already installed.'
fi

echo '[OK] Restart Codex and use /hooks to trust Ponytail hooks.'
echo '[INFO] For input compression launch Codex with: caveman codex'
echo '[INFO] Verify only intended hooks are trusted via Codex /hooks.'
