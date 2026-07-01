# Timer / Async Coverage Matrix

> **This matrix is the design specification header for timer tests**: each row is a concrete verifiable scenario guiding `AngelscriptCoverageTimerTests.cpp` implementation. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 means fork/headless not applicable.
>
> - Test file: `AngelscriptCoverageTimerTests.cpp`, 31 methods
> - Automation prefix: `Angelscript.TestModule.Coverage.Timer`
> - See `../coverage-matrix.md` for the legend.

## 1. Basic Usage And Management

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Basic usage / timer management | ✅ | `TimerBasicUsage` `TimerManagement` |
| Single-shot and multiple-handle compilation | ✅ | `SingleShotAndMultipleHandlesCompile` |

## 2. Handle Operations

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Pause / resume / clear | ✅ | `TimerHandlePauseUnpauseAndClear` |
| Clear and invalidate / reuse handle variable after clear | ✅ | `TimerClearAndInvalidate` `TimerClearThenReuseHandleVariable` |
| Handle invalidation and supported queries / deterministic invalid-handle queries | ✅ | `TimerHandleInvalidationAndSupportedQueries` `TimerInvalidHandleQueriesStayDeterministic` |

## 3. Delay And Periodic Execution

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Delayed execution / first delay / immediate execution / system delay | ✅ | `TimerDelayExecution` `TimerFirstDelay` `TimerImmediateExecution` `SystemDelay` |
| Multiple timers coexist | ✅ | `MultipleTimers` |
| Remaining / elapsed time queries | ✅ | `TimerRemainingAndElapsed` |

## 4. Parameters And Callbacks

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Parameterized callback / lambda capture | ✅ | `TimerWithParameters` `TimerLambdaCapture` |
| Same function name replaces existing timer | ✅ | `TimerRepeatedFunctionNameReplacesExistingTimer` |
| Dynamic function-name reflection lifecycle | ✅ | `TimerDynamicFunctionNameReflectionLifecycle` |

## 5. Component / Actor Callbacks

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Actor destruction stops callbacks | ✅ | `TimerActorDestroyStopsCallbacks` |
| Component callbacks run on owner world / component destruction stops callbacks | ✅ | `TimerComponentCallbacksRunOnOwnerWorld` `TimerDestroyedComponentStopsCallbacks` |
| Delayed spawn use case / Actor and component call-site compile stability | ✅ | `TimerDelayedSpawnUseCaseRunsFromWorldTimer` `TimerCompileStableActorAndComponentCallSites` |

## 6. Common Use Cases

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Skill cooldown / periodic check / buff duration | ✅ | `TimerUseCaseSkillCooldown` `TimerUseCasePeriodicCheck` `TimerUseCaseBuffDuration` |
| UI countdown and AI state patterns | ✅ | `TimerUiCountdownAndAiStatePatterns` |

## 7. Lambda / Latent Boundaries

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Lambda delegate SetTimer / single-shot boundary | 🚫 | `TimerDelegateLambdaSetTimerBoundary` `TimerDelegateLambdaSingleShotBoundary` |
| Latent movement function compile boundary | 🚫 | `LatentMovementFunctionsRemainCompileBoundaries` |
| Delay compiles without deterministic Latent advancement | 🚫 | `SystemDelayCompilesWithoutDeterministicLatentAdvance` |

---

**Corresponding test methods**: 31 methods.
**Pending (⬜)**: no hard gaps currently; headless assertions focus on deterministic handle state, while Latent/Lambda paths are compile boundaries.
