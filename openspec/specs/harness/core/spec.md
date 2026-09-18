# Harness Core

## Purpose

This capability defines how the AngelscriptProject Skill harness selects a workspace, dispatches project commands, maintains a resumable execution plan, handles explicit Review input, and replans autonomously without crossing user authority boundaries.

## Requirements

### Requirement: Progressive skill routing

Harness SHALL remain the single short entry for project workflow and SHALL load only the selected leaf module or focused reference. Workspace lifecycle, Git mutation, OpenSpec primitives, task status, Harness observation, and Unreal development SHALL retain separate routes and authority boundaries. Default context MUST NOT bulk-load command documentation, attachments, historical observations, Replans, or leaf implementations.

#### Scenario: Route one project command
- **WHEN** a caller requests one installed Harness command
- **THEN** the dispatcher loads only the owning leaf, returns the common result envelope, and does not acquire unrelated workflow authority

#### Scenario: Route an Unreal operation
- **WHEN** a caller requests a verified `ue.*` route
- **THEN** Harness supplies the exact WorkspaceRoot context to the Unreal leaf and the leaf enforces its own engine/process authority

### Requirement: Unified workspace context

Harness MUST preserve the exact selected execution Context. The primary workspace SHALL be both control center and a full execution workspace, including major host, Harness and plugin work. New workspaces SHALL be minimal project replicas under `.workspaces/<name>/` without a parent Git worktree; edited plugins SHALL use their own Git worktrees and necessary unmodified plugins SHALL use fixed committed file snapshots. Replica identity MUST match its local descriptor and primary registration. Canonical OpenSpec SHALL remain in the primary workspace, while queue state and build outputs SHALL remain local to each execution workspace. Existing parent Git worktrees SHALL remain inspectable in place and parked outside the new queue workflow. Caller parameters MUST NOT retarget dispatcher-owned roots; exact primary queue-management targets are an explicit exception. Codex `/goal` SHALL be optional continuation only. Workspace creation, integration, push and removal MUST retain separate explicit authority.

#### Scenario: Work in the primary checkout
- **WHEN** the caller selects the registered primary checkout
- **THEN** Harness targets that exact root without creating, switching, or assigning a repository mode and preserves unrelated local changes

#### Scenario: Work in an existing linked worktree
- **WHEN** the caller selects any worktree registered in the same Git common directory
- **THEN** Harness accepts its actual path and branch without requiring `.worktrees/<name>` or a branch prefix

#### Scenario: Interpret Codex Goal continuation
- **WHEN** work is running under Codex `/goal`

    > `/goal` contributes unattended continuation only; it does not choose a branch, create a worktree, or expand Git authority.

- **THEN** repository selection still comes from the explicit or discoverable WorkspaceRoot and no repository-mode state is created

    > The same selected-workspace contract applies to interactive and repeated continuation calls.
    >
    > - Repository identity remains the explicit or current-directory-discovered `WorkspaceRoot`.
    > - No repository mode or machine-global Goal selection is created.

#### Scenario: Reject a route target override
- **GIVEN** Harness has resolved one exact selected Context
- **WHEN** caller parameters supply a blank, conflicting, or different dispatcher-owned root or internal Context
- **THEN** Harness returns `ContextAuthorityMismatch` before loading or invoking the leaf and does not mutate either the selected or requested target

    > Inputs: Workspace routes, Git routes, Unreal routes, and internal Harness routes with both canonical parameter names and supported aliases.
    > Observables: Matching explicit roots are normalized to the selected Context; rejected results contain no leaf data and no target-side effect.
    > Boundaries: Portable native OpenSpec and task routes receive authority through their working directory and never accept a second repository-selection parameter.
    > Verification: Table-driven dispatcher fixtures cover every routed root category and an alternate registered worktree.

#### Scenario: Integrate from the primary Context
- **WHEN** `git.integrate` is dispatched from the canonical primary Context with an explicitly selected registered linked source
- **THEN** the target remains that primary Context and `SourceWorkspaceRoot` is the only authorized different workspace root

    > Boundaries: Selecting a linked Context and silently redirecting its target to `PrimaryRoot` is forbidden.

### Requirement: Retained Harness performance evidence

Harness SHALL expose one PowerShell 7 performance-test profile that measures fresh-process and persistent-session harness paths independently. Every sample MUST also validate the invoked behavior. Each run MUST write a unique structured summary and raw sample table without overwriting or automatically deleting prior runs, while the change record retains a privacy-trimmed aggregate baseline and hashes of its raw source artifacts. Default TaskStatus sampling MUST use a hermetic temporary Task Graph that does not depend on an active project change; an explicit `-TaskChange` MAY select an active project record intentionally.

#### Scenario: Record a PowerShell 7 performance run
- **WHEN** the Performance profile runs in the supported PowerShell 7 host
- **THEN** it reports its warmup count, measured samples, min/median/p95/max, behavior result, and broad catastrophe-budget result in one unique Saved run directory

#### Scenario: Preserve comparable evidence without a flaky machine gate
- **WHEN** one accepted run is registered as the current baseline
- **THEN** raw machine-specific samples remain ignored local data, a trimmed aggregate is indexed under change attachments before archive, and a single prior-run regression ratio remains advisory until representative history establishes a portable threshold

#### Scenario: Run without an active project change
- **WHEN** the default Performance profile runs after every project change has been archived
- **THEN** TaskStatus measures the real Harness/OpenSpec route against an isolated temporary Task Graph and removes that fixture after the run

### Requirement: Archive-stable closure gates

Reusable gates cited as closure evidence MUST use hermetic fixtures or stable repository inputs and MUST NOT require the subject record to remain under `openspec/changes/`. A default gate that needs a schedulable Task DAG MUST create a hermetic active fixture. An explicit `-TaskChange` MUST resolve the selected active record or fail without falling back to an archive. A historical protocol audit MAY bind an exact immutable archive path, but archived tasks MUST NOT become `task.status` scheduling input. After a deterministic archive move, the coordinator MUST run strict archived validation plus the smallest applicable non-destructive lifecycle gate that can expose active-path coupling. A newly exposed defect MUST preserve the completed archive and record source evidence in the feedback inbox or a linked draft. New repair scope and formal successor handoff require user selection and the applicable Gate; an already authorized bounded direct repair MAY continue within its existing scope without a successor Change or repeated approval.

#### Scenario: Detect active-path coupling after archive
- **WHEN** an applicable gate fails only after its subject change moves to the archive
- **THEN** the archive remains immutable while the feedback inbox or linked draft records the failure and source evidence
- **AND** a formal successor is created only after user-led convergence and its exact handoff Gate; an existing authorized direct repair continues within scope

#### Scenario: Retain accepted evidence before archive
- **WHEN** a performance run is accepted as closure evidence
- **THEN** its privacy-trimmed aggregate and raw-artifact hashes are indexed in the active change before the archive move

#### Scenario: Select an explicit active Task Graph
- **WHEN** a caller passes `-TaskChange` for a missing or archived record
- **THEN** the gate fails that explicit selection and does not silently substitute a fixture or historical Task DAG

#### Scenario: Audit immutable protocol history
- **WHEN** a reusable protocol test intentionally checks the completed dogfood Review/Replan history
- **THEN** it reads the exact immutable archive path without treating that record as current execution state

### Requirement: Harness-recognized Task Graph

`tasks.md` MUST be the change's only current execution state and DAG. A current file MUST declare one versioned YAML-frontmatter `task_graph.depends_on` map whose directly quoted stable `X.Y` keys exactly match its task-node IDs. A task node MUST be a level-2 heading whose text starts with `[ ] ` or `[x] `, then the `X.Y` ID, then a short title; its body MUST be every Markdown block until the next level-1 or level-2 heading, written without indentation. Each node MUST contain exactly one direct **Files** paragraph followed by one fenced `diff` tree and one direct **Verification** paragraph followed by one non-empty fenced proving command. In the Files tree a line beginning `+` creates, `-` deletes, and a leading space modifies; a path ending in `/` prefixes the deeper-indented lines beneath it; text after ` # ` is a comment; the literal `none` alone denotes file-free work. The projection MUST keep `files` as plain paths and MUST add `file_roles` with each path's role. Level-2 headings without a checkbox are group headings and MUST NOT own Files or Verification. Root-level checkbox list items, inline verification, blockquote Files and body After metadata MUST all be reported as `unsupported-task-format` with no Ready work. A completed task MUST NOT return to incomplete, and an ID MUST NOT be reused or renumbered.

#### Scenario: Derive ready work through Harness

- **GIVEN** a valid graph has completed `1.1`, pending `1.2` depending on `1.1`, pending `1.3` depending on `1.2`, and independent pending `2.1`

    Every task owns its exact Files tree and proving command. Graph keys
    and body task IDs match; no dependency is inferred from display order.

- **WHEN** Harness reads the current task plan

- **THEN** `1.2` and `2.1` are Ready, `1.3` remains blocked, and completed `1.1` is not Ready

    The public projection retains `id / description / done / files / verify /
    after / ready / line` and adds `file_roles`. Parallel execution
    additionally requires disjoint files, generated artifacts and resource
    leases.

- **BUT** any graph or task-card issue suppresses every Ready result

    An independent valid task is not schedulable while another card is
    malformed. Diagnostics retain the task identity and source location where
    applicable; validation does not rewrite the document.

#### Scenario: Keep presentation separate from execution

- **WHEN** Graph keys and task blocks are displayed in a different Markdown order

- **THEN** output uses natural numeric task-ID order and derives dependencies only from `depends_on`

    Group headings, nested headings of level 3 or deeper, tables, quotations
    and fenced task examples remain content of their enclosing card or group.
    They do not create nodes; only a level-2 heading ends the owning task.

#### Scenario: Read historical task records

- **GIVEN** a record still uses root-level checkbox list nodes, inline verification, blockquote Files or body After metadata

- **WHEN** the current parser is asked to inspect it

- **THEN** the parser reports explicit `unsupported-task-format` diagnostics naming the heading-node form and exposes no Ready work

    There is no old-format fallback, automatic conversion or dependency
    inference from retired fields. The original record bytes remain
    unchanged; migration is a separately scoped action.

#### Scenario: Preserve exact metadata values

- **GIVEN** one task's Files tree lists `src/a b.rs` as a created file and `tests/a,b.rs` as a modified file under a `/`-terminated directory line with a ` # ` comment

    Its Verification fence contains a command spanning multiple lines. A
    quoted example elsewhere in the card also contains a Files label.

