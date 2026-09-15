## MODIFIED Requirements

### Requirement: Tokens and identifiers have compact session-owned representation

The frontend SHALL intern identifier spelling once per compilation session, preserve equal-spelling identity under concurrent file tokenization, and use declarative token metadata for names, classifications and keyword properties.

#### Scenario: Repeated spellings arrive concurrently

- **GIVEN** A.as and B.as each contain `int Shared;` in one immutable source session
- **WHEN** one or several workers tokenize the files in any arrival order
- **THEN** both Shared tokens refer to the same immutable session-owned identifier entry

    The entry's spelling and token classification remain readable until the owning session is released. Pointer identity is compared only inside that session.

- **AND** canonical token kinds, spellings, byte ranges and diagnostic projections equal the single-worker result
- **BUT** pointer values, allocation order and worker completion order never become durable declaration or type identity

## ADDED Requirements

### Requirement: Lexical failure facts are file-local and independent of presentation

A tokenizer SHALL retain whether its own input produced lexical Error diagnostics independently of other files, consumer submission and diagnostic display policy.

#### Scenario: One tokenizer fails while another is clean

- **GIVEN** A.as contains an unterminated string and B.as contains `int B;`
- **WHEN** both tokenizers use the same diagnostic engine and flush their fragments
- **THEN** A retains its lexical-error fact and B remains free of lexical errors

    Flushing, hiding A's diagnostic, or submitting A before B must not change either file's lexical fact. A recoverable Error remains distinct from a hard Lex operation failure.

- **AND** A's recoverable tokenization still advances through its retained invalid/unterminated token to EOF
