## ADDED Requirements

### Requirement: Bundle-backed UE-AngelScript analysis and compatible loading
The UE analyzer SHALL select exactly one complete symbol bundle, then validate required files, UTF-8/schema, counts, hashes, stable identities, duplicates, producer/fork/compiler properties, feature flags, scope, and adapter requirements before registration or source compilation. It SHALL use the packaged `default-engine` bundle when `--bundle` is omitted and SHALL use only the explicitly selected complete bundle when the option is present.

#### Scenario: Bundle is compatible
- **WHEN** all required contract and integrity fields are supported
- **THEN** loading succeeds and records the bundle identity

#### Scenario: Bundle option is omitted
- **WHEN** UE compilation starts without `--bundle`
- **THEN** the analyzer selects the packaged `default-engine` bundle and records `packaged-default` as its source

#### Scenario: Explicit project bundle is selected
- **WHEN** UE compilation starts with `--bundle <project-directory>`
- **THEN** that complete bundle replaces the packaged default, no records are merged from the default, and the analyzer records `explicit` as its source

#### Scenario: Bundle is incompatible
- **WHEN** an explicitly selected bundle has an invalid path, required field, hash, identity, schema, or compatibility contract
- **THEN** the CLI exits `2` before any source compilation, identifies the incompatibility, and does not fall back to the packaged default

#### Scenario: Packaged default is unavailable
- **WHEN** `--bundle` is omitted and the packaged default is missing or incompatible
- **THEN** the CLI exits `2` and reports an installation or release-package error

#### Scenario: Symbol scope is incomplete
- **WHEN** the selected manifest does not prove `symbolScope.complete: true`
- **THEN** the CLI exits `2` before any registration or source compilation

### Requirement: Source-closure baseline replacement
The analyzer SHALL determine the selected module closure before registration, replay all host-surface declarations, suppress matching script baselines, and retain only closure-external script declarations.

#### Scenario: Current source replaces baseline
- **WHEN** a current source module matches an exported stable module ID
- **THEN** its baseline declarations are excluded before current source compiles

#### Scenario: External baseline remains
- **WHEN** an imported baseline module is outside the selected source closure
- **THEN** its declarations remain available as compile-only dependencies

#### Scenario: Module identity is ambiguous
- **WHEN** incompatible records or sources claim the same stable module identity
- **THEN** analysis fails deterministically instead of choosing by order

### Requirement: Deterministic compile-only registration
The analyzer SHALL register compatible engine settings, declarations, types, relationships, members, and callables in deterministic dependency order with no native UE execution.

#### Scenario: Exported callable resolves
- **WHEN** source calls a host or external-baseline declaration
- **THEN** overload resolution uses the exported owner, namespace, complete declaration, defaults, qualifiers, and stable symbol ID

#### Scenario: Compile-only callable executes internally
- **WHEN** an internal test or defect invokes its generic trap
- **THEN** the host fails immediately without returning a fabricated value

### Requirement: Hard non-execution boundary
The UE-validation profile SHALL expose analysis only and SHALL NOT execute validation bytecode, invoke imported UE behavior, materialize Unreal reflection/runtime state, or offer a UE run command.

#### Scenario: User requests UE execution
- **WHEN** a command, option, or artifact request attempts to run the UE-validation profile
- **THEN** the CLI exits `2`, explains that the profile is compile-only, and prepares no execution context

#### Scenario: Internal path reaches imported behavior
- **WHEN** an internal defect reaches a compile-only callable or behavior trap
- **THEN** the process fails closed without returning fabricated state or invoking host behavior

### Requirement: Address-free validation bytecode
UE analysis bytecode SHALL use the maintained AngelScript used-function signature linkage, SHALL contain no UE address, and SHALL be marked `ue-validation-only` with compiler/profile/bundle/adapter identity.

#### Scenario: UE native address changes
- **WHEN** the same contract declarations are exported from a process with different native addresses
- **THEN** standalone semantic resolution and artifact identity are unaffected by those addresses

#### Scenario: Validation artifact is passed to run
- **WHEN** the native run command receives UE-validation identity
- **THEN** it rejects the artifact before context preparation

### Requirement: Portable source and module frontend
The standalone analyzer SHALL use host-neutral UTF-8 source records, locations, roots, include/import graphs, deterministic conditions, and diagnostics for its published supported frontend slice. Unreal remains the integration authority through its existing preprocessor and focused automation evidence.

#### Scenario: Supported fixture is promoted
- **WHEN** a frontend fixture is added to the published corpus
- **THEN** its standalone result and relevant Unreal automation or project evidence are recorded and any host difference is classified