- **WHEN** the parser projects the task

- **THEN** it returns exactly the two resolved paths in `files`, their roles in `file_roles`, and preserves internal command newlines

    Commas, spaces and Unicode inside a path are data, not delimiters; the
    comment is not part of the path. The quoted label supplies no metadata.
    Missing or duplicate direct sections, empty commands, a malformed tree
    line and multiple proving fences produce diagnostics.

### Requirement: Two-tier exploration

Harness MUST own one discussion/execution double loop with independently callable peripheral tools. Brainstorming owns current candidate design; Update owns reconsideration of existing accepted Change truth. Explaining-work and independent Grill MUST inspect affected scope, behavior, interfaces, dependencies, failure paths and acceptance, explain the relevant current architecture and terms, collect actual answers and continue ready question rounds without a separate user restart request. Returning a convergence, pause or waiting state to the caller MUST preserve the exact continuation point; an ordinary answered round does not complete discussion. Explicit bounded direct work MAY bypass the formal lifecycle. Ordinary implementation defects remain task-local.

#### Scenario: Explain after every answer

- **WHEN** the user answers a Grill question
- **THEN** the agent re-presents the complete relevant current architecture, roles, terminology, behavior and changed boundary before the next frontier questions

    Use faithful simplified annotated code and relevant ASCII relationships. Preserve
    real names and important branches; label omissions or unverified inferences.
    A delta list, acknowledgement or reference to a previous diagram is insufficient.

#### Scenario: Continue the next question without a restart request

- **GIVEN** an active Grill and a consequential next question whose prerequisites are settled
- **WHEN** the user answers the current question without pausing or requesting convergence
- **THEN** the agent re-explains the updated relevant architecture and actually submits the next question through the permitted host mechanism in the same turn
- **AND** a summary, a promise to ask later, or a request for the user to say continue cannot substitute for the question

#### Scenario: Recover a missing question form

- **WHEN** a question tool fails or the user reports that the expected next question is not visible
- **THEN** the agent sends the concrete unresolved question through the host-permitted visible fallback and retains the discussion in an awaiting-answer state
- **AND** the next actual answer resumes explanation and questioning without an additional restart message; a host-required end of the current reply is not discussion completion

#### Scenario: No substantive next question is available

- **WHEN** the current frontier is empty and useful in-scope investigation is exhausted without user-led convergence
- **THEN** the agent presents its current understanding and explicitly waits for feedback or convergence while leaving the topic open
- **AND** it does not fabricate another question, repeat a settled choice or propose creation merely to keep the interaction active

#### Scenario: User initiates convergence

- **WHEN** the agent believes every current question is answered but the user has not signaled readiness
- **THEN** it continues explaining and asking relevant questions without suggesting Create or Replan
- **WHEN** the user proactively says the design is ready
- **THEN** it prepares the exact handoff and asks the version-bound Gate; convergence alone does not create or apply anything

#### Scenario: Pause the current Change for an answer

- **WHEN** a necessary user-owned choice remains unanswered
- **THEN** implementation pauses while read-only investigation may continue in a linked draft and Change-owned planning talk
- **AND** an attended session asks through Grill; unattended continuation records the question and waits without inventing answers

#### Scenario: Return through both Gates

- **WHEN** the user approves the concrete Create or Replan and application succeeds
- **THEN** the agent asks draft disposition and execution arrangement, applies actual choices, and only then returns to authorized execution

### Requirement: Change-owned discussion and applied planning

Change-owned planning talks MUST remain indexed under attachments/talks with concise impact, provenance, questions and return state. Candidate design discussion MAY use a linked local draft without copying full conversation into both owners. The grill- prefix denotes interactive origin and talk- technical analysis, not lifecycle state. Open, settled, closed and superseded states preserve prior decisions. Explicit optional transcript frames preserve original wording; historical schema-less talks remain readable without migration. Only successfully applied planning updates create immutable applied Replans.

Superseding a planning talk MUST name an indexed active planning replacement in the same Change, scope and workspace. Pending questions and their source/revision/return-task provenance MUST transfer before the source stops blocking. Missing or terminal replacements, cycles, conflicting identities and loss of inherited decisions MUST fail closed; exact source-talk queries MUST follow its replacement. Closing unresolved questions as rejected or no-change MUST retain an actual resolution source, not only a disposition label.

#### Scenario: Preserve a decision through discussion replacement

- **WHEN** an unresolved planning talk is replaced by another planning talk
- **THEN** its pending questions and provenance remain visible and block execution through the replacement
- **AND** a nonexistent replacement or arbitrary superseded disposition leaves the original blocker intact

#### Scenario: Correct current conclusions

- **WHEN** the user corrects a decision
- **THEN** the candidate design and key-decision context preserve the correction and reason; the Change talk records planning impact without requiring a transcript mirror
- **AND** if recording was explicitly enabled, original source occurrences retain their language and retry identity

#### Scenario: Apply a design-only Replan

- **WHEN** a settled discussion changes design while retaining its DAG and the user approves the exact preview
- **THEN** Harness validates candidates and baselines, journals the changes, and records one applied Replan with its handoff receipt and purpose-specific followup in the same transaction
- **AND** execution remains blocked until the actual post-handoff arrangement is recorded and applied

#### Scenario: Recover an interrupted planning update

- **WHEN** validation fails, baselines change or application is interrupted
- **THEN** failed validation leaves live artifacts unchanged, stale baselines are rejected and the journal blocks execution/closure until explicit recovery
- **AND** recovery preserves unrelated edits, permanent task IDs and completed work; status never repairs

### Requirement: Explicit execution continuation

Harness MUST bind all explicitly authorized Change execution to one selected-workspace queue core and session. Scope=Change MUST be a bounded single-item adapter. The controller MUST retain ordered authorized UIDs and actual source; an existing queue MUST NOT be replaced or silently reordered to satisfy a non-head request. Recording and queries never start execution. Derived status MUST expose pending input, handoff decisions, pause, blockers, current work and completion without replacing native TaskPlan readiness.

Controller release, claim and takeover MUST preserve a queue pause. Resume MUST consume a fresh actual resolving source through execution start/checkpoint; ownership authority alone MUST NOT resume work. Session takeover MUST retain the original request and exact authorized UID range, handoff authority, pending and handled input identities, deduplication history, pause/blockers and return state. Interrupted transfer MUST remain blocked until deterministic recovery publishes both bindings; status MUST NOT perform recovery.

#### Scenario: Retain feedback and pause across ownership transfer

- **WHEN** a paused request with pending feedback is released/reclaimed or transferred to a stopped-session successor
- **THEN** the pause and pending feedback still prevent implementation and terminal closure
- **AND** takeover cannot widen its authorized range, replay an old resume source, or count feedback as handled

#### Scenario: Accept feedback through a public route

- **WHEN** harness.execution.input receives SessionId, InputId, actual SourceRef, Summary and Kind feedback or pause
- **THEN** pending input blocks implementation; identical retries are idempotent and conflicting reuse of an ID is rejected
- **AND** acknowledgement records triage without approving a design or resuming a pause; unrelated ideas do not change queue membership

#### Scenario: Exhaust only the authorized range

- **WHEN** the final authorized item has a completed archive and queue advance runs
- **THEN** the controller releases without marking the next pending item started
- **AND** edits cannot alter the remaining authorized ordered prefix; newly appended tail work needs new authority

#### Scenario: Respect a new handoff wait decision

- **WHEN** an existing execution request is interrupted by a new applied handoff whose arrangement is later
- **THEN** the earlier execution source cannot revive implementation; an actual later resume source is required
- **AND** a whole-queue start can authorize already settled handoffs in its chosen range without inventing identical per-item decision sources

#### Scenario: Pause and explicitly release scope

- **WHEN** the user pauses execution
- **THEN** implementation stops at the boundary but a running UE worker is not implicitly cancelled
- **WHEN** the user explicitly releases the request with a source and reason
- **THEN** only its own controller is released, its history remains, and the request is not marked completed

#### Scenario: Archive after optional recording

- **WHEN** a Change reaches terminal evaluation/archive
- **THEN** current-scope decisions, post-handoff arrangements and Replan recovery are resolved
- **AND** any explicitly enabled recording sink is synchronized/unbound; archived originals remain immutable and no project hook is required

### Requirement: Exploration carryover

After user-led convergence, the concrete handoff presentation MUST present every carryover candidate with its draft source, target (talk or knowledge), and reason, and the user MUST confirm the list before it enters the decision-complete handoff. `openspec-create-change` MUST be the only Skill that creates the target Change from a designed draft; in the same step it MUST copy the approved draft `design.md`, `handoff.md` and any actually needed optional glossary into indexed `attachments/drafts/`, MUST copy every draft finding that the design or a confirmed talk or knowledge cites into indexed `attachments/drafts/research/` (legacy findings retain their compatibility mapping), and MUST materialize exactly the confirmed candidates — non-obvious decisions and their useful visuals into indexed talks, reusable evidence-backed insights or visuals into indexed change-local knowledge — with provenance naming the draft round or the copied finding. Because drafts are local and git-ignored, no Change file MAY reference an `openspec/drafts/` path. Afterwards canonical truth MUST enter proposal/spec/design/tasks through the `Ensure plan` step of `openspec-apply-change`, which MUST write every missing required artifact from the seeded handoff in one pass, MUST NOT recreate the seeded carryover, MUST route newly invalidated decisions through Update to a linked draft, and MUST stop and report — never invent — when the handoff lacks a user-owned decision or a settled public name.

When an extended user-led exploration establishes multiple interacting cross-capability constraints, meaningful corrections, rejected interpretations, or non-obvious rationale that canonical artifacts would flatten and future agents would otherwise re-decide, planning MUST preserve one selective indexed intent talk. The talk MUST retain provenance, capture date, source limits, architecture-changing corrections, exclusions, and canonical mappings. It MUST NOT impersonate an earlier record when reconstructed later. Clear defects, mechanical documentation changes, one-step requests, routine task-local choices, and decisions fully represented by canonical artifacts MUST NOT create a required talk or a not-required placeholder. Transient navigation state, task state, and progress evidence MUST NOT be copied into the Change; the pre-Change round log stays in the draft. After creation, substantive candidate design can use a linked draft; the Change's indexed talks retain planning impact and provenance without full dual-writing.

#### Scenario: Carry accepted exploration into a new Change

- **GIVEN** the target Change exists and the decision-complete handoff has classified its accepted carryover

- **WHEN** an accepted handoff contains a non-obvious decision and a reusable insight after the target Change is created

