## Context

This is the successor planning truth from the accepted diagnostics-tooling-successor handoff and inherited in-process language-service contracts. Every type and behavior described below is proposed unless explicitly identified as existing. The product implementation tasks remain pending.

The completed Builder reconstruction supplies `asCBuilder`, `asCCompilationSession`, one context-owned typed AST, immutable UTF-8 sources, explicit frozen host-definition inputs and fixed stable identities directly in `BEGIN_AS_NAMESPACE`. Its legacy runtime/test paths remain dormant. The current diagnostic engine stores flat records; semantic producers often supply generic IDs, and some declaration paths only update text projections. The indexed current migration inventory records the September 12 source baseline, including emission and CompileOutput boundaries; the obsolete September 5 attachment is not carried. A reason-string scan is not behavioral coverage: 2.1 establishes explicit branch dispositions and each producer task supplies actual cases. `asCBuilder::GetModuleDefinitionSet` / `TakeModuleDefinitionSet` own compile definitions; `GetCompileOutput` / `TakeCompileOutput` expose diagnostics and descriptors. The analysis result must retain the actual definition/source owners required by its queries, without recreating MetadataImage or treating CompileOutput as a TypeInfo owner.

Clang 22.1.8 is the local architecture reference. `Diagnostic.td`, `DiagnosticsEngine`, `SemaLookup` and `SemaCodeComplete` inform the native design; clangd `StoreDiags`, `ParsedAST`, `CodeComplete` and source-position helpers demonstrate grouping, ownership and editor-facing boundaries. Clang itself streams notes; storing explicit groups here is an intentional adaptation for deterministic parallel collection, not a claim that its engine stores the same tree.

## Goals and non-goals

Deliver rich diagnostics for all currently supported frontend failures, the four real semantic query families, and an in-process SDK language service that formats those diagnostics and exposes notes/fixes after ordinary compilation. A string-only wrapper, fabricated notes, or completed-AST-only completion cannot satisfy the contract. Reuse current AS grammar and semantic authority, not all C++ features.

The native layer may use UE basic containers and strings. It has no AS Engine requirement and no LLVM library dependency. JSON-RPC/LSP transport, asynchronous document scheduling, workspace indexing, incremental caches and existing extension migration remain separate work. `asCLanguageService` is a library facade in the plugin SDK, not a server. The TypeScript language server is evidence about future adapter requirements, not a fallback semantic provider.

## Working architecture

Hosts never talk to Parser/Sema through LSP in this Change. Layer 1 produces `asSDiagnosticGroup` values during Builder compilation. Layer 2 renders those groups (Clang-style text, JSON, atomic edits) and runs cursor queries on `asCToolingSession`. Layer 3 is `asCLanguageService`: attach the compilation result, format, inspect notes/fixes, apply one alternative in memory. Layer 4 (JSON-RPC) is a later adapter over 2 and 3.

Two in-process entry points stay distinct: `AttachCompilation` consumes an already-built diagnostic result; `Analyze` builds an owned `asCAnalysisResult` for incomplete-source queries. The language service does not wrap Complete/Hover/Definition here. The loadable diagram and LSP mapping live in `attachments/knowledges/in-process-language-service-architecture.md`.

## Accepted production and parallel execution

Source authority: [selected design](attachments/drafts/design.md), [handoff](attachments/drafts/handoff.md), [glossary](attachments/drafts/glossary.md). Q9/Q12–Q17 accept behavior and Q10/Q18 accept carryover and creation. The predecessor contracts below remain intact.

Fragment.Diag returns move-only asCDiagnostic. No-stream calls are valid. Temporary-friendly member operator<< overloads accept Argument, FixIt, RelatedRange, FStringView, int64 and bool. Payload data is owned before the expression ends. Destruction reports once into the current fragment; copying is deleted and moving transfers the reporting obligation. An invalid/submitted target cannot emit; debug assertions may diagnose misuse. Initial streaming has no Note overload, but full groups retain notes.

