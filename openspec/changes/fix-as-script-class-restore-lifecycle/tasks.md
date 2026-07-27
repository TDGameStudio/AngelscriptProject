## 1. Hunk and Lifecycle Inventory

- [x] 1.1 Map builder/compiler special-member, restore-layout, context-cleanup, script-object, allocation, and raw-registry hunks. The current production-hunk record assigns all 56 lifecycle hunks here without file-level inference.
- [x] 1.2 Define fresh-versus-restored metadata and lifecycle oracles: exact size/alignment/property declarations and offsets, source/destination execution values, retained/released predecessor modes, cleanup stages, module lookup removal, engine destruction, and post-teardown allocation.

## 2. Focused Regression Coverage

- [x] 2.1 Add base/derived/value-member save-load layout equivalence tests for predecessor-released and predecessor-retained workflows in `PredecessorRetentionBySaveLoadLifecycle`.
- [x] 2.2 Add constructor/member/base partial-failure and exceptional-destructor cleanup tests with exact event order through Constructor Failure and Destructor PartialConstruction products.
- [x] 2.3 Add raw object refcount/free/engine-teardown isolation tests and post-teardown controls. The enabled owner records the current-fork outstanding-object shutdown limitation and proves registry removal plus an independent successor engine; it does not fabricate unsupported shutdown destruction.
  - [x] 2.3.1 Cover public SDK retain/release for constructed, copied, assigned/uninitialized raw script objects with exact destructor counts and module-discard no-repeat assertions.
  - [x] 2.3.2 Add wrong-TypeInfo no-op and destructor-time retain/release coverage, including one destructor call across resurrection and later final free.
  - [x] 2.3.3 Retain a derived-to-base virtual-dispatch regression that proves the static base view keeps the registered dynamic raw object alive; keep the unrelated-TypeInfo public control green.

## 3. Runtime Repair

- [x] 3.1 Rebuild restored layouts in validated base-before-derived dependency order and reject unresolved/inconsistent layouts before publication.
- [x] 3.2 Preserve special-member, parameter-offset, inherited-property, and member-initialization behavior through version-2 restore.
- [x] 3.3 Repair exceptional destructor cleanup and raw object registry containment while retaining the separately recorded outstanding-object engine-shutdown limitation.
  - [x] 3.3.1 Bridge public `AddRefScriptObject` / `ReleaseScriptObject` to the exact registered raw-object ownership entry and destroy/free only on the final release.
  - [x] 3.3.2 Unify public, interpreter, and StaticJIT raw release through registered-TypeInfo lifecycle transitions with destructor-in-progress and destructor-called state.
  - [x] 3.3.3 Resolve the registered dynamic TypeInfo for raw transitions, accept only exact/base/interface-compatible static types, and invoke final destruction through the dynamic type.

## 4. Verification

- [x] 4.1 Run layout/lifecycle static reconciliation before building.
- [x] 4.2 Build the coherent batch once and batch compile repairs.
- [x] 4.3 Run focused Module, Constructors, Destructors, Runtime, Conformance, and full SDK prefixes with teardown evidence.