- **THEN** `openspec-create-change` copies the approved draft `design.md`, `handoff.md` and any actually needed optional glossary and the cited findings into `attachments/drafts/`, indexes each once, materializes the confirmed decision and its visualization as one talk and the confirmed insight as change-local knowledge, and `openspec-apply-change` step `Ensure plan` then copies settled current truth into the canonical planning artifacts

    The selected design metadata records `status: handed-off` and `target_change` in the
    same step so the source discussion and the Change point at each other.
    Each talk and knowledge cites the copied finding by its Change-relative
    path in English; the original key decisions stay in draft CONTEXT; optional legacy transcript stays local.

- **AND** the original draft files remain local; the Change uses self-contained copies and still works when the draft directory is unavailable

- **BUT** a talk is retained only when its rationale prevents likely re-decision, and knowledge is retained only when the insight is reusable beyond the originating task

    > Inputs: The accepted handoff, its evidence and provenance, the non-obvious decision, the reusable insight, and the settled canonical behavior.
    >
    > Observables: Proposal, specification, design, or tasks contain current truth; the attachment index names the draft copies, the copied findings, the talk, and the knowledge candidate; the capability knowledge index changes only after explicit promotion.
    >
    > Boundaries: The draft owns the conversation, the talk owns decision rationale, the knowledge candidate owns reusable guidance, and none becomes a parallel source of current requirements or task state.

#### Scenario: Preserve a major user-intent baseline

- **WHEN** a major user-led refactor is shaped by several interacting goals, corrections, exclusions, or rejected interpretations whose rationale would otherwise be lost

- **THEN** planning indexes one concise intent talk with exact provenance and canonical mappings while proposal/spec/design/tasks retain current truth

#### Scenario: Keep routine work free of intent boilerplate

- **WHEN** a Change is a clear defect, mechanical edit, one-step request, or contains no rationale beyond its canonical artifacts

- **THEN** no intent talk, draft copy, or not-required placeholder is created and closure does not infer one from conversation or diff size

#### Scenario: Repair missing historical carryover honestly

- **WHEN** later evidence shows that required user rationale was never recorded before a source Change was archived

- **THEN** a suitable active Change records a clearly dated reconstruction and does not edit the immutable archive or claim contemporaneous provenance

#### Scenario: Reject transcript accumulation inside the Change

- **WHEN** brainstorming contains temporary held/reopened navigation, redundant prose, progress state, or a one-off visualization with no later decision or reuse value

- **THEN** the Change receives only the approved design, handoff, qualifying talks, and knowledge, while the draft keeps the rest

#### Scenario: Reject transcript accumulation

- **WHEN** exploration contains temporary held/reopened navigation, redundant prose, progress state, or a one-off visualization with no later decision or reuse value

- **THEN** the handoff discards it rather than creating a parallel exploration diary

### Requirement: Persistent brainstorming drafts

New substantial brainstorming topics MUST use ignored openspec/drafts/<domain>/<topic>/ with README.md for identity/status/navigation and CONTEXT.md for key decisions, reasons, corrections and actual sources. Optional research/ holds useful investigation and naming candidates; optional attachments/INDEX.md explains attachment purpose/source. Each designs/<scope>/design.md owns scope metadata, current architecture and terminology. Handoff.md is prepared only after user-led convergence. New drafts MUST NOT require a scope README, separate glossary, full transcript or duplicate chat output. Old flat/scoped drafts, findings and logs remain readable and unchanged.

#### Scenario: Open a discussion automatically

- **WHEN** a substantial unresolved topic requires continuing design discussion
- **THEN** Harness creates the minimal README/CONTEXT structure without asking a creation Gate
- **AND** full explanations remain in chat; only consequential decisions and material design changes require draft writes

#### Scenario: Use research and binary attachments

- **WHEN** an investigation or source diagram benefits future decisions
- **THEN** the draft may add research material or an indexed attachment without creating a Change or mirroring every message

#### Scenario: Archive unresolved work honestly

- **GIVEN** the user has seen unresolved scopes and explicitly chooses archive
- **WHEN** harness.draft.archive receives the actual source/reason
- **THEN** it safely moves the directory under ignored openspec/archive/drafts without rewriting unresolved scopes as complete or abandoned
- **BUT** path escape, collision or an active recorder prevents the move

#### Scenario: Preserve legacy archive behavior

- **GIVEN** a legacy flat draft has a dated completed handoff to its exact existing Change
- **WHEN** its legacy completed-closure archive is requested
- **THEN** original log/design/handoff stay intact with no scoped-layout migration

#### Scenario: Park or abandon

- **WHEN** the user parks discussion
- **THEN** the topic stays active with a revival condition; resumption updates key decisions in the same topic
- **WHEN** the user abandons it
- **THEN** no Change or carryover is created merely to close the discussion

#### Scenario: Keep drafts outside execution truth

- **WHEN** native OpenSpec validation/task.status runs
- **THEN** drafts yield no task state, Ready work or active Change entries

### Requirement: Naming confirmation before implementation

New public names — types, modules, files, and key functions — MUST be confirmed by the user before code is written. `brainstorming` MUST grill each new public name after inspecting neighbouring conventions and record the key choice and source in CONTEXT and the design's vocabulary section; new drafts need no separate glossary. Task authoring MUST list every new public name the task introduces in its **Interfaces** section with its source. Apply MUST NOT ask the user for a name: when implementation requires a new public name that the task does not list, Apply MUST choose the convention-derived name and record `Naming assumed: <name>` in the task's Evidence, and verification MUST surface every assumed name for user review before the task closes.

#### Scenario: Grill a name during planning

- **WHEN** the design introduces a new public type

- **THEN** the round presents the recommended name, alternatives, and the neighbouring convention evidence plus an explicit Provide more names option, and the settled name is written to design terminology/CONTEXT and later to the task's Interfaces

#### Scenario: Request more names

- **WHEN** the user chooses Provide more names in a naming round
- **THEN** the agent writes semantically distinct candidates, actual usage examples, conventions and rejection reasons to research/naming-<subject>.md in the current draft
- **AND** it explains the options and asks again without silently selecting one

#### Scenario: Continue past an unplanned name in Apply

- **WHEN** a Ready task requires a new public class or file whose name is not in its **Interfaces**

- **THEN** the agent proceeds with the convention-derived name and records `Naming assumed: <name> — <reason>` in the task Evidence

    Attended and unattended runs behave identically; Apply has no interactive
    stop. Verification lists every `Naming assumed` entry so the user can
    rename before commit.

- **BUT** repeated assumed names indicate that task authoring skipped the naming round, which is corrected in planning rather than by asking during Apply

### Requirement: Ready-to-execute Task authoring

Planning MUST map affected files, artifacts and exclusive resources, divide work into stage-level independently acceptable outcomes, and map every requirement and acceptance condition to a node. A plan MUST open with `## Goal`, `## Architecture`, `## Global constraints` and `## Requirement coverage` sections and MAY add `## File map`; Harness execution policy MUST be linked from `.agents/skills/harness/references/execution-conventions.md`, not repeated. A behavior task MUST supply, in order, a brief paragraph, **Outcome** with explicit exclusions, **Interfaces** with consumed and produced signatures in code fences and every new public name with its source whenever any symbol is produced or consumed, **Cases**, **Files**, **Verification**, and MAY add **Notes**; a document or migration task MAY omit Interfaces and Cases. Each case MUST open with one header line `N. **Name** — <role>` optionally followed by ` · <kind>`, and its body MUST carry the literal input, the independently derived expected result and, when a count or invariant is asserted, the oracle. Standard roles are `new RED`, `existing control`, `boundary` and `deferred RED until X.Y`; standard kinds are those in the task case catalog. Any other role or kind word MUST be defined once in a `Roles:` or `Kinds:` paragraph of the same Cases block — a role definition states how RED/GREEN treats the case, a kind definition states what the body carries and what its oracle is. The block MAY open with one `Setup:` paragraph that cases reference, and a case MAY carry a `Replaces:` line naming the case it retires. Tables MUST appear only inside an `example-table` case as rows under one clause template. Sequence steps MUST be observations (`action → observation`) under one role and one oracle. Cards MUST NOT contain step-level test-driven-development scripts; the TDD Skill derives grouped RED/GREEN from Cases by role and shapes tests by kind. A `deferred RED until X.Y` case MUST be observed red in its own task, MUST be excluded from that task's GREEN set, and task `X.Y` MUST exist in `task_graph` and cite the case turning green. Evidence MUST be added only after actual execution. Cards MUST NOT contain the forbidden placeholder phrases listed in the task authoring reference. Before a plan is accepted, a three-item self-review — requirement coverage, placeholder scan, cross-task symbol consistency — MUST be recorded in `attachments/data/planning-validation.md`. The task authoring reference MUST hold the single preflight text, and `openspec-apply-change` MUST apply it at two moments without restating it: at plan acceptance inside its `Ensure plan` step, where a failing plan is repaired before any node is selected, and at task start, where preflight MUST refuse to start a task whose mandatory labels are missing, whose Cases lack a `new RED` case or a valid header line, that uses an undefined role or kind word, whose `deferred RED` target is absent from the graph, or whose Interfaces lack a fence when a symbol is named. Tasks MUST NOT be sized by fixed word, test, file, time or process-launch quotas; mandatory labels are information requirements, not size targets.

#### Scenario: Execute a detailed task card

- **WHEN** a task has non-trivial interfaces, state transitions or failure behavior

- **THEN** its card supplies the actual signatures, named literal cases and decisions needed to implement and judge completion

    Code fences, lists, links and images stay in the unindented body under
    the task heading. Label presence alone does not establish planning
    completeness; the preflight checks presence, the reviewer checks content.

#### Scenario: Keep a simple task card small

- **WHEN** a document or migration task's outcome, Files and Verification already settle all relevant decisions

- **THEN** the card omits Interfaces and Cases and adds no empty scaffolding

    Shortness is a consequence of a self-contained contract, not a target that
    permits missing acceptance conditions.

#### Scenario: Recognize an oversized task before continuing

- **WHEN** a pending task accumulates independently acceptable deliverables, hidden prerequisite interfaces or a proving command that cannot establish its whole outcome

- **THEN** the coordinator revises the invalid boundary through evidence-backed Replan

    Completed nodes and valid evidence remain intact. New outcomes receive new
    IDs. Shared files constrain scheduling without inventing semantic edges.
    A routine test failure or a long but bounded card alone does not require
    Replan.

