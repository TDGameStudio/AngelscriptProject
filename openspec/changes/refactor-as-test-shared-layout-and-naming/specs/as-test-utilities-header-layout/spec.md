## ADDED Requirements

### Requirement: AngelscriptTestUtilities.h serves as umbrella header

`Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h` SHALL exist as a thin umbrella header that aggregates the themed sub-headers without containing any inline function definitions of its own. It SHALL remain the single backward-compatible include entry point for all 400+ existing test `.cpp` files.

#### Scenario: Existing test files compile through the umbrella

- **WHEN** a test `.cpp` file in `AngelscriptTest/` or in an extension test module includes only `Shared/AngelscriptTestUtilities.h`
- **THEN** every symbol it previously consumed (engine acquisition, cleanup, memory probes, module builders, AS function execution, fixture) MUST resolve through the umbrella without requiring any additional `#include` change

#### Scenario: Umbrella owns no inline implementations

- **WHEN** the umbrella header is parsed
- **THEN** it MUST contain only `#include` directives plus structural/documentation comments — no function bodies, no class bodies, no inline templates

### Requirement: Shared directory exposes six themed sub-headers split from the umbrella

The `AngelscriptTest/Shared/` directory SHALL contain six themed headers extracted from the historical `AngelscriptTestUtilities.h` god-header, each with a single well-defined responsibility:

| Header | Responsibility |
|--------|----------------|
| `AngelscriptTestEngineAcquisition.h` (+ `.cpp`) | Engine factory / shared engine / isolated engine / transient engine acquisition |
| `AngelscriptTestEngineCleanup.h` | UASClass / `BlueprintActionDatabase` / `K2Node_*` cleanup for GC, including the `WITH_EDITOR` block |
| `AngelscriptTestMemoryProbe.h` | Memory probe sampling and probe-instrumented engine acquisition |
| `AngelscriptTestModuleBuilder.h` | `BuildModule` / `GetFunctionByDecl` / `FScopedAutomaticImportsOverride` |
| `AngelscriptTestExecute.h` | AS global function execution + assertions (sole entry point for the `Execute*` naming family) |
| `AngelscriptTestFixture.h` | `FAngelscriptTestFixture` definition |

#### Scenario: Each themed header owns its responsibility

- **WHEN** a test `.cpp` needs only one of the six themes (e.g., only the memory probe)
- **THEN** including the corresponding themed header alone MUST be sufficient and MUST NOT drag in the other five themes' implementations

#### Scenario: Umbrella aggregates exactly the six themed headers

- **WHEN** the umbrella `AngelscriptTestUtilities.h` is inspected
- **THEN** it MUST include all six themed headers in `Shared/` plus the existing `AngelscriptTestEngine.h` and `Misc/AutomationTest.h`, and no other inline content

### Requirement: AngelscriptTestExecute.h is the sole AS-function-execution entry point

`Shared/AngelscriptTestExecute.h` SHALL be the only header in `AngelscriptTest/Shared/` that defines or re-exports the AS global function executor class, AS function invocation helpers, and AS execution-side assertion helpers. Other `Shared/` headers MUST NOT define equivalent executors or assertion helpers.

#### Scenario: Executor class lives only in Execute.h

- **WHEN** the test module is grep'd for the executor class definition (`class F<...>Executor` / `struct F<...>Executor`)
- **THEN** the unique definition MUST appear inside `AngelscriptTestExecute.h`; other `Shared/` headers MUST NOT define a parallel executor

#### Scenario: Assertion helpers live only in Execute.h

- **WHEN** the test module is grep'd for one-line AS function assertion helpers (`Expect*` or `Execute*`-prefixed free functions that drive AS execution)
- **THEN** they MUST be declared in `AngelscriptTestExecute.h`; other `Shared/` headers MUST NOT re-declare them outside of forward-only headers permitted by the next requirement

### Requirement: Legacy execute-related headers remain as forward-only includes

The two legacy headers `Shared/AngelscriptGlobalFunctionInvoker.h` and `Shared/AngelscriptBindingsAssertions.h` SHALL be preserved as **forward-only** headers (each ~3 lines) that delegate to `AngelscriptTestExecute.h`. They MUST NOT contain any local definitions. Physical deletion of these two headers is deferred to a follow-up change.

#### Scenario: Forward headers contain only a single include

- **WHEN** `AngelscriptGlobalFunctionInvoker.h` or `AngelscriptBindingsAssertions.h` is opened
- **THEN** the file MUST contain only `#pragma once` (optional) and `#include "AngelscriptTestExecute.h"` plus comments; no other declarations

#### Scenario: Existing callsites compile unchanged through forward headers

- **WHEN** any existing test `.cpp` includes `Shared/AngelscriptGlobalFunctionInvoker.h` or `Shared/AngelscriptBindingsAssertions.h` (whether directly or through the umbrella)
- **THEN** every symbol the file previously consumed MUST still resolve, and the file MUST compile without modification

