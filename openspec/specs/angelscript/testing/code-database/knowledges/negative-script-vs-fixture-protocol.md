# Negative language source versus invalid fixture protocol

A test-material carrier must validate its own authoring protocol without validating the language behavior under test. Intentionally invalid AngelScript is valid material when metadata, version boundaries, annotations and topology are valid. A malformed fixture protocol is infrastructure failure and must never masquerade as a passing negative language test.

```text
valid fixture + invalid AS body
└─ generate and register successfully
   └─ consuming test asserts the exact failing stage and diagnostics

invalid fixture protocol
└─ codegen fails before mutation
   └─ database never publishes the malformed material
```

- Fixture admission validates UTF-8 transport, headers, required metadata, explicit `@end`, annotation syntax and version topology.
- Fixture admission does not lex, parse, type-check, format or compile AngelScript bodies.
- Invalid UTF-8 as a language-input edge case is not a normal v1 text container; use the explicit exact-byte C++ Source path.
- Fixtures that test bad container protocol live under excluded tool or C++ parser test directories and never join the production inventory.
- A `Negative` topic is selection metadata only; it is not inherited through Parent and is not an automatic oracle. Compile versus runtime polarity lives on the `CompileFail` / `RuntimeFail` file suffix, not a closed topic enum.
- Case headers use `@begin <tag>`. Several versions may omit Parent; a Tag spelled `root` has no privilege.
- Database consumers treat missing or rejected material as infrastructure error rather than expected negative execution.
