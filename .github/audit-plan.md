# Implementation Plan: Fixing Audit Findings for is-my-code-great

## Plan Overview

**Approach:** Incremental refactoring with Critical + High severity issues
**Breaking Changes:** Internal APIs can break; CLI interface remains stable
**Testing Strategy:** Add unit tests as we go; keep existing integration tests
**Timeline:** Phased by weeks (4-week sprint)
**Dependencies:** Add `shellcheck` and `bats-core` for quality and testing

---

## Week 1: Foundation & Critical Safety Issues

### Phase 1.1: Error Handling Infrastructure
- [x] **Create comprehensive unit tests (TDD approach)**
  - [x] `test/unit/test_helper.bash` - Shared test utilities
  - [x] `test/unit/test_errors.bats` - Tests for error handling functions
  - [x] `test/unit/test_strict_mode.bats` - Tests for strict mode integration
  - [x] `test/unit/test_phase1_integration.bats` - Integration tests
  - [x] `test/unit/run_tests.sh` - Test runner script
  - [x] `test/unit/README.md` - Testing documentation
  - [x] `test/unit/setup.sh` - Test infrastructure setup
- [x] Add `set -euo pipefail` to all bash scripts
  - [x] `bin/is-my-code-great`
  - [x] `lib/analysis.sh`
  - [x] All `lib/core/*.sh` files (14 files)
  - [x] All `lib/validations/*/*.sh` files (23 files)
- [x] Create error handling utility: `lib/core/errors.sh`
  - [x] `die()` function for fatal errors with cleanup
  - [x] `warn()` function for non-fatal warnings
  - [x] `debug()` function for verbose logging
  - [x] Trap handlers for EXIT, ERR, INT signals
- [x] Test each script individually to catch break points
- [x] Fix any issues that surface from strict mode (builder.sh array initialization)

**Testing:**
- [x] Unit test infrastructure with bats-core
- [x] Run existing integration tests after each file update (all passing)
- [ ] Unskip and pass remaining unit tests as needed

**Deliverable:** ✅ All scripts have proper error handling; existing tests pass

### Phase 1.2: Remove Security Vulnerability
- [x] Refactor `lib/core/builder.sh` to remove `eval`
  - [x] Change validation registration to store function names
  - [x] Use direct function invocation: `"$command"` instead of `eval "$command"`
  - [x] Verify all validations still execute correctly
- [x] Add input sanitization for validation function names
- [x] Update documentation on validation registration

**Testing:**
- [x] Create unit test for `register_validation` function
- [x] Verify all 22 existing validation scripts still work
- [x] Run full test suite for all frameworks (dart, csharp, node)

**Deliverable:** ✅ No `eval` usage; validation system secure

### Phase 1.3: Setup Testing Infrastructure
- [x] Install `bats-core` (Bash Automated Testing System)
- [x] Create test directory structure: `test/unit/`
- [x] Setup test helpers: `test/test_helper.bash`
  - [x] Mock functions for file operations
  - [x] Assertion helpers
  - [x] Test fixtures
- [x] Add `shellcheck` to CI pipeline
  - [x] Update `.github/workflows/validate_pr.yml`
  - [x] Configure shellcheck rules (`.shellcheckrc`)
  - [x] Fix immediate shellcheck warnings

**Testing:**
- [x] Create first unit test example (test the error handling utilities)
- [x] Verify shellcheck runs in CI

**Deliverable:** ✅ Testing infrastructure ready; CI includes shellcheck

---

## Week 2: Eliminate Code Duplication & Fix `cd` Hell

### Phase 2.1: DRY Refactor - Text Finders
- [ ] Refactor `lib/core/text-finders.sh`
  - [ ] Extract common logic: `_sum_results(file_getter, flags, pattern)`
  - [ ] Simplify `sum_test_results()` and `sum_code_results()`
  - [ ] Remove duplication between `find_text_*` and `find_regex_*` functions
- [ ] Create constants file: `lib/core/constants.sh`
  - [ ] Define `readonly PAGINATION_SIZE=200`
  - [ ] Define `readonly MAX_TEST_LINES=15`
  - [ ] Move other magic numbers to constants

**Testing:**
- [ ] Unit tests for `_sum_results` with mocked file lists
- [ ] Unit tests for edge cases (empty results, large files)
- [ ] Integration tests still pass

**Deliverable:** 50% less code in text-finders.sh; constants file created

### Phase 2.2: Fix Git Operations
- [ ] Refactor `lib/core/git_diff.sh` to eliminate `cd` usage
  - [ ] Replace all `cd` with `git -C "$DIR"` flag
  - [ ] Remove `original_dir` tracking
  - [ ] Simplify `get_git_test_files()` and `get_git_files()`
  - [ ] Extract common git operations to helper functions
- [ ] Improve error messages for git failures
- [ ] Add validation that `$DIR` is within a git repository

**Testing:**
- [ ] Unit tests for git validation functions
- [ ] Test behavior when not in git repo
- [ ] Test behavior with invalid branch names
- [ ] Integration tests with actual git operations