### Requirement: Portable declaration and class model
The analyzer SHALL represent classes, structs, enums, delegates, properties, functions, events, defaults, metadata, relationships, source ranges, resolved symbol IDs, and support findings in standard-C++ records without Unreal pointers or runtime layouts.

#### Scenario: Supported class compiles
- **WHEN** its declarations and body are valid under the bundle
- **THEN** a script type, validation bytecode, and deterministic class-model record are emitted

#### Scenario: Architecture scan sees Unreal state in portable IR
- **WHEN** portable records include UE pointers/types, reflection objects, or UE property offsets
- **THEN** architecture verification fails

### Requirement: Existing UE materialization remains isolated
The standalone SHALL never invoke ClassGenerator or create reflection objects, and V1 SHALL preserve the existing UE preprocessor/ClassGenerator materialization path unchanged.

#### Scenario: UE facade parity migration is attempted
- **WHEN** portable declaration parsing is introduced as the UE descriptor producer
- **THEN** `refactor-as-language-core-ue-facade-parity` must first prove descriptor and callback parity

#### Scenario: Standalone reaches materialization
- **WHEN** analysis requires UClass/UFunction/FProperty/CDO/component/World/Blueprint VM/RPC/GC/reinstancing state
- **THEN** it emits `ue-required` and creates no fake object

### Requirement: Core UE declaration validation
The core slice SHALL validate supported class/struct/enum/delegate macro shapes, specifier combinations, bases/interfaces, member conflicts, signatures, overrides/events, property/function/argument types, access, metadata syntax, defaults, globals, and script-to-script calls.

#### Scenario: Override matches exported base
- **WHEN** method name, parameters, return, const/access, and override availability match
- **THEN** the override is accepted and records the resolved base symbol ID

#### Scenario: Declaration rule is invalid
- **WHEN** a supported annotation, type, relationship, default, or override rule is violated
- **THEN** a stable source-located diagnostic is emitted

### Requirement: Explicit support classification
Every used imported or UE-derived capability SHALL be classified exact, compile-shim, ue-required, or unsupported and SHALL contribute to complete/partial/failed status.

#### Scenario: UE-required is disallowed
- **WHEN** a used capability is ue-required without `--allow-ue-required`
- **THEN** analysis exits `1` and is incomplete

#### Scenario: UE-required is allowed
- **WHEN** the option is present and no other failure remains
- **THEN** analysis exits `0` with `partial` and `complete: false`

#### Scenario: Unsupported feature is used
- **WHEN** source uses an unavailable adapter or unrepresentable construct
- **THEN** analysis exits `1` and names the capability

#### Scenario: Used exported symbol is unavailable in the selected host profile
- **WHEN** semantic observation resolves a used function or type stable ID whose selected-bundle availability is `editor-only` or `unavailable`
- **THEN** analysis classifies that stable-ID use as `unsupported`, exits `1` even with `--allow-ue-required`, and does not reject unrelated unavailable records that the source never uses

### Requirement: Stable analysis output
The analyzer SHALL emit deterministic `result.json`, `diagnostics.jsonl`, per-module `.asbc`, and `.classes.jsonl` with source/module graph, compiler/profile, resolved bundle source/kind/path/hash, independent symbol/asset completeness, adapter, symbol, and status data.

#### Scenario: Identical analysis repeats
- **WHEN** all declared inputs are identical
- **THEN** bytecode, class models, diagnostics, and deterministic result fields are identical

#### Scenario: Bundle source changes
- **WHEN** otherwise identical compilation selects an explicit project bundle instead of the packaged default
- **THEN** result identity and bundle-source fields identify the selected project snapshot

### Requirement: Phase-gated support boundary
Before the template-adapter and resource-validation workstreams are promoted, the analyzer SHALL report non-declarative UE container/object-wrapper adapters as unsupported and typed asset-index findings as deferred; the final release SHALL promote only fixtures backed by the corresponding adapter or resource evidence.

#### Scenario: Container requires a future adapter
- **WHEN** source instantiates a non-declarative UE template not supported by the core slice
- **THEN** analysis exits `1` with its required adapter identity

#### Scenario: Typed resource context is found
- **WHEN** source uses a path-bearing declaration before resource validation is installed
- **THEN** the context is recorded as deferred without claiming found, missing, or compatible

### Requirement: Normalized differential evidence model
The release SHALL define a normalized differential result containing outcome, diagnostic category/location, declaration/class/resource subset, resolved stable symbol IDs, classification, and bytecode completion while excluding bytecode bytes, addresses, runtime IDs, prose, elapsed time, and machine paths.

