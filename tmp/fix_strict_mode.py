#!/usr/bin/env python3
import os
import re

files = []
# Collect all files
for pattern in ['bin/is-my-code-great', 'lib/analysis.sh']:
    if os.path.exists(pattern):
        files.append(pattern)

for root, dirs, filenames in os.walk('lib/core'):
    for filename in filenames:
        if filename.endswith('.sh'):
            files.append(os.path.join(root, filename))

for root, dirs, filenames in os.walk('lib/validations'):
    for filename in filenames:
        if filename.endswith('.sh'):
            files.append(os.path.join(root, filename))

for filepath in files:
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    # Check if already has set -euo pipefail
    has_strict = any('set -euo pipefail' in line for line in lines)
    if has_strict:
        print(f"Skip (already has): {filepath}")
        continue
    
    # Find where to insert
    if lines and lines[0].startswith('#!/'):
        # Has shebang - insert after it
        lines.insert(1, 'set -euo pipefail\n')
        lines.insert(2, '\n')  # Blank line after
    else:
        # No shebang - insert at top
        lines.insert(0, 'set -euo pipefail\n')
        lines.insert(1, '\n')  # Blank line after
    
    with open(filepath, 'w') as f:
        f.writelines(lines)
    
    print(f"Fixed: {filepath}")

print(f"\nProcessed {len(files)} files")

