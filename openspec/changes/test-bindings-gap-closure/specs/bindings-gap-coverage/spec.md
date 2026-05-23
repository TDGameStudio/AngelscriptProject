## ADDED Requirements

### Requirement: Binding gap cases SHALL be explicit and runnable
The `Bindings` test surface SHALL no longer rely on silent placeholder skips for the covered gap clusters. Each affected case SHALL either execute against an available binding or remain as an explicit negative contract that names the missing binding or environment constraint.

#### Scenario: Covered files no longer contain silent binding-gap placeholders
- **WHEN** the covered binding test files are scanned after this change is applied
- **THEN** the targeted cases do not rely on unlabeled `TODO(binding-gap)` or `#if 0 // Disabled: binding gap` placeholders to hide the test outcome
- **AND** any remaining limitation is described with a concrete reason

#### Scenario: Existing binding discovery remains stable
- **WHEN** the automation framework scans the `Bindings` theme after this change is applied
- **THEN** the restored cases remain discoverable under `Angelscript.TestModule.Bindings.*`
- **AND** the existing themed file layout stays intact

### Requirement: Geometry and math binding coverage SHALL exercise the box and plane surfaces
The binding suite SHALL provide explicit coverage for the box, sphere, and plane surfaces currently represented by the `Box3f` and `Sphere3f` binding tests.

#### Scenario: FBox and FBox3f cases have explicit outcomes
- **WHEN** `AngelscriptBox3fBindingsTests.cpp` is run after this change is applied
- **THEN** the FBox and FBox3f cases validate the intended constructor, validity, and geometry behaviors with real assertions or named negative contracts

#### Scenario: Plane-related coverage is represented explicitly
- **WHEN** `AngelscriptSphere3fBindingsTests.cpp` or the related geometry binding coverage is run after this change is applied
- **THEN** the FPlane-related case is no longer a silent skip and instead documents the actual supported outcome for the available plane constructor surface

### Requirement: Platform, path, and profiler binding coverage SHALL exercise the runtime helper surfaces
The binding suite SHALL provide explicit coverage for the app, platform, path, and profiler helper bindings that are currently hidden behind placeholder gaps.

#### Scenario: FApp and platform helper cases are explicit
- **WHEN** `AngelscriptPathsBindingsTests.cpp` and `AngelscriptPlatformMiscBindingsTests.cpp` are run after this change is applied
- **THEN** the FApp and FGenericPlatformMisc cases assert the supported helper behavior or name the unsupported boundary explicitly

#### Scenario: CpuProfiler coverage is explicit
- **WHEN** `AngelscriptCpuProfilerBindingsTests.cpp` is run after this change is applied
- **THEN** the FCpuProfilerTraceScoped coverage no longer depends on a silent skip and instead reports a concrete supported or unsupported outcome

### Requirement: String, delegate, memory, and component-adjacent binding coverage SHALL be explicit
The binding suite SHALL provide explicit coverage for the string, delegate, memory-reader, and component-adjacent binding cases that are currently hidden behind placeholder gaps.

#### Scenario: FString and delegate cases are no longer silent skips
- **WHEN** `AngelscriptFStringBindingsTests.cpp` and `AngelscriptFileAndDelegateBindingsTests.cpp` are run after this change is applied
- **THEN** the affected cases either exercise the available binding surface or state a concrete unsupported boundary

#### Scenario: MemoryReader and projectile-movement cases are explicit
- **WHEN** `AngelscriptMemoryReaderBindingsTests.cpp` and `AngelscriptMeshComponentBindingsTests.cpp` are run after this change is applied
- **THEN** the covered cases do not rely on silent placeholder skips for the headless or bounds-check limitation

### Requirement: Binding coverage SHALL remain under the existing test entry points and documentation
The restored binding coverage SHALL remain under the existing `Bindings` Automation family and SHALL be reflected in the project test documentation.

#### Scenario: Bindings prefix regression remains stable
- **WHEN** `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings."` is executed after this change is applied
- **THEN** the restored cases are included in the run and the active binding coverage remains green

#### Scenario: Documentation reflects the restored coverage map
- **WHEN** `Documents/Guides/TestCatalog.md` and `Documents/Guides/Test.md` are inspected after this change is applied
- **THEN** they describe the restored binding coverage surface and any remaining explicit boundary cases

## Testing Requirements

- **Target test layer**: Bindings CQTest layer under `Plugins/Angelscript/Source/AngelscriptTest/Bindings/`.
- **Expected Automation prefix**: `Angelscript.TestModule.Bindings.<Type>.*`.
- **Recommended helper / harness**: `CQTest.h`, `FCoverageModuleScope`, and the existing `Bindings/Shared/` helpers.
- **Verification entry point command**:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings-gap-closure -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label bindings-gap-closure -TimeoutMs 180000`
