## Delivery reconciliation

This checklist replaces the original phase-by-phase research backlog after the
implementation established the final V1 boundary. OpenSpec plans are
disposable; completed behavior is now tracked by product capability and fresh
evidence rather than by the order in which it was discovered.

The earlier shared `AngelscriptLanguageCore` direction is superseded. The UE
`FAngelscriptPreprocessor` remains authoritative, Standalone owns its frontend
privately, and `refactor-as-language-core-ue-facade-parity` now records only
future algorithm-by-algorithm compatibility work. Standalone V1 obtains the
final binding/reflection surface from one complete exported JSON bundle and
does not require a UE frontend ownership migration.

The 2026-07-31 default-bundle decision reopens the affected producer,
packaging, documentation, and verification work. The official packaged
snapshot is generated from the checked-in `AngelscriptProject` host and its
normally enabled plugins; no separate minimal-host fixture is required.

## 1. Historical shared-source direction (superseded by 2D)

The checked items in this section record work completed under the earlier
shared-frontend direction. They are retained as lifecycle history, not as the
current architecture; section 2D is authoritative for frontend ownership.

- [x] Build the maintained AngelScript fork from the same Runtime source files under Win64 CMake with no Unreal installation/include/library path, generated code, or process startup, resolving its existing UE Core includes only through `Standalone/Compat`.
- [x] Build one standard-C++ `AngelscriptLanguageCore` source set from UBT and CMake.
- [x] Keep `ANGELSCRIPT_LANGUAGE_STANDALONE` confined to the LanguageCore platform header and CMake propagation; add no UBT/public standalone option.
- [x] Keep existing `Bind_*.cpp` and ClassGenerator sources out of standalone and free of standalone branches, exporter calls, or symbol-only macros.
- [x] Replace the old “UE spelling is forbidden in the fork” scan with Compat-boundary checks for no real UE path/library, no Compat in UBT/LanguageCore/binds/ClassGenerator/ordinary host code, no standalone macro in the fork, and no mechanical standard-library fork rewrite.
- [x] Preserve the UE-facing preprocessor API and mature descriptor/ClassGenerator path.
- [x] Transfer full UE LanguageCore facade ownership/lowering/callback parity to `refactor-as-language-core-ue-facade-parity` with an executable migration plan.

## 2. Portable maintained fork and native runtime

- [x] Restore audited maintained-fork containers, atomics, math/assert/logging, memory, settings, and raw-object calls to their existing UE spellings; implement their standalone subset in `Standalone/Compat` and target-owned translation units.
- [x] Route engine/add-on allocation through the standalone `FMemory` compatibility boundary and verify zero tracked allocations after shutdown without installing a UE Runtime process-global host-service table.
- [x] Configure maximum-portability generic calls and select only the maintained parser/builder/compiler/module/context/bytecode/runtime sources required by standalone.
- [x] Import and document the pinned string, array, dictionary, and math add-ons with licenses and maintained deltas.
- [x] Provide the bounded UTF-8 string/array/dictionary/math/print/assert native profile with no file, network, process, dynamic-library, or arbitrary FFI registration.
- [x] Implement deterministic native compile artifacts and save/load bytecode coverage.
- [x] Implement native `run` for only `void main(const array<string> args)` and `int main(const array<string> args)`.
- [x] Enforce default/override timeout and counted memory limits, cancellation, exception/abort/resource exit categories, and context cleanup.
- [x] Implement CLI parsing, output-directory replacement, JSON/text diagnostics, deterministic identity, help/version, and exit codes `0`–`4`.
- [x] Add native corpus, add-on, runtime, CLI, end-to-end, lifecycle, determinism, soak, and benchmark tests.

## 2A. Compat-first fork minimization — approved 2026-08-01

