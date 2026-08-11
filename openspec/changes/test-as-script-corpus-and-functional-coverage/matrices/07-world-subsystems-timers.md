# 07 — World, Subsystems, And Timers Corpus And Script Tests

| ID | User scenario / AS surface | Corpus target | Script-test target | Existing evidence to audit | Fixture / log policy | Initial disposition |
|---|---|---|---|---|---|---|
| WORLD-01 | Obtain World from object/context and validate identity | `Script/World/WorldContext.as` | `Script/Tests/World/Test_WorldContext.as` | UWorld/scope WorldContext binds; ScopeWorldContext Bindings | World; assert same instance | `CorpusGap`, `ScriptTestGap` |
| WORLD-02 | Spawn/destroy actors through World and observe lifecycle | `Script/World/WorldActorManagement.as` | `Script/Tests/World/Test_WorldActorManagement.as` | UWorld/AActor binds; Functional ActorSpawn/Lifecycle | World; explicit destroy/drain | `CorpusGap`, `ScriptTestGap` |
| WORLD-03 | World tick versus direct callback dispatch | `Script/World/WorldTicking.as` | `Script/Tests/World/Test_WorldTicking.as` | Template_WorldTick; reflected suite World tests | World; explain nondeterministic scheduler counts vs exact direct tick | `CorpusGap`, `ScriptTestGap` |
| WORLD-04 | Time advancement and deterministic scheduled work | `Script/World/WorldTime.as` | `Script/Tests/World/Test_WorldTime.as` | test command/time helpers; timer Coverage | World; `AdvanceTime`; summary log | `CorpusGap`, `ScriptTestGap` |
| WORLD-05 | GameInstance/local player context and lookup | `Script/World/GameInstanceContext.as` | `Script/Tests/World/Test_GameInstanceContext.as` | GameInstance/LocalPlayer binds; Bindings tests | `CreateTestWorld(true)`; headless limits | `CorpusGap`, `ScriptTestGap` |
| SUBSYS-01 | EngineSubsystem access and lifetime | `Script/Subsystems/EngineSubsystems.as` | `Script/Tests/Subsystems/Test_EngineSubsystems.as` | subsystem binds; EngineSubsystem tests; production surface spec | Engine context; assert same service/lifecycle | `CorpusGap`, `ScriptTestGap` |
| SUBSYS-02 | GameInstanceSubsystem initialize/deinitialize and access | `Script/Subsystems/GameInstanceSubsystems.as` | `Script/Tests/Subsystems/Test_GameInstanceSubsystems.as` | GameInstanceSubsystem tests; subsystem test types | GameInstance World; phase logs and assertions | `CorpusGap`, `ScriptTestGap` |
| SUBSYS-03 | WorldSubsystem initialize/tick/deinitialize | `Script/Subsystems/WorldSubsystems.as` | `Script/Tests/Subsystems/Test_WorldSubsystems.as` | WorldSubsystem tests; script subsystem specs | World; World tick; assert lifecycle order | `CorpusGap`, `ScriptTestGap` |
| SUBSYS-04 | LocalPlayerSubsystem access and player dependency | `Script/Subsystems/LocalPlayerSubsystems.as` | `Script/Tests/Subsystems/Test_LocalPlayerSubsystems.as` | current SubsystemLifecycle; LocalPlayer binds | GameInstance/local player fixture; environment-bound if no player | `CorpusGap`, `ScriptTestGap`, `EnvironmentBound` |
| TIMER-01 | Set one-shot/repeating timer and callback | `Script/Timers/TimerScheduling.as` | `Script/Tests/Timers/Test_TimerScheduling.as` | `Bind_SystemTimers`; Coverage Timer; Functional ActorTimer | World; `AdvanceTime`; assert count/time | `CorpusGap`, `ScriptTestGap` |
| TIMER-02 | Pause/resume timer and remaining state | `Script/Timers/TimerPauseResume.as` | `Script/Tests/Timers/Test_TimerPauseResume.as` | current Timer example; Coverage Timer | World; deterministic time; state logs | `CorpusGap`, `ScriptTestGap` |
| TIMER-03 | Clear/invalidate timer and prevent future callback | `Script/Timers/TimerCleanup.as` | `Script/Tests/Timers/Test_TimerCleanup.as` | timer binds/tests | World; assert no post-clear call | `CorpusGap`, `ScriptTestGap` |
| TIMER-04 | Timer owner destruction/cleanup behavior | `Script/Timers/TimerOwnerLifetime.as` | `Script/Tests/Timers/Test_TimerOwnerLifetime.as` | Functional ActorTimer runtime; lifecycle tests | World Actor; destroy and advance; assert cleanup | `CorpusGap`, `ScriptTestGap` |
| TIMER-05 | Latent script-test command queue is test infrastructure, not gameplay timer API | No corpus placement except testing guide reference | Retain `Test_ReflectedScriptSuites.as` framework examples | script-test runner/hot-reload tests | Test framework only | `OutOfScope` for gameplay corpus |

## API Table Ownership

World, Subsystem, and Timer corpus files include usage tables. Tables identify WorldContext requirements, ownership/lifetime, whether a call drives scheduler time, and which callbacks are exact versus World-scheduled.

