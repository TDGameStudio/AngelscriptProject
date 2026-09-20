## Context

The accepted [source and lifecycle contract](attachments/drafts/design.md) is the implementation boundary. [Storage evidence](attachments/drafts/findings/builder-source-storage-evidence.md) identifies AddFile copying and host field consumers; [lifecycle evidence](attachments/drafts/findings/builder-source-lifecycle-evidence.md) identifies late descriptor degradation and raw definition borrowing.

## Goals / Non-Goals

**Goals:** shared ready-source input, unchanged raw-byte identity, explicit compiler stages, one stable declaration publication per file-module, ordered host hooks, and safe terminal ownership transfer.

**Non-Goals:** source acquisition/VFS, streaming, host object publication, the complete diagnostics tooling design, LSP activation, and all legacy-runtime restoration.

## Decisions

### Common source ownership

Move the sole FAngelscriptSource definition to angelscript/unreal/AngelscriptSource.h with its necessary implementation. Keep existing host fields and compatibility factories. Use one FUtf8String SourceText, noncopyable Source semantics, preparation-time moves, and shared-const submission. GetPath supplies exact logical identity independent of physical filename and compatibility ModuleName.

An existing UTF-8 body is moved; FString input is converted once during host preparation. Byte views reference that body by explicit length. The host stops mutating published aliases; automatic freezing is intentionally not part of the contract.

Remove the old snapshot body-building API and migrate its users into shared-source indexing owned internally by the existing SourceManager. Retain an internal shared lifetime for indexes and references so AST/results can outlive the Builder, without a new public collection type. Existing SnapshotID coordinate fields may retain their identity meaning. Keep provenance/index data separate from source acquisition.

### Entry and scheduling

Use exactly the constructor, RunThrough, RunStage, and callback signatures in [the glossary](attachments/drafts/glossary.md). Copy small option values, source references, and callback pointer lists, not body bytes or the caller's array lifetime. Dependencies remain borrowed.

Retain the existing stage sequence. SourceReady records input validation but construction never calls user code. The first execution reports a pending invalid-input failure. A private execution guard distinguishes API misuse/re-entry from a newly failed compilation and prevents duplicate final delivery. Invalid callback registrations are rejected deterministically before invocation; null pointers and duplicate object pointers are invalid, so each valid registered object has one notification identity.

Intermediate success is not terminal. All required hooks accepting ByteCodeEmitted completes a build; ordinary failure records the attempted stage before final notification. RunThrough and RunStage share this state machine.

### Diagnostic and observation costs

The Builder creates its diagnostic/index association internally. Preserve located diagnostic behavior; non-located input and callback failures are exposed by Error without invented source ranges. The separate diagnostic-tooling plan remains responsible for its larger public diagnostic model.

Stage status, errors, and typed products remain available in ordinary compilation. Complete Text/Json generation is controlled by an explicit option following the existing asSBuilderOptions convention, named bGenerateDebugObservations and defaulting false. This is a convention-derived detail of the approved opt-in observation decision, not a change to stage semantics. Existing deterministic observation tests opt in.

### Declaration publication

The typed descriptor consumer is the only declaration projection. Complete and validate the batch after DeclarationsResolved, preserving an empty module for a prepared empty file. Only then expose output and notify. Remove the late ModuleDefinitions-based reconstruction; diagnostics can refresh independently.

Keep the existing descriptor family. Deep read-only delivery requires removing public mutation/escape paths from the published output surface, including mutable descendant shared references. It is not satisfied by changing only the outer shared pointer to const. Internal construction may use mutable descriptor data; published access must use recursively read-only traversal/field access and must not return a mutable descendant. Fine-grained accessors follow existing Get-style naming, with no duplicate semantic descriptor family. Runtime pointers stay unmaterialized. Later association uses stable keys in the separately owned DefinitionSet.

A late compiler or hook failure retains already published declaration facts for inspection but does not authorize host publication. DefinitionSet remains one possible ownership container for several semantic modules.

### Hook and transfer boundaries

Call hooks on the execution caller's thread after workers join. Ordinary hooks follow registration order and stop on false. Completion is void and broadcasts once to all valid registered objects even when earlier work short-circuited. The host owns callback lifetime, UObject cleanup, and abandoning unfinished builds.

Reject Take during execution, in callbacks, and at intermediate pauses. Enable CompileOutput transfer after terminal execution returns on success or failure. Enable definition transfer only after final success; clear or guard session raw borrows when moving ownership. Repeated transfer returns null. Source/index retention follows escaped location consumers, not Builder stack lifetime; external definition dependencies retain their own owner contract.

## Compatibility and migration

The old Core Source header forwards the common definition and keeps host helper contracts. Only the minimal path/data dependency closure moves. The generic SDK path must not accidentally call a host mount-prefix validator. Provider/cache/watcher/preprocessor/snippet/JIT consumers receive necessary field encoding, move, and include changes; this does not promise full legacy zero-copy behavior.

SourceManager, AST, diagnostics, preprocessing, compilation sessions, and replacement fixtures migrate together where the removed snapshot API requires it. Existing compile-stage helpers remain useful lower-level test boundaries; no caller is required to build a source collection before calling Builder. Retained dormant sources remain dormant.

The diagnostic-tooling Change and this Change overlap in file ownership, not authorization: inspect overlapping edits before implementation and adapt shared-source integration without changing that Change's task state. Replan only if its actual intervening implementation invalidates a contract.

## Risks / Trade-offs

- Mutable aliases can invalidate byte views: document publication discipline and test two independently retained versions; no hidden freeze is claimed.
- Public descriptor descendants currently escape mutably: test recursive constness, not only top-level API types.
- Result and dependency lifetimes differ: test Builder destruction separately from external definition-owner destruction.
- Host encoding changes have runtime/editor consumers: build the affected plugin host before scoped Automation; do not infer compatibility from SDK tests alone.
- Current builder and source-diagnostics specs have pre-existing detail-indentation errors. Future synchronization includes formatting-only repairs in those two targets, preserving all unrelated clauses. The planning baseline is recorded in attachments/data/planning-validation.md.

## Verification and recovery

Each task owns concrete replacement NativeEngine cases and an exact selector. Shared source/index migration justifies a broader NativeEngine regression run because fixtures and source-coordinate ownership cross frontend/VM consumers; callback/output tasks use their focused prefixes. No unconditional Quick, Performance, Integration, or legacy suite is added.

Implementation may be backed out by reverting only this Change's owned edits with user-directed Git work; never restore the dormant runtime as a fallback. Keep the input and result contract coherent at each completed task boundary. This document is a plan, not a record of successful implementation.