- [x] Record the exact pre-migration fork diff and classify every changed hunk as mechanical portability, retained semantic behavior, unrelated/manual-binding work, or deferred review evidence.
- [x] Change `AngelscriptStandaloneArchitectureTests` first and observe it fail because `Standalone/Compat` is absent, the CMake target does not select it, fork-owned portability headers still exist, and the UE Runtime still installs standalone host services.
- [x] Add the bounded compatibility include tree for primitive aliases/macros, traits, `FMemory`, `FMath`, `FCStringAnsi`, `FCrc`, `FPlatformAtomics`, `TArray`, `TMap`, `TMultiMap`, `TSet`, `TPair`, `TInlineAllocator`, `TGuardValue`, and `FMemStackBase`.
- [x] Add standalone target-owned engine/settings, raw-script-object, string-scan, object-type, memory-callback, and thread cleanup/lock definitions with focused compatibility tests.
- [x] Put `Standalone/Compat` first only on `AngelscriptMaintainedFork`; keep compatibility headers private to the build tree and ship the V1 package as CLI-only without adding a UBT/public plugin option or fork conditional.
- [x] Remove `as_portable_containers.h`, `as_memoryarena.h`, and `as_host_services.*` from the fork and restore the 23 portability-only fork files to their UE-spelled baseline.
- [x] Shrink `angelscript.h`, `as_compiler.*`, `as_context.cpp`, and `as_scriptengine.cpp` to the explicit semantic allowlist; preserve `as_parser.cpp`, `as_restore.cpp`, and typed user data only with focused tests.
- [x] Restore `Core/angelscript.cpp`, UE string scanning, normal Runtime startup/shutdown, and remove `AngelscriptSDKHostServices.*`; leave unrelated manual-binding origin changes untouched.
- [x] Re-run architecture, compatibility, smoke, semantic observer, native runtime/add-on/lifecycle/soak, UE analysis, package, UE Development build, and focused NativeCore/compiler tests; attach fresh commands and results to verification records.

## 2D. Standalone-private frontend correction — approved 2026-08-01

- [x] <!-- TDD --> Invert the Standalone architecture test so the current Runtime `Language/` directory, `AngelscriptLanguageCore` CMake target, standalone language macro, and UE preprocessor delegation fail the intended final boundary.
- [x] <!-- TDD --> Add focused UE characterization for virtual-path module naming, range-for lowering, and OfflineContract SHA-256 output before changing ownership.
- [x] <!-- Non-TDD --> Move source, lexing, rewrite, preprocessing-session, and declaration code under `Standalone/Source/Compiler/Frontend`, move portable SHA-256 into Standalone support, and remove `UEAngelscript::Language` plus language export macros.
- [x] <!-- Non-TDD --> Compile the private frontend directly into `AngelscriptStandaloneHost`, rename the LanguageCore test target to `AngelscriptStandalone.Frontend`, and preserve the 19-test CTest inventory.
- [x] <!-- Non-TDD --> Restore UE module naming and range-for preprocessing to the pre-Language baseline, keep OfflineContract SHA-256 private to its new Dump identity translation unit after proving UE 5.8's generic platform API is unimplemented, and delete Runtime `Language/` after all consumers move.
- [x] <!-- Non-TDD --> Update Chinese-first architecture/build/test/offline-bundle documentation and mark shared-LanguageCore research or verification claims as superseded without deleting historical evidence.
- [x] <!-- Non-TDD --> Run Standalone Debug/Release, external package smoke, UE Development build, focused Preprocessor and Runtime/Editor OfflineContract tests, strict validation for both OpenSpecs, and path-scoped diff checks.

## 2B. Review remediation — 2026-08-01

- [x] Make the counted allocator a true hard limit: reserve atomically before the backing allocation, return null without allocating when the request would exceed the limit, preserve current/peak accounting, and record rejection count.
- [x] Route Compat container storage plus bounded `string`/string-stream/string-factory and `dictionary` key/map storage through the AngelScript/FMemory allocation boundary; remove unbounded `regexFind` from the registered native profile and prove shutdown returns tracked bytes to zero.
- [x] Add CMake-private `AS_USE_EXCEPTIONS=1` only for `AngelscriptMaintainedFork` so add-on allocation failure is caught by the existing AngelScript generic-call guard and becomes exit `4`; preserve the UE/UBT default `AS_NO_EXCEPTIONS` policy and add no plugin setting or public macro.
- [x] Reject native memory budgets below the measured 16 MiB engine-bootstrap floor before engine creation; retain the 256 MiB default and document host/OS allocation exclusions.
- [x] Keep the raw-object registry alive through type/user-data cleanup, destroy its allocator-bearing map whenever it becomes empty, and verify direct `Engine::Release()` teardown and repeated allocator ownership.
- [x] Emit instruction-callback `AFTER` only when the corresponding instruction was executed; verify a `BEFORE` callback exception has no false `AFTER` event.
- [x] Implement balanced standalone thread-manager prepare/get/unprepare ownership instead of returning success with a null manager.
- [x] Consume exported `editor-only` and `unavailable` availability by stable ID only when the semantic observer proves the symbol is used; classify each use as deterministic `unsupported` even when `--allow-ue-required` is present.
- [x] Align the standalone editor-only setting with the UE default and normalize reviewed public/internal names to UE acronym conventions (`UERequired`, `bAllowUERequired`, `UETypePath`, getters).
- [x] Correct the V1 packaging contract to CLI-only and make package inspection reject every non-allowlisted file, including compatibility/public headers.
- [x] Re-run the complete Debug/Release standalone matrix, installed package smoke, UE Development build, focused NativeCore/Compiler tests, strict OpenSpec validation, and diff checks; record fresh review-remediation evidence.