**Deliverable:** Zero `cd` usage; git operations atomic and safe

### Phase 2.3: Extract Inline AWK Scripts
- [ ] Create `lib/awk/` directory
- [ ] Extract AWK from `lib/validations/dart/big-test-files.sh`
  - [ ] Create `lib/awk/find_big_functions.awk`
  - [ ] Update validation to use external AWK file
  - [ ] Add comments to AWK script for maintainability
- [ ] Extract other complex AWK scripts similarly
- [ ] Document AWK script inputs/outputs

**Testing:**
- [ ] Test AWK scripts independently with sample input
- [ ] Verify validation results unchanged
- [ ] Integration tests pass

**Deliverable:** AWK scripts extracted to separate files; maintainable and testable

---

## Week 3: Reduce Global State & Improve Architecture

### Phase 3.1: Refactor Global Variables
- [ ] Create configuration object approach
  - [ ] Create `lib/core/config.sh` with config management
  - [ ] Define `init_config()` to set defaults
  - [ ] Define `get_config(key)` and `set_config(key, value)`
  - [ ] Use associative array for config storage
- [ ] Refactor core modules to accept config as parameter
  - [ ] Update `lib/core/files.sh` functions to accept config
  - [ ] Update `lib/core/git_diff.sh` functions to accept config
  - [ ] Update `lib/core/text-finders.sh` functions to accept config
- [ ] Update validation registration to pass config