Tokenizer and Preprocessor use ordinary Diag helpers. Parser forwards to Sema's phase fragment. Session/Builder use current work-item fragments. Explicit Flush/Process completion/EndFragment submits; fragment destruction does not. PP cannot keep a shared mutable current-fragment slot on its const processor. No phase interface inheritance, engine single slot, new phase folder or additional consumer virtual interface is introduced.

Implement 1.1 lexical/PP production, then 1.2 scheduling, then 2.1 catalogue. Catalogue enriches the existing Diag payload without replacing the production convention. Position conversion is independent preparation. Rendering/fixes precede broad producer enrichment; the in-process facade precedes full queries.

## Queued Lex and per-file PP

X uses WorkerCount. LexBatchSize is the Q15 convention-derived option, default 4, normalized to at least 1; WorkerCount likewise has a minimum of 1. X=1 runs on the calling thread. Each fixed worker claims at most K source work items under the queue lock, processes the batch, and claims again. No one-job-per-file dispatch or static stride. Existing concurrency facilities may host X workers.

Session asCIdentifierTable uses its own FCriticalSection. Protect counters too, or admit their observation only after join. Equal spellings share one immutable heap-stable Info within the session; addresses/insertion order are not stable semantic identity. No queue lock is held across Intern. PP retains its own per-file IdentifierOwner.

Each worker owns tokenizer, stream, raw tokens, lexical fragment and local result records. Sources and PP flags are frozen. After Lex/Flush, immediately run PP on the same thread only if that file has neither hard failure nor lexical Error. A local asCTokenizer::HasErrors() accessor exposes the monotonic lexical fact independently of global collector or display policy. PP validity is a separate failure fact. Lex failure, recoverable Error or source acquisition failure does not cancel other queue work.

Join before merging State.Inputs and Preprocessed. Sort by LogicalSourceKey. Every source has a keyed outcome; never zip compact clean PP products with a full lexical input array after one file fails. Ranges and internal work-item keys maintain identity without introducing another stable-key system. Partial availability never bypasses declaration completeness or publication gates.

## Public stage observations with early PP

Lexed executes the joined Lex/PP wave and retains both products; raw-token text remains the lexical projection. Any file lexical failure or invalid PP makes the joined wave fail, while clean PP products remain inspectable on the failed Builder. Preprocessed advancement consumes retained keyed PP results, produces active-token text and never invokes Process again. Later declarations still require valid prerequisites.

Successful RunThrough(Preprocessed) and explicit Lexed then Preprocessed produce equivalent final products. Early PP availability is deliberate; token rules and successful final projections remain unchanged. Tests prove one-time work/diagnostics, sorted file identity, failed-file mapping and resumed stage observations. Illegal stage requests remain nonpoisoning.

Historical draft prose said Lex()==false broke the entire file loop. September 14 inspection shows it breaks the inner token loop while the outer file loop continues; source lookup failure does break the outer loop. Q14 still defines the new scheduler's all-work completion contract. This corrects baseline evidence without changing the accepted decision.

## Concurrency proof and tuning boundary

Compare two equal-spelling files and uneven workloads across X=1/4, K=1/4 and reversed input order. Assert canonical token/diagnostic/PP projections, equal within-session spelling pointers and correct ownership after join; never require scheduling order. A test-local seam over the same internal worker routine may inject one lexical hard failure, with no public testing option.

No measured speedup or latency target has been accepted. Use FCriticalSection first; read/write locking and sharding require evidence. Parallel declarations and stable-identity reconstruction remain excluded.

## Diagnostic data and catalog

Use one `as_diagnostic_catalog.def` with explicit numeric IDs and descriptors, consumed by C++ declarations/definitions without introducing TableGen or another build-time generator. Retain IDs with already-specific meanings (Lexer 1001–1006, preprocessor 2001–2014 and declaration 3002/3004–3007). Where an existing cause is too broad, introduce more precise appended entries; reserve retired generic numbers rather than reusing their meanings. No runtime hash or insertion order assigns diagnostic IDs.

