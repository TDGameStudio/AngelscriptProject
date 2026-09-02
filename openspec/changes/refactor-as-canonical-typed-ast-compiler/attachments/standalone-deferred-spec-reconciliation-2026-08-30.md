# Standalone deferred scope reconciliation (2026-08-30)

## Finding

The task graph and current design decisions already excluded Standalone host
adaptation and Standalone Debug/Release verification from the completion gate
for this change:

- Task 10.1 limits cutover publishers to in-scope UE source-build purposes and
  explicitly defers Standalone.
- Task 10.2 explicitly excludes Standalone from the default transition.
- Task 13.12 explicitly excludes Standalone from the final rerun.
- CTA-S53 and later gate records repeatedly state that Standalone is not part
  of their completion boundary.

However, two delta-spec requirements still contradicted that decision:

1. `as-canonical-compiler-pipeline` required every active Standalone fixture
   before CANONICAL could become default and required a Standalone host to use
   the completed compiler.
2. `as-static-jit-aot-test` required Standalone Debug/Release in the final
   cutover gate.

That contradiction made completion unprovable: following the task graph would
leave a spec requirement unmet, while following the stale spec would silently
reintroduce work that the user explicitly moved to a later Standalone
refactor.

## Resolution

The delta specs, proposal impact, and design goals/migration plan now use one
scope boundary:

- This change must keep SourceManager, Parser, Sema, ASTContext, verifier, DTO,
  and Bytecode CodeGen standard C++ and free of Unreal/Clang/LLVM dependencies.
- The UE Runtime must consume that maintained compiler through its host
  bridges.
- Standalone host adaptation, refactoring, and final Debug/Release verification
  belong to a separate future OpenSpec.
- Existing historical Standalone implementation and green evidence remain in
  the record; they are neither deleted nor promoted into a current cutover or
  archive gate.

This is a scope reconciliation only. It changes no Runtime/compiler source,
does not weaken the in-scope UE/SDK/Script/Hot Reload/StaticJIT/Cache-boundary
gates, and does not authorize Unreal dependencies in the maintained frontend.

## Files reconciled

- `specs/as-canonical-compiler-pipeline/spec.md`
- `specs/as-static-jit-aot-test/spec.md`
- `design.md`
- `proposal.md`

## Completion consequence

Future completion accounting for this OpenSpec must not count a missing or
stale Standalone adapter/run as a blocker. It must still prove the host-neutral
source boundary and every named in-scope UE source-build purpose. Earlier
Standalone results may be cited only as historical regression evidence.