#### Scenario: Plan a feature group before implementation

- **WHEN** an author prepares a behavior task for a zero-context implementer

- **THEN** the card names concrete missing-behavior cases tagged new RED and existing regression controls, and the TDD Skill orders test preparation, observed RED, bounded implementation and grouped GREEN from them

    One direct Verification command has an exact working context, nonempty
    case selection and completion criteria; shared proof retains task-specific
    case mapping. Kind decides the test's inner shape: a sequence is one test
    with several assertions, an example-table is normally one parameterized
    test whose rows red and green together, a measurement is normally a
    boundary compared to a checked-in baseline.

- **AND** templates and lifecycle preflight judge information sufficiency rather than matching prescribed wording beyond the mandatory labels and the case header line

#### Scenario: Block a thin card at apply time

- **GIVEN** a migrated plan whose card lacks an Interfaces fence or any new RED case

- **WHEN** `openspec-apply-change` selects that task

- **THEN** preflight refuses to start it and names the missing element; the owning Change repairs the card through `openspec-update-change`

    Syntax migration never fills in interfaces or cases on another Change's
    behalf.

#### Scenario: Express a lifetime, a matrix and a bound in one Cases block

- **GIVEN** a behavior card whose Cases block opens with `Setup:` and lists a `new RED · sequence` case of three `action → observation` steps, a `boundary · example-table` case with a clause template and five homogeneous rows, and a `boundary · measurement` case with Corpus, Metric, Bound and Baseline

- **WHEN** plan-acceptance preflight runs

- **THEN** the card is accepted: every header matches the grammar, one case is `new RED`, no word needs a definition

    The Rust parser projects the same `files`, `fileRoles`, `after` and
    `ready` as for a Form 2 card; Cases content is never machine-read.

- **BUT** the same block with a table outside an `example-table` case, or a sequence whose steps carry their own role tags, is rejected by preflight naming the case

#### Scenario: Define a custom role or kind in the card

- **GIVEN** a Cases block containing `Roles:` with `` `quarantined` — runs and is recorded; neither red nor green counts toward this card; re-enabled by 3.2`` and `Kinds:` with `` `protocol` — message round-trip table; oracle is the checked-in .trace file``

- **WHEN** a case header reads `2. **Handshake** — quarantined · protocol`

- **THEN** preflight accepts the case and the TDD Skill treats it as the definition states

    Standard roles and catalog kinds never need a definition; the definition
    travels with the card so a zero-context implementer needs no other file.

- **BUT** a header `3. **Retry** — flaky` with no `Roles:` entry for `flaky` fails preflight with the undefined word named

#### Scenario: Defer a red case to a later task

- **GIVEN** task `1.1` lists `4. **ShutdownDestroysLeftovers** — deferred RED until 2.1` and `2.1` exists in `task_graph`

- **WHEN** `1.1` is applied and later `2.1` is applied

- **THEN** `1.1` records the case observed red and completes with its other `new RED` cases green; `2.1` Evidence cites `ShutdownDestroysLeftovers` turning green

    A deferred case that never turns green is a planning defect of the plan,
    not of `1.1`.

- **BUT** `deferred RED until 9.9` with no `9.9` in the graph fails plan-acceptance preflight

#### Scenario: Plan a created Change inside apply

- **GIVEN** a Change created by `openspec-create-change` whose `openspec.status` reports proposal and tasks missing, and whose `attachments/drafts/handoff.md` names every requirement change, owned file and task boundary

- **WHEN** `openspec-apply-change` runs

- **THEN** its `Ensure plan` step writes proposal, any durable-behavior specs delta, design when a non-obvious decision exists, and `tasks.md`, runs the plan-acceptance preflight from the task authoring reference, records `planning-validation.md`, validates strictly, and only then selects Ready nodes

    Names come from copied design terminology or an optional legacy glossary; a new non-obvious decision
    becomes one indexed talk in the same edit; the draft `log.md` is never
    pasted.

- **BUT** when the handoff lacks a user-owned decision or a public name that no glossary or convention settles, the step stops and reports instead of deriving it; `Naming assumed` belongs to implementation steps only

### Requirement: Flexible Scenario Card authoring

Maintained behavioral specifications SHALL use real root Requirement and Scenario headings, with direct non-empty WHEN and THEN clauses. GIVEN, AND and BUT MAY add meaningful state or guarantees. Every authored clause SHALL carry the durable detail needed to make its case unambiguous; a self-contained clause MAY omit detail that adds no information. Direct content and wrapped clause continuations MUST use four spaces, with deeper Markdown owned by its immediate container. Detail MUST NOT drift into an unowned Scenario-wide tail.

Scenario content MAY include prose, headings, tables, code, lists, quotes, links, images and other Markdown without a fixed field matrix or length target. Specs MUST retain durable observable behavior and examples, not source-edit steps, Task state or transient execution evidence. Parsing and synchronization MUST preserve complete raw cards and their relative links; nested example headings MUST NOT create Requirement, Scenario or delta-operation structure. Both validation profiles SHALL check authored scenarios without requiring optional specifications to exist.

#### Scenario: Enrich individual behavior clauses

- **GIVEN** a durable case needs explicit identity, input, state or boundary information

- **WHEN** an author writes or modifies its behavior clauses

    Each useful detail is attached to the exact GIVEN, WHEN, THEN, AND or BUT
    that it qualifies. A wrapped behavior sentence itself uses at least four
    spaces on every continuation line.

- **THEN** the card retains enough concrete information to distinguish accepted and rejected behavior

    A table may map literal inputs to results; code may demonstrate a public
    call or input/output fixture; an ordered list may explain durable protocol
    precedence. None of these forms implies task execution.

- **AND** a same-name modified scenario replaces the complete named card during semantic synchronization

    Still-valid clause content is repeated in the replacement; unspecified
    scenarios remain unchanged. The CLI does not implement automatic merging.

#### Scenario: Keep a simple behavior scenario compact

- **WHEN** a self-contained trigger and result have no additional useful durable information

- **THEN** the card may remain a pair of clear clauses without boilerplate

#### Scenario: Reject detached or missing behavior

- **GIVEN** a card lacks a direct WHEN or THEN, or places its explanation outside every clause

- **WHEN** either validator profile examines the authored scenario

- **THEN** validation reports the structural defect without editing the document

    A WHEN/THEN shown only in a quote, nested list or code fence does not satisfy
    the direct clause requirement. Two-space or lazy unindented continuations
    are invalid even when a permissive Markdown renderer would display them.

### Requirement: Material implementation issue history

`attachments/implementation/` MUST contain only material technical issue lifecycles. A problem is material when it blocks or repeats, needs non-obvious investigation, invalidates prior evidence, crosses a task/module/repository, changes approach, requires non-trivial Critical/Required Review repair, needs a durable handoff, preserves a failed path likely to recur, forces a manual bypass of a maintained Harness route, or is explicitly admitted by the user as a Harness self-evolution problem. Multiple symptoms with one root cause and repair MUST remain one issue. Routine TDD RED, first expected failures, immediate corrections, transient timing variation, unverified preferences, progress summaries, and ordinary final success MUST NOT create issues.

New issues MUST use `issue_schema: openspec-material-issue-v2` with an exact issue ID, `open | resolved | rejected | superseded` status, source evidence, affected Task IDs, and creation time. They MUST retain the detailed Symptom, Investigation Log, Root Cause, Disposition, RED/GREEN evidence with proof limits, and Links body. Open issues MUST omit terminal fields. Resolved or rejected issues MUST provide resolution time and evidence reference. Superseded issues MUST provide resolution time and an exact `harness/<change>#issue-<id>` reference to an existing v2 issue. Historical issue records without `issue_schema` remain readable legacy v1 records and MUST NOT be rewritten.

#### Scenario: Resolve an investigated root cause
- **WHEN** a material issue is resolved
- **THEN** one indexed v2 issue records source and affected tasks, chronological investigation, demonstrated root cause, disposition, exact RED/GREEN evidence, rejected evidence when material, and what the evidence proves and does not prove

#### Scenario: Reject or supersede work explicitly
- **WHEN** an admitted issue will not be repaired in its owning Change
- **THEN** it becomes rejected with evidence or superseded by an exact existing v2 issue rather than being deferred in prose

#### Scenario: Keep routine execution lightweight
- **WHEN** a first expected test failure is fixed directly by the planned implementation
- **THEN** evidence remains with the task and no implementation attachment is created

### Requirement: Evidence-gated replan

A Review finding MUST NOT directly trigger Replan. Harness may apply a Replan only after evidence proves that a requirement, design, acceptance condition, task boundary, dependency edge, or completion record is invalid, and it MUST preserve a lightweight immutable semantic-diff record.

#### Scenario: Fix within the current plan
- **WHEN** a finding exposes only an implementation defect inside the current task
- **THEN** the system fixes it in that task or an implementation issue without creating a Replan

#### Scenario: Replace an invalid plan branch
- **GIVEN** the relevant evidence has been reproduced or independently verified against the accepted planning artifacts
- **WHEN** verified evidence invalidates part of the existing Task DAG
- **THEN** the system records old-task dispositions, preserves valid work, updates current artifacts/tasks, and creates one `status: applied` Replan file
- **AND** the Replan records the affected behavior, task and edge changes, retained work, and resulting canonical plan
- **BUT** a finding, severity label, preference, or implementation defect inside an otherwise valid task does not by itself authorize Replan

    > Inputs: The exact evidence reference and the affected requirement, design boundary, acceptance condition, task boundary, dependency edge, or completion record.
    >
    > Observables: One immutable applied Replan records old-task disposition and a bounded semantic diff, while the current canonical artifacts and Task Graph contain the repaired truth.
    >
    > Boundaries: Valid completed work remains preserved; local implementation repair stays in its owning task or material issue when planning truth remains valid.
    >
    > Verification: Replan protocol fixtures require applied-only state, old-task dispositions, preserved work, and a bounded task, edge, artifact, and path-status diff.

### Requirement: Explicit Review intake and direct closure

Harness MUST NOT start Incident Review, Final Review, or any other Review automatically from impact, diff size, task count, a local defect, or a verification result. When no Review has been explicitly requested, verified work MAY proceed directly to completed closure and archive after tasks, durable-spec sync, attachments, and evidence are ready; it MUST NOT create a placeholder Review or a not-required Review disposition. A problem found during implementation or verification SHALL be diagnosed and repaired inside the current task when planning truth remains valid, or SHALL trigger the evidence-gated replan path when requirements, design, verification, artifacts, or Task DAG truth became invalid.

