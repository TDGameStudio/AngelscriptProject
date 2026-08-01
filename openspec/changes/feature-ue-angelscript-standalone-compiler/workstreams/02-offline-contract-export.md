# Workstream 02: Offline Contract Export

## Context

Existing StateDump CSVs are diagnostic and count-oriented. DebugServer `DebugDatabase` and `AssetDatabase` are useful IDE projections but omit registration ABI, complete flags/behaviors, templates, provenance, script replacement semantics, integrity, and authoritative asset-scope metadata. Binding-source parsing would miss runtime conditions, reflective fallback, optional plugins, Blueprint/reflection facts, and final engine properties.

This workstream produces the only canonical UE-to-standalone data boundary. It is a producer phase; a frozen fixture reader is used for tests, but the production standalone consumer belongs to the following workstream.

## Goals / Non-Goals

**Goals:**

- Observe the final registered AngelScript environment without exporting implementation addresses or code.
- Serialize deterministic, streamable, diffable symbol and asset records.
- Publish either a release `default-engine` or project complete symbol snapshot through the same contract.
- Make compatibility, scope, completeness, provenance, and adapter requirements explicit.
- Support incremental standalone compilation by exporting declaration-only script baselines.
- Publish bundles atomically through a commandlet and test seam.

**Non-Goals:**

- Replaying registrations or compiling standalone source.
- Exporting function bodies, bytecode, native pointers, UObject addresses, asset payloads, or editor transient state.
- Claiming unloaded plugins/modules or unscanned assets exist or do not exist.
- Module/plugin-filtered symbol bundles, default/project deltas, tombstones, or merge policy.
- Replacing StateDump/DebugDatabase or changing their wire formats.

## Decisions

### 1. Own the canonical records in Runtime Dump

Create:

```text
AngelscriptRuntime/Dump/
  AngelscriptOfflineContractTypes.*
  AngelscriptOfflineContractIdentity.*
  AngelscriptOfflineSymbolExporter.*
  AngelscriptOfflineBundleWriter.*

AngelscriptEditor/Offline/
  AngelscriptOfflineAssetExporter.*
  AngelscriptOfflineExportCommandlet.*
```

Contract record structs separate semantic payload from UE traversal. Identity and canonical serialization have focused tests. The exporter remains a pure observer and consumes existing public engine/module/type/reflection APIs before requesting any new hook.

### 2. Export one fixed physical layout

```text
manifest.json
symbols.jsonl
assets.jsonl
```

Files are UTF-8 without BOM. Object keys and records follow documented canonical ordering. Line endings are LF. JSONL permits streaming and stable diffs.

A sibling staging directory receives symbol/assets files first, then hashes/counts, then the manifest. Publication renames the completed staging directory into the requested destination. Any failure removes or leaves only a clearly invalid staging directory; it never publishes a manifest-valid partial bundle.

### 3. Define semantic IDs independent of runtime IDs

Stable symbol ID is SHA-256 over a versioned canonical identity tuple:

```text
symbol-kind
normalized namespace
normalized owner stable identity
normalized complete declaration
```

Stable module ID is SHA-256 over:

```text
module-identity-version
normalized logical module name
normalized virtual source identity
```

Source contents and machine-absolute paths are excluded, so a changed module keeps its replacement identity. Content hashes remain separate debug/integrity fields.

Runtime type/function/module IDs may appear only in explicitly non-contract diagnostic fields and never participate in stable IDs or compatibility hashes.

### 4. Observe final state and supplement public AS gaps

Export begins only after:

- engine properties and feature flags are fixed;
- manual, UHT-generated, native-module, reflective, and optional-plugin registration completes;
- initial script compilation succeeds for included script baselines;
- required Asset Registry scanning reaches the declared completeness state.

`asIScriptEngine` enumeration is authoritative for the final callable/type surface. Existing `FAngelscriptType`, module descriptions, reflection, plugin/module inventory, and binding metadata supplement UE path, base/interface, availability, provenance, adapter, and scope fields not exposed publicly by AngelScript.

No per-bind exporter branch is added. Existing and future manual Binding providers register normally and are observed only through the final engine. If provenance cannot be proven, it is recorded as `unknown` rather than guessed. Any traversal failure or symbol filter makes the symbol scope incomplete and prevents publication of a manifest-valid bundle.

### 5. Separate host surface and script baseline

Every symbol record has:

- `originLayer`: `host-surface` or `script-baseline`;
- `originKind`: manual/generated/reflective/blueprint/script/optional-plugin/unknown;
- origin module/plugin;
- availability/editor/deprecation/internal state;
- stable module ID for script baseline records.

Host-surface includes application registrations and reflection-derived declarations. Script-baseline includes declaration/type/member relationships from successfully compiled script modules, with no function bodies, source text, default implementation bodies, or bytecode.

Failed/outdated script modules are excluded and listed in manifest scope diagnostics.

### 6. Export complete compile-relevant type and callable data

Type records cover object/reference/value/template/enum/typedef/funcdef/delegate kinds, namespace, base/interfaces, UE type path, flags, size/alignment, template shape, members, traits, availability, origin, and adapter requirement.

Callable records cover owner, namespace, kind/behavior, complete declaration, return, arguments, directions/defaults, const/accessor/access state, UE metadata needed by compilation, availability, origin, and stable identity.

