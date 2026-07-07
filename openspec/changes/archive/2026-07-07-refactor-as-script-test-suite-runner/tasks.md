## 1. OpenSpec Record

- [x] 1.1 <!-- Non-TDD --> Create the `refactor-as-script-test-suite-runner` OpenSpec change.
- [x] 1.2 <!-- Non-TDD --> Record the proposal explaining why the old Angelscript-side global-function test runner is being replaced.
- [x] 1.3 <!-- Non-TDD --> Record the design for native-base-class suite discovery, lifecycle hooks, fixture selection, failure semantics, and old-runner removal.
- [x] 1.4 <!-- Non-TDD --> Add the `as-script-test-suite-runner` capability spec.
- [x] 1.5 <!-- Non-TDD --> Validate the OpenSpec record with `openspec validate "refactor-as-script-test-suite-runner" --strict --json`.

## 2. Discovery Tests

- [ ] 2.1 <!-- TDD --> Add a focused test proving only script classes deriving from the native script test suite base are discovered as script suites.
- [ ] 2.2 <!-- TDD --> Add a focused test proving only `void Test_*()` instance methods on derived suites are registered as suite test methods.
- [ ] 2.3 <!-- TDD --> Add a focused test proving old global `Test_*(FUnitTest&)` and `IntegrationTest_*(FIntegrationTest&)` functions are not registered by the new runner.

## 3. Lifecycle Runner

- [ ] 3.1 <!-- TDD --> Add a runner test proving `BeforeAll`, `BeforeEach`, `Test_*`, `AfterEach`, and `AfterAll` execute in deterministic order.
- [ ] 3.2 <!-- TDD --> Add failure-path tests for `BeforeAll`, `BeforeEach`, `Test_*`, `AfterEach`, and `AfterAll`.
- [ ] 3.3 <!-- Non-TDD --> Implement suite-level runner execution over discovered script suite descriptors.
- [ ] 3.4 <!-- Non-TDD --> Register one UE Automation command per script suite.

## 4. Context and Assertions

- [ ] 4.1 <!-- TDD --> Add tests proving AS classes can derive from the native `UAngelscriptTestSuite` `UCLASS`.
- [ ] 4.2 <!-- TDD --> Add tests proving runner-created generated suite instances receive injected run state before lifecycle or test methods execute.
- [ ] 4.3 <!-- TDD --> Add tests proving `Expect*` records non-fatal failures and continues method execution.
- [ ] 4.4 <!-- TDD --> Add tests proving `Require*` and `Fail` record fatal failures and stop the current method.
- [ ] 4.5 <!-- Non-TDD --> Implement `UAngelscriptTestSuite` as an abstract transient native `UCLASS` derived from `UObject`.
- [ ] 4.6 <!-- Non-TDD --> Bind the v1 assertion set onto `UAngelscriptTestSuite` with `FAngelscriptBinds::ExistingClass`.
- [ ] 4.7 <!-- Non-TDD --> Preserve script line/column diagnostics for failures reported through the native base class.
- [ ] 4.8 <!-- Non-TDD --> Keep fixture state runner-owned; do not expose public AS setters that can replace the active world or game instance.

## 5. Fixtures

- [ ] 5.1 <!-- TDD --> Add a test proving suites default to a pure fixture with no implicit `World` or `GameInstance`.
- [ ] 5.2 <!-- TDD --> Add a test proving `FScriptTestFixture::World()` creates an explicit transient world fixture.
- [ ] 5.3 <!-- TDD --> Add a test proving world fixtures can select a per-suite game instance class.
- [ ] 5.4 <!-- Non-TDD --> Implement `FScriptTestFixture` bindings for `Pure`, `World`, and optional game instance class selection.
- [ ] 5.5 <!-- Non-TDD --> Stop reading global `UnitTestGameInstanceClass` for new script suite execution.

## 6. Old Runner Retirement

- [ ] 6.1 <!-- Non-TDD --> Remove or disable old Angelscript-side global unit test discovery.
- [ ] 6.2 <!-- Non-TDD --> Remove or disable old Angelscript-side global integration test discovery.
- [ ] 6.3 <!-- Non-TDD --> Remove or disable old `Angelscript.UnitTests` / `Angelscript.IntegrationTests` script automation entrypoints.
- [ ] 6.4 <!-- Non-TDD --> Keep any remaining old C++ types only as temporary compile dependencies, not as registered script test APIs.

## 7. Documentation and Verification

- [ ] 7.1 <!-- Non-TDD --> Update Angelscript test documentation to describe native-base-class suite tests as the script-side test entrypoint.
- [ ] 7.2 <!-- Non-TDD --> Add or update script examples showing pure and world fixture suites.
- [ ] 7.3 <!-- Non-TDD --> Run the focused new test prefix through `Tools\RunTests.ps1`.
- [ ] 7.4 <!-- Non-TDD --> Run `Tools\RunBuild.ps1` after implementation.
- [ ] 7.5 <!-- Non-TDD --> Re-run `openspec validate "refactor-as-script-test-suite-runner" --strict --json`.
