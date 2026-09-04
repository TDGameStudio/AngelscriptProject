## Why

The established AngelScript runtime, editor integrations, JIT carriers, and broad legacy test suite currently activate as part of the normal host-project baseline. That makes it difficult to restart language work from the lexer and AST while reliably separating new behavior from old bootstrap side effects and old test infrastructure.

The legacy implementation remains valuable as a reference and must stay available. This change therefore creates a source-preserving dormant baseline: legacy behavior is compiled but cannot activate, legacy tests are excluded from source discovery while their compatibility macro remains disabled, and a clean replacement Automation namespace is available for new work.

## What Changes

- Lock the preserved legacy AngelScript runtime into a dormant reconstruction state with no supported config-based opt-in.
- Keep the engine subsystem and UE module shells loadable, but suppress legacy engine creation, ticking, editor hooks, JIT-provider discovery, optional GameplayTags integration, and other active legacy side effects throughout the reconstruction state.
- Preserve `WITH_ANGELSCRIPT_UNITTESTS` as a legacy-only macro with a default value of `0`, introduce `WITH_ANGELSCRIPT_TESTS` with a default value of `1`, and compile legacy test translation units out as complete files.
- Reduce the default `AngelscriptTest` module to its loadable shell plus `NewVersion`: retained test trees live beneath ignored `Legacy/` parents, while legacy framework headers, force-included CQTest macros, engine-pool startup, and legacy-only module dependencies remain behind the old macro.
- Add the temporary physical directory `AngelscriptTest/NewVersion/` for replacement tests whose public names use the final `Angelscript.UnitTest.<Area>.<Scenario>` identity.
- Add one real-UE baseline Automation test proving the dormant default and replacement-test discovery without depending on legacy CQTest helpers or engine-pool fixtures.
- Use the existing Harness `ue.test` Fast profile and the narrowest exact Automation prefix for replacement-unit-test feedback, and retain measured process duration as evidence of the unavoidable fresh-editor startup floor.
- Add a concise project-level routing invariant to `AGENTS.md`; detailed behavior remains owned by OpenSpec. Existing Skills are not reorganized in this change.

## Capabilities

### New Capabilities

- `angelscript/runtime/startup`: Hard dormant reconstruction state and the observable subsystem/module baseline.
- `angelscript/testing/baseline`: Compile-time separation of the legacy suite from the replacement Automation namespace and its default discovery behavior.

### Modified Capabilities

None. The existing AST capability remains unchanged until later lexer/AST changes define new language behavior.

## Impact

- `Plugins/Angelscript`: runtime/editor bootstrap gates, compile definitions, complete legacy test-file isolation, a thin replacement-only test-module shell, TestJIT provider gating, and the replacement baseline test.
- `Plugins/AngelscriptGameplayTags`: runtime/editor extension startup gates and complete legacy test-file isolation.
- `Plugins/AngelscriptGAS`: complete legacy test-file isolation while leaving the runtime plugin source intact.
- Parent project: default settings, Automation group, host legacy test isolation, `AGENTS.md`, OpenSpec records/specifications, and resulting submodule gitlinks.

No public Harness or Unreal command API changes. The existing `ue.test -Fast` route is reused rather than introducing a custom test launcher or commandlet. The dormant legacy implementation has no supported reactivation promise in this baseline; restoring any old execution path requires a later explicit Change. No legacy source is deleted: test trees are relocated only beneath ignored `Legacy/` parents owned by the same modules and retained as reference without mechanical content rewrites. No lexer or AST implementation begins here, generated JIT artifacts are not regenerated or rewritten, and `Documents/`, `Wiki/`, and `openspec-old/` remain untouched. The project test Skill gains one focused reference for the verified UE source-isolation rule.