## 2C. V1 boundary and external-consumer closeout — approved 2026-08-01

- [x] <!-- TDD --> Add a configure-time target-interface assertion and observe it reject the current public maintained-fork definitions and propagated `Standalone/Compat` include path.
- [x] <!-- TDD --> Make the complete maintained-fork policy definition set and Compat include path private, keep only the required Core/fork include surface public, and prove the permanent interface assertion plus Debug/Release consumers pass.
- [x] <!-- TDD --> Reproduce a zero-size allocation freed after `FCountingAllocator` destruction, then track outstanding allocations independently from bytes so the owner state remains valid until the last delayed free.
- [x] <!-- Non-TDD --> Remove the always-successful `ValidateBundleKind` public API, its calls, and obsolete direct tests while preserving identical complete Project/Default traversal behavior.
- [x] <!-- Non-TDD --> Restore the two unrelated StateSnapshot loop-type edits, retain the two required `asFunctionCaller{}` registration fixes, and keep the eight unused wrappers deleted after a fresh Release compile proved they reference members absent with `AS_REFERENCE_DEBUGGING=0`.
- [x] <!-- Non-TDD --> Preserve unrelated Coverage Input/UStruct and shared TestMacros changes without reverting or staging them; add no new bind, ClassGenerator, or mature UE Runtime/Editor Standalone branch.
- [x] <!-- TDD --> Extend the parent CMakeCTest suite runner with optional additional build targets, add an independent `StandaloneRelease` suite that builds the final package target before Release CTest, and cover the entry with PowerShell self-tests without adding it to `All`.
- [x] <!-- TDD --> Add optional external `-ProjectFile` support to the standard Commandlet runner with unchanged default-project behavior and focused path/argument/failure-propagation self-tests.
- [x] <!-- TDD --> Add a parent-owned external Standalone smoke runner that creates a transient content-only project under `Saved`, exports deterministic default-path and explicit-path Project bundles, and consumes the bundle with the CLI extracted from the final Release ZIP.
- [x] <!-- Non-TDD --> Record the rejected PR-04 and PR-07 rationales: cross-module conditional SDK layout requires public Runtime definitions, and existing public Editor headers already expose AssetRegistry types.
- [x] <!-- Non-TDD --> Refresh Chinese-first documentation, English guidance, phase records, and final claim-to-evidence only after fresh external-project and installed-package evidence exists.
- [x] <!-- Non-TDD --> Run the official Debug/Release Standalone suites, external smoke, UE Development build, focused OfflineContract/NativeCore/Compiler/Preprocessor/Bindings tests, strict validation for both active OpenSpecs, and final path-scoped diff checks before declaring archive-ready.

## 3. Final-engine offline contract

