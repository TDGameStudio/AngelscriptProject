# SDK Domain Test Depth

This record defines how much evidence is required before any SDK domain or theme may be called covered. It is deliberately separate from the source-unit, internal-class, interface, and public-API inventories: those records prove that an owner exists; this record proves that the owner's tests are deep enough to protect a fork change or selective backport.

## Existing Coverage suite benchmark

The existing `AngelscriptTest/Coverage` suite is the local quality benchmark for test depth. A source scan performed while planning this change found 90 C++ test files, 1,022 `TEST_METHOD` definitions, and 120,825 lines. Forty-two files contain at least 10 test methods, 11 contain at least 20, and 41 exceed 1,000 lines. Examples include `UStruct` with 47 methods, `UFunction` with 44, and `UClass` with 36.

Those numbers are evidence of the existing suite's breadth, not quotas for this change. The relevant pattern is that a subject is tested across independent operations, representative type/value partitions, valid and invalid input, runtime-observable state, lifecycle, and feature interactions. The native SDK suite must reach that behavioral depth while keeping files focused and excluding UE binding behavior and external add-ons.

## Domain completion rules

Every domain must satisfy all applicable rules below. A row may be marked not applicable only with a reason tied to the fork, active platform, or raw-SDK boundary.

| Evidence dimension | Required evidence |
| --- | --- |
| Public behavior | Execute the public or exported contract and assert values, state, metadata, callback observations, or diagnostics; header/source presence is not sufficient. |
| Internal paths | Exercise materially different phases, branches, state transitions, or algorithms owned by the mapped implementation units/classes; one high-level smoke path cannot own unrelated internals. |
| Input partitions | Select representative types, values, encodings, flags, object/reference forms, and boundary values whenever they change the implementation path or result. |
| Negative behavior | Assert invalid arguments, invalid ordering/state, duplicate/missing symbols, malformed data, or unsupported fork semantics using exact result codes and stable diagnostic categories/text fragments. |
| Lifecycle and cleanup | Cover create/use/reset/reuse/release, success and failure cleanup, module/context/engine teardown, reference ownership, and callback cleanup where applicable. |
| Interactions | Cover combinations where one feature changes lookup, compilation, execution, ownership, serialization, calling convention, or diagnostics. |
| Isolation | Own mutable engine/module/context/message/registration state per case; safely pair thread, lock, allocation, stream, and callback resources according to `global-state.md`. |
| Classification | Separate active fork behavior, active compatible behavior, active-platform behavior, `Platform N/A`, `Fork N/A`, and compiled-disabled future 2.38 expectations. |

Aggregate test count, source size, file presence, compilation success, or a single happy path cannot independently close a domain.

## Current assessment and required closure

This is a pre-implementation assessment. No domain is marked complete in advance.

