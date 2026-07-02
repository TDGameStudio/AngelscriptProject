## Bindings And Coverage Responsibility Boundary

This change is not trying to turn `AngelscriptTest/Bindings` into the authoritative coverage matrix. The project already has `AngelscriptTest/Coverage`, backed by OpenSpec `test-coverage`, for large matrix coverage across language features, AS type behavior, function/property/expression paths, UObject semantics, and cross-feature combinations.

## Current Split

`Coverage/` is the matrix layer:

- It owns the broad scenario inventory and status tracking through `openspec/changes/test-coverage/coverage-matrix.md` and `matrices/*.md`.
- It is organized around AS language and feature behavior: basic types, math structs, containers, object references, UCLASS/USTRUCT/UFUNCTION/UENUM, delegates, control flow, components, input, physics, widgets, networking, assets, debug/logging, and misc systems.
- Its rows are concrete behavioral scenarios with a corresponding `TEST_METHOD`, including positive paths, negative/fork boundaries, cross-feature combinations, and regression assertions.
- It can be exhaustive or near-exhaustive where the fork needs confidence around semantic behavior.

`Bindings/` is the binding-surface contract layer:

- It should answer: "Is this manually/default-bound class, function, method, property, operator, or namespace entry visible to AS, callable through the expected declaration, and wired to the intended native path?"
- It may use representative values and native parity checks, but it should not grow into every edge case, parameter combination, expression mode, lifecycle path, or feature matrix row.
- It is the right place for narrow binding regressions: missing manual bind, wrong declaration, wrong overload selected, reflective fallback/cache dispatch broken, namespace/static function not exposed, operator missing, exception path exposed incorrectly, or native entrypoint no longer callable from AS.
- It is not the right place for large semantic matrices once the binding entrypoint is proven; those belong in `Coverage/`.

## Practical Routing Rule

Add or keep a test in `Bindings/` when the primary question is whether an AS-visible binding exists and can be invoked through its exposed signature.

Add or move a test to `Coverage/` when the primary question is behavior saturation: many combinations, many language positions, many runtime states, cross-feature interaction, lifecycle/world behavior, or a coverage-gap row that should be tracked in the matrix.

When a scenario contains both concerns, keep a small Bindings smoke/contract test for the exposed entrypoint and put deeper semantic expansion in Coverage.

## Impact On This Refactor

The current layout refactor still preserves the existing Bindings tests and verifies the prefix passes. The strategic goal is narrower than "make Bindings a full coverage suite": normalize structure and inline AS formatting now, then use the new boundary to prevent future Bindings growth from duplicating `Coverage/`.

Future cleanup can use this record to identify oversized Bindings tests whose semantic sections should be split or moved into `Coverage/`, while retaining small entrypoint checks in `Bindings/`.