The user or an external agent MAY explicitly request a fixed-snapshot Review. Harness SHALL register that Review with a unique file and materializable immutable content reference, reproduce and triage its findings, and MAY run the assigned reviewer asynchronously when useful; asynchronous execution is optional and does not become the default lifecycle. A finding never directly triggers replan. Before completed archive, every explicitly registered Review file MUST be `closed` or `superseded`, no Critical or Required finding may remain open or deferred, and resolutions MUST retain evidence. Review records MUST preserve actual lifecycle times, concrete findings, and detailed resolution history without a report line limit.

The single `code-review` Skill owns the reviewer's stance. A reviewer MUST read tests and task cards before code, MUST inspect other revisions read-only, MUST NOT dispatch further reviewers, and MUST label a finding whose defect lies in the requirement, design, or task card as a planning finding without prescribing Replan. Severity MUST use the retained names with fixed meaning: `Critical` is wrong behavior, data or safety loss, or a broken contract that blocks; `Required` must be fixed before the Change closes but does not endanger the snapshot's correctness claim; `Advisory` is optional and MAY be deferred only with a named follow-up. A re-review MUST check only the previous findings' resolution conditions against a new immutable snapshot; a new scope MUST become a new Review. The coordinator MAY fan one snapshot out into several Reviews by area with distinct reviewers and non-overlapping scopes, MUST clarify every ambiguous finding before repairing any, and MUST route a finding that contradicts a user-owned decision to the user when attended or to `openspec-update-change` when unattended.

#### Scenario: Archive verified work without Review

- **WHEN** every task and required verification passes, durable truth is synchronized, closure evidence is ready, and no Review was explicitly requested

- **THEN** Harness prepares completed closure and archives directly without creating a Review record or impact classification ceremony

#### Scenario: Replan a discovered planning failure

- **WHEN** implementation or verification evidence invalidates a requirement, design boundary, verification contract, required artifact, or Task DAG edge

- **THEN** Harness applies the replan protocol, preserves valid work, repairs the new plan, and verifies again without starting Review automatically

#### Scenario: Process an explicitly requested Review

- **WHEN** the user or an external agent requests Review of an exact snapshot

- **THEN** Harness registers and triages the Review, optionally delegates it asynchronously, and blocks archive only until that explicit Review is resolved or superseded

- **AND** the Review is bound to one materializable immutable snapshot and retains its actual assignment, completion, and closure lifecycle

- **BUT** report arrival or finding severity does not trigger Replan until evidence proves that accepted planning truth is invalid

    > Context: Review is an explicit intake path rather than automatic lifecycle cadence.
    >
    > Inputs: The requesting authority, Review kind, exact immutable snapshot reference and digest, and any already available verification evidence.
    >
    > Observables: One unique Review file records concrete findings, dispositions, repair evidence, any required re-review, and a final `closed` or `superseded` state.
    >
    > Boundaries: An asynchronous reviewer writes only its assigned Review file; disjoint work may continue, but the reviewed work cannot archive while its explicit Review remains unresolved.
    >
    > Verification: Review protocol fixtures accept valid closed and superseded lifecycles and reject invalid requesters, snapshots, timestamps, verdicts, open blocking findings, and unowned deferred advice.

#### Scenario: Preserve detailed Review evidence

- **WHEN** findings require extensive evidence, impact analysis, resolution conditions, or re-review history

- **THEN** the Review file retains the necessary detail without a line cap while avoiding redundant verification already supplied with the snapshot

#### Scenario: Classify a finding by fixed severity

- **WHEN** the reviewer records a finding against the assigned snapshot

- **THEN** the finding carries `Critical`, `Required`, or `Advisory` with the fixed meaning, file or record location, observation, impact, evidence or reproduction, and a concrete resolution condition

    | Severity | Meaning | Closure effect |
    |---|---|---|
    | `Critical` | Wrong behavior, data or safety loss, or a broken contract | Blocks; must be resolved |
    | `Required` | Must be fixed before the Change closes; does not endanger the correctness claim | Blocks until resolved or rejected with evidence |
    | `Advisory` | Optional improvement | May be deferred only with a named follow-up |

- **AND** a finding whose defect is in the requirement, design, or task card is labelled a planning finding and does not prescribe Replan

- **AND** the Review lists what was checked and found sound so a re-review can bound its scope

#### Scenario: Re-review a repaired snapshot

- **WHEN** the coordinator requests a re-review after repairing findings

- **THEN** the re-review checks only the previous findings' resolution conditions against a new immutable snapshot and appends its result under each original finding

- **BUT** a request that widens the scope becomes a new Review file rather than another round of the same chain

#### Scenario: Fan a snapshot out by area

- **WHEN** one snapshot is too broad for a single reviewer pass

- **THEN** the coordinator assigns several Review files with distinct reviewers and non-overlapping scopes before any reviewer starts

- **BUT** a reviewer never dispatches another reviewer for part of its own assignment

#### Scenario: Triage a finding that contradicts a user-owned decision

- **WHEN** a finding asks to reverse a decision recorded in the design or an indexed talk

- **THEN** the coordinator does not repair it locally; attended, it puts the decision to the user, and unattended, it parks the finding through `openspec-update-change`

- **AND** every ambiguous finding is clarified before any finding in the same Review is repaired

### Requirement: Deterministic OpenSpec package

The distributed OpenSpec executable MUST be located at `.agents/skills/openspec/bin/openspec.exe` and MUST be reproducible from the parent-recorded `Tools/openspec` commit, immutable `v0.10.0` tag layered after the preserved `v0.9.0` and earlier snapshots, locked build commands, byte-identical isolated rebuild gate, and release manifest. Existing candidate tags MUST NOT be moved to impersonate a repaired snapshot. The parent repository MUST commit only the final accepted package once per release and MUST NOT commit intermediate or candidate executable builds.

#### Scenario: Validate a packaged release

- **WHEN** installation health checks validate the OpenSpec package

- **THEN** the executable version, SHA-256, source commit, annotated tag object/target, command-document set, release gates, and manifest agree

#### Scenario: Preserve parent binary history

- **WHEN** an OpenSpec release is iterated before final acceptance

- **THEN** candidate executables remain outside parent history and the final accepted package enters the parent repository in exactly one release commit

### Requirement: English OpenSpec maintenance surface

All maintained OpenSpec source documentation, Skills, command references, project workflows/templates, manifests, current specs, active changes, attachments, and new archive records MUST use English. Files explicitly named with `_ZH` MAY remain temporarily and MUST be the only localization exception.

#### Scenario: Reject a non-English maintained record
- **WHEN** package validation scans an ordinary maintained OpenSpec path or supported text file containing a Han character
- **THEN** validation fails and reports the exact relative file and line

#### Scenario: Preserve an explicit localization file
- **WHEN** the same scan encounters a file whose name contains `_ZH`
- **THEN** that file is excluded without exempting sibling files or parent directories

### Requirement: Harness dogfooding feedback

Harness SHALL expose cheap visible feedback without expanding authorized scope automatically. harness.status MUST return installation/workspace identity plus a small updates.json revision/published_at/summary/affected_skills notice. Missing or corrupt notice MUST appear as a nonfatal issue. The agent shows the notice once per conversation revision at entry/resume; no watcher, seen database or directory hashing is required.

#### Scenario: Collect and group observations

- **WHEN** evidence reveals recurring workflow friction or a concrete explanation/tool defect
- **THEN** harness.observe appends bounded versioned raw JSON with actual SourceRef and optional DedupKey/OwnerDraftId under ignored Saved/Harness/Observations
- **AND** the human-readable INBOX is derived from raw occurrences and triage dispositions; mutations may regenerate it while queries never write
- **BUT** ordinary compilation failures, expected RED and cancellation are not inherently workflow defects

#### Scenario: Confirm a batch before improvement

- **WHEN** an improvement batch is presented
- **THEN** the user selects, defers or dismisses bounded scopes; harness.evolution.triage retains exact observation IDs, DecisionSource and Scope
- **AND** a resolved result requires a prior selected scope plus Result and Evidence while retaining original authority; new recurrence remains pending

#### Scenario: Preserve an immutable archive

- **WHEN** a new workflow problem is discovered after archive
- **THEN** it enters the inbox or linked draft without changing the archive or automatically creating a successor Change
- **AND** any formal repair uses user-led convergence and both handoff Gates; already authorized direct maintenance can proceed in its accepted scope

#### Scenario: Retain terminal evidence boundaries

- **WHEN** feedback is explicitly admitted as a material issue of an authorized active Change
- **THEN** its existing v2 issue lifecycle and exact terminal evaluation apply
- **BUT** merely collecting an observation neither blocks closure nor starts Review/Replan

### Requirement: Fail-closed active evolution closure

Harness SHALL evaluate terminal closure only for one exact active Change and one explicit `completed`, `abandoned`, or `superseded` closure kind. It MUST consume the portable OpenSpec TaskPlan rather than parse Task DAG YAML. A completed closure MUST have a valid non-empty TaskPlan whose every node is complete; incomplete closure kinds MAY retain incomplete nodes for explicit disposition by the portable closure manifest. An early abandoned or superseded Change with no tasks.md MAY close without inventing a TaskPlan, while a present invalid or empty plan MUST block closure. Ordinary status MAY inspect immutable archives, but terminal policy MUST reject an archived target and leave historical audit to strict archived validation.

The public archive mutation MUST enforce the terminal gate using the exact closure file kind and current active inputs immediately before the move. The kind MUST be an explicit root discriminator in plain/quoted YAML or JSON; the checked closure bytes MUST be the bytes consumed by the native archive operation. A previous successful query or alternate casing of a route MUST NOT bypass a mutation gate.

Active material issues and Reviews MUST be discovered recursively and validated against the exact active TaskPlan, attachment index, lifecycle schema, evidence body, timestamps, and terminal disposition. Active schema-less issues or Reviews MUST NOT receive historical compatibility. A superseded issue MUST reference one exact active, indexed, non-superseded v2 owner with a reciprocal source reference. Review absence SHALL remain valid, while any existing Review MUST be closed or superseded with no open or deferred Critical/Required finding.

The canonical workflow evaluation MUST name the requested closure kind, include a lowercase SHA-256 of every ordinary active Change input except itself, and be captured no earlier than the latest terminal issue or Review event. Harness SHALL report the current input digest during ordinary exact status so the evaluation can be written last. Any later input mutation MUST make the evaluation stale and block terminal closure.