| Domain | Current strength | Gaps that must be closed | Required post-change evidence |
| --- | --- | --- | --- |
| Engine | Basic engine, memory, atomic, and thread sources exist. | Atomic/thread cases are compiled out; ownership profiles, repeated lifecycle, TLS/manager behavior, allocator boundaries, and process-global safety are incomplete. | Named tests for engine create/configure/shutdown and repeated isolation; profile differences; allocation/free and invalid-size/failure behavior where supported; atomic transitions; per-thread TLS plus joined cleanup; manager observation without mutating production global ownership; lock/weak-bool lifecycle. |
| Frontend | Tokenizer, parser, and script-node coverage is already one of the stronger areas. | Real string utilities are replaced by disabled lambda tests; source/encoding/position boundaries and parser recovery need an end-to-end disposition. | Named tests across token families, numeric/string suffixes and escapes, whitespace/comments/BOM/EOF, malformed tokens and source positions; declaration/expression parsing plus recovery/diagnostics; node shape/copy/source ranges; script-code sections; real scan/compare and UTF-8/UTF-16 encode/decode success and malformed boundaries. |
| Compiler | Builder and bytecode have broad existing sources. | Large mixed files obscure ownership; expression-state/output-buffer internals and several compile-only claims lack runtime linkage or negative cleanup. | Named tests for builder phases, dependencies, symbols, layout, lifecycle, diagnostics and post-failure reuse; instruction encoding/stack/jumps/finalization/optimization; expression value/context state transitions; output-buffer ordering/clear; successful bytecode execution and stable compiler errors. |
| Runtime | Context execution, GC, and some exception cases exist. | Argument/return ABI paths are duplicated; suspend is not actually proven; generic-call, object lifecycle, GC failure/reuse, and exception state depth are uneven. | Named tests for the complete context state machine—prepare, arguments, execute, suspend, resume, abort, exception, unprepare, reuse—with primitive/value/reference/object return accessors; generic callbacks; object construct/copy/property/refcount/weak-flag behavior; GC cycles, enumeration, release, statistics, and cleanup. |
| Module | Sections, lookups, imports, namespaces, restore, and save/load sources exist. | Monoliths and permissive lookup blur exact behavior; corrupt/truncated streams, bind/unbind execution, discard cleanup, and loaded-code equivalence need stronger assertions. | Named tests for module lifecycle, section ordering/duplicates/source coordinates, exact declaration versus explicit name lookup, globals/functions/types, namespace lookup, import bind/unbind/missing targets, discard/recreate; one stream implementation with save/load round trip, corruption/truncation failures, metadata equivalence, and post-load execution. |
| TypeSystem | Data type, config group, properties, traits, scopes, and general type sources exist. | Wrapper-era helpers and broad type tests leave concrete class lifecycle, relationship, modifier, removal/error, and metadata families uneven. | Named tests for data-type identity/modifiers/equality/stack behavior; config-group membership, access, removal and in-use failures; global-property and variable-scope lookup/lifecycle; type/object/function metadata, relationships and traits; enum, typedef, and funcdef identity, enumeration, declaration strings, and cleanup. |
| Language | Parser/operator/function cases provide useful breadth. | Properties, constructors, destructors, inheritance, references, control flow, and runtime interactions are notably uneven; several cases accept contradictory outcomes or stop at compilation. | Every one of the 14 themes in `language-semantics.md` closes every applicable grammar, resolution, runtime, type/value, interaction, lifecycle, negative, classification, and isolation dimension with named method evidence. |
| Embedding | Registration, callfunc, and calling-convention sources exist. | Several ABI claims are compile-only; callback invocation/cleanup, duplicate/invalid registration, native interfaces, string factory, JIT, and active-backend partitions are incomplete. | Named tests for global/object/interface registration success and invalid/duplicate signatures; core metadata; callbacks and cleanup; minimal local string-factory/JIT/thread host contracts invoked by a real engine; generic and active Win64 MSVC calls across materially different argument/return/reference/object shapes; inactive backends explicitly `Platform N/A`. |
| Conformance | Fork-reference rejection tests exist. | Some assertions allow either success or failure, current behavior and future expectations are mixed, and disabled discovery is inconsistent. | Singular enabled assertions for const-only globals, automatic references/no `@`, rejected script interfaces, global mixin functions/rejected `mixin class`, with exact diagnostics; compiled, discoverable, assertion-bearing Disabled classes for the seven expressible Future238 script subjects with the exact `#as-v238-backport` tag; absent C++ API surfaces remain explicitly deferred rather than hidden in dead code. |

## Final evidence format

Before the complete static audit passes, each domain row above must be supplemented with:

1. the final topic-named source files;
2. representative `TEST_METHOD` names for every applicable evidence dimension;
3. explicit `Platform N/A`, `Fork N/A`, or raw-SDK-boundary reasons for non-executable items;
4. the exact domain prefix run recorded in `verification.md`;
5. no unresolved placeholder such as `TBD`, “covered elsewhere”, or an owner without a method name.

`audits/test-scenarios.md` is the normative named-method realization of these dimensions. Language keeps its classification detail in `language-semantics.md`; the other domains must meet the same standard through this record, the exact scenarios, and their subject-specific inventories.
