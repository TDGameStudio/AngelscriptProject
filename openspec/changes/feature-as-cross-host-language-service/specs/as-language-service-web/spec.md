## ADDED Requirements

### Requirement: Native and Web builds compile the same Language Service implementation
The Web target SHALL compile the maintained fork, Standalone frontend, adapters, resident Language Service, and shared diagnostics evaluator from the same C++ sources used by the Native service. JavaScript SHALL NOT reimplement AngelScript parsing, compilation, semantic rules, completion filtering, or class-outline construction.

#### Scenario: Native and Web analyze the same fixture
- **WHEN** both builds use identical source, profile, document version, and rule policy
- **THEN** their normalized analysis, diagnostics, completion, and outline results SHALL match
- **AND** differences in elapsed time or internal handles SHALL not affect parity

### Requirement: A narrow stable C ABI backs a versioned ESM API
The Emscripten target SHALL expose a bounded C ABI for service lifecycle, profile bytes, document operations, analysis, completion, outline, result/error bytes, and deallocation. The public ESM wrapper SHALL expose `createLanguageService`, `openDocument`, `updateDocument`, `analyze`, `complete`, `getClassOutline`, `closeDocument`, and `dispose` with versioned structured inputs and outputs.

#### Scenario: ESM client analyzes a document
- **WHEN** a client creates a service, loads a compatible profile, opens a versioned document, and calls `analyze`
- **THEN** it SHALL receive a structured `AnalysisResult` with the requested version, profile identity, and rule-set identity
- **AND** raw C++ pointers and process-local IDs SHALL not be exposed

#### Scenario: Client disposes a result and service
- **WHEN** the ESM wrapper finishes decoding a native buffer and later disposes the service
- **THEN** native buffers, documents, profile state, and opaque handles SHALL be released exactly once

#### Scenario: ABI or result schema is incompatible
- **WHEN** JavaScript and WASM ABI/result versions do not match
- **THEN** initialization SHALL fail with an explicit compatibility error before document analysis

### Requirement: Browser analysis runs in a dedicated Worker
Wiki-facing compilation, analysis, completion, and outline operations SHALL run in a dedicated Worker. The main thread SHALL exchange versioned structured messages and SHALL discard responses older than the current document version.

#### Scenario: User types while analysis is pending
- **WHEN** a newer document version is sent before an earlier Worker response arrives
- **THEN** the earlier response SHALL not update diagnostics, completion, or outline UI

#### Scenario: Analysis benchmark runs
- **WHEN** a 500-LOC warm fixture is analyzed on the recorded baseline environment
- **THEN** the p95 service time excluding the UI debounce SHALL not exceed 500 ms
- **AND** analysis SHALL not cause a main-thread task longer than 50 ms

### Requirement: Web Language Service is compile/analyze-only
The Web build SHALL omit script execution entry points and SHALL not expose file, network, process, dynamic-library, arbitrary FFI, native function registration, or UE runtime simulation capabilities.

#### Scenario: Compilable entry function is provided
- **WHEN** browser source declares a callable entry function
- **THEN** the service SHALL analyze it without creating an execution context or invoking it

#### Scenario: Script references a registered UE function
- **WHEN** the function signature exists in the profile
- **THEN** compilation/completion MAY use the declaration
- **AND** no native trap or host callback SHALL execute

#### Scenario: Package surface is scanned
- **WHEN** exported C symbols and ESM methods are inspected
- **THEN** no run/execute/context invocation, filesystem, network, process, library, or arbitrary registration API SHALL be reachable

### Requirement: Web inputs and resources are bounded
The Web service SHALL enforce configured limits for profile bytes, source bytes, open documents, diagnostic results, completion candidates, analysis duration, and WASM memory. Violations SHALL return structured errors without terminating the containing Wiki.

#### Scenario: Profile exceeds its limit
- **WHEN** profile bytes exceed the configured maximum
- **THEN** initialization SHALL fail before allocation of the full profile index
- **AND** no fallback profile SHALL be selected

#### Scenario: Analysis exceeds its time or result limit
- **WHEN** analysis exceeds a configured duration or diagnostic bound
- **THEN** the Worker SHALL return a stable limit error or bounded result as specified by the operation
- **AND** subsequent valid requests SHALL remain possible after state cleanup

### Requirement: Web assets support a single-file offline consumer
The Web release SHALL provide ESM, WASM, Worker, profile, and manifest assets that can be embedded into a TiddlyWiki `index.html` and instantiated from in-memory bytes/object URLs without a runtime network request.

#### Scenario: Wiki opens without network
- **WHEN** the integrated offline artifact renders an interactive editor with network access disabled
- **THEN** the Worker, WASM module, and profile SHALL initialize from embedded assets
- **AND** no fetch to a remote or local service endpoint SHALL occur

#### Scenario: Ordinary page has no editor
- **WHEN** a Wiki page renders no interactive AngelScript widget
- **THEN** Web assets MAY be present in the single HTML file but SHALL not be decoded, instantiated, or executed

### Requirement: Web packaging is reproducible and provenance-bearing
The Web package SHALL record the product/compiler revision, ABI/schema versions, rule-set identity, profile identity, file hashes, licenses, and build configuration. Identical pinned inputs SHALL produce deterministic content files except for explicitly excluded archive/container metadata.

#### Scenario: Release assets are copied into Wiki
- **WHEN** a reviewed Web package is selected for Wiki
- **THEN** Wiki provenance SHALL match the package manifest and content hashes
- **AND** a mismatched asset SHALL fail Wiki release validation

### Requirement: A repository-standard Web suite validates the target
The parent test tooling SHALL expose a typed `StandaloneWeb` suite that resolves an optional machine-local Emscripten SDK path, configures/builds the Web target, and runs Node contract/parity/security tests with isolated reports.

#### Scenario: Emscripten SDK is configured
- **WHEN** `StandaloneWeb` runs with a valid configured SDK
- **THEN** it SHALL build through the declared CMake/Emscripten presets and run the complete Web test set

#### Scenario: Emscripten SDK is absent
- **WHEN** the explicit Web suite is requested without a valid SDK configuration
- **THEN** it SHALL fail with a configuration diagnostic identifying the required setting
- **AND** Native Standalone and UE suites SHALL remain unaffected
