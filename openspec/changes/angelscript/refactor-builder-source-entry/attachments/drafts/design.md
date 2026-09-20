# Shared Source and Builder Compilation Entry

Approved on 2026-09-13. Source identity: angelscript/virtual-source-filesystem, selected design builder-source-entry. English export of the accepted, curated design. Target: angelscript/refactor-builder-source-entry.

## Goal and scope

The host submits shared references to prepared FAngelscriptSource objects. Builder owns preprocessing and compilation, coordinates stages and host callbacks, and returns results without storing another copy of each submitted source body.

One .as input corresponds to one semantic module identified by its logical path. A Builder processes a batch of modules; it does not merge the batch into a module named after its first file.

File discovery, reading, mounts, VFS, streaming tokens, the complete diagnostic tooling project, standalone LSP restoration, UClass construction, and hot-reload publication are excluded. Existing host loading/query behavior receives only necessary encoding, ownership, and include adaptations.

## Common Source and preparation

FAngelscriptSource remains the single UE/SDK source type. Retain VirtualPath, ModuleName, RelativeFilename, AbsoluteFilename, SourceKind, and bHasSourceText. SourceText becomes the sole FUtf8String body. The SDK uses GetPath() for module identity; the compatibility ModuleName field is not a second SDK identity.

```cpp
FAngelscriptSource();
FAngelscriptSource(FString InPath, FUtf8String&& InSourceText);
FStringView GetPath() const;
const FUtf8String& GetSourceText() const;
```

Default construction starts unprepared with bHasSourceText=false. The ready constructor moves the supplied body and sets readiness. The host may populate the record during preparation, then submits a TSharedRef<const FAngelscriptSource, ESPMode::ThreadSafe>. Published versions are not modified; an update creates a new Source while old results retain the old version. This is a contractual immutability boundary, not a Freeze protocol: const shared references cannot disable other mutable aliases.

Source is noncopyable and movable during preparation. Necessary existing host factories remain compatible; no new static Create or source factory family is required. FString input needs one host-side UTF-8 conversion; existing FUtf8String input moves directly. Length excludes the trailing terminator and must not use strlen to truncate embedded NUL.

Paths are nonempty, exact, case-sensitive logical identities. The SDK does not normalize case, separators, or .. and does not require a mount prefix. The host normalizes before submission. Move only the minimal common path/data dependency closure: host factories may retain mount validation, but the SDK constructor/GetPath must not implicitly reject general logical paths through that validation.

Unprepared sources are rejected without reading AbsoluteFilename. A prepared empty body is valid and never means deletion. Empty input batches, empty or duplicate paths, unrepresentable lengths, and invalid basic options fail explicitly. Invalid UTF-8 and NUL remain locatable and diagnosed rather than silently rewriting the body. Preserve original BOM/CRLF byte coordinates.

## Builder input and execution

```cpp
asCBuilder(
    TConstArrayView<
        TSharedRef<const FAngelscriptSource, ESPMode::ThreadSafe>> Sources,
    const asSBuilderOptions& Options,
    TConstArrayView<asIBuilderCallbacks*> Callbacks = {});

bool RunThrough(
    asEBuilderStage Target = asEBuilderStage::ByteCodeEmitted);
bool RunStage(asEBuilderStage Stage);
```

Construction stores its own reference list, option values, and callback pointer list. It neither borrows caller array storage nor compiles or calls hooks. Empty callback lists are valid. The host owns callback objects for their required lifetime; invalid registrations must never be invoked.

Options retain StableScope, WorkerCount, PreprocessorFlags, TypeContext, and Dependencies. StableScope scopes stable identity; it is not the module filename. Copying options does not acquire ownership of borrowed Dependencies; those owners outlive compilation and all products referring to their definitions.

RunThrough advances monotonically to the requested stage and defaults to full compilation. Reaching an already completed target is a no-op. RunStage accepts only the immediate next stage; both use one dispatcher. Reject backward advancement, continuation after failure, concurrent advancement, and callback re-entry. A new input needs a new Builder.

SourceReady is input validation. Construction sends no stage callbacks. A construction-detected input error is reported by the first explicit execution, including its one final notification. Non-located errors use the stage Error and final notification without fabricating a source location. Rejected API usage and repeated terminal calls do not repeat final notifications.

Keep the stage order SourceReady, Lexed, Preprocessed, DeclarationsCollected, DeclarationsResolved, BodiesAnalyzed, ASTVerified, DefinitionsBuilt, LayoutsFinalized, DefinitionsFrozen, ByteCodeEmitted; Failed denotes terminal failure. Streaming changes are separate work.

## Internal source coordinates

The host does not construct Snapshot, SourceFiles, SourceManager, or Diagnostics. Builder internally organizes shared references, coordinates, and diagnostic association. Existing SourceManager may remain an internal query service, not a filesystem.

Remove the AddFile(view) pipeline that allocates a second body and migrate Snapshot consumers rather than adding another public collection wrapper. Preserve compilation-input identity, local FileID, UTF-8 half-open ranges, revision digests, lazy line tables, internal provenance, and cross-input identity checks. Existing SnapshotID coordinate spelling may remain.

Escaping AST, diagnostics, and results retain the necessary Source references and index lifetime. Internal byte views use the FUtf8String pointer and explicit length; they do not allocate a TArray body. Genuine token, AST, or literal products may allocate. Ordinary compilation must not materialize complete token-text or stage-JSON dumps by default. Explicit debug/test observation remains available and deterministic without changing language semantics.

## Callback contract