The catalog owns symbolic cause, stage/category, default severity, warning group, format and argument kinds. Message formatting remains English by default. Semantic arguments add structured qualified-type, declaration and callable-signature display values; stable identity is included where meaningful, but a local/recovery entity does not gain a fabricated global key. The values retain enough immutable display information or an explicit result lease; they are not unowned pointers or preformatted sentences.

Evolve `asSDiagnosticRecord` as the message payload and add `asSDiagnosticGroup` with one primary, ordered notes and alternative fixes. `asCDiagnosticResult` owns ordered groups, source leases and policy/analysis summary. A note may have its own range and highlights. The primary has an explicit optional location; source-bearing diagnostics require a valid matching range, while driver/input diagnostics explicitly carry no location. Invalid provided locations remain errors rather than silently becoming nonlocated.

`asCDiagnosticFragment` collects complete groups. `asCDiagnosticsEngine` validates and merges them; `asIDiagnosticConsumer` receives an owned result view. Stage views refer to the same group identities instead of maintaining independently authoritative cumulative arrays. Keep the existing abbreviated `SerializeStable` only as an observation adapter where needed; do not parse it or treat it as lossless interchange.

Order located groups by logical source key, half-open primary range, effective severity, diagnostic ID, stable fragment key and local sequence. Nonlocated groups follow located groups and use category, stage, diagnostic ID, stable fragment key and local sequence. Notes use reason category, formal parameter ordinal where relevant, then declaration/source identity. Neither worker completion nor pointer addresses break ties.

## Policy, validity and aggregation

`asSDiagnosticOptions` is an immutable input snapshot. Defaults preserve existing reporting: warning groups enabled, warning-as-error disabled, no report limit. Specific warning overrides precede group overrides, which precede global warning policy; a disabled warning is not promoted. Hard language/internal failure facts cannot be downgraded by output policy, even when a consumer hides their presentation.

Track separately: completed stages/fragments, language errors, internal failure, warning-policy build failure, report truncation, cancellation and publication eligibility. Normal Builder success is derived from required completed stages and failure facts, not by rescanning only displayed `Error` records. Warning-as-error does not mutate semantic AST validity.

A finite error-report limit counts whole effective-error groups. Apply retention in canonical order at deterministic stage barriers, never by the first workers to arrive. Retain complete accepted notes/fixes; if work is stopped, explicitly record unperformed coverage. Fatal failures finish their group and stop unsafe dependent work. Cancellation is independently observable and cannot masquerade as an empty successful diagnostic set.

Recover at grammar-owned boundaries and propagate error-bearing values. Suppress only a direct consequence of an existing invalid value; preserve independent diagnostics and later valid nodes. A generic `recovery` or `*-analysis-failed` text is normally a derived status, not another source error.

Builder forwards structured root causes exactly once. Definition diagnostics retain their existing ranges when available. Metadata/layout/verifier outcomes remain typed internal statuses; a driver diagnostic carries the original status, detail and offending source/node when genuine, rather than converting every internal enum to an AS syntax cause. Preserve the existing behavior of rejected out-of-order API calls: a failed request does not poison previously completed stages. Expose its request status/diagnostic separately from accepted compilation failure facts.

## Rendering, positions and fixes

`asCDiagnosticRenderer` renders snippets, primary carets/highlights and attached notes from the owned result. It must distinguish a byte column, an editor encoding position and a terminal display column. Text display expands tabs consistently and has a deterministic escaped-byte fallback for malformed encoding; it never feeds display positions back into semantic identity. Clang-style output is a first-class SDK rendering: the error line names the catalogued cause and typed arguments, a caret marks the primary range, and each note is emitted with its own location and caret or range. Tests compare this text to independently authored expected strings.

Add a versioned diagnostic JSON observation containing catalog identity, default/effective severity, location or explicit absence, semantic arguments, notes, highlights, fix alternatives and summary. Stable keys use their existing fixed hex form and 64-bit revisions use strings. Exact UTF-8 replacement bytes remain recoverable; this is not an LSP wire protocol and does not change `record-v1` or `requirements-v1`.