The contract explicitly separates declarative size/alignment facts from ABI compatibility. A consumer may use them for validation planning but cannot infer UE-loadable bytecode.

### 7. Version non-declarative adapters

Each required template or registration adapter is represented by:

- stable adapter ID;
- semantic version;
- canonical registration-surface hash;
- required engine properties/traits;
- declarative-only flag when no adapter is needed.

The surface hash covers final exported declarations/behaviors owned by that adapter, not native implementation bytes.

### 8. Export a typed asset index with scope truth

Asset records contain:

- normalized package/object/generated-class paths;
- asset class and known base relationship;
- mount and project/engine/plugin origin;
- redirect source/final target;
- availability;
- minimal tags needed for type checking.

Manifest records scan roots, filters, skipped roots, registry loading state, and `complete`/`incomplete`. Asset completeness is independent of the mandatory complete symbol scope. Incomplete asset export is allowed only when explicitly requested and is unmistakably marked; it cannot support authoritative missing-asset claims.

### 9. Use a commandlet as the production entry

`UAngelscriptOfflineExportCommandlet` accepts:

```text
-Output=<directory>
-BundleKind=Project|DefaultEngine
-AssetRoots=<paths>
-AllowIncompleteAssets
```

Default output is beneath the invoking project's `Saved/AngelscriptStandalone/`. `Project` is the normal local export kind; official release automation uses `DefaultEngine` against this repository's checked-in `AngelscriptProject.uproject`. Both kinds enumerate the same complete final symbol surface and differ only in distribution/selection role and default destination. There are no module/plugin symbol filters. The commandlet waits for required engine/registration/asset state, refuses an authoritative symbol export when prerequisites are incomplete, and returns nonzero without publishing a valid partial bundle. `-AllowIncompleteAssets` affects only asset scope.

The Commandlet and all services needed for its entry live in `AngelscriptEditor`/`AngelscriptRuntime`. They do not depend on `Source/AngelscriptProject`, the repository's PowerShell wrappers, or host-specific bindings. Any consuming Unreal project with the plugin installed can invoke the standard Unreal commandlet entry and export a `Project` bundle after its own final initialization.

An automation seam invokes the producer services without launching a second process. A commandlet smoke test covers argument/scope/result mapping.

### 10. Treat privacy and compatibility as product behavior

The manifest describes `bundleKind`, complete loaded symbol scope, and whether project/plugin/module/asset names are present. Output remains ignored by default and is only published/source-controlled explicitly.

Compatibility fields include schema version, producer version, UE/plugin/fork/compiler contract version, platform/configuration policy, engine properties, feature flags, loaded module/plugin scope, `symbolScope.complete`, independent asset completeness, adapters, record counts, and file hashes.

`default-engine` is produced from the repository's checked-in `AngelscriptProject.uproject` and normal release configuration. It includes the final project registrations, normally enabled optional plugins, successful active script baseline, and declared asset scope actually present in that host. The name means "selected when the distribution user omits `--bundle`"; it does not mean engine-only or minimal. Its manifest records the producer project and exact loaded module/plugin/asset scope. A normal `project` bundle includes the invoking target project's corresponding final environment and is selected explicitly.

## Risks / Trade-offs

- **[Public AS enumeration omits provenance]** → Supplement from existing registries/reflection and record unknown instead of invasive per-bind hooks or guesses.
- **[Script baseline contains stale modules]** → Export only the last successful active module set and list exclusions/outdated states in the manifest.
- **[Absolute paths break determinism/privacy]** → Stable identity uses logical virtual sources; machine paths are omitted or separately redacted diagnostics.
- **[Asset registry completeness is ambiguous]** → Require explicit completeness state, roots, and filters; incomplete exports cannot be authoritative.
- **[A filtered symbol bundle masquerades as complete]** → Remove module/plugin symbol filters and fail publication unless final-engine traversal proves a complete symbol scope.
- **[The packaged default is mistaken for a universal core-only contract]** → Define `default-engine` as a distribution role, generate it from the checked-in `AngelscriptProject`, and publish its exact producer/module/plugin/asset scope.
- **[The Commandlet works only inside this repository]** → Keep the entry and producer dependencies plugin-owned and add a consumer-project smoke invocation that uses no host module or repository-only wrapper API.
- **[Atomic directory replace differs by filesystem]** → Isolate publication behind a tested UE filesystem service and document replacement failure behavior.
- **[Bundle fields imply runtime ABI]** → Name layout fields as compile facts, include no native addresses, and state the no-UE-load contract.

## Migration Plan

1. Add record/identity types and golden canonical serialization.
2. Export complete final symbols and script baselines without per-binding hooks or symbol filters.
3. Add bundle kind, independent symbol/asset completeness, compatibility/integrity, and atomic writer.
4. Add asset index and completeness semantics.
5. Add commandlet, automation seam, project/default fixtures, docs, and frozen fixtures.
6. Hand the versioned complete fixture bundles to the standalone analysis-core workstream.

Rollback removes exporter/commandlet files without changing runtime registration, StateDump, DebugServer, or assets.

## Open Questions

None for the v1 producer. Compression, remote distribution, incremental bundle patches/tombstones, multi-bundle merging, and content redaction profiles require separate changes.
