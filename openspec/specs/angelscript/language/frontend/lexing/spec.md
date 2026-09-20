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

The frontend SHALL intern identifier spelling once per compilation session, preserve equal-spelling identity under concurrent file tokenization, and use declarative token metadata for names, classifications and keyword properties.

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

#### Scenario: Repeated spellings arrive concurrently

- **GIVEN** A.as and B.as each contain `int Shared;` in one immutable source session
- **WHEN** one or several workers tokenize the files in any arrival order
- **THEN** both Shared tokens refer to the same immutable session-owned identifier entry

    The entry's spelling and token classification remain readable until the owning session is released. Pointer identity is compared only inside that session.

- **AND** canonical token kinds, spellings, byte ranges and diagnostic projections equal the single-worker result
- **BUT** pointer values, allocation order and worker completion order never become durable declaration or type identity

### Requirement: Lexical failure facts are file-local and independent of presentation

A tokenizer SHALL retain whether its own input produced lexical Error diagnostics independently of other files, consumer submission and diagnostic display policy.

#### Scenario: One tokenizer fails while another is clean

- **GIVEN** A.as contains an unterminated string and B.as contains `int B;`
- **WHEN** both tokenizers use the same diagnostic engine and flush their fragments
- **THEN** A retains its lexical-error fact and B remains free of lexical errors

    Flushing, hiding A's diagnostic, or submitting A before B must not change either file's lexical fact. A recoverable Error remains distinct from a hard Lex operation failure.

- **AND** A's recoverable tokenization still advances through its retained invalid/unterminated token to EOF

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

#### Scenario: Leading UTF-8 byte-order mark is trivia

- **GIVEN** immutable source bytes beginning with `EF BB BF`

    The three bytes remain part of the owning source snapshot. They are not removed by text ingestion, and every following token range remains relative to the original byte buffer.

- **WHEN** the tokenizer scans the leading byte-order mark under any Unicode-identifier policy

    RetainTrivia exposes one `Whitespace [0,3)` token. SkipTrivia consumes the same range before returning the first non-trivia token.

- **THEN** the byte-order mark behaves as leading whitespace without emitting a lexical diagnostic

    It preserves `StartOfLine`, establishes `LeadingSpace` for the following token or end-of-file, and leaves the selected Unicode-identifier policy unchanged.

- **AND** end-of-file and all following token ranges use the complete source byte count

    For `EF BB BF` followed by `class`, the keyword range is `[3,8)` and end-of-file is `[8,8)`.

- **BUT** byte-order-mark handling does not define Unicode identifier category policy

    Valid identifier code points, valid nonidentifier code points, and malformed UTF-8 continue to follow their own lexical rules.

### Requirement: Common lexical paths avoid per-token allocation

The frontend SHALL scan ordinary ASCII AngelScript source directly from immutable UTF-8 bytes without a heap allocation for each common token.

#### Scenario: A representative source corpus is measured
- **WHEN** the focused lexer microbenchmark records bytes, tokens, allocations, peak memory, and elapsed time
- **THEN** common identifiers, keywords, punctuation, and numeric tokens perform no per-token heap allocation
- **AND** throughput results are retained with corpus and environment provenance
- **BUT** elapsed time is evidence rather than a fixed cross-machine correctness threshold
    > Boundaries: A later performance contract may establish thresholds only from stable multi-environment evidence.

### Requirement: Dedicated annotation and callable declaration keywords

The Lexer SHALL classify UCLASS, USTRUCT, UENUM, UFUNCTION, UPROPERTY and UMETA as dedicated keyword Tokens. The Lexer SHALL classify `delegate` and `event` as dedicated Tokens solely so the Parser can reject them as removed callable introducers. Those two Tokens are a transitional reject surface for this Change; deleting `KwDelegate` / `KwEvent` from the identifier table belongs to a later Change.

    Script callable types are declared with the UE `DECLARE_*` identifier spellings owned by the declarations capability. Those spellings are not additional lexer keywords.

#### Scenario: Lex a marked declaration

- **WHEN** active language source spells one of the supported outer annotation keywords

    > Inputs: `UCLASS`, `USTRUCT`, `UENUM`, `UFUNCTION`, `UPROPERTY`, `UMETA`.

- **THEN** the Token carries its dedicated kind and original source range

    > Observables: token kind and source range.

- **AND** nested annotation arguments remain ordinary structured payload Tokens

- **BUT** UDELEGATE is not implicitly added as a declaration form, and `DECLARE_*` spellings remain identifier Tokens

    > Boundaries: `DECLARE_DELEGATE` and the other five supported families are parsed as declaration-form identifiers, not lexer keywords.

#### Scenario: Lex removed callable introducers

- **WHEN** active language source spells `delegate` or `event` as a declaration introducer

    > Inputs: `delegate void FOnDone();` or `event void FOnChanged();`

- **THEN** the Token carries a dedicated kind and original source range so Parser can emit the removed-syntax diagnostic

    > Observables: dedicated token kind, source range, later `removed-delegate-event-keyword` diagnostic.

- **BUT** the Token does not admit a callable type

    > Boundaries: identifier uses inside strings or comments are not this scenario. Removing the dedicated Token kinds so `delegate` / `event` become ordinary identifiers is out of this Change.
