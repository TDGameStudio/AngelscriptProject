## Context

`AngelscriptTest` is compiled by Unreal Build Tool with unity build enabled in normal local and CI paths. UBT generates files such as `Module.AngelscriptTest.4.cpp` that include many test `.cpp` files into one C++ translation unit. Normal C++ file-scope isolation assumptions are therefore weaker:

- `namespace {}` becomes one anonymous namespace for the generated unity translation unit, so repeated helper names can collide.
- file-level `using namespace TestFile_Private;` remains active for all later includes in the same unity translation unit, so later tests may resolve names from earlier tests.
- file-local statics or locals with generic names can trigger `/w4459` when another included file exposes the same name at wider scope.

The current failure set confirms this mechanism: `WaitUntil` duplicated between two Binding async tests, `LocalPlayerControllerId` became ambiguous between GameInstance and Subsystem binding tests, and `ScriptFilename` triggered `/w4459` in a Core docs test.

## Goals / Non-Goals

**Goals:**

- Remove file-level `using namespace` for test helper/support namespaces from Angelscript test `.cpp` files.
- Prefer method-local `using namespace` inside `TEST_METHOD`, CQTest setup/teardown hooks, or helper function scope when it keeps code readable and matches existing test style.
- Include AngelScriptSDK support imports such as `AngelscriptNativeTestSupport` and `AngelscriptSDKTestSupport` in the first pass.
- Use explicit qualification for short constants or helper calls when it is clearer than adding a local import.
- Fix concrete unity build errors already reported.
- Keep the work incremental and scoped to tests.

**Non-Goals:**

- Do not rewrite shared helper imports such as `using namespace AngelscriptFunctionalTestUtils;` in this first pass unless they are also test-private and conflict-prone.
- Do not disable unity build to hide the problem.
- Do not refactor test behavior, test coverage, runtime code, or public APIs.

## Decisions

### Decision 1: Move private helpers into CQTest classes

Named namespaces such as `AngelscriptTest_Core_AngelscriptDocsTests_Private` avoid global symbol definitions, but they still create file-level symbols in the generated unity translation unit. The preferred final shape is to move helper constants, structs, and functions into the owning `TEST_CLASS_WITH_FLAGS` class as `private` or `static` members, then call them unqualified from that class.

Alternative considered: keep all `_Private` namespaces and only qualify use sites. That fixes lookup leakage, but leaves broad file-level helper namespaces in unity chunks and does not match the desired CQTest ownership model.

### Decision 2: CQTest function-local using is allowed

`using namespace SomeTest_Private;` inside a `TEST_METHOD` confines lookup to the method body and does not leak into later unity-included `.cpp` files. The same applies to CQTest hook bodies such as `BEFORE_ALL`, `BEFORE_EACH`, `AFTER_EACH`, and `AFTER_ALL`. This matches existing style in several CQTest tests and keeps large test methods readable.

`using namespace` is not valid as a C++ class-scope directive, so "inside CQTest" means inside the generated function bodies, not directly at `TEST_CLASS_WITH_FLAGS` class scope.

Alternative considered: fully qualify every helper use. This is safest but makes long table-driven tests noisy. Use explicit qualification when only one or two names are referenced.

### Decision 2 Update: Private namespace imports are fully qualified

After the first pass, the rule is stricter for named file-private namespaces: do not use `using namespace *_Private;` at any scope in test `.cpp` files. Keep the `_Private` namespace definitions, but reference their helpers through explicit qualification such as `AngelscriptTest_Core_Example_Private::MakeFixture()`.

This removes ambiguity between "safe local using" and "unsafe file-level using" and gives unity builds a simple invariant to scan.

### Decision 2 Second Update: Private namespace definitions are removable by default

The stricter target is now to remove `_Private` namespace definitions when the helpers belong to a single CQTest class. Helpers should be moved into the class body under `private:` and the test methods/hooks should remain under `public:`. Complex cases with several CQTest classes or non-CQTest command code may keep a file-level helper only when moving it would duplicate shared setup or change callable linkage; those cases must be explicitly reviewed instead of being hidden by a file-level `using namespace`.

### Decision 3: SDK helper namespaces are part of this pass

AngelScriptSDK tests currently use file-level imports such as `using namespace AngelscriptNativeTestSupport;` and `using namespace AngelscriptSDKTestSupport;`. Even though these namespaces are shared helpers rather than file-private namespaces, they still widen unqualified lookup for every later `.cpp` included into the same unity translation unit. This pass will move those imports into CQTest methods/hooks or replace them with explicit qualification.

Alternative considered: limit the pass only to `_Private` and `*TestHelpers`. That would fix the reported Binding/Core failures but leave the SDK unity chunks vulnerable to the same lookup leakage pattern.

### Decision 4: Treat anonymous namespace collisions separately

The priority is file-level private namespace imports, per the requested refactor. Anonymous namespace duplicate helper names such as `WaitUntil` are still a unity hazard and should be fixed when observed or when a scan finds repeated short helper names in the same generated unity chunk.

Alternative considered: convert every anonymous namespace in tests to a named namespace. That is broader than needed for this pass and risks churn across hundreds of tests.

## Risks / Trade-offs

- **Risk:** Moving a `using namespace` into a test method misses helper references in class-level CQTest hooks.  
  **Mitigation:** Move the import into each hook/function that needs it, or use explicit qualification.

- **Risk:** Current generated unity chunk order can change after UBT regeneration, exposing different collisions later.  
  **Mitigation:** enforce the source-level rule independent of current chunk order, then use build verification when Live Coding is disabled.

- **Risk:** Broad mechanical changes may touch unrelated tests.  
  **Mitigation:** first scan and modify only file-level private helper imports, leaving shared utility namespace imports alone.

- **Risk:** Local build verification may be blocked by active Unreal Live Coding.  
  **Mitigation:** record the exact build command and log path; rerun after closing the editor or pressing `Ctrl+Alt+F11`.
