# Workstream 06: Release Evidence

## Context

Earlier workstreams establish native execution, the UE offline contract, UE analysis core, template adapters, and resource validation. Each owns focused tests, but a release claim needs a single inventory that distinguishes supported behavior from known differences and verifies that packaging cannot blur the native-runtime/UE-validation boundary.

The repository already uses standard PowerShell build/test entry points and multiple test baselines. This workstream adds a Standalone release view without conflating NativeCore, catalogued C++ tests, or the full UE suite counts.

## Goals / Non-Goals

**Goals:**

- Define exactly which source fixtures justify native and UE support claims.
- Fail on unexplained differential, determinism, architecture, or profile-boundary regressions.
- Produce reproducible Win64 packaging with a generated default bundle from the checked-in `AngelscriptProject` host and complete licenses/help/version/schema documentation.
- Record fixed-environment performance/memory baselines and enforce bounded regression.
- Make standard repository runners the only documented verification entry.

**Non-Goals:**

- Adding new language syntax, UE registrations, templates, resource contexts, runtime add-ons, or platforms.
- Publishing a second user-project bundle or source; the one packaged default intentionally reflects this repository host's declared project/plugin scope.
- Promising UE-loadable bytecode, UE execution, or full parity outside the promoted corpus.
- VS Code offline contract projection.

## Decisions

### 1. Use a canonical corpus index and claim ledger

Each corpus entry records:

```text
id
source files and provenance
dialect/profile
required bundle/adapters
expected compile status
expected execution result when native
expected diagnostics
expected resolved stable symbols
expected class/resource results
support classification
intentional difference evidence
```

Corpus families:

- Native language/compiler/module/runtime/standard-library/execution limits;
- UE source/module/preprocessor/annotation/class/override/registration;
- UE templates/wrappers/nesting/traits;
- typed resources/scope/redirect/type;
- representative `Script/` modules and examples.

Every exclusion is `ue-required`, `unsupported`, or a documented intentional host difference. There is no unlabeled skip.

### 2. Normalize comparisons through one result schema

Create `AngelscriptStandaloneDifferentialResult` with:

- compile success/failure and status;
- diagnostic code/category/principal source location;
- resolved stable symbol IDs;
- portable class model subset;
- resource state/path/type;
- support classification;
- bytecode-generation completion;
- native execution outcome/script result when applicable.

Comparisons do not require UE/standalone bytecode byte equality, runtime IDs, native addresses, wall-clock equality, or diagnostic prose equality.

### 3. Separate claim tiers

- `supported-exact`: promoted exact fixtures all agree.
- `supported-compile-shim`: declaration/type/bytecode checks agree while runtime is explicitly unavailable.
- `partial-ue-required`: tool continues only with explicit allowance and reports incomplete.
- `unsupported`: deterministic rejection with named capability.

Documentation may state a feature is supported only if its reviewed matrix has no unexplained difference and every dependent adapter/contract/profile version is covered.

### 4. Enforce release architecture and safety scans

Release scans require:

- no UE headers/libraries/generated code in standalone;
- no copied maintained fork;
- no unapproved standalone business conditionals;
- no standalone branches in existing binds/ClassGenerator;
- no file/network/process/dynamic-library/arbitrary FFI in native profile;
- no native pointers/addresses/code/bodies in bundles;
- no second project-kind bundle, source text, or private machine paths in the package;
- exactly one allowlisted deterministic `default-engine` bundle generated from the checked-in `AngelscriptProject.uproject`, with its project/plugin/asset scope declared;
- no UE run/execute command or callable execution;
- no artifact/documentation statement that UE-validation bytecode is UE-loadable;
- all third-party licenses and source/version/delta notes present.

### 5. Measure performance on a fixed baseline, not across machines

Benchmark metadata records machine/OS/compiler/configuration/commit/profile/corpus. Metrics:

- cold CLI startup;
- native compile;
- native compile+run;
- UE bundle load/index;
- UE core analysis;
- template/resource analysis;
- peak tracked/native process memory where available;
- module count and source LOC.

The first accepted run becomes baseline. Later identical-environment median regression greater than 20% fails. Functional tests never fail on cross-machine absolute seconds. Native safety deadline tests remain separate deterministic behavior tests.

### 6. Stabilize the repository suite before adding it to All

`Standalone` remains independently runnable and writes unique reports. A reliability soak repeats the full standalone CTest/differential set without leaked processes/files or nondeterministic artifacts. Only then is it included in `RunTestSuite.ps1 -Suite All`.

