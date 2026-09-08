# Source Execution and Real Detached Test Definitions

## Context

The user approved replanning this existing Change to test basic AS source all the way through execution, then asked whether manually created object types/functions can also isolate VM tests and test those metadata objects without an Engine. No product implementation was requested in this planning-only continuation.

## Evidence

The original plan explicitly excluded source compilation from fixtures and a source compiler from the bytecode capability. That boundary is invalid after the approved source-execution expansion. The current Builder already produces canonical verified AST and frozen definitions, but not executable bytecode; existing tests stop at those products.

MetadataImageTests::ActualTypesAndMethodsNeedNoEngineOrNumericIds already creates real types and methods without an Engine. The registration fixture shows how to authenticate keys. However, current CreateContext is unavailable and the retained interpreter still uses Engine ownership, callable tables, allocation, GC, resource limits and cleanup services. Detailed source anchors are in data/source-execution-matrix.md and data/runtime-dependency-inventory.md.

## Options and settled decision

1. Keep direct bytecode only: isolates VM, but does not answer the accepted source-language execution requirement.
2. Add the current canonical AST as a second producer for the same image/verifier/linker/VM, and explicitly test real detached metadata: selected.
3. Add fake type/function classes or a test-only interpreter: rejected; this would bypass production definitions and fail to prove the real VM.
4. Extract every runtime service into a new Engine-less owner: potentially viable, but not authorized as a side effect of manually creating metadata. Retain the previously selected minimal SDK Engine execution owner in this Replan.

The manual fixture constructs authentic asCObjectType/asCScriptFunction objects through image factories, without Builder or Engine. A function declaration is not an executable body. Metadata/image/compiler tests need no AS Engine; actual execution explicitly registers definitions and provisions runtime services. UE hosting CQTest is independent of creating an AS Engine.

## Consequences

Add one detached-metadata group and five bounded source groups. Preserve all original direct VM/opcode/cache requirements, permanent task IDs and pending status. Existing metadata/semantic tests remain baseline controls; no past result is relabeled as new runtime proof.

Builder's default terminal stage stays DefinitionsFrozen. A new explicit emitter consumes its sealed typed AST, uses matching declaration keys, and produces owned symbolic code. Cache load remains definition-free; destination definitions can be manually created without recompiling source.

The source boundary is basic expressions, control, calls, AS objects/cleanup and source-produced cache execution, not every source grammar feature. Explicit unsupported lowering avoids partial success. Clang informs typed code-generation and cleanup responsibility, while maintained AS code controls precedence and reverse-formal argument evaluation.

## Flip condition

A later explicit decision that real execution itself must never create asCScriptEngine requires a separate ownership Replan for production runtime services and Engine adapters, using the same interpreter. Failed local tests instead stay in their owning task; only evidence invalidating an interface, required dependency, outcome or proof boundary causes Replan.

## References

- Source/metadata matrix: data/source-execution-matrix.md.
- Earlier accepted cache ownership: talk-20260906-002459-definition-free-cache.md; cache loading and single-Engine metadata constraints remain valid.
- Current truth: proposal.md, design.md, bytecode/testing deltas and tasks.md.