### Requirement: Editor-only header dependencies are quarantined to the Cleanup header

The `WITH_EDITOR`-only includes `BlueprintActionDatabase.h` and `K2Node_GetSubsystem.h` (plus any other editor-only headers required by UASClass GC cleanup) SHALL appear only inside `Shared/AngelscriptTestEngineCleanup.h`. Other `Shared/` headers and the umbrella MUST NOT include them, so test TUs that do not depend on cleanup do not transitively pull editor symbols.

#### Scenario: Cleanup header owns the editor includes

- **WHEN** the test module is grep'd for `BlueprintActionDatabase.h` or `K2Node_GetSubsystem.h` inside `Shared/`
- **THEN** the only `#include` match MUST be `Shared/AngelscriptTestEngineCleanup.h`

#### Scenario: Non-cleanup TUs do not transitively see editor symbols

- **WHEN** a test `.cpp` includes `AngelscriptTestUtilities.h` but never directly includes `AngelscriptTestEngineCleanup.h`
- **THEN** that TU's preprocessor output MUST NOT contain definitions or declarations from `BlueprintActionDatabase.h` / `K2Node_GetSubsystem.h`

### Requirement: Legacy engine acquisition aliases are removed in favor of canonical names

The four pure-forward aliases `GetSharedTestEngine`, `GetResetSharedTestEngine`, `AcquireFreshSharedCloneEngine`, and `ResetSharedInitializedTestEngine` SHALL be removed from `AngelscriptTestSupport::`. The ~46 existing callsites inside the `AngelscriptTest` module SHALL be migrated to the canonical names `GetOrCreateSharedCloneEngine`, `AcquireCleanSharedCloneEngine`, and `ResetSharedCloneEngine` within this change.

#### Scenario: Aliases no longer exist

- **WHEN** the test module is grep'd for the four legacy alias names
- **THEN** no declarations, definitions, or `using` aliases for them MUST exist anywhere in `AngelscriptTest/`

#### Scenario: Callsites use canonical names

- **WHEN** the test module is grep'd for legacy alias callsites
- **THEN** every former call MUST have been replaced with the corresponding canonical name, and the project MUST build without referring to the legacy aliases

### Requirement: Shared directory has a navigation README

`Plugins/Angelscript/Source/AngelscriptTest/Shared/README.md` SHALL exist and SHALL provide a one-screen navigation index covering: the umbrella + six themed headers; the bindings-related sibling headers (`AngelscriptBindingsModuleBuilder.h`, `AngelscriptBindingsExampleSection.h`); the retired `AngelscriptBindingsCoverage.h` Profile abstraction; the legacy forward headers slated for future deletion; and a brief pointer for new code to prefer the `Execute*` naming family over the legacy `Expect*` / `Call*` aliases.

#### Scenario: README enumerates the themed headers

- **WHEN** `Shared/README.md` is opened
- **THEN** it MUST list each of the six themed headers along with a one-line responsibility statement matching the table in the second requirement

#### Scenario: README marks legacy forward headers

- **WHEN** the README's header inventory is read
- **THEN** `AngelscriptGlobalFunctionInvoker.h` and `AngelscriptBindingsAssertions.h` MUST be marked as legacy forward-only headers that point to `AngelscriptTestExecute.h`, with a note that deletion is deferred to a follow-up change

### Requirement: Each themed header carries a leading documentation block

Every new themed header (the six split headers and the legacy forward headers updated in this change) SHALL start with a block comment (approximately 10-20 lines) stating its responsibility, the headers it depends on, and the typical caller pattern. The umbrella header SHALL state that it is an aggregation entry only.

#### Scenario: Header preamble documents responsibility and dependencies

- **WHEN** any themed header file in `Shared/` introduced or rewritten by this change is opened
- **THEN** the first non-`#pragma once` block MUST be a comment that names the header's single responsibility, lists its direct dependencies on other `Shared/` headers or engine APIs, and points to a representative caller or test theme

## Testing Requirements

- Target test layer: existing `AngelscriptTest` Bindings + CppTests + AngelScriptSDK suites; no new test cases added by this requirement set (header layout is verified by compile + existing automation).
- Expected Automation prefix unchanged: `Angelscript.TestModule.*`, `Angelscript.CppTests.*`, `Angelscript.TestModule.AngelScriptSDK`.
- Recommended helpers/harnesses: existing `Shared/AngelscriptTestUtilities.h` umbrella; new themed headers consumed directly where TUs need to minimize transitive includes.
- Verification entry points:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-test-utilities-header-layout -TimeoutMs 1800000 -NoXGE`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Label as-test-utilities-header-layout -TimeoutMs 1800000`