Existing test baselines remain separately reported:

- catalogued C++ baseline;
- source-definition scale;
- active NativeCore prefix;
- live full-suite result.

Standalone counts get their own named baseline.

### 7. Package one Win64 compiler distribution

Package:

```text
as-standalone.exe
README.md
LICENSES/
schemas/
contracts/default-engine/
examples/native/
examples/ue-validation/
```

Release automation runs the plugin-owned offline export Commandlet twice against the repository's checked-in `AngelscriptProject.uproject` and normal release configuration. The two `default-engine` outputs must be byte-identical before one is copied under `contracts/default-engine/`. Its symbols are complete for that host and its independent asset completeness matches the declared export scope. Package inspection accepts project registrations and normally enabled optional plugins captured from that host when their provenance and loaded scope are declared; it rejects source/private machine paths, undeclared scope, a second project-kind bundle, and any additional contract.

Do not package a second `project`-kind bundle. UE examples show both modes: omission of `--bundle` uses the `AngelscriptProject`-generated convenience default, while exact project-specific validation invokes the same plugin-owned Commandlet in that project, exports a complete `Project` bundle to an ignored local path, and passes it explicitly. The package includes `--help` and `--version` golden tests, product/fork/profile/schema/adapter version output, and the exact CLI/result/artifact contracts.

The standalone product version is not independently assigned. It consumes `Core/UnrealAngelscriptVersion.h`, reports `Unreal AngelScript 1.0.0` as the primary identity, reports `AngelScript 2.33.0 WIP lineage + selective 2.38 backports` separately, and runs the plugin-owned `Tools/ValidateVersion.ps1` release check. GitHub tags and package manifests use the same semantic version without an additional standalone version line.

Native and UE examples are visibly separated. UE examples never expose a run action.

### 8. Document support and privacy Chinese-first

Update `AGENTS_ZH.md` before `AGENTS.md`, then plugin standalone README and build/test/tool guides. Documentation covers:

- architecture and ownership;
- two engine profiles;
- native standard library/security/limits;
- bundle production/privacy/scope;
- script-baseline replacement;
- address-free signature linkage;
- portable class model versus ClassGenerator;
- adapters and resource state table;
- support matrix and exact verification commands;
- validation-only/no-UE-load/no-UE-execution boundaries.

### 9. Keep VS Code projection explicitly optional

The canonical bundle may later project into the language server, but release tests do not depend on the extension. DebugServer V2 live mode and DebugDatabase wire compatibility remain unchanged.

## Risks / Trade-offs

- **[Corpus breadth is mistaken for blanket parity]** → Publish exact fixture families, tiers, versions, and exclusions.
- **[Diagnostic prose creates brittle tests]** → Compare stable code/category/principal location and structured evidence.
- **[Benchmark noise blocks development]** → Gate only identical fixed environment medians and keep functional/safety gates separate.
- **[All suite becomes flaky/slow]** → Require isolated soak/reliability evidence before inclusion.
- **[Packaged host scope is mistaken for private payload or a universal contract]** → Allow declared semantic project/plugin/asset scope from the checked-in `AngelscriptProject` default, but reject machine-absolute paths, source/body/bytecode/payload data, undeclared scope, and extra bundles; document how consumers export their exact project.
- **[Packaged default drifts from the executable]** → Generate it in the same release pipeline, export twice, validate schema/fork/profile/adapter compatibility, and include its hash in the package manifest.
- **[Docs imply UE execution]** → Automated phrase/command scans plus explicit profile tables and no run action for UE.

## Migration Plan

1. Consolidate corpus indices and normalized result schema.
2. Run/fix/classify the full reviewed matrix.
3. Add release architecture/safety/determinism scans.
4. Establish and record fixed-environment benchmarks.
5. Soak the Standalone suite and add it to `All` only if stable.
6. Generate the `AngelscriptProject` default bundle twice, require byte identity and declared producer/module/plugin/asset scope, and include only the allowlisted result.
7. Build/inspect the Win64 package and update Chinese-first documentation.
8. Run all final repository and OpenSpec gates.

Rollback can remove package/All-suite integration while retaining isolated Standalone verification and preceding functionality.

## Open Questions

None for the Win64 release evidence. Other platforms, VS Code projection, remote bundle distribution, and broader support claims require separate evidence changes.
