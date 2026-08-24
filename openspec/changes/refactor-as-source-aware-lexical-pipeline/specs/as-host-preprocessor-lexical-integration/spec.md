## ADDED Requirements

### Requirement: The UE preprocessor consumes maintained-fork lexical facts
`FAngelscriptPreprocessor` SHALL obtain comment, whitespace, string/literal, raw identifier, operator, punctuation, and delimiter boundaries through a narrow `FAngelscriptPreprocessorLexicalAdapter` backed by the maintained-fork SourceManager/RawLexer contracts. The adapter SHALL expose non-owning UE-friendly views without adding Unreal dependencies to the maintained-fork lexical implementation.

#### Scenario: Host scans authored source
- **WHEN** the UE preprocessor scans an authored source buffer containing code, comments, strings, identifiers, and nested delimiters
- **THEN** every low-level spelling boundary used by host logic originates from the shared RawLexer facts
- **AND** the adapter does not copy Clang token types or move Unreal types into the core lexer

#### Scenario: Parser scans processed source
- **WHEN** the UE preprocessor emits a different immutable processed/generated buffer
- **THEN** the core Parser path lexes that final buffer as its own SourceManager generation
- **AND** this is distinguished from forbidden Parser rewind/re-tokenization of the same generation

### Requirement: Host-specific preprocessing semantics remain host-owned
The lexical adapter MUST NOT implement UE/host source-provider access, includes, conditionals, imports, module policy, virtual paths, descriptors, generated declarations, ClassGenerator metadata, source rewrites, compilation events, or activation. `FAngelscriptPreprocessor` and its existing host services SHALL remain authoritative for those behaviors.

#### Scenario: UCLASS-like source is encountered
- **WHEN** the adapter returns identifier and delimiter facts for a UCLASS, USTRUCT, UENUM, property, function, mixin, default, namespace, or import shape
- **THEN** the UE preprocessor interprets the host grammar and emits descriptors/transforms
- **AND** the RawLexer has no knowledge of Unreal reflection or descriptor meaning

#### Scenario: Include or provider operation is requested
- **WHEN** authored source requires include resolution, conditional policy, or virtual source-provider access
- **THEN** the UE host performs that operation under existing provider/policy contracts
- **AND** the RawLexer performs no file, network, module, or provider access

### Requirement: Migration preserves exact preprocessor output contracts
For every migrated feature cluster, the shared-lexer path SHALL preserve current processed source bytes where those bytes are a maintained contract, descriptor records, generated declarations, source-provider requests, stable module/logical paths, diagnostics, summaries, compilation events, and downstream compile/VM behavior. Any intentional output normalization MUST be proposed separately and versioned where persistence or diagnostics depend on it.

#### Scenario: Existing valid script is preprocessed
- **WHEN** a maintained preprocessor fixture or Script-corpus file succeeds under the current scanner
- **THEN** the adapter path produces equivalent processed text, descriptors, mappings, events, compile success, and VM-observable behavior

#### Scenario: Existing invalid script is preprocessed
- **WHEN** a maintained fixture fails with a covered diagnostic and source range under the current scanner
- **THEN** the adapter path fails with the maintained diagnostic contract and mapped source range
- **AND** it does not publish partial descriptors or processed source as successful output

### Requirement: Authored and generated provenance is retained through host rewrites
Whenever the UE preprocessor copies, removes, substitutes, injects, or concatenates source, it SHALL register the resulting processed/generated buffer and mapping segments with SourceManager. Mappings SHALL distinguish exact authored origin, generated-only text, and ambiguous/non-contiguous origin. Host diagnostics and later Parser/AST diagnostics MUST NOT guess a false authored range.

#### Scenario: Host injects generated declaration text
- **WHEN** preprocessing emits declaration or wrapper text not present in the authored buffer
- **THEN** the generated range is marked generated-only or linked to an explicit valid origin according to existing provenance policy
- **AND** later token/Parser diagnostics can resolve the same mapping

#### Scenario: Host copies an authored span
- **WHEN** preprocessing copies a contiguous authored span unchanged into the processed buffer
- **THEN** SourceManager records a deterministic processed-to-authored mapping for that span
- **AND** repeated preprocessing of identical inputs yields the same normalized mapping table

### Requirement: Delimiter and text-state decisions use one lexical boundary authority
The UE preprocessor SHALL use shared lexical facts when deciding whether braces, parentheses, brackets, commas, semicolons, directive markers, or identifier spellings occur in code rather than inside comments or literals. Matching-delimiter helpers SHALL be token-based and bounded. Host grammar MAY interpret token sequences contextually but MUST NOT reimplement raw comment/string escape scanning after final cutover.

#### Scenario: Delimiter appears inside a literal or comment
- **WHEN** an apparent brace, parenthesis, bracket, comma, semicolon, directive marker, or keyword spelling occurs inside a comment or literal token
- **THEN** host structural parsing does not treat it as code punctuation or a directive/declaration keyword

