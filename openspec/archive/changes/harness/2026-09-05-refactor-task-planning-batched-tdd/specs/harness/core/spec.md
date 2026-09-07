## MODIFIED Requirements

### Requirement: Ready-to-execute Task authoring

Before a Task DAG is accepted, planning MUST map affected files, artifacts, and exclusive resources; divide work into independently reviewable outcomes; state exact or explicitly bounded paths, cross-task interfaces, and exact verification; and map every requirement and acceptance condition to at least one node. Behavior tasks SHALL define bounded feature groups with concrete test inputs, expected outcomes, expected missing-behavior failures, implementation order and completion evidence before Ready execution. A task MUST NOT be sized by a fixed test count, file count, elapsed-time quota or process launch. Setup, tests, implementation and necessary documentation SHOULD stay with the outcome they enable. Each task card MAY use concise free-form prose, quoted notes, lists, examples or tables; labels remain optional, not a fixed schema. Only the existing DAG frontmatter, checkbox ID, Files and verify text remain machine-readable. This contract MUST NOT change the portable OpenSpec parser or executable.

#### Scenario: Recognize an oversized task before continuing
- **WHEN** one pending task accumulates independently acceptable deliverables, hidden prerequisite interfaces or verification contracts that no longer prove its whole outcome
  > Inputs: Actual file ownership, acceptance conditions and previously verified partial outcomes establish the boundary problem; a routine test failure alone does not.
- **THEN** the coordinator revises the pending task boundary through an evidence-backed Replan before implementing the newly separated work

  - Completed nodes and valid evidence remain intact.
  - New outcomes receive new IDs; shared files constrain scheduling without inventing semantic dependencies.
  - Files and verification are updated with the real scope, not extended only in tail prose.

#### Scenario: Plan a feature group before implementation
- **WHEN** an author prepares a behavior task for an implementer without prior conversation context
  > Context: Several related cases may share one feature outcome and one expensive test process.
- **THEN** the task states concrete inputs and expected results, missing-behavior RED expectations, interface handoffs, ordered implementation actions and an exact proving selection
  > Boundaries: A simple self-contained card may remain short; generic instructions to finish a subsystem or add complete tests do not define a Ready outcome.
- **AND** the template and execution entry actively check that quality and route to the same task-authoring contract
  > Observables: This is authoring quality, not a new parser field, rigid heading set or second completion checklist.

### Requirement: Impact-scoped verification by default

Harness lifecycle guidance SHALL begin task execution, Change completion verification, and post-archive checking with the smallest reliable scope that directly proves the affected behavior. Verification MUST expand only when an affected shared contract, cross-component boundary, observed failure, release gate, or explicit user request provides a concrete reason. Behavior implementation SHALL use bounded feature-group RED/GREEN by default: prepare related tests, observe their expected missing-behavior failures together, implement that group, then verify the same behavior together. Batching SHALL amortize execution cost without removing RED, merging Task state or deferring unrelated unfinished groups indefinitely.

#### Scenario: Verify a ready task
- **WHEN** an agent implements one Ready behavior task
  > Inputs: The task declares the feature boundary, concrete cases, expected failures and an exact impact-related proving command.
- **THEN** it observes the group's expected RED before new behavior implementation and reruns the same proving selection for GREEN
  > Observables: Related tests share each phase; one new case does not require its own process, and one group is not promised only one total run.
- **AND** a local failure is diagnosed and repaired in the task before expanding to the adjacent affected surface
  > Details: Expansion follows evidence from the failure rather than the mere availability of broader suites.
- **BUT** it enters Replan only when evidence invalidates an accepted requirement, design boundary, Task DAG edge, verification contract, or required artifact
  > Boundaries: Ordinary implementation defects and first expected TDD failures remain task-local.

#### Scenario: Share a proving run without merging task state
- **WHEN** compatible Ready tasks share an expensive build or test process
  > Inputs: Each task retains its proving selection and acceptance cases; the shared run selects their documented union or justified superset.
- **THEN** completion evidence maps each task to actual executed test identities and results from the same source and binary snapshot

  - The coordinator freezes source writers during build and Automation.
  - A proven task need not repeat its subset command solely because a shared run supplied its proof.
  - Aggregate counts without case mapping, missing cases, crashes and incomplete reports do not establish task completion.
- **BUT** an unrelated failure cannot be called a completely green batch
  > Boundaries: Individually complete task evidence must also establish that the failure does not invalidate that task's required or adjacent contract.

#### Scenario: Preserve existing work without fabricating RED
- **WHEN** resumed code predates a test or was written under an explicit user-authorized delayed-first-run exception
  > Context: A newer grouped-TDD instruction governs subsequent work without rewriting historical provenance.
- **THEN** the agent preserves that code, records the actual verification gap and validates it without claiming a failure was observed before implementation
  > Boundaries: Neither automatic deletion nor manufactured retroactive RED is authorized. New behavior follows grouped RED/GREEN unless the user explicitly grants another exception.
- **AND** ordinary build errors, fixture crashes or unexecuted cases are repaired as verification setup failures rather than accepted as feature RED
  > Details: Only a minimal interface skeleton needed to execute the test may precede its runtime RED; it must not implement the behavior being proved.
