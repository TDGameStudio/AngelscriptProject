## Purpose

Defines how AngelscriptProject agents must generate and apply OpenSpec `tasks.md`, so a later session can execute the change without the original chat.

## ADDED Requirements

### Requirement: Executable task line
Every implementation checkbox in `tasks.md` for a `feature`, `fix`, `refactor`, `improve`, or `test` change SHALL be a short checkbox title plus an indented multi-line body. The title SHALL contain a stable hierarchical id (`1.1`), a concrete action, and a `<!-- TDD -->` or `<!-- Non-TDD -->` marker. The body SHALL include `Files` (exact create/modify/test paths), `Impact` (what else is affected and what must not change), `Tests` (`Yes` plus what to run, or `No` plus why), `Verify` (the command to run when the line is done), and `Requirement` (capability or requirement name). Extra fields SHALL stay indented under that checkbox so OpenSpec still tracks a single `- [ ]` per task.

#### Scenario: Feature task uses a multi-line body
- **WHEN** an agent writes `tasks.md` for a `feature-*` change
- **THEN** each implementation checkbox is followed by indented `Files`, `Impact`, and `Tests` lines
- **AND** `Files` names at least one repository path
- **AND** `Tests` is either `Yes` with a `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` command or `No` with a reason
- **AND** the title line is not a slogan such as "Implement the feature" or "Add tests"

#### Scenario: Packed one-liner is not apply-ready
- **WHEN** a `feature`, `fix`, `refactor`, `improve`, or `test` checkbox has no indented `Files` / `Impact` / `Tests` body
- **THEN** the change is not treated as ready for apply until that task is rewritten as a multi-line body

### Requirement: Lean tasks still name a path
A `chore` or `docs` change MAY use short task lines, but each checkbox SHALL still name the files or directories it touches and a done condition.

#### Scenario: Chore task is short but located
- **WHEN** an agent writes `tasks.md` for a `chore-*` change
- **THEN** each checkbox may omit TDD markers and long verification commands
- **AND** each checkbox still names the path it will edit

### Requirement: Independently testable groups
`tasks.md` SHALL group checkboxes into numbered increments that can be implemented and verified without later groups. Each group SHALL state a one-sentence Independent Test. Work that blocks every later group SHALL sit in its own leading group and MUST be complete before later groups start.

#### Scenario: Group can stop and verify
- **WHEN** a change has more than one implementation group
- **THEN** each group header includes what the increment delivers and how to verify that increment alone
- **AND** a later session MAY implement only group N and stop

#### Scenario: Blocking work is separated
- **WHEN** shared fixtures, schemas, or harness changes are required by every later increment
- **THEN** those checkboxes appear in a leading group that later groups depend on
- **AND** no later group is marked complete while that leading group is incomplete

### Requirement: Requirement trace and parallel markers
Each implementation checkbox in a behavior-changing change SHALL name the delta-spec requirement or capability it implements. A `[P]` marker SHALL appear only when the line touches different files from other incomplete work and has no unfinished dependency.

#### Scenario: Task traces to a requirement
- **WHEN** the change has delta specs under `specs/`
- **THEN** each implementation checkbox identifies the requirement or capability it serves
- **AND** a checkbox with no matching requirement is removed or marked out of scope before apply

#### Scenario: Parallel marker means different files
- **WHEN** two incomplete checkboxes both modify the same file
- **THEN** neither line carries `[P]` relative to the other

### Requirement: Test-first ordering for TDD lines
For new behavior, bug fixes, and complex logic, a failing-test checkbox marked `<!-- TDD -->` SHALL appear before the implementation checkbox it proves. Agents SHALL NOT mark the implementation checkbox complete while the matching test checkbox is unchecked.

#### Scenario: TDD pair is ordered
- **WHEN** a group implements new observable behavior
- **THEN** `tasks.md` lists a `<!-- TDD -->` failing-test line before the matching implementation line
- **AND** both lines name their files

### Requirement: Apply follows group boundaries
Apply/implement SHALL complete one group, run that group's Independent Test / verification commands, and stop for review when the user asked for one group or when the change type is `feature`, `fix`, `refactor`, `improve`, or `test` unless the user explicitly asked to continue. A failed non-parallel checkbox SHALL stop the group.

