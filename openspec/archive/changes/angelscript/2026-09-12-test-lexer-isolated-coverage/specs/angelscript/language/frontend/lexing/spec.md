## MODIFIED Requirements

### Requirement: Every lexical input terminates with precise recovery

The frontend SHALL either consume source bytes or emit end-of-file on every pull operation, including malformed input.

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

