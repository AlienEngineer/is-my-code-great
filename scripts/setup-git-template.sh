# OPTIONAL: org-wide auto-setup so hooks run after clone/checkout
# Run once per collaborator:
#   bash scripts/setup-git-template.sh

# scripts/setup-git-template.sh
#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_DIR="${HOME}/.git-template"
HOOKS_DIR="${TEMPLATE_DIR}/hooks"

mkdir -p "$HOOKS_DIR"

# post-checkout triggers repo bootstrap if present
cat > "${HOOKS_DIR}/post-checkout" <<'H'
#!/usr/bin/env bash
set -euo pipefail
if [[ -x "scripts/bootstrap-git-hooks.sh" ]]; then
  bash scripts/bootstrap-git-hooks.sh || true
fi
H
chmod +x "${HOOKS_DIR}/post-checkout"

# post-merge too (updates after pulling)
cat > "${HOOKS_DIR}/post-merge" <<'H'
#!/usr/bin/env bash
set -euo pipefail
if [[ -x "scripts/bootstrap-git-hooks.sh" ]]; then
  bash scripts/bootstrap-git-hooks.sh || true
fi
H
chmod +x "${HOOKS_DIR}/post-merge"

git config --global init.templateDir "$TEMPLATE_DIR"

echo "✅ Global template installed at $TEMPLATE_DIR"
echo "ℹ️  New clones will auto-run scripts/bootstrap-git-hooks.sh after checkout/merge."
