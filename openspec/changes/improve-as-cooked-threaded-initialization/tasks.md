# Tasks

> Record-only for now: implement later, after the bind-database ordering fix is in and a packaged
> verification slot is available. Worker-thread cooked init is the target end-state.

## 1. Pre-work audit

- [ ] 1.1 `<!-- Non-TDD -->` Audit global/static state mutated during `Initialize_AnyThread()` and
  `BindScriptTypes()` for off-game-thread safety. Use `Documents/Guides/GlobalStateContainmentMatrix.md`
  as the starting inventory; list any state that assumes `IsInGameThread()` or mutates shared globals.
- [ ] 1.2 `<!-- Non-TDD -->` Record findings in a `notes/threadsafety-audit.md` under this change. If a
  real hazard is found, fix it (engine-scope or proper synchronization) BEFORE flipping the flag.

## 2. Flip the default

- [ ] 2.1 `<!-- Non-TDD -->` Remove the `#if AS_USE_BIND_DB { if (!bForceThreadedInitialize) return false; }`
  block in `FAngelscriptEngine::ShouldInitializeThreaded()`
  (`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`) so cooked builds end at
  `return !RuntimeConfig.bSkipThreadedInitialize`. Update the comment to state worker-thread cooked init
  is the supported default and the bind-database ordering was the real fix. Verify: `Tools\RunBuild.ps1`.

## 3. Verification (packaged)

- [ ] 3.1 Run `Tools\RunPackage.ps1` and launch the packaged exe: confirm zero `not-a-data-type`
  errors, no startup crash, scripts load, and `ActorTestMap` enters cleanly.
- [ ] 3.2 Sanity-run the editor automation suite to confirm the editor path is unaffected:
  `Tools\RunTests.ps1`.
- [ ] 3.3 Confirm the game-thread fallback still works: package or run with `-as-skip-threaded-initialize`
  and verify init runs on the game thread without regression.

## 4. Optional regression guard

- [ ] 4.1 `<!-- Non-TDD -->` Evaluate adding an automated cooked/threaded smoke check (commandlet or
  packaged-run harness) so this path is exercised in CI rather than only by manual packaging. Record the
  decision (implement or defer) in the change notes.

## 5. Rollback note

- [ ] 5.1 If any flakiness appears, revert the flag flip (or document shipping with
  `-as-skip-threaded-initialize`) and capture a repro before retrying. Do not ship a flaky threaded path.
