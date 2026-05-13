## 1. Runner Behavior

- [x] 1.1 <!-- TDD --> Add RalphLoop tests for trusted provider template selection, Claude profile resolution, and default safe provider commands. Verify with `pwsh -NoProfile -ExecutionPolicy Bypass -File Tools\RalphLoop\tests\test-ralph-loop.ps1`.
- [x] 1.2 <!-- TDD --> Implement `-TrustAgent`, trusted command template resolution, and Claude provider profile while preserving existing custom `-AgentCommand` behavior. Verify with `pwsh -NoProfile -ExecutionPolicy Bypass -File Tools\RalphLoop\tests\test-ralph-loop.ps1`.

## 2. PRD Workflow

- [x] 2.1 <!-- TDD --> Add PRD workflow tests for story selection, prompt injection, audit artifacts, read-only PRD/progress files, and complete PRD exit. Verify with `pwsh -NoProfile -ExecutionPolicy Bypass -File Tools\RalphLoop\tests\test-prd-workflow.ps1`.
- [x] 2.2 <!-- TDD --> Implement `-Workflow Basic|Prd`, `-PrdFile`, `-ProgressFile`, PRD story selection, PRD prompt rendering, and `prd-complete` final state. Verify with `pwsh -NoProfile -ExecutionPolicy Bypass -File Tools\RalphLoop\tests\test-prd-workflow.ps1`.

## 3. Standalone Readiness

- [x] 3.1 <!-- Non-TDD --> Add standalone-focused RalphLoop documentation, ignore rules, and usage examples for basic loop, trusted mode, Claude, and PRD mode. Verify with `rg -n "TrustAgent|PrdFile|claude|TDGameStudio/RalphLoop" Tools\RalphLoop`.
- [x] 3.2 <!-- Non-TDD --> Remove or update stale root-level RalphLoop references so current project examples use `Tools\RalphLoop`. Verify with `rg "Tools\\\\ralph-loop|Tools/ralph-loop|Tools\\\\run-codex-loop|Tools\\\\run-opencode-loop" Tools Documents .agents AGENTS.md README.md`.

## 4. Final Verification

- [x] 4.1 <!-- Non-TDD --> Run RalphLoop smoke suites: `pwsh -NoProfile -ExecutionPolicy Bypass -File Tools\RalphLoop\tests\test-ralph-loop.ps1`, `powershell -NoProfile -ExecutionPolicy Bypass -File Tools\RalphLoop\tests\test-ralph-loop.ps1`, `pwsh -NoProfile -ExecutionPolicy Bypass -File Tools\RalphLoop\tests\test-ralph-loop-no-verify.ps1`, and `openspec validate refactor-ralphloop-standalone-workflow --strict --json`.
