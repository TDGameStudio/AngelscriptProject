# Refactor Module Binding Naming Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the overloaded `CrossModule` vocabulary in the UHT module-binding path with canonical `ModuleBinding` names while preserving behavior, ABI layout, and the existing `ModuleLocal` compile gate.

**Architecture:** The public Runtime protocol becomes `AngelscriptModuleBindingProtocol.h`, the Runtime receiver becomes `Bind_ModuleBinding.cpp`, and UHT target-module shards use `AS_FunctionTable_<Module>_ModuleBinding_<NNN>.cpp`. Generated target-module code remains self-contained and keeps its existing dependency boundary; only the names, artifact contracts, and source/test references change.

**Tech Stack:** Unreal Engine C++, UHT C# plugin, Unreal Automation/CQTest, PowerShell project test/build wrappers, OpenSpec.

## Global Constraints

- Preserve `FAngelscriptModuleBindingCallFrame`, `FAngelscriptModuleBinding`, and `FAngelscriptModuleBindingFeatureView` field order and sizes (`48`, `32`, `32` bytes).
- Preserve layout token `0xA5C0DE02`; this is a naming migration, not an ABI layout change.
- Preserve `bCompileAngelscriptModuleLocalBindings` and `WITH_ANGELSCRIPT_MODULE_LOCAL_BINDINGS` exactly.
- Preserve Runtime/UHT dependency boundaries; target-module shards must not add Engine module dependencies to `AngelscriptRuntime.Build.cs`.
- Do not rename unrelated compiler dependency terminology such as builder cross-module initializer diagnostics.
- Use only `Tools\\RunBuild.ps1`, `Tools\\RunTests.ps1`, and `Tools\\RunTestSuite.ps1` for project validation.
- Stage plugin source in `Plugins/Angelscript` first and update the parent gitlink only after the plugin commit.

---

### Task 1: Rename public protocol and Runtime receiver

**Files:**
- Rename: `Plugins/Angelscript/Source/AngelscriptRuntime/Public/UHT/AngelscriptCrossModuleFunctionBindings.h` → `Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/AngelscriptModuleBindingProtocol.h`
- Rename: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CrossModuleDirect.cpp` → `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ModuleBinding.cpp`
- Modify: Runtime tests and includes referencing the old header/bridge symbols.

**Interfaces:**
- Produces `FAngelscriptModuleBindingCallFrame`, `FAngelscriptModuleBinding`, `FAngelscriptModuleBindingFeatureView`, and `FAngelscriptModuleBindingProtocol::FeatureName()` returning `AngelscriptModuleBindingFeature`.
- Produces `GAngelscriptModuleBindingGenericHook`, `InjectModuleBindingFeature()`, and `RegisterExistingModuleBindingFeatures()`.

- [ ] **Step 1: Rename paths and symbols**

Use `git mv` for the two tracked source files, then update only the protocol and Runtime bridge symbols. The canonical public declarations are:

```cpp
struct FAngelscriptModuleBindingCallFrame;
struct FAngelscriptModuleBinding;
struct FAngelscriptModuleBindingFeatureView;
namespace FAngelscriptModuleBindingProtocol { inline FName FeatureName(); }
```

- [ ] **Step 2: Update Runtime tests and source scans**

Replace focused test includes, exported testing helpers, bridge path assertions, and source-scan expectations with the canonical names. Keep unrelated `CrossModule` strings outside the ModuleBinding path unchanged.

- [ ] **Step 3: Run focused compile/test check**

Run:

```powershell
Tools\\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label module-binding-protocol -TimeoutMs 600000
```

Expected: the current tests compile with zero old protocol include/type errors; generated-artifact tests may remain red until Task 2 updates the generator.

### Task 2: Rename UHT generator and generated artifacts

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs`
- Modify: `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs`
- Modify: `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptHeaderSignatureResolver.cs`
- Rename: `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-generation-modules.json` → `module-binding-generation-modules.json`
- Rename: `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-layout-version.txt` → `module-binding-layout-version.txt`

**Interfaces:**
- Generator record: `AngelscriptModuleBinding`.
- Generation helpers: `BuildModuleBindingShard`, `TryCreateModuleBinding`, `TryBuildModuleBinding`, `BuildModuleBindingCallArguments`, and `BuildModuleBindingFlagsExpression`.
- Target shard path: `AS_FunctionTable_<Module>_ModuleBinding_<NNN>.cpp`.
- Diagnostics: `totalModuleBindingEntries`, `moduleBindingEntries`, `moduleBindingRate`, `moduleBindingGenerationEnabled`, `EntryKind=ModuleBinding`.

- [ ] **Step 1: Rename generator internals**

