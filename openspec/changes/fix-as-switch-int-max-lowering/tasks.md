## 1. Ownership and Existing Source

- [x] 1.1 <!-- Non-TDD --> Record P066-P069 as the complete production hunk set under `asCCompiler::CompileSwitchStatement()`.
- [x] 1.2 <!-- Non-TDD --> Confirm the current source widens both range heuristics, the dense-loop counter, and its case comparison without changing script-visible selector width.
- [x] 1.3 <!-- Non-TDD --> Name `FSwitchTests::SelectorsByCaseAndExit` / `LANG-CF-SWITCH` as the regression owner and retain the three exact high-end controls.

## 2. Rollback Boundary

- [x] 2.1 <!-- Non-TDD --> Record P066-P069 and the `INT_MAX`-adjacent execution controls as one indivisible rollback unit.
- [x] 2.2 <!-- Non-TDD --> Exclude parser syntax, duplicate-case diagnostics, interpreter dispatch, and unrelated optimizer cleanup.

## 3. Fresh Verification

- [x] 3.1 <!-- Non-TDD --> Run the exact coherent build command in `verification.md` and record metadata, exit codes, warnings, and errors.
- [x] 3.2 <!-- Non-TDD --> Run the exact Switch prefix and require the `INT_MAX - 5`, `INT_MAX - 4`, and dense-through-`INT_MAX` sources to compile, terminate, and select correctly.
- [x] 3.3 <!-- Non-TDD --> Run the ControlFlow parent and record terminal totals, source visibility, shutdown, and crash/timeout state.
- [x] 3.4 <!-- Non-TDD --> Run the complete SDK prefix and record terminal totals without inferring success from the focused owner.
- [x] 3.5 <!-- Non-TDD --> Run strict OpenSpec validation plus scoped parent/plugin whitespace checks and append fresh outputs to `verification.md`.
