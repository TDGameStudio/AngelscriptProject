## Context

`feature-ue-angelscript-standalone-compiler` established two safe Standalone profiles over the maintained AngelScript fork: bounded native execution and compile/analyze-only UE validation through a complete offline JSON bundle. The current `FUECompiler::Compile()` path is still request-scoped: it loads a bundle, creates and registers an engine, compiles, gathers observations, and tears the engine down for each invocation. There is no Emscripten build or reusable document-session API.

UE compilation already captures AngelScript compiler messages in `FAngelscriptEngine::FDiagnostic` and publishes a compact positional `Diagnostics` message through DebugServer. The TypeScript Language Server then combines those messages with rules implemented in `ls_diagnostics.ts`, including unused variables, missing imports, delegate bind checks, missing `override`, required Super calls, and Unreal naming conventions. Moving similar rules independently into Standalone or Wiki would create three implementations with different ASTs, ranges, settings, and release cadence.

AngelscriptWiki is a separate TiddlyWiki 5.4.1 repository and publishes one offline `dist/index.html`. It deliberately has no plugin-runtime, UE-process, or local-service dependency. Existing `$angelscript-code` and `text/x-angelscript` surfaces are read-only Highlight.js presentations. CodeMirror 6 was removed as an unused global product source; a parent `Reference/tiddlywiki-codemirror-6` checkout remains research-only. Heavy WASM or editor behavior must be explicitly selected, embedded, and lazy.

The primary audience for the Wiki surface is a documentation reader experimenting with an article-provided class example. It is not a project authoring workspace. The user edits one example in memory, sees compiler/shared diagnostics and lightweight suggestions, and inspects a static description of the declared class. Full project indexing, filesystem synchronization, script execution, and persistence are not required.

The change spans the parent repository, the `Plugins/Angelscript` submodule, and the `Wiki` submodule. The plugin is the semantic source of truth. Wiki assets are coordinated release artifacts with provenance; normal Wiki builds must remain deterministic and must not build UE, invoke Emscripten, or fetch assets.

## Goals / Non-Goals

**Goals:**

- Make diagnostic rules a plugin-owned, host-neutral C++ capability compiled unchanged into UE, Native Standalone, Native LSP, and WASM.
- Preserve one canonical rule catalog, default policy, stable IDs, messages, suppression behavior, source ranges, and rule-set identity.
- Introduce a resident Standalone Language Service with versioned document state, analysis, lightweight completion, and static class outlines.
- Produce an offline, integrity-checked partial Wiki API profile from an explicit complete UE bundle.
- Provide a stable ESM/Worker API backed by Emscripten rather than reimplementing the compiler in JavaScript.
- Provide an explicit article-embedded TiddlyWiki widget that is offline, lazy, accessible, failure-tolerant, and isolated from ordinary code presentation.
- Keep existing DebugServer clients, Standalone CLI usage, complete-bundle semantics, ordinary Wiki pages, and the VS Code UE backend compatible.
- Leave the native service ready for a later stdio LSP adapter and ship the first offline LSP milestone as an explicitly selected diagnostics backend.

**Non-Goals:**

- Replacing UE preprocessing, ModuleDesc construction, ClassGenerator, reflection materialization, or the authoritative UE compile pipeline.
- Executing AngelScript in the browser or exposing the Standalone native-runtime profile through Wiki.
- Simulating UObject, UClass, GC, World, Blueprint VM, RPC, asset loading, hot reload, or editor state in WASM.
- Turning Wiki into a multi-file IDE, reading a project directory, importing a workspace archive, saving edits, or connecting to a loopback service.
- Replacing the existing TypeScript Language Server's online completion, navigation, refactoring, asset, or debugging features in the first LSP milestone.
- Automatically regenerating or fetching WASM/profile assets during normal Wiki builds.
- Restoring the complete retired `tiddlywiki-codemirror-6` plugin or changing the global TiddlyWiki editor.

