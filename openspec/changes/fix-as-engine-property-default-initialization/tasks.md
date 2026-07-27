## 1. Property Inventory

- [x] 1.1 Reconcile every engine-property field with constructor initialization and documented fork default.
- [x] 1.2 Confirm `typeCheckSwitchEnums=false` against current-fork behavior.

## 2. Regression Coverage

- [x] 2.1 Retain table-driven Bare/Fork profile coverage for baseline, both applied values, restore, and independent engines.
- [x] 2.2 Retain the isolated regression proving the prior uninitialized baseline failure.

## 3. Runtime Repair

- [x] 3.1 Explicitly initialize `typeCheckSwitchEnums` in `asCScriptEngine`.
- [x] 3.2 Resolve any additional constructor omissions found by the inventory without changing intended defaults.

## 4. Verification

- [x] 4.1 Run static property reconciliation before building.
- [x] 4.2 Build the coherent parent stage once and run focused Engine property/profile/isolation tests.
- [x] 4.3 Run the full SDK prefix and record exact report, duration, shutdown, and crash state.
