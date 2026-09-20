# Isolated pull-lexer test oracles

## Reusable Insight

An isolated pull-lexer test should separate source ownership, execution capture, and authored expectations. One fixture may own the exact input bytes and one stable tokenizer run, while each scenario owns the expected token kinds, source slices, flags, diagnostics, and terminal behavior. Host-framework conversions stay at explicit boundaries so malformed bytes and embedded NUL remain testable without accidental text normalization.

Generated stimulus is not an independent oracle when the generator and lexer consume the same token-definition table. Keep a table-driven round trip for breadth, but pair it with a literal accepted anchor such as a fixed digest or an independently authored vocabulary. Negative generators should likewise generate bounded named inputs only; expected tokens and diagnostics remain authored outside the generator.

Sticky end-of-file needs two distinct observations: retain the first EOF in the semantic token stream, then perform a separately named repeated-EOF probe. This preserves an ordinary one-EOF expectation while proving post-terminal stability without weakening the pull bound.

## Evidence

- The isolated Lexer suite passes 18 contract methods, four spelled-kind methods, and nine recovery methods under one focused Automation prefix.
- The spelling walk exercises every non-empty accepted spelling, while a literal digest independently anchors the complete kind/spelling sequence.
- The recovery matrix proves exact progress, byte ranges, diagnostics, comment/string boundaries, Unicode policy, and leading UTF-8 BOM behavior with bounded named rows.
- Repeated EOF is captured separately from the primary stream, and exact token ranges recover authored bytes from the owning snapshot.

## Boundaries

- Do not turn a lexer fixture into a parser, preprocessor, Sema, Bindings, source-catalog, dynamic-registration, or generic test-framework abstraction.
- A fixed digest detects vocabulary drift but does not decide whether an intentional vocabulary change is desirable; update it only with reviewed product expectations.
- Keep generated recovery matrices bounded until a reusable generator contract exists, and never infer expected output from the tokenizer under test.
- Do not import C/C++ macro provenance, parser token splitting, CR-only newline policy, or string/newline recovery semantics merely because a reference lexer tests them.

## Application

For another isolated frontend stage, expose exact-byte and authored-text input factories, one stable captured run, deterministic failure descriptions, and narrow expectation helpers. Author exact range and diagnostic oracles at scenario scope. If terminal state is sticky, name the post-terminal probe separately; if input breadth comes from implementation metadata, add an independent acceptance anchor.

## Provenance

Promoted from the verified knowledge candidate `isolated-lexer-checklex-matrix.md` in OpenSpec Change `angelscript/test-lexer-isolated-coverage`.
