# Copilot Specialist Agents for is-my-code-great

This repository includes specialized agent guidelines for different types of coding work. Use these to configure Copilot agents that understand the codebase architecture, conventions, and best practices.

---

## 📋 Agent Guides Available

### 1. **Bash Expert Agent** 🧙‍♂️
**File**: `.github/BASH_EXPERT_AGENT.md`  
**Purpose**: High-performance bash script development and optimization  
**Focus Areas**:
- Performance optimization (minimize subprocesses, cache operations)
- Script structure and maintainability
- Framework-specific implementations (Dart, C#, Node)
- Safe file handling (spaces in filenames, symlinks)
- Testing and debugging bash code

**Use this when**: Writing new validations, optimizing existing scripts, debugging performance issues, adding framework support

**Key Principles**:
- Performance is non-negotiable
- Maintainability wins long-term
- Safety (proper error handling, input validation)
- Scale thoughtfully (handle 10K files efficiently)

---

### 2. **Quick Reference Card** 🎯
**File**: `.github/BASH_EXPERT_QUICK_REFERENCE.md`  
**Purpose**: Fast lookup guide for common patterns and gotchas  
**Includes**:
- Copy-paste templates for common patterns
- Do's and don'ts checklist
- Tool selection guide (find vs grep vs awk)
- Performance quick checklist
- Debugging one-liners
- Most common mistakes

**Use this when**: You need quick answers without reading full documentation

---

### 3. **Full Bash Guidelines** 📚
**File**: `.github/bash-expert-guidelines.md`  
**Purpose**: Comprehensive reference for bash patterns in this codebase  
**Includes**:
- Core architecture patterns
- All function patterns with examples
- Text processing and grep patterns
- AWK for complex parsing
- Git operations
- File operations and globbing
- Variable handling and special variables
- Performance considerations
- Testing and validation
- Adding new validations (step-by-step)
- Debugging tips
- Common gotchas and solutions

**Use this when**: Deep dive into how something works, writing complex validations, understanding edge cases

---

### 4. **Copilot Instructions** 🚀
**File**: `.github/copilot-instructions.md`  
**Purpose**: General project overview for any Copilot session  
**Includes**:
- Build, test, and lint commands
- High-level architecture overview
- Key conventions and patterns
- Testing tips

**Use this when**: Starting fresh Copilot work, needing project context

---

### 5. **Validation Comparison Table** 📊
**File**: Session workspace: `validation-comparison.md`  
**Purpose**: Complete inventory of all validations by technology  
**Includes**:
- Summary table (Dart: 9, C#: 4, Node: 3, Agnostic: 1)
- Detailed descriptions of each validation
- Analysis by category and severity
- Implementation file locations

**Use this when**: Understanding what validations exist, planning new checks

---

## 🎯 Quick Navigation

**I want to...**

| Goal | Read This |
|------|-----------|
| Configure a Bash Expert agent | BASH_EXPERT_AGENT.md |
| Find a code pattern quickly | BASH_EXPERT_QUICK_REFERENCE.md |
| Understand how something works | bash-expert-guidelines.md |
| Get project context | copilot-instructions.md |
| See what validations exist | validation-comparison.md |
| Know the project structure | copilot-instructions.md (Architecture section) |
| Debug a performance issue | BASH_EXPERT_AGENT.md (Performance Standards) |
| Add a new validation | bash-expert-guidelines.md (Adding New Validations) |
| Handle a tricky edge case | bash-expert-guidelines.md (Common Gotchas) |

---

## 🏗️ File Organization

```
.github/
├── BASH_EXPERT_AGENT.md              ← Full agent definition
├── BASH_EXPERT_QUICK_REFERENCE.md    ← Cheat sheet
├── bash-expert-guidelines.md         ← Deep reference
├── copilot-instructions.md           ← General project overview
└── AGENT_DIRECTORY.md                ← This file
```

---

## 🚀 How to Use These as Copilot Agents

### Option 1: For GitHub Copilot in VSCode
Create a `.copilot-instructions` file or use the Copilot Chat agent configuration:

```markdown
# Reference Agent Guidelines
You are a Bash Expert specializing in high-performance code quality analysis.
See .github/BASH_EXPERT_AGENT.md for full instructions.
For quick lookups, use BASH_EXPERT_QUICK_REFERENCE.md
```

### Option 2: For Copilot CLI
When starting a Copilot CLI session:
```bash
copilot agent bash-expert --instructions-file .github/BASH_EXPERT_AGENT.md
```

### Option 3: Copy into Session
Copy the agent definition directly into your Copilot chat or session:
```
Read this context: [paste BASH_EXPERT_AGENT.md]
Then: [your specific request]
```

---

## 📋 Agent Roles & Responsibilities

### Bash Expert Agent

**Writes**:
- ✅ New validations for existing frameworks
- ✅ Framework support (new language)
- ✅ Core utilities and helpers
- ✅ Performance optimizations
- ✅ Testing and debugging scripts

**Reviews**:
- ✅ Code for performance issues
- ✅ Scripts for maintainability
- ✅ Patterns for consistency
- ✅ Edge case handling

**Refuses**:
- ❌ Non-bash implementations
- ❌ Breaking existing validations
- ❌ Over-complicated "clever" solutions
- ❌ Optimization without profiling

---

## 🎓 Learning Path

1. **Start here**: BASH_EXPERT_QUICK_REFERENCE.md (5 min read)
2. **Then**: copilot-instructions.md (architecture understanding)
3. **Deep dive**: bash-expert-guidelines.md (detailed patterns)
4. **Reference**: BASH_EXPERT_AGENT.md (system prompt)
5. **See examples**: Look at `lib/validations/dart/*.sh` for patterns in action

---

## 📊 Validation Inventory (Quick Stats)

| Framework | Validations | Type |
|-----------|-------------|------|
| **Dart** | 9 | Flutter widget testing + core patterns |
| **C#** | 4 | .NET testing + coverage |
| **Node.js** | 3 | Jest/Mocha core patterns |
| **Agnostic** | 1 | Law of Demeter (all languages) |
| **TOTAL** | **17** | |

See `validation-comparison.md` for full details.

---

## 🔧 Key Systems in Codebase

| System | File | Purpose |
|--------|------|---------|
| Validation Registration | `lib/core/builder.sh` | Register and execute validations |
| Framework Detection | `lib/core/framework-detect.sh` | Auto-detect Dart/C#/Node |
| File Caching | `lib/core/files.sh` | Cache files, enable pagination |
| Text Processing | `lib/core/text-finders.sh` | Grep helpers |
| Git Integration | `lib/core/git_diff.sh` | Branch comparison |
| Verbosity | `lib/core/verbosity.sh` | Debug output |

---

## ✨ Special Notes

### Why These Documents Exist

1. **BASH_EXPERT_AGENT.md**: Trains Copilot to understand this specific project's constraints, patterns, and philosophy. It's not generic bash advice—it's specialized for high-performance code quality analysis.

2. **BASH_EXPERT_QUICK_REFERENCE.md**: Developers and Copilot need quick answers. This is the "I know where to find it" document.

3. **bash-expert-guidelines.md**: Deep reference for "why do we do it this way?" and "how does this complex thing work?"

4. **copilot-instructions.md**: Project-agnostic overview that any Copilot session should know.

### Performance Philosophy

This codebase processes thousands of files efficiently. Every pattern exists for a reason:
- **Pagination**: Don't load 10K filenames into memory
- **Caching**: Don't call `find` twice
- **Process substitution**: Don't lose variables in subshells
- **Timing instrumentation**: Can't optimize what you don't measure

---

## 🎯 Success Criteria for Using These Agents

Your Copilot agent is working well when:

✅ It understands the validation registration system  
✅ It writes code following established patterns  
✅ It catches performance anti-patterns  
✅ It handles edge cases (spaces in filenames, symlinks)  
✅ It suggests improvements that make code faster AND clearer  
✅ It refuses bad ideas gracefully with explanations  
✅ It can explain "why" something is done a certain way  

---

## 📞 Questions?

Refer to:
- **What does this pattern do?** → bash-expert-guidelines.md
- **How do I do this faster?** → BASH_EXPERT_QUICK_REFERENCE.md
- **What's the system design?** → copilot-instructions.md
- **How should I approach this?** → BASH_EXPERT_AGENT.md

---

**Created**: January 29, 2026  
**For**: Bash Expert Copilot Agent specialization  
**Focus**: Performance + Maintainability + Reliability  

🧙‍♂️ Write bash that would make a Unix wizard proud.
