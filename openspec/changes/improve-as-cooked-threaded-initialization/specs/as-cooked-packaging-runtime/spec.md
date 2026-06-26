## MODIFIED Requirements

### Requirement: Cooked Builds Initialize On Game Thread

When `AS_USE_BIND_DB` is active, `FAngelscriptEngine::ShouldInitializeThreaded()` SHALL return
`!bSkipThreadedInitialize` (worker-thread initialization by default), matching upstream behavior.
Cooked initialization SHALL only fall back to the game thread when `-as-skip-threaded-initialize`
(`bSkipThreadedInitialize`) is set. The previous precautionary game-thread forcing is removed once
worker-thread cooked initialization is verified end-to-end on a packaged build.

#### Scenario: Cooked init runs on a worker thread by default

- **WHEN** a cooked build initializes the AngelScript engine without `-as-skip-threaded-initialize`
- **THEN** `Initialize_AnyThread()` runs on a worker task (not the game thread)
- **AND** all engine types register correctly with no `"is not a data type"` errors

#### Scenario: Game-thread fallback remains available

- **WHEN** a cooked build is launched with `-as-skip-threaded-initialize`
- **THEN** initialization runs on the game thread

#### Scenario: Threaded cooked startup verified on a package

- **WHEN** the worker-thread default is enabled
- **THEN** a packaged run loads scripts, enters the test map, and does not crash during initialization