Rename the C# records, properties, locals, helper methods, generated namespace/type names, and log labels. Leave `ModuleLocalBindingsSettingName` unchanged.

- [ ] **Step 2: Rename files and discovery paths**

Use the new lowercase filenames in all candidate enumeration, external dependency registration, error messages, and stale cleanup globs. Keep the numeric layout token unchanged.

- [ ] **Step 3: Rename generated output contracts**

Update generated paths and diagnostics as follows:

```text
AS_FunctionTable_<Module>_CrossModule_000.cpp → AS_FunctionTable_<Module>_ModuleBinding_000.cpp
AS_FunctionTable_Engine_LinkProbe.cpp → AS_FunctionTable_Engine_ModuleBinding_LinkProbe.cpp
EntryKind=CrossModule → EntryKind=ModuleBinding
totalCrossModuleEntries → totalModuleBindingEntries
crossModuleRate → moduleBindingRate
```

Use `module-binding-*` for binding protocol skip reasons, but do not touch unrelated AngelScript compiler dependency reasons.

- [ ] **Step 4: Run generator-focused tests**

Run:

```powershell
Tools\\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label module-binding-generator -TimeoutMs 600000
```

Expected: all UHT resolver, layout, profile, default-off, and generated-shard tests pass with the new filenames and fields.

### Task 3: Rename focused tests and maintained documentation

**Files:**
- Rename: `Plugins/Angelscript/Source/AngelscriptTest/UHTTool/AngelscriptCrossModuleLinkProbeTests.cpp` → `AngelscriptModuleBindingLinkProbeTests.cpp`
- Rename: `Plugins/Angelscript/Source/AngelscriptTest/UHTTool/AngelscriptCrossModuleDirectBindRuntimeTests.cpp` → `AngelscriptModuleBindingRuntimeTests.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptGeneratedFunctionTableTests.cpp`
- Modify: maintained UHT/build architecture docs under `Documents/Guides`, `Documents/Knowledges/ZH`, and `Plugins/Angelscript/README.md`.

**Interfaces:**
- Focused prefixes become `Angelscript.CppTests.UHTToolResolver.ModuleBinding...`.
- Public docs use `ModuleBinding`; compile policy docs retain `ModuleLocal`.

- [ ] **Step 1: Rename focused test files/classes/prefixes**

Update test helper names, artifact path helpers, automation prefixes, generated-file assertions, and public header assertions. Do not alter unrelated `AngelscriptBuilderDependencyTests.cpp` cross-module dependency tests.

- [ ] **Step 2: Update generated-table assertions**

Change expected JSON/CSV fields, `EntryKind`, and error messages to the new ModuleBinding schema while preserving count and rate assertions.

- [ ] **Step 3: Update maintained docs**

Update the architecture diagrams, build guide, extension guide, and Chinese UHT/type-binding notes. Explain that `ModuleLocal` is the build gate and `ModuleBinding` is the published protocol.

- [ ] **Step 4: Run source scan**

Run:

```powershell
rg -n "CrossModule|CrossoverModule|cross-module-generation|cross-module-layout" Plugins/Angelscript/Source/AngelscriptRuntime Plugins/Angelscript/Source/AngelscriptUHTTool Plugins/Angelscript/Source/AngelscriptTest/UHTTool
```

Expected: no legacy ModuleBinding-path symbols or artifact names; unrelated builder dependency tests are outside this scan.

### Task 4: Build, regression verification, and dual-repository handoff

**Files:**
- Modify: `openspec/changes/refactor-module-binding-naming/verification.md`
- Stage: only the explicit plugin files, new OpenSpec directory, plan file, and parent plugin gitlink.

- [ ] **Step 1: Run focused Runtime/editor tests**

Run the generated-table, FunctionCallers, BindConfig, and Editor module prefixes through `Tools\\RunTests.ps1`, recording exact totals.

- [ ] **Step 2: Run the configured editor build**

Run:

```powershell
Tools\\RunBuild.ps1 -Label refactor-module-binding-naming -NoXGE -TimeoutMs 1800000
```

Expected: build succeeds with default ModuleLocal bindings disabled and no target-module ModuleBinding shards emitted.

- [ ] **Step 3: Run final diff checks**

Run `git diff --check` in both repositories, inspect staged names, verify old-name stale cleanup behavior, and confirm unrelated dirty files remain unstaged.

- [ ] **Step 4: Commit plugin then parent**

Use:

```powershell
git -C Plugins/Angelscript commit -m "[Angelscript] Refactor: rename cross-module bridge to ModuleBinding"
git commit -m "[OpenSpec] Refactor: adopt ModuleBinding naming"
```

The parent commit records the OpenSpec change and updated `Plugins/Angelscript` gitlink only.
