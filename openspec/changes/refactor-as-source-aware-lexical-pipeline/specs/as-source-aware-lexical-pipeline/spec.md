## ADDED Requirements

### Requirement: Lexical input is owned by one source manager
Every maintained-fork lexical build SHALL register immutable source-buffer generations with one `asCSourceManager`. The manager SHALL distinguish stable logical source keys from build-local buffer IDs, SHALL provide checked byte locations/ranges and line tables, and SHALL represent authored, processed, and generated source mappings without storing owning strings in each token.

#### Scenario: Token location resolves after Parser rewind operations disappear
- **WHEN** a token is produced for a registered source buffer and Parser later performs speculative parsing through token checkpoints
- **THEN** the token range resolves to the same logical source, byte offsets, row, and column without re-tokenizing the source

#### Scenario: Generated source maps to authored source
- **WHEN** a processed or generated token has a valid authored origin mapping
- **THEN** diagnostics can report both its generated range and the mapped authored range through SourceManager
- **AND** the token itself does not own a copied source path or mapping graph

#### Scenario: Foreign range is rejected
- **WHEN** a range crosses buffer generations, exceeds the registered buffer length, or overflows offset arithmetic
- **THEN** SourceManager rejects it with a stable error before Parser, cache, dump, or diagnostic publication

### Requirement: Tokens are compact source-aware lexical facts
The internal token model SHALL carry a token kind, one contiguous source spelling range, required lexical flags, and optional build-local identifier/literal references. It MUST NOT carry Parser/AST nodes, Runtime semantic pointers, Unreal objects, Clang/LLVM objects, owning source strings, or durable Cache V2 identity.

#### Scenario: Parser receives a normal token
- **WHEN** the Lexer recognizes a valid identifier, keyword, literal, operator, or delimiter
- **THEN** Parser receives a token whose kind and spelling range reproduce current maintained behavior
- **AND** its source location belongs to the exact immutable buffer generation that was scanned

#### Scenario: End of file is explicit
- **WHEN** lexing reaches the end of a source buffer
- **THEN** it emits one explicit EOF token at the checked end offset
- **AND** repeated cursor lookahead observes the same buffered EOF token without scanning again

### Requirement: Raw lexing advances monotonically and preserves current spelling boundaries
`asCRawLexer` SHALL scan one immutable source buffer from beginning to end without Parser grammar or host-policy dependencies. Every non-EOF result, including malformed input, MUST consume at least one input byte/code unit. The recognized whitespace, comment, identifier, literal, operator, punctuation, error, and EOF boundaries SHALL preserve current accepted AngelScript behavior unless a separate language change explicitly modifies it.

#### Scenario: Longest operator match is stable
- **WHEN** source begins with overlapping valid operator spellings
- **THEN** raw lexing selects the same longest valid token boundary as the maintained tokenizer baseline

#### Scenario: Unterminated spelling cannot hang
- **WHEN** source contains an unterminated string, heredoc-like literal, block comment, invalid byte sequence, or malformed numeric spelling
- **THEN** the Lexer emits a bounded lexical error/range and always advances or terminates
- **AND** repeated execution produces the same error category and range

#### Scenario: Parser backtracking does not move the Lexer backward
- **WHEN** Parser restores an earlier speculative checkpoint
- **THEN** only the TokenCursor index changes
- **AND** the RawLexer invocation position and already-buffered tokens are not rewound or regenerated

### Requirement: Identifier, keyword, literal, and trivia policies are separated
Raw identifier boundaries SHALL be recognized before keyword lookup. Keyword classification SHALL use an explicit language/engine-option snapshot. Identifier interning and literal records SHALL be build-local. Literal parsing SHALL validate lexical spelling and decoding but MUST NOT perform overload resolution, implicit conversion, Runtime value construction, or final semantic typing. Trivia filtering SHALL reuse raw tokens rather than a separate scanner.

#### Scenario: Raw host identifier is not forced through Parser keyword policy
- **WHEN** the host adapter requests the spelling boundary for a raw identifier
- **THEN** it receives that identifier spelling even if the Parser channel would classify the same spelling as a keyword