## Decisions

### Plugin-owned normalized diagnostics core

The shared implementation will live in a standard-C++ portion of `AngelscriptRuntime` and will be compiled as ordinary sources by UBT and explicitly by Standalone CMake. It will not include Unreal headers or use Unreal containers, strings, reflection objects, logging, settings, or filesystem APIs. UE-specific and Standalone-specific code will convert host state into a versioned normalized fact graph.

The fact graph will contain only information needed by registered rules: document/range identities; declared symbols and kinds; read/write/reference uses; imports and resolved stable IDs; classes, bases, methods, overrides, metadata flags, and resolved Super calls; delegate targets and signatures; naming contexts; and profile completeness. Facts will carry stable source locations and semantic identities, never raw compiler pointers or process-local IDs.

This separates three concerns:

1. The host proves semantic facts from its authoritative environment.
2. The shared evaluator applies the canonical rules.
3. Each client presents the returned diagnostics.

An alternative was to keep TypeScript rules and port them independently to WASM-facing JavaScript. That is rejected because it creates behavior drift and prevents UE compilation from using the same rules. Another alternative was to make Standalone reuse UE ModuleDesc/ClassGenerator code. That is rejected because it would violate the established no-UE Standalone boundary.

### Canonical rule catalog and non-fatal static semantics

The first rule set is fixed to the existing high-value Language Server behaviors:

- `ASLINT1001`: unused local or parameter; Hint with Unnecessary tag.
- `ASLINT1002`: resolved symbol lacking an explicit import; Information.
- `ASLINT1003`: script parent method overridden without `override`; Warning.
- `ASLINT1004`: required `Super::` call missing; Warning, respecting `NoSuperCall` on the parent or override.
- `ASLINT1005`: delegate/event bind target absent or signature-incompatible; Error presentation, non-fatal compile semantics.
- `ASLINT1101`: Unreal type naming violation; Warning.
- `ASLINT1102`: Unreal function naming violation; Hint.
- `ASLINT1103`: Unreal variable/bool naming violation; Hint.

Compiler messages remain compiler diagnostics. Shared static diagnostics have an explicit `nonFatal` field. They may be presented as Error but never set module compile failure, reject hot reload, alter packaging, or exit the Standalone compiler with a compiler-failure status unless a future spec explicitly defines a lint gate. UE will therefore publish static results through a dedicated rich-diagnostic snapshot rather than blindly calling the current error-logging `ScriptCompileError()` path.

All callers start from the same default rule policy. A caller may request a rule-group mask for presentation or analysis cost, but that mask does not change rule definitions. The core returns a deterministic `ruleSetVersion` and `ruleSetHash` computed from the catalog's normative identity. Rule behavior changes require an explicit version/hash update and golden-fixture review.

Rules that require a complete semantic graph do not run after a structural parse/compile failure. If a partial profile cannot prove a relationship, the fact provider marks it unknown; the evaluator does not convert unknown into missing or incompatible.

### Bounded semantic-observer and offline-contract extension

The maintained fork already exposes `asISemanticObserver` for resolved calls, constructors, assignments, and constant strings. It will gain the minimum observations required for declarations, references, resolved override/Super relationships, and delegate calls. The observer remains optional and side-effect-free; compilation without an observer behaves identically.

The UE offline producer will export explicit versioned semantic flags on appropriate symbol records, including BlueprintEvent, `RequireSuperCall`, `NoSuperCall`, signature identity, and inheritance/override availability. It will not export an unbounded metadata map. Existing complete-bundle rules remain: explicit selection replaces the default, invalid selection fails without fallback, and the bundle contains no code bodies, addresses, or private machine paths.

The compact Wiki profile is a derived consumer artifact, not a second implicit default bundle and not a replacement for the complete offline contract.

### Resident document Language Service

