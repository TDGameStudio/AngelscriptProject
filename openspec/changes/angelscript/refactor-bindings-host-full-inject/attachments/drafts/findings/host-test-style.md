# Host test style (2026-09-16)

User: the previous Host tests were too compact; later code should not be written that way.

## What they look like now

Typical `RuntimeBindingHostCoreTests.cpp` / `HostProductionTests.cpp` problems:

- One `TEST_METHOD` builds a Collection, Finalizes, ExecuteToHost, finds methods, calls native, accounts, and injects two engines.
- Assertions and locals sit in one block with no scene breaks.
- Family ledger tables share a file and method family with real calls.

That was a 21-node serial proof, not a later template.

## How to write next

- One method proves one thing: build a freeze, inject, call, fail a boundary, or account — separately.
- Blank lines between arrange, act, and assert.
- Shared fixtures are allowed; do not hide the whole story in a helper and then stack another layer in the method.
- When a short `.as` can prove "after inject it compiles and runs", use `ASTEST_AS`. Do not hand-write `void*` argument buffers unless the case is the ABI.
- When retiring old Store tests, do not copy their one-line multi-assert style.

This is the authoring convention for `host-bind-completion` tests. Do not rewrite archived Host files unless this Change migrates them and splits them along the way.

Post-bind compile/call for production `TArray` / `FString` / `FVector` / `Print` lives under `AngelscriptTest/Temp`, one method per scene, with bind-log assertions. Do not treat packed Host* pointer calls as that oracle.
