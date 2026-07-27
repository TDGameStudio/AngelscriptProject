## 1. Ownership and Existing Source

- [x] 1.1 <!-- Non-TDD --> Record P019 as the only production hunk and identify `FAngelscriptBytecode::GetInstrDebugString()` as the exact owner.
- [x] 1.2 <!-- Non-TDD --> Confirm the current source contains the terminal `Out.TrimEndInline()` and no runtime/test source change is required in this record-only session.
- [x] 1.3 <!-- Non-TDD --> Name `FAngelscriptStaticJITAotTests::GeneratedOutputVerify` and the literal generated-fixture scan as the existing regression contract.

## 2. Rollback Boundary

- [x] 2.1 <!-- Non-TDD --> Record P019, its exact formatting assertion, and normalization-only generated fixture delta as one rollback boundary.
- [x] 2.2 <!-- Non-TDD --> Exclude bytecode execution, serialization, diagnostics commands, and unrelated generated-source cleanup.

## 3. Fresh Verification

- [x] 3.1 <!-- Non-TDD --> Run the exact `Tools\RunBuild.ps1` command in `verification.md` and record metadata, exit codes, and new warnings/errors.
- [x] 3.2 <!-- Non-TDD --> Run the documented StaticJIT AOT workflow in `verification.md` and record generation, generated-build, automation, shutdown, and crash/timeout evidence.
- [x] 3.3 <!-- Non-TDD --> Run the literal generated-fixture trailing-whitespace scan and require zero matches.
- [x] 3.4 <!-- Non-TDD --> Run strict OpenSpec validation plus scoped parent/plugin whitespace checks and append fresh outputs to `verification.md`.