#### Scenario: Comparable producer evidence exists
- **WHEN** Unreal and standalone evidence for the same fixture is available
- **THEN** it is compared through the normalized model and an unexplained disagreement prevents promotion

### Requirement: Adapter registry and compatibility handshake
The analyzer SHALL resolve every non-declarative template through a registered adapter whose stable ID, semantic version, trait schema, required engine properties, and registration-surface hash match the bundle.

#### Scenario: Adapter matches
- **WHEN** every required handshake field is supported
- **THEN** registration planning may install the adapter before source compilation

#### Scenario: Adapter differs
- **WHEN** ID, version, trait schema, engine property, or surface hash differs
- **THEN** bundle loading exits `2` before compilation

### Requirement: Canonical compile traits
Template validation SHALL use explicit constructible, destructible, copyable, comparable, hashable, template-eligible, object-handle, kind, size, alignment, and GC-related traits and SHALL NOT infer missing required traits optimistically.

#### Scenario: Required trait is absent
- **WHEN** a subtype record cannot prove a required trait
- **THEN** instantiation fails with the adapter and missing trait

### Requirement: Non-executable non-UE layout
Adapters SHALL provide deterministic standalone compile layouts and trap-backed declarations and SHALL label those layouts non-UE-ABI.

#### Scenario: Adapter specialization compiles
- **WHEN** subtype validation succeeds
- **THEN** bytecode may use the adapter's versioned compile layout and artifact metadata marks it non-UE-ABI

#### Scenario: Runtime method is invoked internally
- **WHEN** a template method trap executes
- **THEN** the host fails immediately without mutating a container or returning fabricated data

### Requirement: Array and iterator validation
`TArray<T>` SHALL require a valid, constructible, destructible, copyable, non-zero-size, template-eligible subtype and SHALL expose specialization-bound mutable/const iterator declarations.

#### Scenario: Valid array subtype
- **WHEN** all required element traits and nesting rules pass
- **THEN** the specialization and exported methods/iterators participate in type checking

#### Scenario: Array subtype lacks a trait
- **WHEN** an element lacks construct, destruct, copy, eligibility, or non-zero size
- **THEN** instantiation is rejected with the missing rule

### Requirement: Map validation
`TMap<K,V>` SHALL require key construct/destruct/copy/compare/hash traits, value construct/destruct/copy traits, and current nested-template and iterator rules.

#### Scenario: Valid map
- **WHEN** key/value traits and nesting pass
- **THEN** map, index/find/out-ref, assignment, and iterator declarations participate in compilation

#### Scenario: Invalid key
- **WHEN** a key lacks comparison or hashing
- **THEN** instantiation is rejected with a key-trait diagnostic equivalent in category to UE

### Requirement: Set validation
`TSet<T>` SHALL require construct/destruct/copy/compare/hash traits and current nested-template and iterator rules.

#### Scenario: Valid set
- **WHEN** element traits and nesting pass
- **THEN** set and iterator declarations participate in compilation

#### Scenario: Invalid element
- **WHEN** an element lacks a required trait
- **THEN** instantiation is rejected and identifies the trait

### Requirement: Optional validation
`TOptional<T>` SHALL require valid construct/destruct/copy traits and SHALL use a checked deterministic subtype-derived compile layout with null/has-value/access declarations.

#### Scenario: Valid optional
- **WHEN** subtype traits, size, and alignment are valid
- **THEN** optional compiles with non-UE-ABI layout metadata

#### Scenario: Invalid optional subtype
- **WHEN** construction, destruction, copy, size, alignment, or overflow validation fails
- **THEN** instantiation is rejected

### Requirement: Object-wrapper subtype validation
`TObjectPtr`, `TWeakObjectPtr`, `TSoftObjectPtr`, `TSubclassOf`, and `TSoftClassPtr` SHALL accept only compatible UObject-derived reference/class subtypes and SHALL perform no object load, resolution, GC, or reflection execution.

#### Scenario: Object subtype is compatible
- **WHEN** bundle relationships prove the subtype satisfies the wrapper kind
- **THEN** wrapper declarations, assignment, covariance, cast, null, and path construction participate in compilation

#### Scenario: Value subtype is supplied
- **WHEN** an ordinary value type is used
- **THEN** instantiation is rejected

### Requirement: Nested-template compatibility
Adapters SHALL enforce the current exported nested-template policy, including only explicitly recorded exceptions.

#### Scenario: Unsupported nesting is requested
- **WHEN** a subtype combination violates the current policy
- **THEN** instantiation is rejected with the normalized nested-template rule