`asCSourcePositionCodec` exposes explicit UTF-8/UTF-16 zero-based positions. Keep existing one-based byte presentation APIs unchanged. A zero-length range at EOF is valid. A CRLF pair separates lines; the position before CR is the preceding line end and after LF is the next line start; the interior between CR and LF is rejected. Interior UTF-8 byte or UTF-16 surrogate positions, overflow and out-of-line coordinates fail rather than clamp. Malformed UTF-8 remains addressable for native diagnostics but its undecodable presentation conversion returns an explicit error.

`asSDiagnosticFixAlternative` contains one title and one atomic list of `asSSourceEdit` values: logical source key, expected revision, byte range, expected original bytes and replacement bytes. `asCSourceEditApplier::Apply` validates all files and edits before constructing a new in-memory snapshot. Reject overlaps (including conflicting insertions at the same point), foreign input, stale revisions and ambiguous provenance; apply no partial edits. Source revision hashes are not security authorities, so validate expected original bytes too.

Producers offer applicable delimiter fixes only when the grammar identifies an unambiguous boundary. Typo suggestions use visible semantically viable candidates, not all names in the repository. In the initial implementation, an applicable name correction requires a unique best viable candidate, at least three input characters and edit distance one; weaker/distant/tied suggestions remain notes. Name matching never changes ordinary compilation meaning. No source-wide replacement, automatic disk write, rewrite in comments/strings/inactive bodies, or guessed edit of generated text is allowed.

## Shared semantic assessment

Introduce `asSCallAssessment` and `asSCandidateAssessment` in `as_call_assessment.h`, implemented with the current Sema/type rules. Assessment returns candidate identity/signature, visibility/access/receiver/context constraints, actual-to-formal mapping, conversion ranks, default requirements and explicit rejection reasons. Include script calls, constructors, member calls, indirect signatures and frozen-host callables; preserve their different language restrictions.

Split `ResolveCall` and `ResolveExternalCall` into assessment and commit. Complete compilation selects its result and then commits conversion/default/list-initializer nodes. Query assessment may use request-local scratch state but cannot mutate the formal AST, canonical published lookup, diagnostic result or frozen definitions. Unsupported defaults on one candidate cannot abort assessment of unrelated candidates.

Use a complete/incomplete call mode. Unknown future arguments in `F(a, |)` are not missing-required-argument failures; known duplicate named arguments or incompatible supplied arguments remain relevant. List-initializer probes retain uncertainty until context is sufficient; do not guess a type or write speculative nodes into the formal result. Typo correction, completion and signature help share these assessment facts.

## In-process language service

`asCLanguageService` is the public SDK facade for compile-time diagnostic consumption. It lives in `BEGIN_AS_NAMESPACE` with a header on the existing AngelscriptRuntime public include path (`frontend/Compile/as_language_service.h`). It does not extend `asIScriptEngine`, create an Engine, own a background thread, or speak JSON-RPC.

```cpp
enum asELanguageServiceFeature : asDWORD
{
	asLANGUAGE_SERVICE_DIAGNOSTICS = 1u << 0,
	asLANGUAGE_SERVICE_FIXES = 1u << 1
};

class asCLanguageService
{
public:
	static std::shared_ptr<asCLanguageService> Create(asDWORD Features =
		asLANGUAGE_SERVICE_DIAGNOSTICS | asLANGUAGE_SERVICE_FIXES);
	asELanguageServiceStatus AttachCompilation(
		TSharedRef<const asCDiagnosticResult, ESPMode::ThreadSafe> Result);
	TConstArrayView<const asSDiagnosticGroup> GetGroups() const;
	asELanguageServiceStatus Format(const asSDiagnosticGroup& Group, FString& OutText) const;
	asELanguageServiceStatus ApplyFix(
		const asSDiagnosticFixAlternative& Alternative,
		TSharedPtr<const asCSourceSnapshot, ESPMode::ThreadSafe>& OutSnapshot);
};
```

