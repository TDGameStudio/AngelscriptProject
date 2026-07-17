## 1. OpenSpec and migration contract

- [x] 1.1 Record the approved breaking rename policy and canonical binding vocabulary in `proposal.md` and `design.md`.
- [x] 1.2 Record the current generated-artifact and cross-module ABI baselines before source edits.

## 2. Runtime binding registry

- [x] 2.1 Introduce `FAngelscriptFunctionBinding` and canonical field names without changing record layout or initialization semantics.
- [x] 2.2 Add `RegisterFunctionBinding` and canonical registry accessor names while preserving duplicate precedence behavior.
- [x] 2.3 Migrate Runtime binding consumers, reflective fallback code, cross-module injection, and focused tests to canonical names.
- [x] 2.4 Remove all Runtime registry legacy names and add source-scan assertions that no aliases or wrappers remain.

## 3. UHT and Editor generators

- [x] 3.1 Rename UHT generator-internal entry records, helpers, locals, and binding-kind terminology while preserving CSV/JSON field names.
- [x] 3.2 Emit canonical Runtime registration calls from normal UHT function-table shards.
- [x] 3.3 Migrate the legacy Editor-side generator call sites and verify generated legacy output remains behaviorally equivalent.
- [x] 3.4 Add source and generated-artifact checks proving production paths use canonical names outside the compatibility layer.

## 4. Cross-module compatibility

- [x] 4.1 Rename the cross-module public header, POD types, namespace, and Modular Feature key without changing the payload layout.
- [x] 4.2 Run cross-module layout, link-probe, late-registration, multi-shard, and fallback-priority coverage.
- [x] 4.3 Verify generated shard names, feature registration, flags, layout version, and diagnostics remain unchanged.

## 5. Validation and handoff

- [x] 5.1 Run focused UHT/function-table tests through `Tools\\RunTests.ps1`.
- [x] 5.2 Run the relevant full test suite through `Tools\\RunTestSuite.ps1`; the known baseline remains `90/101` with 11 shared Engine/TypeDatabase lifecycle failures.
- [x] 5.3 Run `Tools\\RunBuild.ps1` for the configured editor target.
- [x] 5.4 Update affected documentation and summarize parent/submodule commit boundaries without committing unrelated dirty-worktree changes.

## 6. ModuleLocal compile gate and engine distribution policy

- [x] 6.1 Add the compile option, default ini value, and compile-macro validation coverage. <!-- TDD -->
- [x] 6.2 Make `AngelscriptRuntime.Build.cs` read the option, invalidate UBT on ini changes, define the macro, and hard-fail on non-source engines. <!-- TDD -->
- [x] 6.3 Gate the Runtime ModuleLocal bridge and its runtime-only automation coverage behind the macro. <!-- TDD -->
- [x] 6.4 Make UHT read the same option, hard-fail on installed/unknown engines, and suppress shards when disabled. <!-- TDD -->
- [x] 6.5 Bind Editor compile-option `OnModified` validation with error/revert/reject behavior and add settings coverage. <!-- TDD -->
- [x] 6.6 Update policy/configuration documentation and run focused build/test plus the full suite. <!-- Non-TDD -->
