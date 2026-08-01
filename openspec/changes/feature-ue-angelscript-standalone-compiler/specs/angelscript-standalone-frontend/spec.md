## ADDED Requirements

### Requirement: Standalone-private frontend ownership
The standalone compiler SHALL own its source preprocessing, declaration analysis, rewrite, source-map, and diagnostic implementation beneath `Plugins/Angelscript/Standalone/`, and Unreal Runtime SHALL NOT compile or include those frontend sources.

#### Scenario: Both hosts build
- **WHEN** the Unreal target and standalone target are built from the same revision
- **THEN** Unreal uses its existing `FAngelscriptPreprocessor` implementation while CMake compiles the standalone-private frontend directly into `AngelscriptStandaloneHost`

#### Scenario: Architecture scan runs
- **WHEN** active Runtime, Standalone, and CMake sources are scanned
- **THEN** no Runtime `Language/` directory, `AngelscriptLanguageCore` target, `ANGELSCRIPT_LANGUAGE_STANDALONE` definition, or `UEAngelscript::Language` namespace remains

### Requirement: Narrow host-neutral frontend output
The standalone frontend SHALL stop at normalized source/module identity, processed source, value-only declaration IR, rewrite plans, UTF-8 source maps, and structured diagnostics.

#### Scenario: Standalone analysis completes
- **WHEN** a supported source set is processed
- **THEN** the result contains deterministic processed text, declarations, rewrites, mappings, imports, and diagnostics without creating Unreal reflection objects or simulating Unreal runtime ownership

### Requirement: Bundle-backed host knowledge
The standalone frontend SHALL receive source text and configuration as values and SHALL query final UE type and symbol facts only through the read-only bundle-backed `ITypeOracle` contract.

#### Scenario: Standalone analyzes a UE declaration
- **WHEN** a declaration needs base, interface, trait, or symbol facts
- **THEN** the selected complete offline bundle answers through `ITypeOracle` without loading Unreal Engine

#### Scenario: Unreal-only facts are required
- **WHEN** final registered types, functions, traits, relationships, or assets are needed
- **THEN** Unreal exports those facts through the offline contract rather than adding Unreal reflection types or branches to the standalone frontend

### Requirement: Unreal frontend authority
`FAngelscriptPreprocessor` SHALL remain the UE-facing frontend and preserve its existing module-name, range-for, descriptor, callback, summary, source-loading, and ClassGenerator behavior without depending on standalone frontend sources.

#### Scenario: Existing Unreal caller compiles unchanged
- **WHEN** Runtime or Editor callers use `FAngelscriptPreprocessor`
- **THEN** no public API, module dependency, compile definition, or call-site migration is required

### Requirement: Canonical standalone source coordinates and rewrites
The standalone frontend SHALL retain canonical UTF-8 byte offsets, deterministic logical paths and module identities, ordered non-overlapping rewrites, and original-to-processed source mappings.

#### Scenario: Non-ASCII source and separator variants are processed
- **WHEN** equivalent sources contain multi-byte UTF-8 text or slash and backslash path variants
- **THEN** diagnostics and module identities match the existing standalone frontend behavior

#### Scenario: Multiple rewrites are requested
- **WHEN** supported preprocessing produces several edits
- **THEN** edits are deterministically ordered, applied once, and overlaps fail with the existing structured diagnostic

### Requirement: No public standalone plugin switch
Standalone frontend ownership SHALL be selected only by the Standalone CMake target and SHALL NOT add a UBT option, `.uplugin` module, public plugin macro, or branch to bindings or ClassGenerator.

#### Scenario: Plugin metadata is inspected
- **WHEN** `.uplugin`, Build.cs, binds, and ClassGenerator sources are checked
- **THEN** they contain no standalone frontend toggle or standalone execution path

### Requirement: Current global-variable semantics remain unchanged
This change SHALL preserve the maintained fork's current const-only global-variable policy and SHALL continue to reject raw handle syntax that the UE dialect does not expose.

#### Scenario: Mutable global is compiled
- **WHEN** source declares a mutable script global under the current dialect
- **THEN** the existing rejection behavior and diagnostic category remain unchanged
