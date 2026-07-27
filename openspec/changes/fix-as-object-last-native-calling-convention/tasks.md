## 1. Contract Inventory

- [x] 1.1 Map supported caller/signature/object-position combinations and all 34 affected production hunks across callfunc, compiler, context, restore, and StaticJIT. `supported-contract.md` names every supported/rejected shape and exact owner.
- [x] 1.2 Record current-fork rejected combinations and stable diagnostics.
  - [x] Write the current-fork supported/rejected source contract.
  - [x] Confirm every declared shape through the coherent build and focused runs.

## 2. Focused Regression Coverage

- [x] 2.1 Add sentinel object/argument/return tests across default, scalar, wide, multi-argument, copy, destructor, external-method, return-storage, and generated-AOT object-last shapes.
- [x] 2.2 Add missing/invalid-caller, native-exception, cleanup, context-reuse, and independent-engine isolation tests.
- [x] 2.3 Add compatible destination-engine save/load call-identity tests with exact active-engine and native-caller observations.
  - [x] Write the focused source owners and printable fixtures.
  - [x] Prove the focused owners through fresh execution.

## 3. Runtime Repair

- [x] 3.1 Align callfunc registration/preparation with compiler emission, including explicit-argument object-last placement and moved generic by-value ownership.
- [x] 3.2 Align context dispatch/cleanup with the same stack and caller contract for return storage, normal completion, exception, reuse, no-count implicit handles, and generated execution.
- [x] 3.3 Align native-call stream translation with the linked persistence contract.
  - [x] Reconcile the source paths and add direct regression owners.
  - [x] Exclude no-count implicit handles from generic ownership cleanup and guard missing release.
  - [x] Confirm counted implicit-handle cleanup remains green.

## 4. Verification

- [x] 4.1 Run static signature/opcode reconciliation before building.
  - [x] Record the source-level caller/opcode reconciliation.
- [x] 4.2 Build the coherent batch once and batch compile repairs.
- [x] 4.3 Run focused Embedding, Runtime, Module, and full SDK prefixes and record ABI/cleanup evidence.
