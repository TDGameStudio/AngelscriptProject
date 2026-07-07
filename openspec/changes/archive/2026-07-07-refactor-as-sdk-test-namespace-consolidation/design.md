# Design: SDK namespace consolidation boundary

## Context

`AngelScriptSDK/` tests are native SDK tests. They run on raw `asIScriptEngine` / `asCScriptEngine` helpers, not the UE-facing `FAngelscriptEngine` layer. That makes them good for compiler-core, parser, bytecode, native execution, and bare-engine behavior, but it also creates a real boundary for behavior that depends on UE wrapper registrations.

The original change record mixed two different scopes:

- a structural refactor: helper consolidation, `_Private` namespace removal, and `ASSDK` to `SDK` naming cleanup;
- a behavior expansion roadmap: object lifetime, OOP polymorphism, string runtime, array/container semantics, suspend/resume, Thiscall, and related semantic coverage.

The current plugin state supports closing the structural refactor, but not the broad behavior roadmap. The OpenSpec record should reflect that split.

## Goals / Non-Goals

**Goals:**

- Make this OpenSpec closeable by matching the current plugin code state.
- Keep the structural SDK cleanup as the scope of this change.
- Preserve audit evidence for remaining SDK behavior gaps without representing them as unfinished tasks in this refactor.
- Record the bare-engine boundary so future work chooses the right test layer.

**Non-Goals:**

- Do not implement new SDK behavior tests in this change record cleanup.
- Do not migrate raw SDK tests to the UE wrapper layer.
- Do not claim a fresh SDK test pass without a clean current `Tools\RunTests.ps1` result.
- Do not treat documentation prose references to "ASSDK/raw SDK" as source-level namespace failures.

## Decisions

### Keep this change structural

The namespace/helper/naming cleanup is a coherent refactor. It has source-level evidence in the current plugin tree: no `AngelscriptTest_*_Private` namespaces remain in the SDK test directory, source/automation `ASSDK` naming residues are gone from SDK code, and shared support headers now exist.

### Move behavior coverage to follow-up

The remaining gaps are real, but they are behavior work rather than namespace consolidation. Keeping them as unchecked tasks in this change makes the OpenSpec impossible to archive accurately and hides the fact that the structural refactor has already landed.

The follow-up should be a dedicated behavior-coverage change with its own test-layer decisions and verification plan.

### Preserve the bare-engine test boundary

Bare-engine SDK tests can execute primitive functions, numeric conversions, native registration, bytecode/parser/tokenizer white-box paths, and runtime exceptions that do not require UE wrapper registrations. Script-reference-class instantiation, UE string runtime behavior, and some thread/atomic internals are either documented exceptions or require separate linkage/registration work.

Future behavior coverage should decide per item whether it belongs in:

- `AngelScriptSDK/` raw SDK tests;
- a UE-wrapper runtime integration theme;
- bindings/CQTest coverage;
- or a separate prerequisite/linkage change.

## Risks / Trade-offs

- Stale documentation may still mention historical `ASSDK` terminology. This is a small docs cleanup item, not evidence that the source refactor is incomplete.
- The source-level test count can differ from Automation discovery because disabled `#if 0` files and generated/discovery rules affect runtime totals.
- Archiving this change does not mean SDK behavior coverage is complete; it means the namespace/helper consolidation record has been made accurate.