Standalone will add a service object that owns one initialized engine, validated registration surface, profile index, adapter registry, and document table. Documents are keyed by URI and monotonically increasing caller version. Opening or updating a document replaces its complete text in v1; the service rebuilds that document's affected module state without recreating the global engine and registration index.

The public service operations are:

```text
createLanguageService(options)
openDocument({ uri, text, version })
updateDocument({ uri, text, version })
analyze({ uri, version })
complete({ uri, version, position })
getClassOutline({ uri, version })
closeDocument({ uri })
dispose()
```

Native C++ types and the JS projection use the same versioned shapes: `AnalysisResult`, `Diagnostic`, `CompletionItem`, `ClassOutline`, `ProfileInfo`, and `RuleSetInfo`. External positions are zero-based UTF-16 so CodeMirror and LSP do not each invent a conversion. The service owns one tested UTF-8/UTF-16 mapping utility for compiler byte/row/column inputs.

Every asynchronous result echoes the requested document version. Results for a closed, missing, or newer-version document are stale errors and must not replace current presentation state. Closing a document removes its modules and cached analysis while retaining the shared engine/profile until service disposal.

Completion is intentionally lightweight: language keywords/specifiers, symbols declared in the current example, and visible types/members/functions in the selected profile. It does not scan a project, edit imports, resolve references across source roots, or promise the current TypeScript LSP's full behavior. Class outline is a static description of declared classes, bases, properties, methods, and declaration flags; it never claims a UClass exists.

The existing `as-standalone` commands become thin callers of this service. Output formats and exit behavior remain compatible unless a new language-service command is explicitly selected.

### Deterministic `.aslp` partial profile

The Standalone package adds a profile packer. Its inputs are an explicit valid complete offline bundle, a reviewed allowlist of Wiki root symbols, adapter versions, and the packer version. It resolves stable-ID dependencies and emits only declarations and relationships required by the closure.

The pack contains compact string/symbol tables, signatures, type/member relationships, documentation summaries, semantic diagnostic flags, adapter identities, and completeness metadata. Its manifest records:

```text
packSchemaVersion
offlineSchemaVersion
producerProductVersion
producerRevision
sourceBundleIdentity
allowlistHash
ruleSetVersion
ruleSetHash
adapterSetHash
recordCounts
completeness = partial
file hashes
```

The pack must not contain source text, function bodies, executable bytecode, native addresses, UObject layouts, asset payloads, arbitrary metadata, or absolute/private paths. Identical inputs produce byte-identical output. Unknown schema, failed hashes, inconsistent record counts, missing dependencies, or incompatible rule/adapter versions fail before a document is opened. There is no cache search or fallback after an explicit invalid selection.

The packaged Wiki profile is maintained as an audited release asset with its manifest. A normal Wiki build validates the committed hashes but does not regenerate the pack or access UE.

### Emscripten C ABI plus ESM/Worker projection

Emscripten compiles the same maintained fork, Standalone frontend, adapters, Language Service, and shared diagnostics core. A narrow C ABI manages opaque service/document handles and exchanges UTF-8 JSON plus binary profile bytes. The public ESM wrapper owns allocation, deallocation, error conversion, version checking, and lifecycle; JavaScript clients never call raw pointers directly.

Compilation and completion run only in a dedicated Worker. The Wiki main thread sends versioned requests and receives structured results. Worker creation uses embedded TiddlyWiki assets and object URLs so the final offline `index.html` performs no network fetch and also works from the test artifact server. The product tests additionally cover the intended direct-offline loading path.

The Web build does not expose AngelScript execution. File, network, process, dynamic-library, arbitrary FFI, and native host registration APIs are absent. Limits cover profile bytes, source bytes, document count, diagnostic count, completion count, analysis duration, and WASM memory. Limit failures are structured service errors and do not crash the Wiki.

Native/WASM parity compares normalized deterministic results rather than elapsed time or internal IDs. The release package uses an ESM package identity but is not automatically published to a registry.