#### Scenario: Reject an archive without current matching evaluation

- **WHEN** a public archive request has missing, stale, failed or wrong-kind terminal evaluation
- **THEN** it fails before changing the active manifest or moving the directory, even if native closure validation alone would pass
- **AND** a valid current evaluation permits the exact requested closure without another human confirmation

#### Scenario: Reject incomplete completed closure
- **WHEN** terminal evaluation requests `completed` for an active Change whose portable TaskPlan is missing, invalid, empty, or contains an incomplete node
- **THEN** Harness reports the exact task blocker and does not declare the Change closure-ready

#### Scenario: Reject stale workflow evaluation
- **WHEN** an active Change input differs from the digest recorded by its passed workflow evaluation or its evaluation predates a terminal issue or Review event
- **THEN** terminal evaluation fails until current evidence is captured last with the requested closure kind

    > Observables: Ordinary exact status exposes `CurrentInputSha256`, the recorded digest, evaluation freshness, and bounded closure blockers.

#### Scenario: Reject unfinished active evidence
- **WHEN** an active material issue or existing Review is schema-less, malformed, unindexed, task-invalid, time-invalid, open, improperly superseded, or retains an open/deferred Critical or Required finding
- **THEN** terminal evaluation rejects the exact evidence owner without changing its files or starting a Review automatically

#### Scenario: Preserve immutable archive compatibility
- **WHEN** a caller inspects an archived Change containing historical evidence formats
- **THEN** ordinary evolution status remains read-only and terminal evaluation directs the caller to strict archived validation instead of applying new active-record requirements or rewriting history

### Requirement: Progressive harness knowledge promotion

Reusable harness knowledge MUST be loaded progressively and promoted explicitly. Change attachments own current evidence; capability-side `knowledges/` owns stable reusable guidance; project instructions own only cross-capability invariants. Every capability knowledge directory MUST have one `INDEX.md` that links every knowledge file exactly once with summary, served requirement/capability, source, and status. Archive MUST NOT promote knowledge implicitly.

#### Scenario: Promote a stable learning
- **WHEN** a finding is evidence-backed, remains valid after repair and verification, applies beyond one task, and changes future agent decisions
- **THEN** closure copies a concise generalized record into the Harness capability knowledge and indexes it without copying transient logs, hashes, or incident chronology

#### Scenario: Retain one-off evidence locally
- **WHEN** an observation is specific to one failure, machine, snapshot, or temporary workaround
- **THEN** it remains in the change Review/implementation/data attachment and is not loaded as durable harness knowledge

#### Scenario: Load capability knowledge progressively
- **WHEN** a later task needs reusable guidance from a capability
- **THEN** it reads that capability's knowledge INDEX and loads only the linked current file needed by the task

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

#### Scenario: Select a broader Harness profile
- **WHEN** an agent chooses among focused tests, `Quick`, `Performance`, and `Integration`

    > Inputs: The demonstrated affected surface and any explicit user or release requirement control the choice.
- **THEN** it selects the profile whose contract matches the demonstrated impact

    > Details: The escalation rules are:
    >
    > 1. `Performance` applies to performance contracts or suspected performance regressions.
    > 2. `Integration` applies to changed cross-component integration boundaries.
    > 3. `Quick` applies when changes span multiple Harness core groups, the affected surface cannot be bounded reliably, or the user explicitly requests broader regression.
- **BUT** profile availability does not make all profiles unconditional daily gates

    > Boundaries: A focused static-contract change does not acquire an unrelated full Harness or Unreal gate.

#### Scenario: Select Unreal verification
- **WHEN** a change affects a Harness `ue.*` route

    > Inputs: Route implementation, native-plan rendering, fixture coverage, and the presence or absence of product-code impact determine the initial scope.
- **THEN** it first runs the route's focused fixture or protocol proof

    > Observables: The proof covers the exact arguments, envelope, persisted evidence, or status behavior changed by the route.
- **AND** it launches the matching Unreal operation only when the actual Unreal behavior cannot be proven by the fixture, product code is affected, release policy requires it, or the user explicitly requests it

    > Boundaries: Real Unreal startup is an evidence-selected validation surface, not an automatic consequence of editing a `ue.*` route.

#### Scenario: Complete and archive a guidance-only Change
- **WHEN** a completed Change affects only Skills, Markdown, templates, specifications, or their static contracts

    > Inputs: The changed owners and their direct static or protocol fixtures bound completion verification.
- **THEN** completion uses the owning static or protocol tests plus strict OpenSpec validation

    > Observables: The final evidence identifies exact checks, results, and the content snapshot they prove.
- **AND** post-archive checking adds strict archived validation and the smallest non-destructive lifecycle check without repeating unrelated tests

    > Verification: The archived record validates strictly and no active Change remains unexpectedly.
- **AND** final evidence records tests actually run and heavier gates intentionally omitted with their reasons

    > Details: Omitted suites remain explicit evidence decisions rather than silent gaps.

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

### Requirement: Consistent maintained project guidance

The root `AGENTS.md` SHALL be the sole canonical project-level agent entry and SHALL contain only stable, cross-capability invariants needed to route work safely. Detailed architecture, commands, lifecycle procedures, validation selection, implementation rules, mutable counts, reference inventories, and history MUST remain in their owning Skills, OpenSpec specifications, source, or existing indexes rather than being copied into the root entry. A second root language mirror MUST NOT be required.

The canonical entry and live Harness-facing Skills SHALL agree that project Skills are enabled, Harness is the project workflow entry, the selected execution workspace and canonical record root are authoritative, Codex `/goal` is continuation rather than a repository mode, Review begins only on explicit request, ordinary routes run in the current PowerShell 7 process, intentional child `pwsh` hosts are bounded exceptions, and Unreal operations use `ue.*` routes without a root `Tools` wrapper fallback.

#### Scenario: Enter the project through maintained guidance
- **WHEN** an agent opens the root project guidance

    > Inputs: The root entry supplies stable cross-capability policy and links, not a snapshot of mutable implementation detail.
- **THEN** the sole root `AGENTS.md` provides the stable routing and authority boundaries needed to select the owning Skill, current Change, specification, or index

    > Observables: The entry routes to `.agents/skills/README.md`, Harness and OpenSpec Skills, `openspec/specs/`, and `Reference/README.md` without reproducing their volatile detail.
- **AND** focused static checks reject a second root Agent guide and representative architecture inventories, mutable test counts, reference-repository catalogs, historical milestones, or detailed command tutorials in the canonical entry

    > Verification: The project-entry fixture checks both required routing anchors and prohibited heavyweight content.
- **BUT** immutable OpenSpec archives and subsystem-owned guidance such as `Wiki/Agents_ZH.md` remain outside this single-entry cleanup

    > Boundaries: Historical evidence and subsystem documentation are not alternate root project instructions.

#### Scenario: Invoke Harness in an existing PowerShell session

- **GIVEN** a caller already runs PowerShell 7 Core
- **WHEN** the caller imports Harness and dispatches an ordinary route
- **THEN** the route executes in that current process without launching another PowerShell host
- **BUT** an isolated test, hook/native fixture, or managed Unreal worker may intentionally launch a bounded child `pwsh` process

#### Scenario: Run an Unreal operation

- **WHEN** maintained guidance directs a build, Automation test, suite, commandlet, status, progress, or cancellation operation
- **THEN** it uses the matching Harness `ue.*` route for the exact selected workspace and does not offer a root `Tools` PowerShell wrapper as a fallback

### Requirement: Reusable PowerShell entry

Harness SHALL require PowerShell 7.0 or later with the Core edition and SHALL support repeated Workspace, Git, observation, OpenSpec, and Unreal invocations directly in one caller session without polluting caller location or shared global state. Ordinary route dispatch MUST NOT launch a redundant PowerShell process. Intentional child `pwsh` processes MAY be used only where process isolation or lifetime ownership is part of the declared contract, including test hosts, Git hooks or native fixtures, and Harness-managed Unreal workers. Every invocation SHALL return an independent run ID and the common result envelope. Session-local caches MAY retain bounded stable facts but MUST NOT cache dirty state, branch tips, authorization decisions, or mutation preconditions.

#### Scenario: Reuse one PowerShell 7 session

- **WHEN** Harness commands run repeatedly in one supported session
- **THEN** leaf modules remain reusable in that process, caller location is restored, every invocation has an independent run ID, and no Windows PowerShell 5.1 or redundant child-shell path is exposed

#### Scenario: Start an intentional isolated process

- **WHEN** a declared test-isolation, hook/native-fixture, or Unreal-worker boundary requires a child PowerShell process
- **THEN** Harness uses `pwsh`, keeps the child bounded to that operation, and does not redefine ordinary route dispatch as process spawning

#### Scenario: Observe mutable facts

- **WHEN** branch, dirty-state, authorization, or process facts change between invocations
- **THEN** Harness reads the current fact instead of trusting a stale cache

### Requirement: Autonomous execution within authority

Harness SHALL autonomously investigate, select in-scope technical solutions, update/replan, implement, verify, and resolve explicitly registered Review findings in the selected workspace without interrupting the user for ordinary technical choices. It MUST stop when progress requires new authority, risks destructive user-data changes, requires integration, push, publication, or removal without authorization, lacks external credentials, or faces irreconcilable explicit instructions. This autonomy is independent of whether Codex `/goal` is active.

#### Scenario: Resolve an in-scope Review finding
- **WHEN** a Required finding can be repaired within the accepted scope and current authority
- **THEN** Harness completes triage, repair, verification, and re-review in the same selected workspace without requesting an ordinary technical decision

### Requirement: Ready-to-deliver finish state

Successful work MUST reach verified and closure-ready state while preserving its selected workspace and plugin branches for inspection. Queue closure SHALL commit exact owned plugin changes; primary-repository commits SHALL remain user-directed, and recorded uncommitted host/Harness work MUST NOT alone block completed closure. Any explicitly registered Review MUST also be resolved or superseded. `git.commit` MAY establish scoped Git closure without claiming verification completion. `git.integrate` MAY run only after explicit user authorization against the exact verified source workspace and HEAD. `git.push` and `workspace.remove` MUST remain distinct later operations requiring separate explicit user intent.

#### Scenario: Finish in the selected workspace
- **WHEN** all tasks and verification complete and any explicitly registered Review is resolved
- **THEN** Harness reports commits, evidence, excluded tests, elapsed workflow evaluation, and delivery options without automatically integrating, pushing, or removing a workspace

