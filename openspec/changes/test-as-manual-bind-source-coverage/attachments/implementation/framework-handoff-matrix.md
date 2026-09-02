# TestFramework driver-handoff matrix (provisional)

The 38 `TestSource/TestFramework/**/*.as` files remain **provisional**. Internal `Assert*` / `Fail` calls are payload, not acceptance. A later C++ driver OpenSpec must check the observations below. Do not treat this matrix as Bind-style source-semantic acceptance.

| Area | Source | C++ oracle owner | External observations the driver must check |
|---|---|---|---|
| Discovery | `Discovery/Test_SuiteAndMethodDiscovery.as` | `AngelscriptScriptTestDiscoveryTests.cpp` | Discovered suite/method count, stable identities, declaration order |
| Discovery | `Discovery/Test_AutomationFlagsAndDisabledCases.as` | same | Exact flag masks; Disabled leaves discovered and not executed; invalid masks diagnosed |
| Discovery | `Discovery/Test_InvalidDiscoveryDiagnostics.as` | same | Each invalid declaration diagnosed and omitted; valid control descriptor remains |
| Discovery | `Discovery/Test_RegistryGenerationRebuild.as` | same | One immutable generation per rebuild; generation numbers advance; empty discovery does not leak stale descriptors |
| Assertions | `Assertions/Test_BooleanNullIdentityAssertions.as` | `AngelscriptScriptTestAssertionTests.cpp` | Per-overload pass/fail; one source-located diagnostic with custom message on each failing overload |
| Assertions | `Assertions/Test_EqualityAndOrderingAssertions.as` | same | Per-overload pass/fail; diagnostic text contains actual/expected; source locations |
| Assertions | `Assertions/Test_NearValueAssertions.as` | same | Within-tolerance pass; outside-tolerance one precise diagnostic per overload family |
| Assertions | `Assertions/Test_ExpectedErrorAssertions.as` | same | Matching errors finalized as expected; count mismatch and missing error become framework failures |
| Assertions | `Assertions/Test_FailureDiagnosticsAndFailFast.as` | same | Exactly one diagnostic with message+location; statements after failure do not run; cleanup still runs |
| Assertions | `Assertions/Test_AssertionExceptionsAcrossPhases.as` | same | Originating phase distinguishable; first failure preserved; later cleanup exceptions still reported |
| Lifecycle | `Lifecycle/Test_AllAndEachHookOrder.as` | `AngelscriptScriptTestLifecycleTests.cpp` | BeforeAll once, each leaf BeforeEach/AfterEach, AfterAll once; all-hook state isolated |
| Lifecycle | `Lifecycle/Test_FreshSuiteInstances.as` | same | Distinct instance identities; neither leaf sees the other's mutations |
| Lifecycle | `Lifecycle/Test_TeardownAndCleanupAfterFailure.as` | same | Required phases still run; LIFO callbacks observable; no fixture leak after failure |
| Commands | `Commands/Test_DoThenFifo.as` | `AngelscriptScriptTestCommandTests.cpp` | FIFO action order; descriptions attached; final callback sees complete ordered list |
| Commands | `Commands/Test_StartWhenUntil.as` | same | No action before StartWhen; Until polls to completion; callback scope is owning leaf |
| Commands | `Commands/Test_WaitDelayTiming.as` | same | Resume only after delay; World time unchanged unless explicitly advanced |
| Commands | `Commands/Test_TeardownCleanupLifo.as` | same | LIFO per phase; teardown before cleanup; both run after leaf failure |
| Commands | `Commands/Test_CommandScopeAndQueueMutationErrors.as` | same | Callbacks route to correct suite; illegal mutations fail at call site |
| Commands | `Commands/Test_AdvancedLatentCommandLifecycle.as` | same | Before once, Update exact count, After once; current-suite identity stable |
| Commands | `Commands/Test_AdvancedCommandTimeoutAndClientPolicy.as` | same | Timeout/client flags observable; FinishClient cannot hang the suite |
| World | `World/Test_PureObjectFixture.as` | `AngelscriptScriptTestWorldTests.cpp` | Object non-null, suite-owned, auto-released; GetTestWorld remains null |
| World | `World/Test_WorldActorComponentLifecycle.as` | same | World/actor/component identities; BeginPlay idempotent; tick counts; explicit destroy |
| World | `World/Test_GameInstanceWorldCleanup.as` | same | GameInstance present; duplicate create fails without leak; terminal cleanup releases World |
| World | `World/Test_TickAndAdvanceTime.as` | same | Direct ticks vs scheduler/time advancement independent; elapsed time not discarded |
| World | `World/Test_WorldFailureCleanup.as` | same | Every terminal path releases owned resources once; next leaf has no leftover World |
| Automation | `Automation/Test_FlagBridgeAndSectionSession.as` | `AngelscriptScriptTestAutomationTests.cpp` | Flags exact; descriptors stable; sections share session without sharing leaf instances |
| Automation | `Automation/Test_HookFailureReporting.as` | same | BeforeAll failure skips leaves but closes session; AfterAll failure counted |
| Automation | `Automation/Test_CommandOwnershipAndStaleHandles.as` | same | Stale commands fail once; current commands remain executable |
| HotReload | `HotReload/Test_RegistryRefreshAndCoalescing_V1.as` | `AngelscriptScriptTestHotReloadTests.cpp` | Initial generation uniquely identifiable; cleanup markers for reload oracle |
| HotReload | `HotReload/Test_RegistryRefreshAndCoalescing_V2.as` | same | Idle refresh immediate; active refresh coalesces and publishes after cleanup |
| HotReload | `HotReload/Test_LastGoodGenerationRetention_Good.as` | same | Valid generation becomes last-good until later valid replacement |
| HotReload | `HotReload/Test_LastGoodGenerationRetention_Broken.as` | same | Compile fails; no partial registry; prior good generation remains authoritative |
| HotReload | `HotReload/Test_ActiveLeafCancellationAndCleanup.as` | same | Cancellation runs After/teardown/cleanup once before old generation is released |
| HotReload | `HotReload/Test_SessionReopenAcrossReload_V1.as` | same | Original session opens once and closes before replacement |
| HotReload | `HotReload/Test_SessionReopenAcrossReload_V2.as` | same | Reload reopens hooks for the new generation; no old session state reused |
| SelfHosted | `SelfHosted/Test_FrameworkSelfHostedSmoke.as` | all seven framework test classes plus `Script/Tests/Test_ReflectedScriptSuites.as` | Expected leaf count, zero failures, all phase markers complete |
| SelfHosted | `SelfHosted/Test_FrameworkSelfHostedFailureOracle.as` | same | Exact pass/fail counts, messages, locations, fail-fast, cleanup order without circular self-validation |
| SelfHosted | `SelfHosted/Test_FrameworkSelfHostedLatent.as` | same | One completed leaf, exact callback order, no timeout, final cleanup |

Disposition: `ProvisionalExternalOracle` until the later driver change exists. Section 9 OpenSpec checkboxes stay unchecked in this source-only wave.