### Requirement: Template differential evidence
Every supported adapter SHALL have UE/standalone positive and negative fixtures comparing accept/reject, diagnostic category/location, missing rule, specialization relationships, resolved stable IDs, classification, and bytecode completion.

#### Scenario: Adapter fixture disagrees
- **WHEN** a fixture claimed supported differs without an approved classification
- **THEN** the template differential suite fails

### Requirement: Validated offline asset index
The analyzer SHALL build immutable normalized asset, generated-class, redirect, mount, origin, type, availability, and scope indices from an integrity-checked bundle and SHALL reject inconsistent internal relationships as infrastructure failures.

#### Scenario: Asset records are consistent
- **WHEN** identities, relationships, redirects, mounts, types, and scope data validate
- **THEN** the index is available for source analysis

#### Scenario: Redirect graph is invalid
- **WHEN** redirects cycle, exceed the supported depth, or reference an invalid target form
- **THEN** bundle interpretation exits `2` before source diagnostics

### Requirement: Typed resource-context discovery
Resource analysis SHALL run only for resolved path-bearing constructors, assignments, wrappers, properties/defaults, and callable parameters identified by stable declaration/type data.

#### Scenario: Soft object wrapper receives a literal
- **WHEN** the resolved target is `TSoftObjectPtr<T>` or `TSoftClassPtr<T>`
- **THEN** a context records source range, requested type, object/class expectation, softness, and origin symbol

#### Scenario: Ordinary string resembles a path
- **WHEN** a string outside a recognized typed context contains `/Game/...`
- **THEN** no resource context or diagnostic is created

### Requirement: Bounded constant resource expressions
The analyzer SHALL evaluate direct accepted literals, supported const declarations, and deterministic concatenations and SHALL defer other dynamic expressions without claiming found or missing.

#### Scenario: Const concatenation is deterministic
- **WHEN** every operand resolves to a supported compile-time string
- **THEN** the normalized combined value is validated

#### Scenario: Value is dynamic
- **WHEN** the path depends on mutable state, runtime calls, formatting, or unsupported conversion
- **THEN** the analyzer records at most a deferred context and emits no existence claim

### Requirement: UE path normalization
The analyzer SHALL normalize supported package, object, generated Blueprint class, `/Game`, `/Engine`, `/Script`, and plugin-mount forms consistently with the exporter while retaining original spelling.

#### Scenario: Blueprint class path is supplied
- **WHEN** a class context uses a generated `_C` path
- **THEN** lookup uses the generated-class identity rather than conflating it with the Blueprint asset

### Requirement: Structured resource states
Each statically decidable context SHALL return found, redirected, missing, incompatible, or unknown with original/normalized/final path, requested/resolved type, context symbol, and scope evidence.

#### Scenario: Compatible asset exists
- **WHEN** the normalized path exists and its asset/generated class is assignable
- **THEN** the state is found

#### Scenario: Redirect resolves
- **WHEN** a source path resolves through a valid redirect chain to a compatible asset
- **THEN** the state is redirected and the final target is recorded

#### Scenario: Authoritative path is absent
- **WHEN** complete scope proves the path absent
- **THEN** the state is missing

#### Scenario: Snapshot cannot decide
- **WHEN** scope, completeness, availability, or required type hierarchy is insufficient
- **THEN** the state is unknown rather than missing or incompatible

### Requirement: Asset type compatibility
Object contexts SHALL validate asset class assignability and class contexts SHALL validate generated-class/base assignability using bundle relationships without loading assets or classes.

#### Scenario: Existing type is incompatible
- **WHEN** the path exists but the resolved object/generated class is not assignable to the requested type
- **THEN** the state is incompatible and analysis exits `1`

### Requirement: Resource severity policy
Missing soft references SHALL warn by default, authoritative missing hard/load contexts and incompatible types SHALL error, redirected paths SHALL report the final target, and `--strict-resources` SHALL promote all authoritative missing results to errors without promoting unknown.

#### Scenario: Strict soft missing
- **WHEN** a soft path is authoritatively missing and strict resources is enabled
- **THEN** it is an error and analysis exits `1`

#### Scenario: Unknown under strict mode
- **WHEN** a path remains unknown
- **THEN** strict mode does not reclassify it as missing

### Requirement: Resource artifact evidence
Diagnostics and results SHALL record stable resource state, paths, types, context, scope, severity, and counts, and class/default records SHALL reference related diagnostic IDs.

#### Scenario: Analysis repeats
- **WHEN** source, bundle, and policy are identical
- **THEN** resource diagnostics and deterministic result fields are identical