### Separate lazy Wiki workbench plugin

The Wiki feature is a new local composition plugin, `$:/plugins/TDGameStudio/angelscript-workbench`. Keeping it separate from `angelscript-tools` prevents CodeMirror/WASM assets from joining the browser-startup path and preserves the existing Highlight.js-only contract for read-only code.

The plugin exposes:

```wikitext
<$angelscript-editor sourceTiddler="AS/Examples/GeneratedActor" showOutline="yes" />
```

`sourceTiddler` supplies initial `text` and takes precedence over `code`; `code` is the fallback for small inline examples. A source tiddler should use `type: text/x-angelscript`. Neither input is modified. The widget keeps an in-memory draft, provides Reset, and discards the draft when its lifecycle ends. When its source-defining attribute or source tiddler changes through a TiddlyWiki refresh, the widget reinitializes from the new author-owned source.

The widget provides CodeMirror editing/highlighting, diagnostic gutter and list, light completion, service/profile state, and an optional class outline. The outline visibly states that it is a static semantic preview and not a generated UE UClass. No Run button, console, project import, directory picker, persistence, rename, references, or source write-back is present.

CodeMirror is selected as minimal npm modules needed for the local editor, lint decorations, completion, keyboard commands, and accessibility. The retired BTC plugin remains absent; its reference checkout may inform lifecycle integration only. Licenses, exact package versions, lockfile changes, product-source policy, and third-party notices are reviewed and recorded.

The first rendered widget lazy-loads one shared Worker/service/profile. Each widget has an isolated document URI/version. Reference counting closes documents as widgets are removed and disposes the Worker, object URLs, and WASM instance when no widgets remain. Analysis is debounced by approximately 250 ms, and stale versions are ignored.

If CodeMirror cannot initialize, the widget renders a readable escaped source fallback. If Worker/WASM/profile initialization or analysis fails, editing remains available where possible and an accessible analysis-unavailable state is shown. Failures never prevent the rest of the tiddler or Wiki from rendering.

The integrated artifact budgets are a 24 MiB maximum final HTML, a 16 MiB maximum added Workbench payload, a 5-second baseline cold start, a 500 ms warm p95 analysis for a 500-LOC fixture excluding debounce, and no analysis-attributable main-thread task longer than 50 ms.

### Backward-compatible rich diagnostics negotiation

The existing positional DebugServer `Diagnostics` structure is not extended in place. A new message type carries rich diagnostics after an explicit per-client capability request. Per-connection state decides which message is sent; no global debug-adapter version controls serialization.

Rich entries carry rule/source ID, severity, non-fatal flag, complete UTF-16 range, tags, related information, document version, profile identity, and rule-set identity. Legacy clients continue receiving the old payload mapped from compiler diagnostics as before. A new client consumes rich entries and must not also synthesize migrated TypeScript rules.

This design avoids buffer over-read for old decoders and permits simultaneous old/new clients. It also separates editor severity from UE compile failure.

### Staged Native stdio LSP adapter

The native LSP target is a thin stdio JSON-RPC adapter over the resident service. Its first offline milestone supports initialize/shutdown, full-document synchronization, didOpen/didChange/didClose, and publishDiagnostics. The VS Code setting uses an explicit `unreal` or `standalone` backend; `unreal` remains the default, and changing the backend restarts the server.

The offline backend requires explicit executable and profile/bundle paths and performs no cache search. Existing online completion, hover, signature help, definition, references, rename, asset data, and debugging continue through the current UE-connected TypeScript server. Migrating those online features to the native core is deferred to a separate future decision, even though the core already exposes the lightweight completion and outline used by Wiki.

### Coordinated repository and release ownership

Implementation lands in dependency order:

1. Plugin/Standalone shared core, export, native service, WASM, and protocol producer.
2. VS Code consumer changes and tests in the parent repository.
3. Wiki plugin, committed release assets, content fixtures, provenance, and tests in the Wiki submodule.
4. Parent OpenSpec evidence, tooling/docs, and submodule gitlinks.

