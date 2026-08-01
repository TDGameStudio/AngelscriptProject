## ADDED Requirements

### Requirement: Unreal-independent native runtime build
The system SHALL build the maintained AngelScript fork, native host, CLI, standard library, and tests on Win64 without an Unreal installation, Unreal include/library paths, generated code, installation paths, or process startup. CMake SHALL resolve the fork's existing UE Core includes through the bounded `Standalone/Compat` facade rather than requiring the fork to replace its established UE container, memory, math, atomic, assertion, and host-facade spellings.

#### Scenario: Standalone build has no Unreal installation
- **WHEN** the CMake preset is configured and built without Unreal paths
- **THEN** all native standalone targets build and CTest runs

#### Scenario: Real Unreal dependency is introduced
- **WHEN** a standalone build input contains an Unreal installation/include/library path, generated include, linked UE module, or UE binary dependency
- **THEN** architecture verification fails with the offending path

#### Scenario: Compatibility facade supplies a fork include
- **WHEN** a maintained fork source includes one of its existing UE Core headers during CMake compilation
- **THEN** include ordering resolves the bounded header from `Standalone/Compat`, the generated project contains no Unreal installation path, and the same source continues to resolve the real UE header under UBT

### Requirement: Shared maintained fork
UE and standalone SHALL compile the same maintained fork sources and SHALL NOT maintain a copied standalone compiler/runtime fork.

#### Scenario: Shared source changes
- **WHEN** a maintained parser, compiler, bytecode, module, type-system, or context source changes
- **THEN** the source is compiled and tested by both host build systems

#### Scenario: Mechanical portability is proposed
- **WHEN** standalone compilation would otherwise replace an established fork use of `TArray`, `TMap`, `TMultiMap`, `TPair`, `FMemory`, `FMath`, `FPlatformAtomics`, `FMemStackBase`, `FAngelscriptEngine`, or `UASClass`
- **THEN** the behavior is implemented in `Standalone/Compat` or a target-selected standalone translation unit unless the change is independently justified and tested as host-neutral language/runtime behavior

#### Scenario: Compatibility boundary is inspected
- **WHEN** architecture verification scans Build.cs, Runtime frontend and descriptor owners, bindings, ClassGenerator, and ordinary standalone host sources outside the maintained-fork target
- **THEN** none of them imports `Standalone/Compat`, no standalone macro appears in the maintained fork, and Compat is selected only by the CMake maintained-fork target

### Requirement: Native compilation
`as-standalone compile --dialect native` SHALL compile selected source modules and emit deterministic native-runtime bytecode and identity metadata without a UE bundle.

#### Scenario: Native source is valid
- **WHEN** all selected native modules parse, resolve, and build
- **THEN** the CLI exits `0` and emits `result.json`, `diagnostics.jsonl`, and per-module bytecode

#### Scenario: Native source is invalid
- **WHEN** parser, semantic, template, module, or bytecode generation fails
- **THEN** the CLI exits `1`, emits normalized source diagnostics, and does not report complete output

### Requirement: Bounded standard library
The native runtime SHALL expose UTF-8 string, array, dictionary, math, print, and assert through a versioned generic-binding profile and SHALL expose no file, network, process, dynamic-library, or arbitrary FFI API.

#### Scenario: Supported standard-library code executes
- **WHEN** native source uses only the bounded profile
- **THEN** it compiles and executes through the portable implementations

#### Scenario: Excluded host API is referenced
- **WHEN** native source references an unregistered external capability
- **THEN** compilation rejects it as unavailable

### Requirement: Native entry execution
`as-standalone run` SHALL compile current source and execute only `void main(const array<string> args)` or `int main(const array<string> args)`.

#### Scenario: Arguments are supplied
- **WHEN** arguments follow `--`
- **THEN** the entry receives them in order as UTF-8 strings

#### Scenario: Integer main returns
- **WHEN** the integer entry returns any value
- **THEN** the CLI exits `0` and records the value as `scriptResult`

#### Scenario: Entry is absent
- **WHEN** neither accepted declaration exists
- **THEN** the CLI exits `1` and reports both accepted declarations

### Requirement: Execution limits and failure isolation
Native execution SHALL default to 5000 ms and 256 MiB, SHALL support explicit overrides, and SHALL distinguish resource termination from script exception and infrastructure failure.

#### Scenario: Deadline expires
- **WHEN** the active context exceeds its deadline
- **THEN** it is aborted, the CLI exits `4`, and a timeout diagnostic is emitted

#### Scenario: Allocation limit is exceeded
- **WHEN** an engine or bounded-library allocation would exceed the limit
- **THEN** execution terminates with exit `4`, a memory diagnostic, and no tracked leak after shutdown

#### Scenario: Memory budget cannot bootstrap the engine
- **WHEN** an explicit native-run memory budget is below 16 MiB
- **THEN** the runner exits `4` before engine creation, reports the minimum bootstrap budget, performs no over-limit backing allocation, and leaves no tracked allocation

