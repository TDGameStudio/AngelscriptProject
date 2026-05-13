## ADDED Requirements

### Requirement: Stable preprocessing summaries
The runtime SHALL provide read-only preprocessing summary data that describes files, modules, chunks, imports, reflected declarations, generated code, and preprocessing result state without requiring consumers to inspect mutable preprocessor internals.

#### Scenario: Summary reports processed script structure
- **WHEN** preprocessing succeeds for scripts containing imports, classes, functions, properties, enums, delegates, and generated code
- **THEN** the summary SHALL report stable counts or names sufficient to verify those categories were observed

#### Scenario: Summary does not expose mutable internals
- **WHEN** a hook or test consumes the preprocessing summary
- **THEN** the consumer SHALL be able to inspect the summary without receiving mutable access to `FAngelscriptPreprocessor::Files`, chunk arrays, replacement lists, or generated code buffers

### Requirement: Summary availability at existing hook points
The runtime SHALL make preprocessing summaries available at the existing process-chunks and post-process-code hook moments.

#### Scenario: Process-chunks summary is available
- **WHEN** preprocessing reaches the process-chunks hook point
- **THEN** consumers SHALL be able to obtain a summary of chunk/import/class/macro/delegate analysis completed up to that point

#### Scenario: Post-process-code summary is available
- **WHEN** preprocessing reaches the post-process-code hook point
- **THEN** consumers SHALL be able to obtain a summary of final processed code, generated code, and module assembly data available at that point

### Requirement: Existing preprocessor hooks remain compatible
The runtime SHALL preserve existing `OnProcessChunks` and `OnPostProcessCode` hook behavior while enabling new summary-based consumption.

#### Scenario: Existing hook subscribers still run
- **WHEN** existing code subscribes to `FAngelscriptPreprocessor::OnProcessChunks` or `OnPostProcessCode`
- **THEN** those subscribers SHALL still be invoked during preprocessing as they were before this change

## Testing Requirements

- Target test layer: Runtime Integration and Learning under `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/` and `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/`.
- Expected Automation prefix: `Angelscript.TestModule.Preprocessor.*` for core summary behavior and `Angelscript.TestModule.Learning.Runtime.*` for structured guide-facing examples if updated in this change.
- Recommended helper/harness: `AngelscriptPreprocessorTestHelpers.h` for focused preprocessing fixtures; `Shared/AngelscriptLearningTrace.*` only for Learning output formatting.
- Verification entry point: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label preprocessor-summary -TimeoutMs 600000`.
