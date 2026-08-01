# Phase 04 compile-only template adapters

Status: passed for promoted adapters.

The final external-consumer, Release-package, regression, and path-scope
reconciliation is recorded in `v1-closeout-20260801.md`; that record is the
current authority for counts and hashes.

The registry validates adapter ID, version, trait schema, engine properties,
and registration-surface hash before compilation. Trait derivation remains
explicit and fail-closed. Layouts are deterministic compile layouts marked
`non-ue-abi`; every behavior is a generic trap.

Promoted compile-only families:

- `TArray` and mutable/const iterators;
- `TMap`, `TSet`, and iterators;
- `TOptional`;
- `TObjectPtr`, `TWeakObjectPtr`, `TSoftObjectPtr`, `TSubclassOf`, and
  `TSoftClassPtr`;
- exported nested-template policy and recorded exception handling.

Evidence:

- `AngelscriptStandalone.Adapters`: passed in the final suite;
- `AngelscriptStandalone.UEAnalysis`: passed;
- project-v6 adapter matrix, Array/Map examples, object-handle key and iterator
  regressions: complete;
- UE Compiler `81/81`;
- UE Bindings `244/244`,
  `Saved/Tests/standalone-final-bindings-v7/20260731_092805_332_54fd5986`;
- final architecture scan proves no container bind branch and no Unreal
  container/property/GC source enters standalone.

These adapters validate compilation only; no UE container ABI or behavior is
emulated.