- [x] Define versioned value-only manifest, symbol, callable/parameter, property, type/trait, adapter, scope, and asset records without pointer/address/body/source/bytecode/payload fields.
- [x] Define canonical UTF-8/LF JSON/JSONL, stable record ordering, schema compatibility, and versioned SHA-256 symbol/module/adapter/asset/file/bundle identities.
- [x] Publish machine-readable manifest, symbol, asset, result, differential-result, and corpus-index schemas.
- [x] Observe the final `asIScriptEngine` after configuration, manual/generated/reflective/optional/project registration and successful active script compilation.
- [x] Export primitives, enums, typedefs, funcdefs, delegates, types/templates, relationships, traits/layout, behaviors, properties, methods, globals, defaults, qualifiers, availability, origin, and UE semantic paths.
- [x] Export `host-surface` and declaration-only active `script-baseline` layers with stable module replacement identity and no script body/source/bytecode.
- [x] Supplement final observations with UE reflection/module/plugin/provenance facts while preserving explicit unknown provenance.
- [x] Export adapter ID/version/trait schema/engine properties/surface hash and reject drift before compilation.
- [x] Export normalized asset paths, generated classes, bases, mounts, redirects, availability, safe tags, included/skipped roots, and independent completeness.
- [x] Assemble counts/hashes/identity and publish through staging plus atomic destination replacement.
- [x] Reject incomplete symbol scope; allow only explicitly requested incomplete asset scope.
- [x] Make the plugin-owned project/default Commandlet usable from an external consuming Unreal project without host-module or repository-wrapper dependencies; cover argument gating, ignored default output, no symbol filters, producer fixture reading, safety scans, and repeated deterministic publication.
- [x] Redefine `DefaultEngine` as the packaged selection role rather than a minimal-host filter, allow the checked-in `AngelscriptProject` project/optional-plugin/script/asset scope, and keep both `project` and `default-engine` as complete full replacements with no merge, fallback, automatic cache search, or environment selection.

## 4. Standalone UE-validation compiler

- [x] Load exactly one selected bundle and validate required files, UTF-8/schema, counts/hashes, stable IDs, duplicates, complete symbol scope, producer/compiler/profile, feature flags, and adapters before registration.
- [x] Implement immutable symbol/owner/namespace/module/asset indices and a bundle-backed `ITypeOracle`.
- [x] Resolve source roots/entries/import closure deterministically and replace matching script-baseline modules while retaining only closure-external baseline dependencies.
- [x] Build deterministic registration passes for engine properties, primitives/enums/typedefs/funcdefs, type skeletons, relationships, members/callables, adapters, and source.
- [x] Register imported behavior through generic compile-only traps and prove invocation fails closed.
- [x] Add read-only compiler semantic observations for resolved calls, constructors, assignments, argument spans/types, stable function/type identities, and bounded constant strings without affecting normal compilation.
- [x] Produce value-only declaration/class semantics with source ranges, metadata/defaults, relationships, resolved stable symbols, and support findings.
- [x] Classify every used capability as exact, compile-shim, ue-required, or unsupported; implement `--allow-ue-required` partial status.
- [x] Emit deterministic `result.json`, `diagnostics.jsonl`, `.asbc`, and `.classes.jsonl` marked `ue-validation-only` and `non-ue-abi`.
- [x] Enforce no UE execution command and reject UE-validation identity before native `Prepare`.
- [x] Implement packaged-default selection and explicit project replacement with no fallback.
- [x] Add UE-analysis, registration, source-closure, CLI end-to-end, determinism, address-free, and representative project-script evidence.

## 5. Compile-only UE template adapters

- [x] Implement adapter registry handshake for ID, semantic version, trait schema, engine properties, and registration-surface hash.
- [x] Derive explicit construct/destruct/copy/compare/hash/template/object-handle/type-kind/size/alignment/GC traits without optimistic defaults.
- [x] Provide checked deterministic opaque layouts labeled `non-ue-abi` and trap every behavior.
- [x] Implement compile adapters for `TArray`, mutable/const iterators, `TMap`, `TSet`, `TOptional`, `TObjectPtr`, `TWeakObjectPtr`, `TSoftObjectPtr`, `TSubclassOf`, and `TSoftClassPtr`.
- [x] Enforce exported nested-template policy and recorded exceptions.
- [x] Cover positive/negative trait matrices, zero/invalid layout, overflow, object-handle keys, specialization relationships, iterator surfaces, wrappers, surface drift, and project Array/Map examples.
- [x] Document exact compile-only/no-UE-ABI/no-execution support boundaries.

## 6. Offline resource validation