#### Scenario: Literal lexical and semantic work remain separate
- **WHEN** a numeric or text literal has a lexically valid spelling
- **THEN** the lexical layer records only the validated spelling/decoded lexical facts
- **AND** Parser/Sema/compiler stages remain responsible for its semantic type and conversion behavior

#### Scenario: Trivia has one boundary authority
- **WHEN** the Parser filters comments and whitespace while the UE adapter retains them
- **THEN** both views originate from the same RawLexer token boundaries
- **AND** neither consumer maintains a second comment/string scanner

### Requirement: TokenBuffer and TokenCursor provide indexed bounded consumption
`asCTokenBuffer` SHALL materialize tokens on demand in an append-only sequence for one immutable source-buffer generation, scanning each required source portion at most once. `asCTokenCursor` SHALL provide current token, bounded lookahead, consume, checkpoint, restore, and commit operations using token indices. Checkpoints MUST be validated against their owner and source generation.

#### Scenario: Nested speculative parsing restores exactly
- **WHEN** Parser creates nested checkpoints, consumes tokens, commits an inner alternative, and restores an outer alternative
- **THEN** the cursor returns to the exact recorded token index
- **AND** all previously materialized token kinds/ranges remain unchanged

#### Scenario: Foreign checkpoint fails closed
- **WHEN** a cursor receives a checkpoint from another token buffer or source generation
- **THEN** restore fails deterministically without changing cursor position or source state

#### Scenario: Lookahead limit is exceeded
- **WHEN** Parser requests lookahead beyond the configured hard limit
- **THEN** compilation reports a controlled source-located limit failure
- **AND** the buffer does not allocate an unbounded token sequence

### Requirement: The current Parser migrates to token-index navigation before semantic AST cutover
The maintained `asCParser` SHALL consume `asCTokenCursor` without directly calling the legacy tokenizer or using byte-position rewind to regenerate tokens. Grammar, contextual interpretation, source recovery, and Parser depth/cartesian guards SHALL remain Parser responsibilities. This lexical migration MUST NOT require canonical AST/Sema implementation and MUST remain compatible with the temporary `asCScriptNode` output until the related canonical compiler change replaces it.

#### Scenario: Existing Parser grammar uses the new cursor
- **WHEN** the native frontend compiles a currently accepted declaration, statement, expression, list pattern, default argument, or import
- **THEN** Parser recognition obtains all input tokens through TokenCursor
- **AND** compile acceptance, maintained diagnostics, source ranges, and resulting VM behavior match the frozen baseline

#### Scenario: Syntax recovery restores by token index
- **WHEN** Parser speculates or recovers from malformed syntax
- **THEN** it restores/advances through token indices and emits the maintained recovery diagnostics
- **AND** no production call re-tokenizes the same source generation from a saved byte position

### Requirement: Public ParseToken remains behaviorally compatible
`asIScriptEngine::ParseToken` SHALL retain its current public signature and compatibility behavior for token kind, consumed length, engine-option handling, valid and invalid input boundaries, and error results. Its implementation SHALL delegate to the new lexical logic without exposing internal SourceManager, token, identifier, literal, or cursor lifetimes.

#### Scenario: Existing embedder tokenizes one spelling
- **WHEN** an embedder calls `ParseToken` with an input covered by the maintained public tokenizer matrix
- **THEN** it receives the same public token classification and consumed length as before migration

#### Scenario: Caller input has no persistent owner
- **WHEN** `ParseToken` returns
- **THEN** no internal token or source view retaining the caller's buffer escapes the call
- **AND** later compiler activity cannot access that caller memory through the lexical facade

### Requirement: Lexical diagnostics and dumps are deterministic
Lexical errors SHALL have stable categories and source ranges. Row/column diagnostics SHALL be derived through SourceManager. A normalized token dump SHALL be deterministic for the same source, compiler options, and lexical contract; it MUST NOT contain raw pointers, process-local IDs as durable identity, or become accepted compiler input.

#### Scenario: Identical inputs produce identical dumps
- **WHEN** identical source and lexical options are scanned in separate Engines or processes
- **THEN** normalized token dumps are byte-identical after stable logical source normalization
- **AND** no pointer spelling or build-local identifier ID affects equality

#### Scenario: Mapping is unavailable
- **WHEN** a generated token has no valid authored-origin mapping
- **THEN** diagnostics report the generated source range and explicit missing-origin state
- **AND** they do not fabricate an authored file/line coordinate