#### Scenario: Delimiter depth limit is exceeded
- **WHEN** authored input exceeds the configured host delimiter nesting limit
- **THEN** preprocessing terminates with a controlled source-located failure
- **AND** it does not recurse or allocate without bound

### Requirement: Preprocessor migration is feature-clustered and differential
The old and adapter-backed scanners SHALL coexist only in development/test comparison modes during migration. Comment/string boundaries, identifiers/keywords, delimiter matching, directives, declarations/descriptors, imports/namespaces, literals/defaults, and generated-source mapping SHALL migrate as explicit clusters. Only one selected path may publish output, and a mismatch MUST block removal of the old cluster implementation.

#### Scenario: Cluster comparison differs
- **WHEN** old and adapter-backed processing differs in tokens consumed, processed bytes, descriptor fields, mappings, diagnostics, summaries, events, or provider requests
- **THEN** the cluster remains on the old authoritative implementation
- **AND** the mismatch is recorded with deterministic source evidence

#### Scenario: Cluster cutover passes
- **WHEN** all focused tests and representative corpus files for one cluster compare equal under isolated runs
- **THEN** the adapter-backed cluster may become authoritative
- **AND** the superseded low-level scanning helper for that cluster is removed rather than left as a second production authority

### Requirement: Preprocessor failure cannot leak partial host state
Lexical, mapping, limit, cancellation, provider, directive, or descriptor failures SHALL abort the current preprocessing transaction before successful source/descriptor publication. Existing module, Hot Reload, or active-generation state SHALL remain unchanged. Comparison mode SHALL not merge partial results from old and new paths.

#### Scenario: Lexical adapter reports malformed input
- **WHEN** the adapter reports an unterminated literal/comment, invalid range, token limit, or non-progress failure
- **THEN** preprocessing reports the mapped diagnostic and discards transaction-local processed text, descriptors, and mappings
- **AND** no executable module is activated from that failed result

#### Scenario: Hot Reload replacement fails preprocessing
- **WHEN** an edited source generation fails in the adapter-backed preprocessing path
- **THEN** the prior module/generation remains current
- **AND** no partial new lexical buffer or descriptor graph becomes visible to readers

### Requirement: Virtual paths and source-provider identity remain stable
Adopting shared lexical facts SHALL preserve existing virtual script path, stable module key, source-provider selection, include/import identity, and offline bundle mapping contracts. SourceManager buffer-local IDs MUST NOT replace those stable host identities in descriptors, Cache V2, Hot Reload, or diagnostics.

#### Scenario: Virtual script path is preprocessed
- **WHEN** a source provider returns a script under an existing virtual/logical path
- **THEN** preprocessing and later diagnostics preserve that path and stable module identity
- **AND** build-local SourceManager IDs remain an internal lookup detail

#### Scenario: Explicit offline bundle source is used
- **WHEN** Standalone/UE validation supplies its authoritative logical source mapping
- **THEN** the same core lexer operates on the resulting buffer
- **AND** the UE lexical adapter does not introduce fallback source search or merge behavior

### Requirement: Host lexical state is transaction-local and concurrency-safe
Each preprocessing request SHALL own or lease immutable source generations and transaction-local adapter/cursor state. Concurrent preprocessing requests MUST NOT share mutable lexer positions, identifier/literal tables, delimiter stacks, descriptor builders, or mapping writers without an explicit synchronized owner. Cancellation and source replacement SHALL invalidate publication, not mutate an already published generation.

#### Scenario: Concurrent modules preprocess
- **WHEN** two modules preprocess different authored buffers concurrently
- **THEN** their lexical traversal, mappings, descriptor output, errors, and cancellation state remain isolated

#### Scenario: Source changes during preprocessing
- **WHEN** a newer authored generation supersedes an in-flight request before publication
- **THEN** the stale request cannot publish as the current generation
- **AND** its immutable buffers remain safe only until transaction readers release them

### Requirement: Final host cutover removes duplicate raw scanners
After all host parity and performance gates pass, production `FAngelscriptPreprocessor` code SHALL NOT maintain independent comment, string/literal escape, raw identifier-boundary, or generic delimiter scanners that duplicate the maintained RawLexer. Host-specific token-sequence grammar and transformations SHALL remain. No Shipping/runtime option SHALL select a legacy or dual raw scanner.

#### Scenario: Final source scan is performed
- **WHEN** the completed change is scanned and the preprocessor/Script-corpus suites run
- **THEN** raw lexical boundaries come from the maintained lexer adapter
- **AND** any remaining byte-level scanning helper is justified as host transformation/output work rather than duplicate lexical classification

#### Scenario: Shared lexer rejects a valid host construct
- **WHEN** a current host fixture cannot be represented by the shared lexical-facts contract
- **THEN** final cutover is blocked and the adapter contract is extended with host-neutral facts
- **AND** production does not silently fall back for only that source fragment
