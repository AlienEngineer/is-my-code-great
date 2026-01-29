# 🚀 START HERE: Bash Expert Agent Setup

> You've been set up with a **Bash Expert Copilot Agent** specialized for the is-my-code-great project.

---

## What You Have

A complete knowledge base for a Copilot agent that specializes in:
- 🚀 **High-performance bash** script writing
- 🏗️ **Maintainable architecture** for shell code
- 🔒 **Safety-first** approach to scripting
- ⚡ **Performance optimization** with profiling
- 🎯 **Multi-language support** (Dart, C#, Node.js)

---

## 📁 Your Files (in `.github/`)

| File | Size | Purpose |
|------|------|---------|
| **BASH_EXPERT_AGENT.md** | 13 KB | Full agent system prompt (main config) |
| **BASH_EXPERT_QUICK_REFERENCE.md** | 6.5 KB | Fast lookup card (when you're in a hurry) |
| **bash-expert-guidelines.md** | 16 KB | Deep technical reference |
| **copilot-instructions.md** | 5.5 KB | Project overview for any Copilot session |
| **AGENT_DIRECTORY.md** | 8 KB | Navigation guide to all files |
| **START_HERE.md** | ← You are here | Quick orientation |

---

## 🎯 Pick Your Path

### 🏃 I'm in a hurry (5 minutes)
1. Read: **BASH_EXPERT_QUICK_REFERENCE.md**
2. Use: Copy code templates as needed
3. Done!

### 📚 I want to understand the project (20 minutes)
1. Read: **copilot-instructions.md** (project overview)
2. Read: **BASH_EXPERT_QUICK_REFERENCE.md** (patterns)
3. Reference: **bash-expert-guidelines.md** (when needed)
4. Navigate: Use **AGENT_DIRECTORY.md** for "where's the answer"

### 🧙‍♂️ I'm configuring a Copilot Agent (30 minutes)
1. Read: **AGENT_DIRECTORY.md** (understand the system)
2. Use: **BASH_EXPERT_AGENT.md** as your agent prompt
3. Keep: **BASH_EXPERT_QUICK_REFERENCE.md** as supplementary
4. Reference: Others as deep dives

### 🔬 I'm doing deep work on validations (45+ minutes)
1. Start: **BASH_EXPERT_AGENT.md** (understand the mission)
2. Study: **bash-expert-guidelines.md** (all the patterns)
3. Example: Check `lib/validations/dart/` for real code
4. Reference: **BASH_EXPERT_QUICK_REFERENCE.md** for quick lookups
5. Navigate: **AGENT_DIRECTORY.md** for "how do I..."

---

## 🤖 Using With Copilot

### Method 1: Copy-Paste the Agent Prompt
```
Copy the entire content of BASH_EXPERT_AGENT.md
Paste into Copilot Chat or VSCode Custom Instructions
Then make your request
```

### Method 2: Reference the Files
```
"I'm working on a bash script for is-my-code-great.
Please follow the guidelines in:
- .github/BASH_EXPERT_AGENT.md (core approach)
- .github/BASH_EXPERT_QUICK_REFERENCE.md (common patterns)

My task: [your request]"
```

### Method 3: Ask for Navigation
```
"I need to add a new validation for Dart.
Reference: AGENT_DIRECTORY.md
What should I read first?"
```

---

## 🎯 The Agent's Core Mission

The Bash Expert Agent optimizes code for this project's unique needs:

✅ **Performance**: Handle 10,000 files efficiently  
✅ **Maintainability**: Code anyone can understand  
✅ **Safety**: Proper error handling always  
✅ **Multi-language**: Dart, C#, Node.js patterns  
✅ **Quality**: Testing before scaling  

---

## 💡 Key Insights About This Project

### Architecture
```
lib/core/            ← Shared utilities (files, git, builder)
lib/validations/     ← Where validations are added
lib/core/{framework}/← Framework configs (patterns, extensions)
examples/            ← Test data to validate against
```

### Total Validations
- **Dart**: 9 validations (most comprehensive, Flutter focus)
- **C#**: 4 validations (.NET testing)
- **Node**: 3 validations (minimal)
- **Agnostic**: 1 validation (Law of Demeter)

### Core Systems
| What | File | Does |
|------|------|------|
| Register validations | `lib/core/builder.sh` | Executes and tracks checks |
| Framework detection | `lib/core/framework-detect.sh` | Identifies Dart/C#/Node |
| File handling | `lib/core/files.sh` | Caches & paginate files |
| Text searching | `lib/core/text-finders.sh` | Grep/AWK helpers |
| Git operations | `lib/core/git_diff.sh` | Branch comparison |

---

## 🚀 Common Tasks

### "I want to add a new Dart validation"
1. Read: **bash-expert-guidelines.md** → "Adding New Validations" section
2. Template: Copy the validation template
3. Register: Call `register_test_validation()`
4. Test: Run `./test/validate_results.sh dart`

### "I need to optimize this script"
1. Read: **BASH_EXPERT_AGENT.md** → "Performance Standards" section
2. Check: **BASH_EXPERT_QUICK_REFERENCE.md** → Performance checklist
3. Profile: Add timing, measure improvements
4. Reference: **bash-expert-guidelines.md** → Performance Considerations

### "This looks slow, how do I debug it?"
1. Check: **BASH_EXPERT_QUICK_REFERENCE.md** → Debugging one-liners
2. Run: `./bin/is-my-code-great -v /path` (verbose mode)
3. Study: **bash-expert-guidelines.md** → Debugging Checklist
4. Measure: Add timing instrumentation

### "What's the pattern for this?"
1. Check: **BASH_EXPERT_QUICK_REFERENCE.md** (maybe 30 seconds)
2. If not there → **bash-expert-guidelines.md** (search for keyword)
3. If still stuck → **AGENT_DIRECTORY.md** (navigation help)

---

## ✅ Your Checklist

When using the Bash Expert Agent, verify:

- [ ] Reading from the right guide for your task
- [ ] Using established patterns from quick-reference
- [ ] Profiling before optimizing
- [ ] Quoting all variables
- [ ] Checking exit codes
- [ ] Handling edge cases (spaces in filenames)
- [ ] Testing with examples first
- [ ] Adding timing for slow operations

---

## 🆘 If You Get Stuck

**"I need to find something quickly"**
→ Use **AGENT_DIRECTORY.md** table: "I want to... read this"

**"I don't know where to start"**
→ Read **BASH_EXPERT_QUICK_REFERENCE.md** (it's designed to be quick)

**"I need deep technical understanding"**
→ Read **bash-expert-guidelines.md** sections in order

**"I'm debugging something strange"**
→ Check **bash-expert-guidelines.md** → "Common Gotchas & Solutions"

**"I want to understand the whole project"**
→ Start with **copilot-instructions.md** → Architecture section

---

## 🎓 Suggested Learning Order

1. **5 min**: This file (you're reading it!)
2. **5 min**: **BASH_EXPERT_QUICK_REFERENCE.md**
3. **10 min**: **copilot-instructions.md** → Commands & Architecture
4. **20 min**: **bash-expert-guidelines.md** → Core Patterns section
5. **As needed**: Refer to specific sections for deep work

Total time: ~40 minutes to be dangerous, 2 hours to be proficient

---

## 🧙‍♂️ Remember

This agent is designed to make you **fast AND safe**:
- ⚡ Fast: Optimized patterns, no unnecessary subshells
- 🛡️ Safe: Proper quoting, error handling, edge cases
- 📚 Smart: Understands why something is done a certain way
- 🧠 Maintainable: Code that's clear to the next developer

---

## Next Steps

### Right Now
Pick your path above and start reading the appropriate file.

### When You're Ready to Code
Reference **BASH_EXPERT_AGENT.md** or use Quick Reference as you work.

### When You Hit a Problem
Check the **AGENT_DIRECTORY.md** for "where do I find answers"

---

**Good luck! Write bash that would make a Unix wizard proud.** 🧙‍♂️✨

---

*Last updated: January 29, 2026*  
*For: is-my-code-great project*  
*Agent: Bash Expert Specialist*
