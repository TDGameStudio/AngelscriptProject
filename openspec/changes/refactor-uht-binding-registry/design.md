## Context

The current pipeline has two build/runtime paths:

1. `AngelscriptUHTTool` scans UHT reflection data and emits `AS_FunctionTable_*.gen.cpp` shards. Same-module shards call `FAngelscriptBinds::RegisterFunctionBinding` with either a direct native pointer or `ERASE_NO_FUNCTION()`.
2. `AngelscriptRuntime` stores those records in `ClassFunctionBindings`. `Bind_BlueprintCallable.cpp` later consumes the records and chooses direct AngelScript registration or reflective fallback. Cross-module shards publish a separate feature payload through `IModularFeatures`, and the Runtime bridge injects their callable targets into the same table.

The existing names obscure this separation. `AddFunctionEntry` sounds like AngelScript registration and suggests unconditional insertion, while its implementation applies a precedence policy. `FFuncEntry` is a generic container name, and `ClassFuncMaps`/`FuncPtr`/`Caller` use abbreviations that make the registry harder to discover. UHT generator records also reuse `Entry` for several different concepts.

The repository has pre-existing direct-bind, incremental-generation, cross-module ABI, allowlist, profile, and diagnostics specifications. This change must preserve those requirements while making the Runtime registry and cross-module protocol names explicit. The rename is intentionally source-breaking: this repository and any generated consumers are migrated together, with no compatibility alias.

## Goals / Non-Goals

**Goals:**

- Establish canonical Runtime-side names based on `FunctionBinding` and `FunctionBindingRegistry` semantics.
- Make the generated C++ call site communicate that it registers a callable target, not an AngelScript function.
- Separate internal generator terminology for normal binding records, cross-module binding records, and ABI payload records.
- Preserve registration precedence, reflective fallback selection, bind ordering, generated artifact names, diagnostic columns, and cross-module ABI layout.
- Remove the legacy Runtime-side and cross-module protocol names so production code has one vocabulary.
- Update tests and documentation to assert behavior through the canonical names.

**Non-Goals:**

- Do not expand direct-bind coverage or change signature parsing rules.
- Do not enable cross-module generation by default or change profile/allowlist behavior.
- Do not change the `FAngelscriptCrossModuleCallFrame` field layout, feature name, flags, or layout-version token.
- Do not redesign the UHT header parser or replace the UHT exporter mechanism in this change.
- Do not change generated file names or CSV/JSON schema fields used by existing diagnostics and tests.
- Do not modify unrelated dirty-worktree files.

## Decisions

### 1. Use `RegisterFunctionBinding` as the canonical Runtime operation

`RegisterFunctionBinding` accurately describes the operation and leaves room for direct, generic, cross-module, and stub-backed records. The implementation will retain the current merge policy: an existing valid direct binding wins; a previously empty/stub slot can be replaced by a valid binding; otherwise the later registration is ignored.

Alternatives considered:

- `AddFunctionEntry`: rejected because it describes neither the semantic object nor the duplicate policy.
- `BindFunction`: rejected because it implies immediate AngelScript registration, which still belongs to `Bind_BlueprintCallable.cpp`.
- `SetFunctionBinding`: rejected because registration is conditional and does not blindly overwrite an existing value.

### 2. Use `FAngelscriptFunctionBinding` for the Runtime record

The record represents a callable target plus dispatch metadata and fallback state. Its fields use full names (`FunctionPointer`, `FunctionCaller`, `bUsesGenericCall`) while preserving the existing field order and initialization behavior. `FFuncEntry` and `AddFunctionEntry` are removed rather than aliased.

The first implementation keeps the existing string key type and map shape to avoid changing name comparison semantics at the same time as the terminology migration. Converting the key to `FName` remains a separate optimization/refactor.

### 3. Rename the cross-module function-binding protocol as one contract

UHT generator records will use `Binding` terminology internally. The public cross-module header becomes `AngelscriptCrossModuleFunctionBindings.h`; `FAngelscriptCrossModuleEntry` becomes `FAngelscriptCrossModuleBinding`; `FAngelscriptCrossModuleFeatureReader` becomes `FAngelscriptCrossModuleBindingFeatureReader`; and the namespace/key become `FAngelscriptCrossModuleFunctionBindings` / `AngelscriptCrossModuleFunctionBindings`. The POD field layout, flags, feature payload layout, and layout token remain unchanged. Mixed old/new producers are not supported because the Modular Feature key changes.

