## 1. Evidence and Design Selection

- [ ] 1.1 <!-- Non-TDD --> Capture the UBT dependency graph, generated shard ownership, source/installed profile module sets, module load timing, modular-feature lifecycle, payload layout/version, and every late-injected engine path.
- [ ] 1.2 <!-- Non-TDD --> Evaluate dependency-neutral interface-module, generated aggregation, build-time manifest/static aggregation, and other evidence-backed candidates; select one design with explicit symbol ownership, load ordering, and rollback behavior.
- [ ] 1.3 <!-- Non-TDD --> Rewrite `design.md` to close all open questions before implementation.

## 2. Pre-Seal Transport

- [ ] 2.1 <!-- TDD --> Add failing UHT golden tests proving target shards remain Runtime-independent and emit the selected transport shape.
- [ ] 2.2 <!-- TDD --> Add failing Runtime tests for deterministic pre-seal discovery under permuted module load order and for two-engine payload replay through explicit engine contexts.
- [ ] 2.3 <!-- TDD --> Implement the selected transport without changing profile eligibility, RPC fallback, or generated statistics.
- [ ] 2.4 <!-- TDD --> Add source- and installed-profile coverage for missing/invalid payload diagnostics and restart-after-seal behavior.

## 3. Dynamic Bridge Removal and Verification

- [ ] 3.1 <!-- TDD --> Prove parity between the pre-seal catalog and the current `IModularFeatures` bridge for every configured module before switching production consumption.
- [ ] 3.2 <!-- Non-TDD --> Remove NativeModuleFunctionAddress pending payloads, arrival/unload handlers, object-construction injection, and already-created-engine replay; remove all temporary dual-path code.
- [ ] 3.3 <!-- TDD --> Verify the binding/view layout byte-for-byte and bump the layout version only if the coordinated POD fields changed.
- [ ] 3.4 <!-- Non-TDD --> Run UHT resolver, generated binding, reflection/RPC, NativeCore, and All-suite validation through project scripts; run strict OpenSpec validation and `git diff --check`.
