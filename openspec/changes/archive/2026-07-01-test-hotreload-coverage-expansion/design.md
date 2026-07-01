## Context

The recent Blueprint-child crash came from a `DoSoftReload` assumption that every generated Blueprint class visited during schema refresh was itself a `UASClass`. That specific issue needs a soft-reload regression, but the broader problem is that HotReload coverage is sparse compared with the analyzer's decision surface.

## Goals / Non-Goals

**Goals:**
- Cover reload decision branches that are not just UPROPERTY shape changes.
- Keep tests local to the existing HotReload automation harness and helpers.
- Make failures identify the edited source category that changed the expected reload decision.

**Non-Goals:**
- Change HotReload behavior.
- Introduce a new test runner or helper framework.
- Replace existing HotReload functional tests.

## Decisions

- Use `AnalyzeReloadFromMemory` for the decision matrix because it directly reports `EReloadRequirement`, `bWantsFullReload`, and `bNeedsFullReload` without needing editor file watcher timing.
- Use a separate Blueprint-child functional test for the crash regression because the crash occurs while refreshing real `UBlueprintGeneratedClass` objects during soft reload.
- Add a dedicated HotReload sequence fixture for multi-step runtime behavior. Soft reload sequence tests keep the same begun Blueprint actor alive across several body-only edits; structural/full reload sequence tests verify the Blueprint child remains recoverable and can spawn a fresh actor against the latest AS parent.
- Keep each script pair in a unique module/class namespace to avoid leaked state across tests.

## Risks / Trade-offs

- Analyzer expectations may expose existing behavior that is surprising but intentional. Mitigation: each case asserts current documented branch behavior from `AngelscriptClassGenerator.cpp` rather than inventing new policy.
- Blueprint-child tests touch editor-only Blueprint compilation and GC. Mitigation: use transient packages and existing cleanup patterns.
- Structural full reload can replace AS parent classes and may not guarantee a single old Blueprint actor instance migrates through every reload. Mitigation: assert the AS parent version chain and Blueprint parent-chain recovery, then spawn a fresh Blueprint actor for post-reload behavior.
