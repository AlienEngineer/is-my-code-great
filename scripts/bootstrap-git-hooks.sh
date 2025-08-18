# Your repo bootstrap stays the same (already provided earlier):
# scripts/bootstrap-git-hooks.sh
#!/usr/bin/env bash
set -euo pipefail
git rev-parse --is-inside-work-tree >/dev/null 2>&1
git config core.hooksPath .githooks
mkdir -p .githooks
if [[ ! -f .githooks/pre-push ]]; then
  cat > .githooks/pre-push <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail
git fetch origin --quiet
default_main="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/@@' || true)"
default_main="${default_main:-main}"
local_branch="$(git rev-parse --abbrev-ref HEAD)"
[[ "$local_branch" == "$default_main" ]] && exit 0
if git diff --name-only "origin/${default_main}"...HEAD | grep -qx "VERSION"; then
  echo "✅ VERSION changed vs ${default_main}."
  exit 0
fi
echo "❌ VERSION must be updated vs ${default_main} before pushing."
exit 1
HOOK
fi
chmod +x .githooks/pre-push
echo "Git hooks bootstrapped."
