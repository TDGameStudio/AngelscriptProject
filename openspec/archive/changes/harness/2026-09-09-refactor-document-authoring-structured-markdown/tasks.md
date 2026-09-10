---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "3.1": ["1.1", "2.1"]
    "4.1": ["3.1"]
---

# Structured Markdown authoring implementation

## Execution context

This implementation record was bootstrapped with the installed 0.8.1 package and converted to the new-only format at the 0.9.0 local package cutover. Other business records and archives are not owned. The accepted plan is in design.md; retain all unrelated dirty files. Rust commands run from Tools/openspec. Harness commands execute in the current PowerShell 7 process in the selected workspace.

## 1. Task ownership

- [x] 1.1 Parse new-only task cards with executable owned metadata

    **Outcome and context**

    Consume the existing TaskNode fields and graph validator. Produce direct owned Files/Verification extraction and zero Ready nodes on invalid input. Cases cover multiline commands, individually quoted paths with spaces/commas/Unicode, rich nested blocks, literal task examples, detached metadata, duplicate/missing sections, old syntax rejection, BOM/CRLF and preserved graph semantics.

    **Implementation**

    1. Add real parser cases using literal expected files, command strings and issue codes; observe RED together.
    2. Implement CommonMark container extraction and new-only metadata, preserving graph checks and source positions.
    3. Run the exact group GREEN, migrate adjacent graph fixture representation and prove existing dependency contracts.

    **Files**

    - `Tools/openspec/src/core/task_plan.rs`
    - `Tools/openspec/src/core/markdown.rs`
    - `Tools/openspec/src/core/mod.rs`
    - `Tools/openspec/Cargo.toml`
    - `Tools/openspec/Cargo.lock`
    - `Tools/openspec/tests/structured_task_contract.rs`
    - `Tools/openspec/tests/task_plan_contract.rs`

    **Verification**

    Run from `Tools/openspec`.

    ```sh
    cargo test --locked --test structured_task_contract
    ```

    All selected cases must execute and pass. Completion requires the whole
    stated outcome; a successful empty selection is not proof.

    **Evidence**

    See [implementation evidence](attachments/implementation-evidence.md) for observed RED/GREEN
    and the exact adjacent checks.

## 2. Scenario ownership

- [x] 2.1 Preserve rich clause content and validate real scenario structure

    **Outcome and context**

    Parse real Requirement/Scenario headings, require WHEN/THEN and reject detached detail while preserving raw Markdown. Cases include nested same-named headings, code/quote examples, tables, lists, image paths, multiple clauses, malformed cards and complete delta retention. Do not implement an automatic spec merger or new task state in specs.

    **Implementation**

    1. Add concrete raw-card and validation cases and observe behavioral RED.
    2. Use shared Markdown container ownership; expose meaningful source diagnostics without serializing a second spec schema.
    3. Prove the focused group and adjacent validation contracts.

    **Files**

    - `Tools/openspec/src/core/markdown.rs`
    - `Tools/openspec/src/core/spec_parser.rs`
    - `Tools/openspec/src/cli/validate.rs`
    - `Tools/openspec/tests/structured_spec_contract.rs`
    - `Tools/openspec/tests/validate_contract.rs`

    **Verification**

    Run from `Tools/openspec`.

    ```sh
    cargo test --locked --test structured_spec_contract
    ```

    All selected cases must execute and pass. Completion requires the whole
    stated outcome; a successful empty selection is not proof.

    **Evidence**

    See [implementation evidence](attachments/implementation-evidence.md) for observed RED/GREEN
    and the exact adjacent checks.

## 3. Authoring and consumers

- [x] 3.1 Generate detailed readable cards and align maintained consumers

    **Outcome and context**

    Scope is authoring/fixture/consumer representation only, not unrelated implementation. This includes openspec/config.yaml, whose generated instructions consume the same authoring contract. Write full task/spec examples, explicit information requirements, rich indentation rules and new-only diagnostics. Replace obsolete source-wording assertions with executable fixtures where they concern the changed contract. Migrate maintained generated test records, not existing business or archive data. The same three independent raw requests compare old/new guidance; record actual outputs and limitations.

    **Implementation**

    1. Preserve the independent old-guidance exercise before editing guidance.
    2. Update templates, references, lifecycle routes and deterministic consumer fixtures. Synchronize only this Harness contract.
    3. Run all Rust targets and focused Harness/Skill checks; repeat the independent exercise on new guidance and inspect detail, ownership and acceptance decisions.

    **Files**

    - `.agents/skills/harness/**`
    - `.agents/skills/openspec/**`
    - `.agents/skills/openspec-continue-change/SKILL.md`
    - `.agents/skills/openspec-update-change/SKILL.md`
    - `.agents/skills/openspec-apply-change/SKILL.md`
    - `.agents/skills/openspec-verify-change/SKILL.md`
    - `.agents/skills/openspec-sync-specs/SKILL.md`
    - `openspec/workflows/angelscript/**`
    - `Tools/openspec/src/**`
    - `Tools/openspec/tests/**`
    - `Tools/openspec/docs/**`
    - `Tools/openspec/README.md`
    - `openspec/specs/harness/core/spec.md`
    - `openspec/config.yaml`

    **Verification**

    Run from `Tools/openspec`.

    ```sh
    cargo test --locked --all-targets
    ```

    All selected cases must execute and pass. Completion requires the whole
    stated outcome; a successful empty selection is not proof.

    **Evidence**

    See [implementation evidence](attachments/implementation-evidence.md) and
    [independent generation exercise](attachments/authoring-exercise.md).

## 4. Local release

- [x] 4.1 Publish the verified package and prove the immediate format cutover

    **Outcome and context**

    Release OpenSpec 0.9.0 through the existing clean-source/tagged local publisher, with only owned source changes committed. Convert this implementation record after publishing and verify exact new task.status, strict new-record validation and explicit old-record migration errors. Preserve the user's business records, archive files and unrelated changes. Full historical validation is deliberately omitted from new-format acceptance.

    **Implementation**

    1. Complete package gates: fmt, Clippy, all tests, command parity, locked Release and reproducibility.
    2. Publish the local package, convert this task record, verify route/JSON compatibility and old-format diagnostics.
    3. Retain exact verification and generation exercise evidence, record terminal evaluation and close this implementation Change through project lifecycle rules.

    **Files**

    - `Tools/openspec/Cargo.toml`
    - `Tools/openspec/Cargo.lock`
    - `.agents/skills/openspec/bin/openspec.exe`
    - `.agents/skills/openspec/release-manifest.json`
    - `.agents/skills/harness/scripts/Harness.psm1`
    - `.agents/skills/harness/scripts/Test-Harness.ps1`
    - `.agents/skills/harness/tests/Harness.Tests.ps1`
    - `.agents/skills/harness/tests/TaskOutput.Tests.ps1`
    - `.agents/skills/openspec/commands/**`
    - `.agents/skills/openspec/SKILL.md`
    - `Tools/openspec`
    - `openspec/changes/harness/refactor-document-authoring-structured-markdown/**`

    **Verification**

    Run from the selected workspace root.

    ```powershell
    & ./.agents/skills/harness/tests/Harness.Tests.ps1
    ```

    All selected cases must execute and pass. Completion requires the whole
    stated outcome; a successful empty selection is not proof.

    **Evidence**

    See [final verification](attachments/final-verification.md) for package
    gates, exact Harness checks, old-format cutover and preserved scope.