#### Scenario: One group then stop
- **WHEN** a user asks to apply a `feature-*` change without saying "all groups"
- **THEN** the agent implements only the first incomplete group, marks finished checkboxes `[x]`, runs the group's verification command, and stops

### Requirement: Guidance is injected not optional chat
The task contract SHALL be present in `openspec/config.yaml` rules for the `tasks` artifact and in `openspec-work`, and those two sources SHALL NOT contradict each other. `openspec-work` SHALL NOT instruct agents to start lean for `feature`, `fix`, `refactor`, `improve`, or `test` changes.

#### Scenario: Propose sees the same bar as the skill
- **WHEN** an agent generates `tasks.md` through `/opsx:propose` or through `openspec-work`
- **THEN** both paths are required to emit path-bearing, requirement-traced checkboxes for behavior-changing types
- **AND** `openspec-work` does not tell the agent that a lean proposal-plus-slogan-tasks record is sufficient for those types

#### Scenario: Config and skill agree
- **WHEN** `openspec/config.yaml` `rules.tasks` and `openspec-work` are both present
- **THEN** they list the same required fields and the same lean-vs-full type split

### Requirement: Progressive execution record
During planning, unexpected findings SHALL be appended to `attachments/planning/issues.md` and/or `attachments/planning/progress.md`. During apply, they SHALL be appended to `attachments/implementation/issues.md` and/or `attachments/implementation/progress.md`. `tasks.md` SHALL remain a checkbox list. Agents SHALL NOT hide a finding by weakening a test or deleting the historical note.

#### Scenario: Apply failure is logged the same day
- **WHEN** a non-parallel task fails, a verification command disagrees with the spec, or a tool wrapper times out while work continues
- **THEN** `attachments/implementation/issues.md` gains a row with id, status, evidence path or observation, and next action
- **AND** `tasks.md` is not used as the log

#### Scenario: Design overturn updates the contract first
- **WHEN** implementation shows the recorded design or tasks are wrong
- **THEN** `design.md` / specs / `tasks.md` are rewritten to the new direction
- **AND** `attachments/implementation/progress.md` records what was overturned, without deleting the earlier note

#### Scenario: Follow-on is not stuffed into the current checklist
- **WHEN** a finding is valid but outside this change's intent
- **THEN** it is `Deferred` in `attachments/implementation/issues.md` (or `attachments/planning/issues.md` if still in planning) with a resumption trigger, or named as a follow-on change
- **AND** it is not implemented silently inside an unrelated checkbox

### Requirement: Attachment isolation
A change's attachments SHALL be split into `attachments/planning/` (discussion and research) and `attachments/implementation/` (apply working set). Apply and implement sessions SHALL NOT read `planning/` unless the current task is blocked. When blocked, the agent SHALL log the blocker in `attachments/implementation/issues.md` and open only the one planning file that matches the blocker.

#### Scenario: Apply does not load planning notes
- **WHEN** an agent applies a group from `tasks.md`
- **THEN** it reads proposal, design, specs, tasks, and `attachments/implementation/`
- **AND** it does not read `attachments/planning/` as a batch

#### Scenario: Blocker opens one planning file
- **WHEN** apply is stuck and a planning note is needed
- **THEN** `attachments/implementation/issues.md` records the blocker first
- **AND** at most one file under `attachments/planning/` is opened for that blocker

### Requirement: Mid-change OpenSpec refactor is recorded
If implementation changes OpenSpec itself (task format, attachment layout, `config.yaml`, `openspec-work`, or schema), the agent SHALL update the governing proposal/design/specs/tasks in the same session and append a dated entry to `attachments/implementation/openspec-refactors.md` with trigger, files changed, and why.

#### Scenario: Task format change is logged
- **WHEN** apply rewrites how `tasks.md` is structured mid-change
- **THEN** `attachments/implementation/openspec-refactors.md` gains a dated entry
- **AND** `specs/` and `tasks.md` match the new format before more implementation continues