#### Scenario: Integrate after explicit authorization
- **WHEN** the user explicitly requests local integration
- **THEN** the coordinator checks the exact reviewed source HEAD, preserves unrelated target changes, integrates affected submodules before the parent, and leaves remote state and source workspace unchanged

### Requirement: No Codex project hooks

The repository does not register Codex project hooks. Conversation recording and execution continuation MUST remain available through public Harness routes (`harness.draft.record`, `harness.conversation.record`, `harness.execution.start` / `checkpoint` / `status` / `input`) on Cursor, Grok, Codex, and other hosts. Unbound sessions MUST NOT require a hook adapter or Python worker. The agent's public Harness workflow MUST remain responsible for continuation, feedback handling and source reconciliation.

#### Scenario: Use Harness without project hooks
- **WHEN** any host uses Harness
- **THEN** all cross-client workflow routes remain functional without `.codex/hooks.json` or a Codex hook adapter

### Requirement: Visible OpenSpec maintenance state

Harness SHALL expose a read-only `openspec.maintenance.status` route that compares the packaged executable and release manifest with the recorded `Tools/openspec` source submodule state. It MUST report source path, source HEAD, source dirtiness, packaged version/hash, and alignment or maintenance-needed reasons without fetching, rebuilding, tagging, replacing, or committing the executable. Upgrade execution remains an explicit future OpenSpec maintenance Change.

#### Scenario: Inspect an aligned package
- **WHEN** the packaged manifest, executable identity, and recorded source commit agree
- **THEN** maintenance status reports aligned with the exact source and package identities

#### Scenario: Detect maintenance work
- **WHEN** source state, manifest, or package identity differs
- **THEN** the route reports evidence and recommends a separate maintenance Change without mutating either repository

### Requirement: Canonical Harness public identity

The maintained live framework SHALL use `Harness` as its only public identity. Its entry Skill and PowerShell module SHALL be located beneath `.agents/skills/harness`; public and internal PowerShell symbols SHALL use `Harness`; framework-owned routes SHALL be `harness.status`, `harness.observe`, and `harness.evolution.status`; environment variables SHALL use `HARNESS_`; and new schemas, mutexes, leases, temporary identities, Saved paths, LocalAppData paths, and default commit scopes SHALL use the matching Harness form. The old module, symbols, routes, environment variables, and commit scope MUST NOT remain as aliases.

Readers MAY retain narrow old-name constants only to discover and migrate persisted machine-local data or inspect immutable historical evidence. New writes MUST use `Saved/Harness`, `TDGameStudio/Harness`, and `harness-*` record identities. `harness.evolution.status` MUST continue to read `hardness-workflow-evaluation-v1` only from immutable historical records while new evaluations use `harness-workflow-evaluation-v1`.

#### Scenario: Use the renamed framework
- **WHEN** a caller imports the maintained entry module and invokes framework routes
- **THEN** only Harness module, symbol, route, environment, schema, and output identities are exposed

#### Scenario: Reject the mistaken public API
- **WHEN** a caller attempts an old Hardness import, function, route, or environment-based selection after cutover
- **THEN** the public operation is unavailable rather than silently redirected through a compatibility alias

#### Scenario: Read immutable historical evidence
- **WHEN** evolution status inspects a pre-cutover immutable archive or old ignored observation root
- **THEN** it may parse the recognized historical record without changing it and all newly written evidence still uses Harness identity

### Requirement: Harness live OpenSpec namespace

The live OpenSpec domain, current specifications, active Changes, and maintained configuration SHALL use the `harness` namespace. The namespace change MUST use the portable OpenSpec domain-move operation so stable object identity and old-ID aliases are retained. Existing archive paths under `openspec/archive/changes/hardness/` MUST remain immutable.

#### Scenario: Move the live domain
- **WHEN** the naming cutover is applied
- **THEN** live domain/spec/change manifests resolve canonically beneath `harness` while old IDs remain CLI aliases

#### Scenario: Preserve historical archives
- **WHEN** the live domain moves to Harness
- **THEN** existing Hardness archive directories and contents remain byte-for-byte historical records

### Requirement: Semantic Change naming

New project OpenSpec Changes SHALL use a canonical `<domain>/<type>-<scope>-<outcome>` identity whose leaf is lowercase portable kebab-case. The type MUST be `feature`, `fix`, `refactor`, `improve`, `docs`, `test`, or `chore`; `feature` and the Git commit type `Feat` remain intentionally distinct. Harness MUST reject a nonconforming create target or move target before invoking the portable OpenSpec CLI, while the generic CLI remains free of project-specific semantic policy.

#### Scenario: Create a conforming Change
- **WHEN** a caller creates a Change through Harness with a registered domain and a semantic type, scope, and outcome
- **THEN** Harness permits the portable CLI to create the canonical active identity

    > Inputs: A registered domain and a lowercase Change leaf whose first segment is an allowed semantic type and whose remaining segments provide a scope and outcome.
    > Observables: The resulting active Change resolves at the requested canonical ID and normal OpenSpec validation remains available.
    > Boundaries: This naming rule is an AngelscriptProject policy and does not change portable CLI syntax for other projects.
    > Verification: Harness route fixtures cover all allowed types and representative nested outcomes.

#### Scenario: Reject a nonconforming target
- **WHEN** a caller asks Harness to create or move a Change to a leaf with an unknown type, `feat`, uppercase text, or no distinct scope and outcome
- **THEN** Harness returns a structured naming failure before the portable CLI mutates any record

    > Observables: No target directory or manifest is created or moved, and the diagnostic states the required form and allowed types.
    > Verification: Negative create and move fixtures assert both the failure envelope and an unchanged record tree.

#### Scenario: Repair an active legacy name
- **GIVEN** an active Change predates semantic enforcement and has a nonconforming source identity
- **WHEN** the caller moves it through Harness to a conforming target
- **THEN** the source remains acceptable only for resolution and the conforming target is permitted

    > Boundaries: The exception applies only to the existing move source; it never permits a new nonconforming target.

#### Scenario: Preserve immutable archives
- **WHEN** naming validation audits current project records
- **THEN** it checks live Changes and excludes every archived path and historical manifest from semantic renaming

    > Verification: Repository fixtures retain known pre-rule archive names byte-for-byte while an invalid active fixture is reported.

### Requirement: Bound draft conversation recording

- `harness.draft.record` MUST bind one exact workspace, session, source, draft and starting message range; support sync, read-only status and unbind; and close an old range before switching drafts.
- Recording MUST be explicit opt-in through public routes; the repository registers no Codex project hooks. New-schema bind creates optional attachments/transcript.md and INDEX, never overwrites CONTEXT; legacy log sinks stay compatible. Unbound sessions remain inert with no newest-draft guessing or cross-workspace recording.
- Source occurrences MUST retain their own identity even when text repeats. Retry MUST be idempotent, append/checkpoint writes serialized, and progress advanced only after durable append. Unsupported, changed, partial or missing source MUST expose a coverage gap; every host uses explicit source reconciliation.

#### Scenario: Retry after interrupted recording

- **WHEN** a delivered message is appended but the checkpoint write is interrupted
- **THEN** the next sync recognizes the same source occurrence and advances without another copy
- **AND** an identical message at a different source position is still recorded separately

#### Scenario: Resume with incomplete source

- **WHEN** the bound source ends in a partial JSONL line or cannot be interpreted
- **THEN** recording reports the covered boundary and gap, preserving the pending range for retry
- **BUT** recording failure does not force a new assistant turn or imply the missing final is already covered

### Requirement: Exact scoped handoff and expected exports

New Create and Replan operations MUST preview one exact target, material design/handoff and candidate/baseline revision without writes. Mutation MUST consume a Gate with actual ConvergenceSource, DecisionSource, matching create/replan decision, TargetChange and presented HandoffRevision. Create Title and Goal MUST participate in that full revision; a draft-only DraftRevision MUST NOT stand in for the Create HandoffRevision. Material changes invalidate approval; navigation/CONTEXT progress alone does not. New schema 3 origins and applied Replans MUST persist the consumed receipt and expected indexed followup identity. Historical schemas 1/2 retain accepted verification contracts without reapproval or migration.

Before asking the handoff Gate, the agent MUST follow the dedicated `harness/references/handoff-gate.md` explanation contract and visibly present the full relevant background, current and proposed architecture, terms and roles, causal/call paths, concrete changes, alternatives and consequences, uncertainty, proof and carryover. The account MUST be understandable without prior system knowledge and MUST distinguish implemented behavior from accepted plans and proposals. Relevant code, data, lifecycle and controls MUST be explained when they affect the decision. A short summary, diff, record link or passing revision check MUST NOT replace this account. The actual question MUST follow the complete presentation and visibly identify the exact operation, target, revision and immediate effect, separately from later archive/execution arrangements. Explanation quality is an agent responsibility, not a fabricated runtime approval field.

#### Scenario: Reject an altered creation request

- **WHEN** Title or Goal changes after the accepted Create preview while the draft remains unchanged
- **THEN** the old Gate cannot create the altered request; preview returns a different HandoffRevision
- **AND** route-name casing cannot expose an unguarded raw creation path

#### Scenario: Explain the full design before creating a Change

- **GIVEN** the user has requested convergence on a scoped design and its read-only preview exists
- **WHEN** the agent prepares the creation Gate
- **THEN** it explains why the change is needed, how the current system works and how the proposed system changes the same concrete path, including relevant roles, terms, diagrams, logic, tradeoffs, proof and boundaries
- **AND** only after that complete visible account does it ask the exact-version creation/discussion/park choice, without treating a file link or short overview as sufficient presentation
- **BUT** this choice does not approve draft archival or implementation startup

#### Scenario: Explain a Replan without conflating plan and completed work

- **GIVEN** evidence invalidates an existing Change's accepted plan and the user requests convergence on revised candidates
- **WHEN** the agent presents the Replan Gate
- **THEN** it explains the background and trigger, accepted architecture, actual implemented work, complete proposed architecture, affected tasks/artifacts/edges, preserved work, invalidated proof and execution return position
- **AND** the visibly marked question binds the presented candidate/baseline revision while execution remains subject to the post-handoff arrangement

#### Scenario: Keep Gate presentation distinct from transcript recording

- **WHEN** the complete Gate account is long or spans several coherent messages
- **THEN** the agent finishes that account before submitting the question, reuses the existing design/handoff or candidate records for decision truth, and does not require a separate continue request to deliver the remaining explanation
- **AND** no compulsory per-round GATE file, duplicated transcript or claim of machine-verified comprehension is introduced

