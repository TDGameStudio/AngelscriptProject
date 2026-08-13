# Cache V2 async update and latest-only retention

Plan-only. Implement later on this same change.

**File map**

| Path | Role |
|------|------|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheService.h` | Queue `RequestCacheUpdate`, coalesced follow-up, completion |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheService.cpp` | Safe-point compile + existing freeze/publish |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheStore.cpp` | After `CurrentCommitted`, clear Previous and sweep this namespace |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheStoreCompaction.cpp` | Reuse Phase B remark/sweep; do not wait for Compact |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheDiagnostics.h` | Update status/outcome types |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheConsoleCommands.cpp` | `as.Cache.Update` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTest.h` or Subsystem public header | Blueprint `RequestCacheUpdate` + delegate |
| `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheAsyncUpdateTests.cpp` | New CQTest prefix `Angelscript.TestModule.Cache.AsyncUpdate` |
| `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheStoreTempCleanupTests.cpp` and lifecycle/store tests | Latest-only vs Previous |
| `Documents/Guides/AngelscriptCacheV2_ZH.md`, `Documents/Knowledges/ZH/RT_CacheV2.md` | Document update API and latest-only |

Verification only through `Tools\RunBuild.ps1` and `Tools\RunTests.ps1`.

## 1. Types and failing API tests

- [ ] 1.1 <!-- TDD --> Add `AngelscriptCacheAsyncUpdateTests.cpp` with `TEST_CLASS` prefix `Angelscript.TestModule.Cache.AsyncUpdate`. First method: `IdleRequestReturnsQueuedWithoutBlockingOnPackIo` calling a not-yet-existing `RequestAngelscriptCacheUpdate`.
- [ ] 1.2 <!-- TDD --> Add methods `ShutdownRequestIsRejected`, `DisabledRequestIsRejected`, `SecondRequestWhileBusyIsBusy`, `SuccessfulCompilePublishesCurrent`, `MatchingSourceIsNoChanges`, `FailedCompileLeavesLastGoodCurrent`.
- [ ] 1.3 <!-- Non-TDD --> Declare update status/outcome enums and `RequestAngelscriptCacheUpdate` on the service/diagnostics header so the test TU compiles and fails on behavior.
- [ ] 1.4 Verify RED: `Tools\RunBuild.ps1 -TimeoutMs 1800000` then `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.AsyncUpdate" -Label cache-async-update -TimeoutMs 600000` (compile succeeds, methods fail until implemented).

## 2. Async update implementation

- [ ] 2.1 <!-- TDD --> Implement queue + mutation-gate compile using the same freeze DTO as Editor reload. Request thread must not call store Flush.
- [ ] 2.2 <!-- TDD --> Wire `UAngelscriptSubsystem::RequestCacheUpdate` and `OnCacheUpdateCompleted`.
- [ ] 2.3 <!-- TDD --> Add `as.Cache.Update` next to `as.Cache.Flush` in `AngelscriptCacheConsoleCommands.cpp`.
- [ ] 2.4 <!-- TDD --> Coalesce at most one follow-up after in-flight publish.
- [ ] 2.5 Verify: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.AsyncUpdate" -Label cache-async-update -TimeoutMs 600000` all methods PASS.

## 3. Latest-only retention tests then store

- [ ] 3.1 <!-- TDD --> Extend or add `Angelscript.TestModule.Cache.LifecyclePublication` / Store tests: two successful publishes leave one Current, Previous absent, first generation exclusive files gone or delete-deferred.
- [ ] 3.2 <!-- TDD --> Failed second compile keeps last-good Current files.
- [ ] 3.3 <!-- TDD --> PIE PendingColdStart publish does not sweep Current.
- [ ] 3.4 <!-- TDD --> Pinned read session overlapping latest-only publish still reads old bytes; sweep defers if needed.
- [ ] 3.5 <!-- TDD --> After `CurrentCommitted`, clear Previous and run namespace remark/sweep only (no sibling Compatibility/Context delete).
- [ ] 3.6 Verify: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.LifecyclePublication" -Label cache-lifecycle-latest-only -TimeoutMs 600000` and `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Store" -Label cache-store-latest-only -TimeoutMs 600000`.

## 4. Regression and docs

- [ ] 4.1 <!-- Non-TDD --> Confirm shutdown still does not compile: existing `Angelscript.TestModule.Cache.SettingsAndShutdown` still PASS via `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.SettingsAndShutdown" -Label cache-shutdown -TimeoutMs 600000`.
- [ ] 4.2 <!-- Non-TDD --> `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache" -Label cache-full -TimeoutMs 3600000` (Heavy; record report path).
- [ ] 4.3 <!-- Non-TDD --> Update `Documents/Guides/AngelscriptCacheV2_ZH.md` and `Documents/Knowledges/ZH/RT_CacheV2.md`: update API, async publish, latest-only after successful Current, shutdown still flush-only, other hex trees not auto-deleted.