`AttachCompilation` retains a shared immutable Builder/session diagnostic result which itself owns the exact source snapshot; it does not copy semantic objects into a second diagnostic authority. `Format` delegates to `asCDiagnosticRenderer` against that retained snapshot. `GetGroups` and note/fix accessors return structured catalog identity, typed arguments, ranges and replacement bytes so hosts can log, assert or re-query without parsing English text. `ApplyFix` is enabled only when `asLANGUAGE_SERVICE_FIXES` is set; it uses `asCSourceEditApplier` and returns a new snapshot.

Completion, signature help, hover and definition remain `asCToolingSession` methods in this Change. Feature bits for those queries are reserved and must report unavailability from this facade rather than wrapping the session. A later protocol adapter may call this facade and the tooling session; it is not introduced here.

## Native query facade and ownership

Use the following native facade directly in the existing AS namespace. This is an interface shape, not code implemented by this Change's creation:

```cpp
asCToolingSession(TSharedRef<const asSAnalysisInputs, ESPMode::ThreadSafe> Inputs);
asSAnalysisResponse Analyze(const asSCancellationToken& Cancel);
asSCompletionResult Complete(asSQueryPosition Position, const asSCancellationToken& Cancel);
asSSignatureHelpResult GetSignatureHelp(asSQueryPosition Position, const asSCancellationToken& Cancel);
asSHoverResult GetHover(const asCAnalysisResult& Result, asSQueryPosition Position,
                       const asSCancellationToken& Cancel);
asSDefinitionResult FindDefinition(const asCAnalysisResult& Result, asSQueryPosition Position,
                                  const asSCancellationToken& Cancel);
```

`asSAnalysisInputs` owns the frozen source snapshot, existing Builder options/type context, explicit source membership/dependencies and explicit frozen host-definition inputs. `asSQueryPosition` contains the exact snapshot-local file/byte location. `asSAnalysisResponse` retains a shared const `asCAnalysisResult` when safe data is available. Query result values either own copied display/identity data or retain that result once; they never expose an unowned temporary array view.

Every response carries input identity (logical source revisions and immutable option/environment identity), status and coverage. Keep caller correlation/document-version data distinct from source content revisions. Result-local handles validate the owning analysis instance, not just identical file numbers. Use existing semantic stable keys for entities that have them; do not introduce a new global type registry or stable-key family.

Statuses are `Success`, `Partial`, `Cancelled`, `InvalidInput`, `InvalidPosition`, `SnapshotMismatch` and `AnalysisUnavailable`. Successful empty candidates/targets use `Success` with an empty payload. Partial carries explicitly available phases/fragments. Cancellation may retain previously safe partial data but remains `Cancelled`. Cancellation is cooperative at stage and bounded parse/assessment loops; it has no background thread, scheduler or server ownership.

`asCAnalysisResult` owns its actual CompilationSession/AST context, source/token/identifier storage, diagnostic result, type context and an owned explicit definition-input bundle. That immutable bundle owns unique DefinitionSets (including their transitive dependencies) transferred into it before analysis; session dependency pointers borrow only from that retained bundle. The current raw-pointer Dependencies array is not a lease. Reject unretained or mutable dependency inputs. Do not add shared ownership to individual TypeInfo or turn CompileOutput into their owner. After worker join, `FreezeForTooling` checks safe ownership, ranges and readable edges and prevents mutation while allowing explicit recovery nodes. It is a distinct state from valid AST sealing; `VerifyAST`, the normal codec and DefinitionsFrozen keep their stricter contracts. Never set an existing sealed bit merely to enable traversal. An unsafe ownership graph returns `AnalysisUnavailable`, not a traversable partial result.

Tooling analysis completes declaration collection for the explicit source set before semantic resolution. It can skip invalid declaration regions while analyzing independently valid bodies. CompilationSession phase facts and per-fragment availability remain authoritative; completion does not resolve against an accidentally half-collected global declaration set.

## Cursor parsing and concrete query behavior

