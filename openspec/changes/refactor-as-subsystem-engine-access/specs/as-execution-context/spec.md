## ADDED Requirements

### Requirement: Execution context refactor is deferred behind subsystem-first access
The archived execution-context proposal SHALL NOT be used as the implementation plan for reducing `FAngelscriptEngine::Get()` until subsystem-first engine access has been added and evaluated.

#### Scenario: Planning current-engine access work
- **WHEN** future work targets call sites that have `WorldContextObject`, `UWorld`, or `UGameInstance`
- **THEN** the plan SHALL prefer `UAngelscriptSubsystem` lookup before introducing a general `FAngelscriptExecutionContext`
- **AND** any later execution-context proposal SHALL justify why subsystem-first and explicit dependency passing are insufficient
