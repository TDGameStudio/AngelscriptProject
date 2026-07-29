## 1. Change Record and Package Setup

- [x] 1.1 <!-- Non-TDD --> Create the feature change, proposal, design, and capability specification for the standalone generator foundation.
- [x] 1.2 <!-- TDD --> Add the Python package metadata, module entry point, CLI argument contract, and failing CLI tests.

## 2. Typed Model and Profiles

- [x] 2.1 <!-- TDD --> Add typed program/model records and invariant validation for scopes, types, lvalues, handles, and control flow.
- [x] 2.2 <!-- TDD --> Add inherited JSON profile loading and validation for native and UE capability declarations.
- [x] 2.3 <!-- TDD --> Add reviewed native-core, UE-value, UE-annotation, and UE-World profile data with evidence and harness requirements.

## 3. Source Generation

- [x] 3.1 <!-- TDD --> Add deterministic random-source/context utilities plus bounded valid expression and statement generation.
- [x] 3.2 <!-- TDD --> Add AngelScript lifting with stable formatting and machine-readable source headers.
- [x] 3.3 <!-- TDD --> Add the isolated single-rule invalid mutation path and expected-outcome metadata.

## 4. Output and Verification

- [x] 4.1 <!-- TDD --> Add source writing, catalog/index generation, hash recording, and deterministic regeneration checks.
- [x] 4.2 <!-- Non-TDD --> Document CLI/profile contracts and the intentionally deferred runner, reducer, and CQTest layers.
- [x] 4.3 <!-- Non-TDD --> Run the complete Python verification suite, CLI smoke generation for all profiles, and deterministic output comparison.