Each completion/signature request creates isolated Parser/Sema state over the same immutable inputs. A cursor token describes a byte position without modifying source buffers. Preserve scope, declaration-before-use, shadowing, receiver and active-argument context at that position. Capture global declarations through the ordinary collection barrier first; parse the target body up to the cursor using request-local state. Query-only recovery and marker tokens neither enter the formal AST nor publish ordinary diagnostics.

Completion returns name/kind, display signature/type, optional semantic identity, the exact identifier replacement range and a deterministic rank. Enumerate current scope, parameters, accessible members, namespaces/types and grammar-appropriate keywords. Rank by scope proximity, prefix quality, known expected-type compatibility, lexical match cost and qualified-name/stable-identity tie-breakers. Unknown expected types do not filter otherwise valid candidates. In comments/strings/inactive source, ordinary semantic completion returns an empty result; directive-specific completion is not introduced.

Signature help returns the enclosing call at the cursor, ordered signatures, active argument, per-candidate formal mapping and known viability/rejection. Select the innermost open call containing the cursor; nested expression commas are not argument separators. Named arguments map to their named formal and defaults remain visible. A complete ordinary call and an equivalent cursor request must agree on applicable semantics.

Hover/definition use a token-to-semantic-reference selection index derived from the retained typed graph, not a second semantic database. Any containing token wins; a containing punctuation/comment token without a semantic reference returns empty without falling back to a left identifier. Only if no token takes precedence may an immediately touching identifier end match, including EOF. Whitespace beyond that boundary and unbound recovery produce empty results. Member/qualified-name components resolve their own bindings, and a resolved callee selects its actual overload.

Hover returns available type, signature, qualification, declaration kind and existing retained source documentation if present; this Change does not add a documentation-comment parser. Definition returns real definitions first, then declarations for the same entity, deduplicated and sorted by logical source/range within each group. Frozen-host symbols without locations return `NoSourceTarget` as the successful target disposition and may still provide hover/completion/signature information. No fake file or unrelated same-name overload is substituted.

## Verification and migration boundaries

Task cards own exact files, fixtures, expected RED and commands. Related tests and implementation form bounded groups; compileable missing-interface stubs may support observed behavioral RED, but postimplementation tests cannot be relabeled as historical RED. Pure structural catalog checks complement, never replace, real language input cases.

The inventory enumerates known strings/enums plus silent returns and source-less losses. Each producer branch receives one disposition: specific source diagnostic, derived stage/view status, or preserved internal status with boundary explanation. Completion requires concrete scenario mapping and no unexplained current branch. No claim of all possible future AS diagnostics follows from this inventory.

Current replacement CQTest is sufficient; do not depend on unimplemented helpers from the separate testing-framework Change. NativeEngine/Baseline execution belongs only to later implementation. Initial creation uses strict record/DAG and focused authoring checks; it neither edits current specs nor starts UE.

## Risks and alternatives

- Rich records alone were rejected: without producer migration, actual users still receive generic errors and lost source data.
- Completed-AST-only completion was rejected: Parser scope stacks and incomplete argument/member states are not recoverable from the existing finalized declaration table alone.
- Directly reusing mutating `ResolveCall` was rejected: candidate probing currently performs conversion/default work and may report diagnostics during search.
- Full clangd cloning was rejected: a server, index and scheduling/cache policy would materially expand this native compiler Change. Independent cursor parses cost more CPU than an incremental editor implementation; measure native work separately from UE startup and add caching only in scoped later work.
- Putting JSON-RPC in this Change was rejected after an explicit user replan: the SDK gets an in-process `asCLanguageService` for format/note/fix consumption, while stdio/pipe LSP transport remains a later adapter.
- Partial graph support is the highest ownership risk. Preserve publication gates and test cross-result handles, host leases, workers, cancellation and unchanged formal results before enabling all query consumers.
- Existing root/submodule changes and other planning records are user-owned. This creation adds the successor and closes the explicitly replaced predecessor; unrelated workspace changes are preserved. Future implementation can be reverted within its owned paths without activating either retired AST or the old runtime; no persistent asset/data migration is required.

## Exploration carryover

