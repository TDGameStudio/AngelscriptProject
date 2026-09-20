# Negative language source versus invalid fixture protocol

## Reusable Insight

A test-material carrier must validate its own authoring protocol without validating the language behavior under test. Intentionally invalid AngelScript is valid material when metadata, version boundaries, annotations and topology are valid. A malformed fixture protocol is infrastructure failure and must never masquerade as a passing negative language test.

## Evidence

The existing Builder accepts `int X=Missing;` because it does not compile AngelScript. Negative versions may target lexing, parsing, name resolution, typing, reload or diagnostics, and failure at one stage does not imply failure at every stage. The user selected version Topics such as `Negative` and `Diagnostics` for material selection only; concrete expectations remain in consuming tests.

## Boundaries

- Python validates UTF-8 fixture transport, headers, required metadata, explicit `@end`, annotation syntax and version topology.
- Python does not lex, parse, type-check, format or compile AngelScript bodies.
- Invalid UTF-8 as a language-input edge case is not a normal v1 text container; use the explicit exact-byte C++ Source path.
- Fixtures intentionally testing bad container protocol live under excluded tool or C++ parser test directories and never join the production inventory.
- `Negative` classification is not inherited through Parent and is not an automatic oracle.

## Application

```text
valid fixture + invalid AS body
└─ generate and register successfully
   └─ consuming test asserts the exact failing stage and diagnostics

invalid fixture protocol
└─ codegen fails before mutation
   └─ database never publishes the malformed material
```

Codegen tests require at least one deliberately invalid AS body that still produces a valid projection, and multiple invalid fixture-protocol cases that leave all outputs unchanged. Database consumers must treat missing/rejected material as infrastructure error rather than expected negative execution.

## Sources

- [Build-time parser evidence](../drafts/findings/generated-build-time-parser.md)
- [Accepted design](../drafts/design.md)
- Approval provenance: negative-metadata and generated-parser rounds in brainstorming topic `angelscript/test-framework-completion`.