```cpp
class asIBuilderCallbacks
{
public:
    virtual ~asIBuilderCallbacks() = default;
    virtual bool OnBeforeStage(asEBuilderStage Stage) { return true; }
    virtual bool OnAfterStage(asEBuilderStage Stage) { return true; }
    virtual bool OnDeclarationsReady(
        const asCDefinitionCompileOutput& Definitions) { return true; }
    virtual void OnBuildFinished(
        bool bSucceeded, asEBuilderStage Stage,
        FStringView Error, const asCCompileOutput& Output) {}
};
```

Callbacks execute synchronously, serially, in registration order on the initiating thread after internal workers join. Stage order is all Before hooks, the stage body, the one declaration delivery when applicable, then all After hooks. Before sees previously completed state; successful output is query-visible before declaration and After callbacks. A failed stage has no After callback, so Before/After are not a paired cleanup protocol.

False from an ordinary callback means host processing failed. Stop remaining ordinary callbacks and stages, record failure, then notify every registered callback object of completion. Final notification returns void and cannot alter the outcome. Even objects skipped by an earlier short circuit receive completion and must tolerate having nothing to clean up. SDK does not roll back UObjects.

Each Builder sends at most one final notification. A successful intermediate pause sends none. Success requires ByteCodeEmitted and acceptance by all required ordinary hooks. Construction/destruction do not notify; abandoning an unfinished Builder is host-managed cleanup. Success carries ByteCodeEmitted and empty Error; failure carries the actual failing stage and a nonempty reason. Output borrows diagnostics and declaration descriptions; it does not own definitions or bytecode.

Callback parameters are valid during the call; consumers must not retain temporary raw references. No layout or binding state is fed back into later compilation, and no asSBuilderContext is introduced. Future typed payload evolution does not promise binary ABI stability.

## One stable declaration publication per module

After DeclarationsResolved succeeds and batch-wide projection validates, produce per-module descriptions once, expose them to queries, then call OnDeclarationsReady. Projection failure must not publish partial successful descriptions. An empty file retains its module identity even with no declarations.

The existing typed declaration projection remains the semantic source of descriptions, including owning path, stable identity, metadata, and source anchors. Remove the RefreshCompileOutput branch that names the complete batch after sorted Inputs[0] and replaces module descriptions with simplified definition summaries. Separate ongoing diagnostic refresh from declaration publication: later stages must not re-project, overwrite, downgrade, or repeat delivery.

Read-only access includes descendants; a const wrapper returning mutable shared objects is insufficient. Runtime fields remain unmaterialized. Never backfill ScriptType or ScriptFunction into already published descriptions. Associate descriptions with later definitions by StableDeclarationKey and existing DefinitionSet::FindType / FindFunction, not display names.

Body, layout, or bytecode failure leaves previously published declaration facts stable, but the final build fails and the host cannot publish a replacement module. One internal DefinitionSet owner does not imply one semantic module; per-file definition ownership is not required.

## Result transfer and dependency lifetimes

Retain GetCompileOutput / TakeCompileOutput and GetModuleDefinitionSet / TakeModuleDefinitionSet. CompileOutput carries diagnostics and declaration descriptions. ModuleDefinitionSet owns types, functions, and bytecode.

Compilation, callbacks, and intermediate pauses are read-only periods: Take is unavailable. After all final callbacks and the execution call return, CompileOutput can be taken from either successful or failed terminal builds; ModuleDefinitionSet can be taken only after final success. Repeated Take returns null. Taking a result does not advance, regenerate output, or notify again.

Transfer must clear or guard stale session borrows of moved definitions. Taken results retain the Source and coordinate indexes they require after Builder destruction. Source retention does not own external Dependencies; definition lookup pointers remain borrowed from their actual definition owner.

## Files and compatibility

- angelscript/unreal/AngelscriptSource.h/.cpp owns the common Source definition and necessary implementation.
- angelscript/as_builder_callbacks.h owns the separate callback interface; as_builder.* owns dispatch.
- Core/AngelscriptSource.h forwards the common definition as needed and retains host helper contracts. Move only required pure data/path dependencies, not all F-prefixed types.
- Basic, AST, compilation, diagnostics, and tests migrate source retention and coordinate queries without adding asCSourceFiles or a public Origins input.
- Compile output and descriptor projection receive only the changes needed for this delivery contract; full UClass generation and runtime replacement remain host-owned.
- Provider, cache discovery, watcher, old preprocessing, and snippet consumers receive minimal encoding, move/shared-reference, and include compatibility edits. Do not reactivate dormant paths or claim zero copies across the entire legacy host pipeline.
- Do not absorb the separate diagnostic tooling Change's catalog, complete owned-diagnostic model, edits, or LSP APIs. Account for its shared Source/Builder consumers without editing its task plan.

## Verification and handoff

Plan replacement NativeEngine feature groups for moved Source/readiness/host fields; pointer identity and coordinate retention; constructor/stage entry; one-time rich per-module descriptions; callback short circuit and all-object final notification; terminal transfer; and two Builders sharing a Source. Product verification is future work, not established by source inspection.

Current authority is Change creation and planning only. Existing builder and source-diagnostics specs have pre-existing clause-indentation validation errors. Record that baseline; future synchronization may repair formatting in those two affected specs without changing unrelated semantics.

## Evidence

- [Source storage and host compatibility](findings/builder-source-storage-evidence.md).
- [Descriptor and lifecycle evidence](findings/builder-source-lifecycle-evidence.md).

Only curated contracts, necessary evidence, and concise rationale are exported. The local discussion history is not a Change dependency.