Diagnostic artifact columns such as `EntryKind` remain unchanged even if the generator's internal property names become `BindingKind`.

### 4. Keep the current build ownership model

The exporter continues to use `ModuleName = "AngelscriptRuntime"`, normal shards continue to be consumed through Runtime wrapper files, and cross-module shards continue to be written to target-module output directories. This refactor changes vocabulary and call boundaries only; it does not change UBT/UHT ownership or dependency discovery.

### 5. Migrate in dependency order

The Runtime record and registration API will be introduced first, followed by Runtime consumers and tests, then UHT generated output, Editor legacy generation, and cross-module injection. The old names are removed only after all Runtime, UHT, Editor, tests, active specifications, and maintained documentation have migrated.

## Risks / Trade-offs

- [Risk] External users may include the old Runtime or cross-module names. → Treat this as a source-breaking plugin update, document the migration, and require a full rebuild of generated UHT output.
- [Risk] Generated C++ and C# source can drift during a broad rename. → Add source scans and generated-artifact assertions that require canonical registration calls and preserve artifact schema fields.
- [Risk] Cross-module ABI semantics could be accidentally changed while renaming local records. → Do not alter the public POD fields, feature name, flags, static assertions, or layout-version token; run the existing cross-module probe tests.
- [Risk] Legacy Editor code generation may be missed because it is not the primary UHT path. → Include `AngelscriptEditorCodeGen.cpp` in the migration search and retain its output-characterization coverage.
- [Risk] Dirty worktree changes could be overwritten. → Limit patches to the OpenSpec directory and explicit Angelscript submodule files; inspect status before and after each phase.

## Migration Plan

1. Record the canonical names and compatibility rules in this change.
2. Add the canonical Runtime record/API and migrate Runtime consumers and tests.
3. Migrate UHT generator records and emitted registration lines while preserving generated artifact schemas.
4. Migrate cross-module injection and legacy Editor generator call sites.
5. Run focused source/artifact checks, then `Tools\\RunBuild.ps1` and the relevant test entry points.
6. Verify no old production symbols, header includes, feature keys, active spec references, or maintained documentation references remain.

Rollback is a source-level revert of the submodule commit plus the parent OpenSpec/gitlink change. No serialized or cooked data migration is required.

### 6. Gate ModuleLocal binding compilation with compile options

The existing `UAngelscriptCompileOptions` object gains `bCompileAngelscriptModuleLocalBindings`, defaulting to `false`. `AngelscriptRuntime.Build.cs` reads the same project `DefaultAngelscriptCompileOptions.ini` as the test module, adds `WITH_ANGELSCRIPT_MODULE_LOCAL_BINDINGS=0/1`, and adds the ini file as an external dependency so UBT invalidates its makefile when the setting changes.

The option is the single build gate for the UHT-emitted module-local binding shards and the Runtime modular-feature bridge. The existing JSON file remains the profile/allowlist source and keeps its schema, but its legacy `enabled` value is migrated to `true`; the compile option now supplies the default-off behavior. Generated artifact names and diagnostic `CrossModule*` schema fields remain unchanged.

The setting is valid only with a source engine. Source detection follows the existing UHT policy: `Build/InstalledBuild.txt` wins as installed, `Build/SourceDistribution.txt` or a source-control marker identifies source, and unknown is treated as non-source. The Editor settings section binds `ISettingsSection::OnModified`; when the option is enabled on a non-source engine it shows an error, restores the disabled value, and returns `false` to reject saving. UBT and UHT repeat the check independently so direct ini edits cannot bypass the gate. UHT raises a generation error before emitting module-local shards; Runtime Build.cs raises a build error before compiling the bridge.

The bridge translation unit is wrapped in `WITH_ANGELSCRIPT_MODULE_LOCAL_BINDINGS`, and runtime-only cross-module automation coverage is compiled only when the bridge is enabled. The public POD header remains available for layout/source checks in either mode.
