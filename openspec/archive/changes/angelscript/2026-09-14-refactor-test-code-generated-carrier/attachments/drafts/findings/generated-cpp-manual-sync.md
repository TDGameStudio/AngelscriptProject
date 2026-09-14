# Evidence for Manually Synchronized Generated C++

Source identity: faithful English translation of the 2026-09-14 local finding `generated-cpp-manual-sync.md`. This is inspected evidence, not current design authority.

## Current implementation evidence

- `FAngelscriptTestCodeRegistration::FCodeFactory` is `FAngelscriptTestCodeBuildResult (*)(const FAngelscriptTestFileMeta&)`. `AngelscriptTestJIT/NewVersion/TestCodeProviderRegistration.cpp` already supplies a normal static factory across a module boundary.
- `FAngelscriptTestSourceParser::Parse(FStringView, TConstArrayView<uint8>)` is exported and reconstructs FileMeta, VersionMeta, clean source, annotations, and origin maps from a complete `.as` v1 container.
- Activation snapshots ordinary records and registry-private batch records before both enter `AdmitDetachedBatches`, so a generated carrier can reuse the existing database.
- `AngelscriptTest.Build.cs` currently discovers the author root, creates `Index.json` and `Entries.rc2`, records external dependencies and a missing sentinel, then embeds `AS_TEST_INDEX` and numeric RCDATA through RC.

## Reusable conclusion and superseded suggestion

Generated C++ does not require changes to Source, Builder, Parser, Case, Result, queries, or activation. Handwritten C++ providers do not need to change.

The original finding considered a module-private generated batch bridge because registration metadata is a real input. The later approved design supersedes that suggestion: each generated file provides the correct extensionless FileTag in an ordinary `FAngelscriptTestCodeRegistration`, retains authored source identity, and invokes the existing parser in its factory. No private bridge or second database is added.

## Legacy tool evidence

`TestSource-old/Generation/python` demonstrates deterministic sorting, whole-input validation before projection writes, UTF-8/LF output, stale projection cleanup, and Python testing conventions. Its Contract V2, callable inventory, recipes, reload histories, coverage schema, oracles, and diagnostics semantics are not reusable for the new carrier.

Reusable principles are:

- projections are not authored truth;
- invalid input fails before the first output write;
- output sorting and canonical serialization are stable;
- read-only strict audit and writing mode are distinct;
- stale and collision behavior has direct tests.

The new package is independent and only performs `AngelscriptTestCode/**/*.as -> one generated C++ per source`.

## Repository generation conventions

The UHT FunctionBinding generator uses `.gen.cpp`, deterministic sorting, an expected output set, and stale cleanup. StaticJIT documents checked generated carriers, manifests, and owned-file inventories. These establish generated C++ as an existing repository technique, though their lifecycle is not reused for TestCode.

## Risks preserved for implementation

- Manual synchronization without `check` permits drift.
- Python parsing metadata would create a second semantic authority.
- Per-source translation units change the UBT source set on add/delete/rename.
- Generated output must preserve raw bytes rather than relying on raw-string delimiters, compiler source encoding, or newline conversion.
- Aggregate or shard layouts should only replace the selected one-file mapping after measured build evidence.