### Requirement: Token state is build-local and not persisted as compiler authority
Live TokenBuffer, TokenCursor, lexer offsets, checkpoints, interned identifier IDs, and literal-table IDs SHALL be owned by one compilation/build generation and released when no active frontend consumer needs them. Cache V2, public AST snapshots, and `SaveByteCode` MUST NOT depend on or persist a mandatory live token stream. Durable records MAY persist stable source keys, hashes, mappings, ranges, and a lexical compatibility revision.

#### Scenario: Cache lexical revision is incompatible
- **WHEN** a cached compiler artifact was produced under an incompatible lexical contract revision
- **THEN** restore reports a normal safe miss/incompatibility and recompiles from authoritative source when allowed
- **AND** it never deserializes old token bytes into live token objects

#### Scenario: Successful build releases discardable tokens
- **WHEN** Parser/Sema/CodeGen complete and no explicit build-local consumer retains lexical data
- **THEN** token buffers, identifier tables, literal tables, and checkpoints can be destroyed without affecting VM execution or retained AST source ranges

### Requirement: Lexical migration uses isolated shadow convergence
Development/test builds SHALL be able to compare old and new lexical paths over identical immutable inputs in isolated Engine/build invocations. Comparison SHALL cover tokens, errors, Parser acceptance/recovery/diagnostics, source ranges, downstream compile behavior, and performance counters. Only one selected path may publish executable or host-processed state, and a mismatch MUST block that migration gate rather than merge results.

#### Scenario: Token equality is insufficient
- **WHEN** old and new token sequences compare equal but Parser diagnostics, recovery, source mappings, or VM-observable behavior differ
- **THEN** the convergence gate fails and the old production path remains authoritative for that milestone

#### Scenario: Final cutover succeeds
- **WHEN** native SDK, preprocessor, Script-corpus, Standalone, UE build, malformed-input, determinism, and performance gates pass
- **THEN** the new lexical pipeline becomes the sole production frontend token source
- **AND** no Shipping/runtime setting selects a legacy or dual lexer

### Requirement: Lexical processing is bounded, progress-safe, and compilation-local
The implementation SHALL use checked offsets and explicit limits for source bytes, token count, trivia/literal spans, decoded literal output, lookahead, checkpoint nesting, and delimiter depth. Source buffers SHALL be immutable, and mutable lexer/token tables SHALL be confined to one compilation owner unless a later design adds synchronization. The accepted implementation SHALL record time, allocation, and peak-memory baselines and SHALL require explicit review for regressions beyond the agreed budget.

#### Scenario: Adversarial source hits a limit
- **WHEN** source exceeds a configured lexical size, token, lookahead, literal, checkpoint, or delimiter limit
- **THEN** compilation terminates with a stable controlled diagnostic
- **AND** it does not wrap offsets, loop indefinitely, exhaust memory without a limit, or publish a partial executable module

#### Scenario: Parallel compilations use separate lexical state
- **WHEN** two Engines or compilation workers lex different source generations concurrently
- **THEN** their cursors, identifier IDs, literal records, checkpoints, errors, and token buffers do not mutate shared process-global lexical state

### Requirement: The lexical layer remains host-neutral and ready for the canonical compiler
SourceManager lexical substrate, RawLexer, classifier, literal parser, TokenBuffer, and TokenCursor SHALL compile as maintained-fork standard C++ for UE and Standalone without Unreal, Clang, or LLVM libraries. The related canonical Parser+Sema pipeline SHALL consume these token/source contracts rather than define a competing lexical or source identity system.

#### Scenario: Standalone and UE classify the same processed source
- **WHEN** UE and Standalone submit byte-identical processed source with the same AngelScript lexical options
- **THEN** the core lexer emits the same normalized token kinds, spellings, ranges, and lexical errors
- **AND** host-specific source preparation remains outside that equality claim

#### Scenario: Canonical Parser migration begins
- **WHEN** `refactor-as-canonical-typed-ast-compiler` replaces legacy Parser-node semantic consumption with Sema actions
- **THEN** it reuses the established SourceManager locations and TokenCursor input
- **AND** it does not create a second token model, live token cache schema, or SourceManager implementation
