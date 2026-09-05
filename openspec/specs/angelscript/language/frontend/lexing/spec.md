## Purpose

Define the deterministic, engine-independent token stream consumed by the reconstructed AngelScript preprocessor and parser.

## Requirements

### Requirement: Lexical behavior is frozen per compilation session

The frontend SHALL tokenize immutable source using an explicit immutable option snapshot and SHALL NOT obtain lexical policy from a live script engine or mutable global state.

#### Scenario: Unicode identifier policy is supplied explicitly
- **GIVEN** two lexical option snapshots with different Unicode-identifier policies
- **WHEN** the same immutable UTF-8 source is tokenized under each snapshot
- **THEN** each token sequence reflects only its supplied option values
  > Observables: No lookup of `asCScriptEngine::ep`, `GEngine`, editor settings, filesystem state, or another session occurs during scanning.
- **AND** repeated tokenization with the same source and options produces byte-identical token projections and diagnostics
  > Verification: The result is independent of construction thread and ambient engine state.

### Requirement: Tokenization is pull-based and source-referential

The frontend SHALL expose a pull operation that advances through one immutable source buffer and returns compact tokens referring to source ranges rather than owning token text.

#### Scenario: A consumer requests the next token
- **WHEN** the consumer calls `Lex(Token&)`
  > Inputs: A tokenizer bound to one source buffer, frozen options, and a selected trivia mode.
- **THEN** exactly one token is returned and the tokenizer advances to the first byte after that token
  > Observables: The token contains its kind, half-open source range or equivalent start/length, required lexical flags, and only the payload appropriate to that kind.
- **AND** token spelling is recovered through the owning source snapshot
  > Boundaries: Ordinary identifier, keyword, operator, and literal tokens do not allocate or copy their spelling.

#### Scenario: A consumer needs lookahead or a retained stream
- **GIVEN** the core tokenizer is forward-only
- **WHEN** Parser requests bounded lookahead or a tooling/test consumer requests capture
- **THEN** the consumer-owned layer buffers only the requested tokens while the core `Lex` contract remains unchanged
- **BUT** full-stream retention is not the default lexical cost
  > Boundaries: Preprocessing records may retain selected tokens for provenance, but this does not make every compilation pretokenize the entire source.

### Requirement: Tokens and identifiers have compact session-owned representation

The frontend SHALL intern identifier spelling once per compilation session and SHALL use declarative token metadata for token names, classifications, and keyword properties.

#### Scenario: Repeated identifiers are scanned
- **WHEN** the same identifier spelling occurs multiple times in one session
- **THEN** its tokens refer to the same immutable identifier entry
  > Observables: Keyword or contextual-keyword metadata is obtained from the identifier entry without repeated string allocation.
- **BUT** the identifier table address and insertion order do not become durable symbol identity
  > Boundaries: Stable declaration and type identities are defined by the stable-identity capability, not by lexer interning.

#### Scenario: Reflection spellings are encountered
- **WHEN** source contains `UCLASS`, `USTRUCT`, `UENUM`, `UFUNCTION`, `UPROPERTY`, or `UMETA`
- **THEN** their exact spelling and range are preserved with deterministic lexical classification
- **BUT** Lexer does not validate annotation targets or construct reflection descriptors
  > Boundaries: Typed Attr construction and validation belong to Parser/Sema.

### Requirement: Every lexical input terminates with precise recovery

The frontend SHALL either consume source bytes or emit end-of-file on every pull operation, including malformed input.

#### Scenario: Invalid UTF-8, embedded NUL, or unknown input is encountered
- **WHEN** the tokenizer cannot form a valid language token at the current byte
- **THEN** it emits one structured lexical diagnostic and an invalid token covering a non-empty source range
- **AND** the next call resumes strictly after the consumed invalid range
  > Verification: Fuzzed and table-driven malformed inputs cannot hang or repeatedly diagnose the same byte.

#### Scenario: Trivia mode changes
- **WHEN** the caller selects skip-trivia, retain-trivia, or raw-directive scanning
- **THEN** whitespace, comments, start-of-line, and leading-space behavior follows that explicit mode
  > Observables: Non-trivia token spelling and ranges remain invariant across compatible modes.

### Requirement: Common lexical paths avoid per-token allocation

The frontend SHALL scan ordinary ASCII AngelScript source directly from immutable UTF-8 bytes without a heap allocation for each common token.

#### Scenario: A representative source corpus is measured
- **WHEN** the focused lexer microbenchmark records bytes, tokens, allocations, peak memory, and elapsed time
- **THEN** common identifiers, keywords, punctuation, and numeric tokens perform no per-token heap allocation
- **AND** throughput results are retained with corpus and environment provenance
- **BUT** elapsed time is evidence rather than a fixed cross-machine correctness threshold
  > Boundaries: A later performance contract may establish thresholds only from stable multi-environment evidence.

### Requirement: Dedicated annotation and callable declaration keywords
The Lexer SHALL classify UCLASS, USTRUCT, UENUM, UFUNCTION, UPROPERTY, UMETA, delegate and event as dedicated keyword Tokens.

#### Scenario: Lex a marked declaration
- **WHEN** active language source spells one of the supported outer keywords
- **THEN** the Token carries its dedicated kind and original source range
- **AND** nested annotation arguments remain ordinary structured payload Tokens
- **BUT** UDELEGATE is not implicitly added as an equivalent delegate declaration form