#### Scenario: Hand off one scope while researching another

- **GIVEN** scope A has the user's convergence and exact Gate while the topic focuses on B
- **WHEN** A's Change is created
- **THEN** only A's selected design/handoff and confirmed export closure are frozen; topic focus and sibling work remain independent

#### Scenario: Export useful self-contained evidence

- **WHEN** the selected handoff includes design/handoff plus required research or binary attachments
- **THEN** English explanations and preserved binary bytes are exported with nested relative identity and rewritten local links, indexed once
- **AND** full CONTEXT/history and unrelated siblings are excluded; separate glossary is optional for new drafts
- **BUT** missing promised exports, duplicate index entries, path escape or broken local closure prevent Ensure plan
- **AND** new creation receipts/origins retain per-file SHA-256 expectations for non-Markdown exports; seed verification rejects altered destination bytes even after the source draft evolves or archives
- **BUT** translated Markdown retains its semantic/link contract, and historical origins without an export-digest schema retain their accepted verification contract

#### Scenario: Recover consumed creation

- **WHEN** creation is retried after its source draft evolves or archives
- **THEN** its persisted receipt identifies the already-created handoff and recovers only the exact missing expected followup without overwriting answered decisions
- **AND** a private consumed intent plus a native manifest UID/hash checkpoint can recover a missing origin marker using the same handoff identity
- **BUT** an unmarked directory without proven ownership, a changed manifest or a different retry request reports a recovery issue without claiming the directory

#### Scenario: Enforce post-handoff arrangements

- **WHEN** Create/Replan succeeds
- **THEN** a purpose handoff-followup talk asks archive/retain and now/queue/later, with actual sources and applied arrangement evidence
- **AND** no-draft uses not-applicable without presenting a fake archive choice
- **BUT** generic close, missing/corrupt/unindexed followup, deferred/superseded shortcut or replaying the post talk as Replan cannot authorize execution

#### Scenario: Keep direct work lightweight

- **WHEN** the user explicitly requests a bounded direct edit
- **THEN** no formal Change or Gate is manufactured
- **WHEN** the user requests a formal Change without a draft
- **THEN** concrete direct HandoffText/reason receives the same exact-version preview and Gate

### Requirement: Minimal project and plugin source identity

Harness SHALL generate only necessary host engineering files, targets and configuration. Host files SHALL come from the primary current working files with recorded hashes. Plugin baselines SHALL be each source repository's HEAD at creation, excluding uncommitted plugin edits; enabled necessary project-plugin dependencies SHALL be included transitively. Later preparation SHALL use those pinned baselines and MUST NOT silently overwrite source changes. A replica MUST NOT report its control repository HEAD as a project-root HEAD.

#### Scenario: Create an isolated plugin workspace
- **WHEN** the approved workspace edits Foo and only depends on Bar
- **THEN** Foo has a plugin Git worktree, Bar has a fixed source snapshot with local build outputs, unrelated plugins are absent, and the parent Git worktree inventory is unchanged

#### Scenario: Upgrade a dependency for later approved editing
- **GIVEN** a necessary plugin is a source snapshot with generated outputs
- **WHEN** approved scope requires editing that plugin
- **THEN** preparation checks original source hashes, preserves generated outputs and creates a plugin worktree at the pinned baseline; changed source stops the upgrade without deletion

#### Scenario: Query from inside a replica
- **WHEN** the working directory is the replica or one of its plugin directories
- **THEN** identity resolves the containing registered replica, including when inspecting sibling workspaces, without a drive-relative Git fallback

#### Scenario: Build a drive-mapped minimal host
- **WHEN** the generated project executes at a mapped drive root under UE 5.8
- **THEN** project-local UBT configuration disables the invalid optional parent Git working-set probe while preserving normal target compilation

### Requirement: Peripheral mutation preserves preview and workspace quiescence

An authorized workspace removal MUST automatically exclude managed runs in queued, waiting or running states, live workers even with terminal metadata, held execution leases and native activity that cannot safely be correlated. Run admission and removal MUST share an interlock from publication/startup through the final removal check, and removal MUST retain the workspace execution lease through deletion. Unknown or unavailable activity inspection MUST fail closed with an actionable diagnostic. Removal MUST NOT infer cancellation authority.

Run cancellation MUST apply ShouldProcess to the complete transition, including worker termination, orphan mapping cleanup and metadata writes. WhatIf or declined confirmation MUST leave all three untouched, including an unset or dead worker PID.

#### Scenario: Reject removal while a worker is waiting

- **WHEN** a managed worker is queued or waiting for a workspace, execution drive or engine lease
- **THEN** both replica and retained worktree removal fail before deletion, even when native UE process discovery has no match
- **AND** concurrent new run admission cannot pass the final removal boundary

#### Scenario: Preview orphan cancellation without mutations

- **WHEN** cancellation is requested with WhatIf or confirmation is declined and the worker is absent
- **THEN** no mapping cleanup, worker kill or Cancelled metadata write occurs
- **AND** an authorized actual cancellation still performs its full transition

### Requirement: Ordered local Change queues

Each primary or replica workspace SHALL own an explicit ordered Change queue under ignored local Saved data. The queue SHALL order Changes while the existing Task DAG determines Ready work inside each Change. A Change SHALL bind to one workspace on enqueue through an indexed execution attachment, without extending the native Change manifest schema. Ordinary chat SHALL be sufficient to execute the entire approved queue. No daemon, automatic chat creation or cross-workspace transfer SHALL be implied.

#### Scenario: Execute the full queue in ordinary chat
- **GIVEN** the current workspace has an approved ordered queue A then B
- **WHEN** the user asks to execute until finished
- **THEN** the agent claims that queue, completes A through required verification and completed archive, advances to B, ensures missing planning from approved material, and continues until exhaustion or a concrete blocker

#### Scenario: Preserve Task DAG progress during feedback
- **WHEN** feedback invalidates accepted planning truth
- **THEN** the executing workspace explores a linked candidate draft, applies the exact user-approved Replan and its post-handoff execution arrangement, preserves valid completed work and continues from derived Ready tasks; ordinary failures remain task-local and do not skip the blocked Change

#### Scenario: Remove queue membership
- **WHEN** a pending member is explicitly removed
- **THEN** its Change lifecycle is unchanged, an unstarted assignment may be released, and an already started member retains provenance even if requeued

#### Scenario: Reconfigure an exhausted queue

- **WHEN** an unclaimed exhausted queue receives new pending Changes
- **THEN** it reports idle with the new membership and does not claim a controller; an existing requested pause remains paused
- **AND** removing the last pending member reports exhaustion and counts removal separately from completed archives

### Requirement: Queue ownership and recovery

Queue membership writes SHALL use revision checks and short recoverable transactions. One logical controller SHALL hold the local queue token; elapsed time alone MUST NOT replace that owner. Explicit takeover SHALL inspect UE activity and require the former controller to have stopped. Queue advance MUST verify exact archived Change UID, ID and completed closure. An abandoned or superseded archive MUST NOT count as completed queue delivery.

#### Scenario: Reject a duplicate assignment or stale update
- **WHEN** another workspace enqueues an assigned Change or a writer uses an old revision
- **THEN** the operation fails without changing accepted ownership or queue order

#### Scenario: Recover an interrupted state write
- **WHEN** a write stops between canonical assignment and local queue publication
- **THEN** the next mutation replays the journal before applying the new request

#### Scenario: Acknowledge a pause
- **WHEN** primary requests a pause for a registered queue
- **THEN** the executing agent preserves work and releases at a task or closure boundary; duplicate claims do not erase the request and the request itself does not terminate a running process

#### Scenario: Advance after archive interruption
- **WHEN** a completed archive exists but queue advance was interrupted
- **THEN** the controller can reconcile that exact archive and advance without repeating finished implementation or counting a different archive

### Requirement: Shared records and execution evidence

Replica Change, TaskPlan, draft, closure and native OpenSpec operations SHALL use canonical OpenSpecRoot while implementation and runtime files use WorkspaceRoot. Queue checkpoints SHALL retain initial and current host/plugin identities, including content fingerprints for intentionally uncommitted host work. Replan base_commit SHALL identify the canonical record repository and SHALL cite individual affected plugin identities. Shared spec publication SHALL use a short lock and expected content SHA-256, with reread and semantic merge after a stale-write rejection.

#### Scenario: Close verified plugin work without committing the primary
- **WHEN** queue implementation and verification finish
- **THEN** exact owned plugin commits preserve unrelated staged content and leave the primary HEAD unchanged, checkpoint actual source identities, synchronize applicable specs, satisfy the terminal gate and complete archive before advance

#### Scenario: Reject a concurrent stale spec merge
- **GIVEN** two workspaces read the same canonical spec
- **WHEN** one publishes before the other
- **THEN** the second stale write is rejected and the first merge remains intact until a new merge uses the current content digest

#### Scenario: Record a replica conversation
- **WHEN** an explicit public recording route reconciles an opt-in replica session
- **THEN** the local session binding retains the execution workspace while the shared recorder appends visible messages to the canonical draft, without copying OpenSpec into the replica

### Requirement: Read-only Harness status queries

Natural-language requests for current task, queue, workspace, lifecycle or build status SHALL route through actual Harness query results. Queries MUST NOT claim, reorder, resume or take over execution. Queue status SHALL distinguish unconfigured, exhausted, paused, missing-plan and unknown-activity states; a controller token MUST NOT be presented as proof of a live agent.

#### Scenario: Query current task progress
- **WHEN** the user asks what remains in the selected workspace
- **THEN** Harness reports queue membership and the current canonical TaskPlan, including complete, total and Ready counts where known; a missing plan is explicitly unknown rather than zero completed tasks

#### Scenario: Query interrupted queue transitions

- **WHEN** queue publication or the transition after completed archive was interrupted
- **THEN** read-only status distinguishes pending write recovery from an unconfigured queue, and an exact completed archive awaiting advance from an active Change needing planning
- **AND** a missing or invalid Change record is reported as blocked; status never recreates planning, replays writes or advances the queue

#### Scenario: Query multiple workspace queues
- **WHEN** the user asks the primary for all workspace progress
- **THEN** the agent lists registered workspaces and reads their exact targeted queue states, reports legacy parent worktrees as parked, and leaves execution ownership unchanged

#### Scenario: Detect a reused worker process identifier
- **WHEN** a recorded UE worker PID exists but its start time does not match the recorded worker
- **THEN** run status reports the orphaned run instead of presenting the unrelated process as active work