**Testing:**
- [ ] Unit tests for config management
- [ ] Test config isolation (multiple configs don't interfere)
- [ ] Integration tests verify config propagation

**Deliverable:** Config object replaces exported globals; functions testable

### Phase 3.2: Break Up God Function
- [ ] Refactor `run_analysis()` in `lib/analysis.sh`
  - [ ] Extract: `source_framework_config(framework)`
  - [ ] Extract: `source_core_utilities()`
  - [ ] Extract: `load_validations(framework)`
  - [ ] Extract: `execute_validations(config)`
  - [ ] Extract: `report_results(parseable)`
  - [ ] Main function orchestrates these steps
- [ ] Each function is independently testable
- [ ] Add proper error handling to each step

**Testing:**
- [ ] Unit test each extracted function with mocks
- [ ] Integration test full analysis pipeline
- [ ] Test error paths (missing framework, failed validations)

**Deliverable:** `run_analysis()` is simple orchestrator; 5 testable functions

### Phase 3.3: Consistent Return Value Convention
- [ ] Document return value convention in `CONVENTIONS.md`
  - [ ] 0 = success
  - [ ] 1 = failure
  - [ ] -1 = not applicable (for validations only)
  - [ ] Functions output to stdout, errors to stderr
- [ ] Audit all functions for compliance
- [ ] Fix inconsistent return values
  - [ ] Update `lib/core/framework-detect.sh`
  - [ ] Update validation return conventions
  - [ ] Update core utility functions
- [ ] Add helper functions: `return_success()`, `return_failure()`, `return_na()`

**Testing:**
- [ ] Unit tests verify return codes
- [ ] Test stdout vs stderr output
- [ ] Integration tests check exit codes

**Deliverable:** All functions follow consistent convention; documented

---

## Week 4: Unit Tests & Code Quality

### Phase 4.1: Add Comprehensive Unit Tests
- [ ] Test coverage for `lib/core/builder.sh`
  - [ ] Test validation registration
  - [ ] Test validation execution
  - [ ] Test result collection
  - [ ] Test error handling
- [ ] Test coverage for `lib/core/files.sh`
  - [ ] Test file caching
  - [ ] Test pagination
  - [ ] Test local vs git mode
- [ ] Test coverage for `lib/core/text-finders.sh`
  - [ ] Test search functions with fixtures
  - [ ] Test detailed vs non-detailed modes
- [ ] Test coverage for `lib/core/git_diff.sh`
  - [ ] Test git validation
  - [ ] Test file diffing
  - [ ] Mock git commands
- [ ] Test coverage for `lib/core/config.sh`
  - [ ] Test config CRUD operations
  - [ ] Test config isolation

**Testing:**
- [ ] Aim for >80% coverage of core modules
- [ ] Use bats' `setup()` and `teardown()` for test isolation
- [ ] Mock external dependencies (git, find, grep)

**Deliverable:** Unit test suite with >80% coverage of core modules

### Phase 4.2: Address Medium-Severity Issues
- [ ] Delete commented-out code
  - [ ] Remove evaluation flag from `bin/is-my-code-great:33-36`
  - [ ] Scan for other commented code and remove
- [ ] Fix typos in comments
  - [ ] Fix "Souce" -> "Source" in `lib/analysis.sh:16`
  - [ ] Run spell checker on comments
- [ ] Standardize indentation
  - [ ] Create `.editorconfig`
  - [ ] Run formatter on all bash files
  - [ ] Add formatting check to CI
- [ ] Improve function naming
  - [ ] Rename `dump_summary()` to `print_summary()`
  - [ ] Review other poorly named functions
- [ ] Add early input validation
  - [ ] Validate parameters at function entry
  - [ ] Use guard clauses

**Testing:**
- [ ] Verify formatting is consistent
- [ ] Run shellcheck to catch new issues
- [ ] Integration tests still pass

**Deliverable:** Code clean, well-formatted, and professional

### Phase 4.3: Documentation & Polish
- [ ] Update `README.md` with testing instructions
- [ ] Create `CONTRIBUTING.md` with:
  - [ ] Coding standards (error handling, naming, testing)
  - [ ] How to run unit tests
  - [ ] How to add new validations
  - [ ] Pull request guidelines
- [ ] Update `.github/copilot-instructions.md`:
  - [ ] Document new config system
  - [ ] Document testing approach
  - [ ] Update architecture section
- [ ] Add inline documentation to complex functions
- [ ] Create architectural decision records (ADRs) for major changes

**Testing:**
- [ ] Review all documentation for accuracy
- [ ] Have someone else follow the CONTRIBUTING guide

**Deliverable:** Complete, accurate documentation for contributors

---

## Post-Implementation Validation

### Week 5: Integration & Validation
- [ ] Run full test suite on all platforms (macOS, Linux)
- [ ] Test as GitHub Action in sample repositories
- [ ] Performance benchmarking (before vs after)
- [ ] Code review by team
- [ ] Update VERSION and CHANGELOG
- [ ] Create release candidate

---

## Success Metrics

**Code Quality:**
- [ ] All scripts pass `shellcheck` with no warnings
- [ ] Unit test coverage >80% for core modules
- [ ] Zero `eval` usage
- [ ] Zero unhandled errors
- [ ] All functions follow return value convention

**Maintainability:**
- [ ] Code duplication reduced by >50%
- [ ] Average function length <50 lines
- [ ] All magic numbers extracted to constants
- [ ] AWK scripts in separate files

**Architecture:**
- [ ] Global state reduced by >70%
- [ ] Config object pattern implemented
- [ ] Functions accept parameters instead of reading globals
- [ ] Dependency injection pattern for core modules

**Documentation:**
- [ ] CONTRIBUTING.md created
- [ ] Coding standards documented
- [ ] Architecture decisions recorded
- [ ] Copilot instructions updated

---

## Risk Mitigation

**Risk:** Breaking existing functionality during refactor
**Mitigation:** Run integration tests after every change; maintain backwards compatibility for CLI

**Risk:** New dependencies not available in CI
**Mitigation:** Add installation steps to CI workflows; test locally first

**Risk:** Unit tests don't catch integration issues
**Mitigation:** Keep existing integration tests; add integration test for new features

**Risk:** Refactoring takes longer than estimated
**Mitigation:** Each week is independently valuable; can stop at any phase boundary

---

## Out of Scope (Future Work)

The following were in the audit but are **not** included in this plan:
- ❌ Rewriting in Go/Rust (too large a change)
- ❌ Plugin architecture for validations (needs design phase)
- ❌ Performance optimization (profile first)
- ❌ Adding more frameworks beyond dart/csharp/node
- ❌ Redesigning validation result format

These can be addressed in future sprints after the foundation is solid.

---

## Notes

- **Backwards Compatibility:** CLI interface (flags, arguments) remains stable
- **Internal APIs:** Can break; validations may need minor updates
- **Testing Philosophy:** Test behavior, not implementation
- **Code Review:** Each week's work should be reviewed before moving to next week
- **Communication:** Update team on progress and blockers weekly

---

## Appendix: Detailed Task Estimates

### Week 1 Breakdown (Critical Issues)
- Error handling infrastructure: 8 hours
- Remove eval: 4 hours
- Testing infrastructure setup: 6 hours
- **Total: ~18 hours (~3 days)**

### Week 2 Breakdown (Duplication & Git)
- DRY refactor: 6 hours
- Fix git operations: 6 hours
- Extract AWK scripts: 4 hours
- **Total: ~16 hours (~2 days)**

### Week 3 Breakdown (Architecture)
- Config object pattern: 8 hours
- Break up god function: 6 hours
- Return value consistency: 4 hours
- **Total: ~18 hours (~3 days)**

### Week 4 Breakdown (Tests & Polish)
- Comprehensive unit tests: 10 hours
- Medium-severity fixes: 4 hours
- Documentation: 4 hours
- **Total: ~18 hours (~3 days)**

**Grand Total: ~70 hours (14 working days, ~3 weeks at 50% allocation)**

---

## Getting Started

To begin implementation:

1. **Create feature branch:** `git checkout -b refactor/audit-fixes`
2. **Start with Week 1, Phase 1.1:** Error handling
3. **Commit frequently:** Small, atomic commits
4. **Run tests after each change:** Catch regressions early
5. **Ask for help when stuck:** Don't waste time on blockers

Let's make this code great! 🚀