#### Scenario: Script exception occurs
- **WHEN** execution ends in a script exception or explicit abort unrelated to a resource limit
- **THEN** the CLI exits `3` and records available exception/call-stack data

#### Scenario: Allocation accounting boundary is inspected
- **WHEN** the runtime enforces or reports the 256 MiB memory limit
- **THEN** engine, Compat, array, dictionary, and script string/stream/cache allocations are counted through the documented allocator boundary, CLI/result/diagnostic/JSON/C++ runtime/OS allocations are named exclusions, and shutdown reports no tracked leak

### Requirement: Native profile isolation
Every native artifact SHALL carry fork, compiler, engine-profile, and add-on identities and SHALL be rejected under an incompatible profile or UE-validation execution request.

#### Scenario: Profile hashes differ
- **WHEN** an artifact identity does not match the interpreting runtime
- **THEN** it is rejected before context preparation

#### Scenario: UE-validation input is passed to run
- **WHEN** run detects UE-validation identity or compile-only UE registrations
- **THEN** it exits `2` without executing a context

### Requirement: Stable result and exit contract
Native commands SHALL use exit `0` for normal completion, `1` for source/entry failure, `2` for usage/I/O/internal incompatibility, `3` for script exception/abort, and `4` for resource termination, with deterministic compile-result fields and an explicit output-publication contract for identical inputs.

#### Scenario: Compilation is repeated
- **WHEN** compiler, profile, sources, and options are identical
- **THEN** bytecode and compile identity fields are identical

#### Scenario: Output directory is omitted
- **WHEN** a compile or run command does not provide an explicit output directory
- **THEN** the CLI uses its documented ignored default, reports that resolved location, and never writes artifacts beside source inputs implicitly

#### Scenario: Artifact publication fails
- **WHEN** result, diagnostic, bytecode, or metadata publication fails before completion
- **THEN** the CLI exits `2` and no partial directory is presented as a complete result

### Requirement: Repository regression gates
The repository SHALL expose a Standalone suite and SHALL preserve the UE build and active NativeCore behavior throughout portability work.

#### Scenario: Portability batch is proposed
- **WHEN** a shared fork dependency family changes
- **THEN** the Standalone suite, relevant NativeCore tests, and UE build must pass before the batch is complete

### Requirement: Corpus-backed native support claims
Native language, module, runtime, standard-library, entry, exception, limit, and artifact behavior SHALL be claimed supported only when reviewed corpus entries record provenance, expected results, and no unexplained standalone/NativeCore disagreement.

#### Scenario: Native fixture agrees
- **WHEN** compile, execution, script result, normalized diagnostics, and artifact completion match its expectation
- **THEN** the fixture may contribute to the published native support tier

#### Scenario: Native fixture disagrees
- **WHEN** a claimed fixture has an unexplained outcome
- **THEN** release verification fails

### Requirement: Native release safety scan
The native release SHALL contain no real Unreal binary/include/library dependency, copied fork, unapproved standalone conditional, file/network/process/dynamic-library/arbitrary FFI registration, missing third-party license, or undocumented add-on delta. Compatibility headers SHALL remain build-tree-private implementation details; the V1 installed package SHALL contain the CLI, contracts, schemas, examples, documentation, and licenses only, and SHALL NOT publish a C++ SDK or claim Unreal ABI, UObject, World, reflection, or GC compatibility.

#### Scenario: Forbidden release surface appears
- **WHEN** source, link input, registration inventory, or package scan finds a forbidden item
- **THEN** release verification fails with evidence

### Requirement: Native artifact and profile determinism
Identical native compile inputs on the same compiler/profile SHALL produce identical bytecode and deterministic result fields, and help/version output SHALL expose fork/profile/add-on identity.

#### Scenario: Native compilation repeats
- **WHEN** deterministic inputs are unchanged
- **THEN** artifacts and identities match

### Requirement: Native performance baseline
The project SHALL record fixed-environment startup, compile, compile-run, and peak-memory metrics and SHALL fail a later identical-environment median regression greater than 20%.

#### Scenario: Baseline environment matches
- **WHEN** the same corpus and recorded environment regress beyond 20%
- **THEN** the performance gate fails with baseline/current metrics

### Requirement: Native Win64 package
The release SHALL package the CLI, documentation, licenses, schemas, exactly one release-generated `default-engine` bundle exported from the repository's checked-in `AngelscriptProject` host and normal enabled-plugin set, and separated native/UE examples. It SHALL NOT package a second `project` bundle, source text, private machine paths, or an unsupported platform claim.

#### Scenario: Package is inspected
- **WHEN** the archive is built
- **THEN** content, hashes, help/version, licenses, paths, the allowlisted deterministic `AngelscriptProject` default bundle and its declared producer/module/plugin/asset scope, absence of a second project bundle, and example commands pass release inspection
