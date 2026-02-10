# Git Hooks

This directory contains git hooks for the project.

## Setup

To enable these hooks, run:

```bash
git config core.hooksPath .githooks
```

## Available Hooks

### pre-push

Runs shellcheck on all bash scripts before pushing. This ensures code quality and prevents shellcheck warnings from reaching CI/CD.

**What it does:**
- Finds all `.sh` files and scripts in `bin/`
- Runs shellcheck on each file
- Blocks push if any issues are found

**To test manually:**
```bash
.githooks/pre-push
```
