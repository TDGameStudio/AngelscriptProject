## 1. Protocol and Runtime bridge

- [x] 1.1 Rename the public protocol header, POD types, protocol namespace, feature key, and layout assertions to `ModuleBinding` names without changing layout.
- [x] 1.2 Rename `Bind_CrossModuleDirect.cpp`, Runtime bridge functions, state variables, test exports, and includes to `Bind_ModuleBinding.cpp` and `ModuleBinding` names.
- [x] 1.3 Update the Runtime source-scan and public-header tests to reject legacy protocol names and accept the canonical names.

## 2. UHT generator and artifacts

- [x] 2.1 Rename UHT generator records, selection/configuration types, helper methods, local generated structs, and protocol classification methods.
- [x] 2.2 Rename the UHT configuration/layout files and all candidate/discovery/stale-cleanup paths.
- [x] 2.3 Rename generated target-module shard and link-probe filenames while preserving target-module output ownership and ModuleLocal gating.
- [x] 2.4 Rename JSON/CSV summary fields, entry-kind values, and binding-specific skip-reason strings.

## 3. Tests and documentation

- [x] 3.1 Rename focused UHT/runtime test files, classes, prefixes, helper paths, and expected ModuleBinding artifacts.
- [x] 3.2 Preserve unrelated compiler dependency tests and migrate maintained UHT/build architecture documentation.
- [x] 3.3 Add/update source scans proving no legacy ModuleBinding protocol or artifact names remain in the active production path.

## 4. Verification and handoff

- [x] 4.1 Run focused UHT resolver and generated-table tests through `Tools\\RunTests.ps1`.
- [x] 4.2 Run the configured editor build through `Tools\\RunBuild.ps1` and verify default ModuleLocal-off output has no ModuleBinding shards.
- [x] 4.3 Run the relevant runtime/editor tests and record results in `verification.md`.
- [x] 4.4 Commit the plugin submodule first, then commit the parent OpenSpec/gitlink without staging unrelated dirty files.