- [x] Normalize package/object/generated-class, `/Game`, `/Engine`, `/Script`, and plugin-mount asset paths while retaining original evidence.
- [x] Build immutable asset, generated-class, type/base, mount/origin, availability, redirect, and complete/incomplete scope indices; reject duplicate inconsistency, cycles, and invalid redirects.
- [x] Discover only stable-identity typed soft object/class constructors, wrappers, properties/defaults, load calls, and bundle-marked callable parameters.
- [x] Export optional parameter-level `resourceKind` / `resourceTypeStableId` from final manual/reflected registrations without changing bind files.
- [x] Consume parameter markers only after compiler-resolved stable callable identity and exact argument span; ignore same-named source callables and unmarked strings.
- [x] Evaluate bounded direct literals, const declarations, and deterministic concatenation; defer mutable/dynamic expressions.
- [x] Validate found, redirected, missing, incompatible, and unknown without loading assets or classes.
- [x] Validate object asset-class and generated-class/base assignability through bundle facts.
- [x] Implement stable resource diagnostics, default soft/hard severity, strict promotion of authoritative missing only, state counts, and class/default diagnostic links.
- [x] Cover complete/incomplete scope, false-positive, redirect, type, strict, constant, semantic-span, marked/unmarked parameter, and deterministic artifact tests.
- [x] Export the current project twice and prove byte identity: 130,068 symbols, 9 assets, complete symbol/asset scope, 37 resource parameter markers.
- [x] Compile the project resource corpus against that bundle under strict mode and record one authoritative `found` result with no asset load.

## 7. Corpus, differential contract, safety, and performance

- [x] Define and validate the versioned corpus index with provenance, profile, dependencies, bundle, classification, expected outcomes, evidence, and rationale.
- [x] Reject duplicate/stale/unlabeled/unknown/incompatible corpus records and external evidence without complete symbol scope.
- [x] Implement a normalized differential result model for status, diagnostics, stable symbols, portable class/resource subsets, classification, bytecode completion, and optional native result.
- [x] Exclude bytecode bytes, runtime IDs, addresses, prose, elapsed time, and machine paths from differential comparison.
- [x] Record 13 reviewed corpus entries with 11 supported, one ue-required, one unsupported, including eight complete-project cases.
- [x] Add repeated native/UE analysis determinism, architecture/privacy/security/claim scans, tracked-allocation soak, and project-bundle exclusion tests.
- [x] Define benchmark environment/result records, cold/native/run/bundle/UE/template/resource/peak-memory collection, same-environment median comparison, 20% gate, and incomparable-environment handling.
- [x] Add Standalone as a typed independent suite entry and to `All` only after soak; preserve isolated reports and separate counts.

## 8. Package, documentation, and release verification

- [x] Assemble the Win64 package with CLI, README/support matrix, licenses/provenance, all schemas, exactly one `default-engine` exported from the checked-in `AngelscriptProject` and normal enabled-plugin set, and separated native/UE examples.
- [x] Generate the `AngelscriptProject` default twice and two package trees; require byte-identical bundle/package manifests, declared producer/module/plugin/asset scope, exact allowlisted contents, no second project bundle, and no extra execution/FFI/source/private-path surfaces.
- [x] Smoke installed `--help`, `--version`, native run, packaged-default UE compile against the real `AngelscriptProject` export, external-project Commandlet export, and explicit-project compile.
- [x] Validate shared product version `Unreal AngelScript 1.0.0` and record upstream lineage/profile/schema/adapter versions separately.
- [x] Publish evidence-scoped support tiers and exact corpus counts without blanket parity language.
- [x] Update Chinese documentation first, then English repository/plugin Build/Test/TestCatalog/Tool/README guidance to explain the generic Commandlet, `AngelscriptProject`-derived default scope, exact-project export workflow, and separate test-count scopes.
- [x] Record VS Code offline projection as optional future work without changing DebugServer V2 or the extension.
- [x] Run a fresh UE Development build after the parameter-level contract (`Saved/Build/standalone-resource-parameter-contract/20260731_090809_936_e3ca1f61`).
- [x] Run OfflineContract runtime tests after the parameter-level contract: `12/12` passed (`Saved/Tests/standalone-resource-parameter-contract/20260731_090835_456_82e8afdb`).
- [x] Re-run the official Standalone suite after the real `AngelscriptProject` default-bundle source/package changes and record fresh evidence.
- [x] Rebuild and inspect the final Release package after the real `AngelscriptProject` default-bundle change; record the new archive and manifest SHA-256.
- [x] Re-run focused Preprocessor, Compiler, Bindings, Editor OfflineContract, and active NativeCore verification after the reopened UE exporter/Commandlet changes.
- [x] Update `verification/phase-00-feasibility.md` through `phase-06-release.md` and `verification/final.md` with the revised default-bundle architecture, external-project Commandlet evidence, exact commands, hashes, known environmental issues, and machine-readable evidence.
- [x] Validate both OpenSpecs strictly and finish this change only when every revised published claim maps to passing evidence.
