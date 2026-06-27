## 1. Test Coverage

- [x] 1.1 Refactor property hot reload tests into CQTest classes.
- [x] 1.2 Add soft reload behavior assertions for member/global function execution.
- [x] 1.3 Add full reload tests for property addition, removal, type change, specifier flags, enum defaults, failed reload isolation, multi-class modules, and inheritance chains.

## 2. Reload Fix

- [x] 2.1 Fix simultaneous parent/child AS class full reload reparenting.
- [x] 2.2 Remove temporary diagnostic assertions and keep useful failure messages.

## 3. Verification

- [x] 3.1 Build touched hot reload/runtime/test files.
- [x] 3.2 Run soft reload property prefix.
- [x] 3.3 Run full reload property prefix.
- [x] 3.4 Run diff hygiene checks.