Four indexed talks preserve production, supersession and native-versus-protocol decisions. Eight change-local knowledge candidates preserve the confirmed Q10/Q18 package. Neither is promoted to current capability knowledge during creation. The migration inventory and validation evidence stay as bounded data attachments, not another task state store.

## Current integration contracts after coverage replan

`CaptureResult()` publishes a shared const diagnostic snapshot at a deterministic barrier; later stage captures are new snapshots. Stable group identities let stage views identify subsets of their associated snapshot. Existing flat getters and consumers remain derived compatibility projections until migrated; new consumers never reconstruct groups from flat arrays. `asCCompileOutput::GetDiagnosticResult()` and the language service retain the same immutable snapshot, including source ownership and summary. Descriptor mutation cannot invalidate a captured diagnostic result. Reattachment replaces the service-held reference; group/fix operations validate owner identity and do not accept handles from the previous attachment.

Group and fix values carry their diagnostic-result owner identity. `GetGroups` views are valid while that result is retained; callers that keep data across reattachment must retain the original result or copy the owned group/fix value. Foreign-owner tests use such valid retained/copied values, never dangling C++ references. The checked `Format` returns an explicit language-service status and writes `OutText` only on success. Language-service statuses distinguish success, unavailable feature, invalid input, result mismatch and stale/conflicting edit rejection; they do not reuse successful empty output to signal failure.

Builder failure propagation retains the existing `asSByteCodeEmissionResult` status and failure fields, including function key, node kind, real source/fragment identity and diagnostic payload. Structured emission failure is part of the current staged compile boundary, not a request to extend bytecode lowering. Report a nonlocated internal cause when no authenticated source range exists; line/column alone cannot justify borrowing the first token. Illegal API stage requests report their own rejection without updating accepted-stage language/internal failure facts.

The owned analysis bundle is transferred/constructed for tooling; ordinary Builder callers may keep their current explicit borrowed input lifetime contract. Tooling admission validates the full retained closure before starting workers. `FreezeForTooling` follows worker join, rejects unsafe edges and blocks all AST allocation/mutation paths. It allows explicit recovery nodes but never sets the existing valid-seal flag. Cursor parsing remains separate request-local scratch state; navigation uses token/reference bindings retained by the analysis result. Formal source offsets, groups and definition projections do not change when queries run.

Task ownership: 2.1 result/catalog/policy; 2.2 renderer; 2.3 position codec; 2.4 edit applier; 3.1 syntax producers; 3.2 semantic producers; 3.3 assessment; 3.4 Builder/CompileOutput/emission bridge; 4.1 analysis/selection; 4.4 cursor preparation; 4.2 completion/signature; 4.3 navigation; 5.1 facade; 6.1 integrated proof. The predecessor acceptance boundaries are mapped to successor task IDs in planning-validation.md. The interface shapes in those cards are proposed implementation contracts, and supporting request/value types follow the existing SDK naming convention.

## Review repair constraints (2026-09-15)

These constraints implement the accepted native-query contracts without adding language or editor scope. Bind responses to immutable source revisions and semantic options/owned host environment even when caller Identity is zero. Navigation never substitutes matching paths for matching revisions. Returned ranges, signatures and display facts own or retain their source/context provenance.

Cursor parsing captures active lexical scopes rather than every declaration in the prefix AST. Use those facts for declaration-before-use, shadowing, expected-type ranking and authoritative member access. Valid file-scope/EOF positions have grammar context; unknown files/out-of-range positions and unavailable analysis retain their explicit error statuses. Cooperative cancellation remains distinct from successful empty results.

Signature help exposes ordered candidate signatures, formal mappings and known viability/rejection from shared assessment. Return copied facts or retained owners, never unowned request-local AST pointers. Share declaration preparation within one request while preserving request-local Parser/Sema mutation. The existing safe-ownership/range/readable-edge audit before FreezeForTooling remains required, independently of valid-AST sealing.

The original GREEN reports prove their exercised historical slice. Added tasks own missing acceptance and both user-requested Reviews need current-snapshot disposition before closure.