### Requirement: Resource producer/consumer evidence
Producer-generated complete/incomplete asset fixtures and standalone UE-AS snippets SHALL record normalized state, paths, type identity, source location, category, severity, and selected bundle identity without loading an asset.

#### Scenario: Claimed resource fixture lacks producer facts
- **WHEN** a fixture has no complete/incomplete scope evidence or its consumer result cannot be reproduced from the selected bundle
- **THEN** the resource support claim is rejected

### Requirement: Corpus-backed UE support claims
UE frontend, registration, class, template, resource, and representative project behavior SHALL be claimed supported only from reviewed entries with provenance, expected diagnostics/symbol/class/resource evidence, and no unexplained differential.

#### Scenario: UE fixture agrees
- **WHEN** outcome, diagnostic category/location, stable symbols, class/resource model, classification, and bytecode completion match
- **THEN** the fixture may contribute to its exact or compile-shim support tier

#### Scenario: UE fixture disagrees
- **WHEN** a claimed fixture differs without approved ue-required/unsupported evidence
- **THEN** release verification fails

### Requirement: Explicit UE claim tiers
Published support SHALL distinguish supported-exact, supported-compile-shim, partial-ue-required, and unsupported and SHALL identify required bundle/profile/adapter versions.

#### Scenario: Feature lacks complete evidence
- **WHEN** a feature has partial, deferred, or unsupported fixtures
- **THEN** documentation cannot describe it as fully supported

### Requirement: UE validation release safety scan
Release verification SHALL reject Unreal dependencies in standalone, branches in existing binds/ClassGenerator, addresses/code/bodies/source/private machine paths in bundles, a second packaged project bundle, UE execution paths, UE-loadable bytecode claims, missing licenses, and unapproved profile mixing. Exactly one deterministic `default-engine` bundle exported from the checked-in `AngelscriptProject` host SHALL be the packaged UE contract; project and optional-plugin symbols captured from that host are allowed when their exact scope and provenance are declared.

#### Scenario: UE run command is exposed
- **WHEN** help, source, package, example, or documentation exposes UE execution
- **THEN** release verification fails

#### Scenario: UE-loadable claim appears
- **WHEN** a UE-validation artifact is described as loadable/executable in UE
- **THEN** release verification fails

#### Scenario: Additional project bundle enters the package
- **WHEN** package inspection finds a second `project`-kind bundle, an undeclared extra contract, source text, or private machine paths
- **THEN** release verification fails while the one allowlisted `AngelscriptProject`-generated `default-engine` bundle remains required

#### Scenario: Default contains the release host's enabled scope
- **WHEN** package inspection finds project or optional-plugin symbols whose provenance and loaded scope match the checked-in `AngelscriptProject` release export
- **THEN** release verification accepts them as part of the declared packaged default rather than treating `default-engine` as an engine-only filter

### Requirement: UE artifact determinism
Identical UE analysis inputs SHALL produce identical validation bytecode, class models, resource diagnostics, and deterministic result fields under the same compiler/profile/bundle/adapters.

#### Scenario: UE analysis repeats
- **WHEN** all identity-bearing inputs are unchanged
- **THEN** deterministic artifacts match

### Requirement: UE analysis performance baseline
The project SHALL record fixed-environment bundle load/index, core analysis, template/resource analysis, source module/LOC, and peak-memory metrics and SHALL fail a later identical-environment median regression greater than 20%.

#### Scenario: Analysis regression exceeds threshold
- **WHEN** an identical baseline environment regresses beyond 20%
- **THEN** the gate fails with per-stage metrics

### Requirement: Standalone suite integration
The Standalone suite SHALL run independently with unique reports and SHALL enter the repository `All` suite only after repeated complete runs show no nondeterministic artifact, leaked process/file, or flaky differential.

#### Scenario: Soak is not stable
- **WHEN** repeated isolated runs disagree or leak resources
- **THEN** Standalone remains excluded from `All`

### Requirement: Chinese-first boundary documentation
Release documentation SHALL explain two profiles, default-versus-project complete bundle selection, no-merge/no-fallback behavior, native limits/security, bundle scope/privacy, script-baseline replacement, address-free linkage, class-model/ClassGenerator boundary, adapters, resource states, support tiers, and validation-only/no-UE-execution/no-UE-load constraints, updating Chinese guidance first.

#### Scenario: Documentation release check runs
- **WHEN** package and repository docs are scanned
- **THEN** required boundaries and exact standard commands are present and contradictory execution/load claims are absent