The plugin submodule is committed before the Wiki asset manifest points to its release identity. Wiki is committed before the parent gitlink update. Existing unrelated dirty files are never staged or rewritten.

## Risks / Trade-offs

- **[Shared standard-C++ code accidentally acquires UE dependencies]** → Compile it independently in Standalone and WASM, add forbidden-include scans, and keep all UE conversions in an adapter layer.
- **[UE and Standalone produce different facts]** → Use one normalized golden corpus with complete diagnostic tuples and reject unexplained UE/Native/WASM differences.
- **[Semantic observer additions perturb compilation]** → Keep the observer optional and read-only; run native AngelScript SDK and UE compiler regression suites with and without an observer.
- **[Static Error changes UE success behavior]** → Publish static results through a non-fatal channel and test compile/hot-reload outcomes separately from presented severity.
- **[Partial profile creates false missing-symbol errors]** → Carry completeness/unknown facts end-to-end and require partial-profile UI labelling.
- **[Compact profile grows toward the full 149 MB symbol stream]** → Use explicit root allowlists, dependency closure, deterministic size reports, and release budgets; adding an API root requires review.
- **[WASM blocks the browser]** → Analyze only in a Worker, debounce changes, cap resources, measure long tasks, and discard stale versions.
- **[Embedded assets inflate every Wiki visit]** → They increase the single HTML artifact size but are decoded/instantiated only when the widget renders; enforce both artifact and payload budgets.
- **[CodeMirror selection recreates the retired global plugin]** → Bundle only local editor modules inside `angelscript-workbench`, retain explicit product provenance, and test that the retired plugin title is absent.
- **[Committed Wiki assets drift from plugin sources]** → Embed producer revision, schema, rule-set, bundle, allowlist, and content hashes; fail Wiki release validation on mismatch.
- **[Old/new DebugServer clients interfere]** → Store negotiated capabilities per connection and test concurrent legacy/rich clients.
- **[Removing TypeScript rules loses diagnostics before UE connects]** → Ship the offline native backend in the same staged change and test explicit backend behavior; keep non-migrated TS capabilities unchanged.
- **[Umbrella change becomes too broad]** → Keep phase gates and verification evidence independent. Tasks may be rewritten as implementation learns, but public boundaries remain in capability specs.

## Migration Plan

1. Land normalized diagnostic types, evaluator, golden corpus, and host adapters while the existing TypeScript rules remain available behind a test-only comparison path.
2. Add non-fatal UE publication and Rich Diagnostics negotiation; update the VS Code decoder before disabling duplicate TypeScript rule emission.
3. Refactor the existing Standalone CLI onto the resident service and prove CLI output/exit compatibility.
4. Add offline semantic flags, `.aslp` generation, integrity/security scans, and a reviewed Wiki sandbox profile.
5. Add Emscripten/ESM/Worker packaging and Native/WASM parity gates.
6. Add the separate Wiki plugin and explicit example tiddlers; ordinary code presentation remains the rollback fallback.
7. Add the Native stdio LSP diagnostics adapter and explicit VS Code offline setting, retaining `unreal` as default.
8. Run release, external-consumer, Wiki offline artifact, protocol compatibility, and performance gates; update Chinese documentation before English.

Rollback is additive by phase. The Wiki widget can be removed from product sources without changing read-only code. The offline VS Code backend can be disabled while the UE backend remains. Rich Diagnostics can be unrequested while legacy diagnostics remain. The existing Standalone CLI remains available throughout. Shared offline schema changes are versioned and never silently interpreted by an older consumer.

## Open Questions

None for this recorded scope. Full project intelligence in Wiki, browser execution, persistent drafts, local-service connectivity, and replacement of the complete TypeScript LSP are explicitly deferred rather than left as implementation choices.
