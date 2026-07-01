## 1. Regression Coverage

- [x] 1.1 Add standalone delegate test for AS `USTRUCT` argument invocation
- [x] 1.2 Verify RED for the focused delegate regression
- [x] 1.3 Keep broad hot reload delegate parameter coverage for AS struct reload

## 2. Investigation Record

- [x] 2.1 Record UE 5.8 fake-vtable callback ABI mismatch
- [x] 2.2 Record discarded null-buffer and pure shell-construction hypotheses

## 3. Runtime Fix

- [x] 3.1 Add AS struct value owner/header storage
- [x] 3.2 Shift AS struct property offsets for the header
- [x] 3.3 Adapt fake-vtable callbacks to Unreal callback signatures
- [x] 3.4 Construct `asCScriptObject` shell before AS constructor logic
- [x] 3.5 Preserve copy/destruct/identical/hash behavior for initialized AS struct values
- [x] 3.6 Remove temporary diagnostic logs

## 4. Documentation

- [x] 4.1 Record the crash cause and regression-test rule in `Documents/UnitTest/UnitTest.md`

## 5. Verification

- [x] 5.1 Run runtime build after source changes
- [x] 5.2 Run focused standalone delegate regression prefix
- [x] 5.3 Run hot reload delegate parameter prefix
