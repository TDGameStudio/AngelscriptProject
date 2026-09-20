# Harness core delta

## MODIFIED Requirements

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

#### Scenario: A side question retains the whole discussion

- **GIVEN** a design discussion with unresolved earlier choices
- **WHEN** the user asks a local question or corrects a detail
- **THEN** the agent addresses that message, re-explains the complete relevant current design, and resumes the whole topic's ready questions or discoverable investigation
- **AND** after listed choices are exhausted it examines relevant counterexamples, failure recovery and boundaries before concluding that useful work is exhausted
- **BUT** it does not manufacture questions, change the objective or infer user convergence


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

#### Scenario: Complete first planning is part of the Create decision

- **GIVEN** user-led convergence on a new Change
- **WHEN** the Create Gate is prepared
- **THEN** the full proposal, root design, task plan, applicable deltas, verification arrangements and formal-record Git selection are prepared and validated as candidates before canonical creation
- **AND** acceptance creates and validates that exact planning version and commits its shown formal-record scope before the separate draft/execution arrangement
- **BUT** a failed stage remains recoverable and cannot be reported as fully persisted

#### Scenario: Replan persists records but not the old implementation

- **WHEN** an exact Replan is accepted and applied
- **THEN** its formal planning and operation provenance are saved through the shown Git selection
- **AND** current implementation changes remain for overall closure unless separately authorized, and a later execution arrangement still governs continuation


### Requirement: Harness dogfooding feedback

Harness SHALL expose the existing small updates notice and retain actual sources for workflow friction and explanation-improvement signals in canonical topic drafts. New upgrade findings MUST use the existing README/CONTEXT/design/research structure without a parallel Saved raw-observation, triage or inbox ledger. Historical observations remain readable and are not automatically migrated or deleted. Queries MUST remain read-only. Source capture, scope selection, handoff and verified improvement MUST remain distinct facts. An understanding signal with an unproven cause MUST remain a question or hypothesis rather than a proven Skill defect.

#### Scenario: Collect and group observations

- **WHEN** concrete sourced workflow friction or an explanation-improvement question is captured
- **THEN** harness.observe writes the bounded finding and actual sources into its canonical topic draft, reusing its known owner and scope
- **AND** grouped queries remain read-only and no new Saved observation, triage or inbox ledger is created
- **BUT** ordinary compilation failures, expected RED, unfamiliarity and cancellation are not inherently workflow defects

#### Scenario: Isolate synthetic observation measurements

- **GIVEN** performance measurements may query an explicitly selected real Change
- **WHEN** the benchmark measures the observation write route
- **THEN** it writes and validates the real draft artifact only in an isolated fixture root, leaving the selected project's feedback unchanged
- **AND** isolation does not replace the measurement with a no-op

#### Scenario: Reconcile historical feedback with exact evidence

- **GIVEN** the user authorizes a batch containing historical observations
- **WHEN** the agent checks each actual source and exact linked issue, task and final evidence
- **THEN** it distinguishes unresolved questions, historically completed corrections and synthetic measurements, retaining new treatment in an active owning topic
- **AND** selected-to-resolved reconciliation cites existing evidence and identifies itself without claiming a new repair or test run
- **BUT** rejection from another scope does not establish repair, and historical raw records and immutable archives remain unchanged

#### Scenario: Explain local feedback retention

- **WHEN** the user asks whether feedback survives sessions, cleanup or clones
- **THEN** the agent explains that new topic drafts and historical Saved feedback are Git-ignored local records
- **AND** admitted Change evidence and verified reusable outcomes follow their maintained record/knowledge owners
- **BUT** an update notice or Git commit does not back up ignored pending questions and no automatic migration is implied

#### Scenario: Preserve an immutable archive

- **WHEN** a new workflow question is discovered after archive
- **THEN** it enters an active topic draft without changing the archive or automatically creating a successor Change
- **AND** formal repair uses user-led convergence and both handoff Gates; already authorized direct maintenance proceeds within its existing scope

#### Scenario: Capture only a topic draft

- **WHEN** concrete sourced workflow friction is captured during execution
- **THEN** Harness creates or reuses the matching topic draft, retains the diagnostic evidence and returns to the authorized work after processing the feedback's actual impact
- **BUT** capture does not create a formal Change, append execution scope, modify Skills or itself block unrelated closure

#### Scenario: Batch treatment remains user-directed

- **WHEN** the user initiates a session to process findings across topic drafts
- **THEN** Harness explains current findings, dispositions and evidence, collects the selected scope and records conclusions in the original owning drafts
- **AND** archive or handoff does not claim implementation repair, and a pure research or rejected topic need not create a Change

#### Scenario: New feedback and measurements do not create another ledger

- **WHEN** a new observation or isolated performance probe exercises feedback capture
- **THEN** the new finding exists only in the owning topic draft, and the probe uses an isolated draft root
- **AND** existing historical Saved data and immutable archives stay unchanged; operational execution/transaction recovery records remain separate from upgrade issues

#### Scenario: Explain local retention honestly

- **WHEN** the user asks how feedback survives sessions or clones
- **THEN** Harness explains that drafts are ignored local records and accepted design/evidence is exported to a formal Change for Git persistence
- **BUT** local draft capture alone provides neither remote backup nor an implementation approval

#### Scenario: Preserve visible updates and material issue boundaries

- **WHEN** status or a current-scope material issue is processed
- **THEN** the existing bounded update notice and source-backed active issue/terminal rules continue to apply
- **AND** malformed notice is nonfatal, no watcher is introduced, and ordinary expected RED or cancellation is not classified as a Harness defect merely for occurring


### Requirement: Ordered local Change queues

Each primary or replica workspace SHALL own an explicit ordered Change queue under ignored local Saved data. The queue SHALL order Changes while the existing Task DAG determines Ready work inside each Change. A Change SHALL bind to one workspace on enqueue through an indexed execution attachment, without extending the native Change manifest schema. Ordinary chat SHALL be sufficient to execute the entire approved queue. No daemon, automatic chat creation or cross-workspace transfer SHALL be implied.

#### Scenario: Execute the full queue in ordinary chat
- **GIVEN** the current workspace has an approved ordered queue A then B
- **WHEN** the user asks to execute until finished
- **THEN** the agent claims that queue, completes A through required verification and completed archive, advances to B, ensures missing planning from approved material, and continues until exhaustion or a concrete blocker
- **AND** the explained exact close decision and all required Git stages must complete before that advancement; incomplete outcomes retain their separately approved truth

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

#### Scenario: Pending Git closure keeps the current item active

- **GIVEN** a current authorized item whose archive exists but whose required Git or withdrawal stage is incomplete
- **WHEN** the queue is inspected or resumed
- **THEN** it reports the partial close state and does not start the next item
- **AND** exact recovery completes remaining stages once without extending the authorized range


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

#### Scenario: Admit verified factual explanatory knowledge

- **GIVEN** clear capability ownership, existing maintenance authority and a reusable factual explanation that does not change accepted behavior
- **WHEN** its source and relevant contract, relationships, examples and applicability have been checked with any needed minimal observation
- **THEN** the agent may promptly publish it in the owning capability knowledges directory and update its INDEX with provenance and status
- **AND** it does not fabricate a code repair or require behavior RED for facts with no behavior change; repair-derived learning retains real implementation and regression proof

#### Scenario: Keep unauthorized or uncertain enrichment in its draft

- **WHEN** a factual claim lacks evidence, the current activity is pre-Change brainstorming, or the proposed update is outside existing authority
- **THEN** the owning topic draft retains the knowledge candidate, evidence gaps and intended destination without publishing it as current guidance
- **AND** archive or handoff alone does not promote it or prove the improvement complete

#### Scenario: Reuse admitted knowledge in later explanations

- **WHEN** a later explanation concerns the admitted topic
- **THEN** the agent reads the owning capability INDEX and relevant current entry, checks applicability and uses that content in the causal explanation
- **AND** existing suitable knowledge is reused rather than duplicated, and an invalidated entry is updated or superseded with provenance while archived sources remain immutable


### Requirement: Shared records and execution evidence

#### Scenario: Close verified plugin work without committing the primary

- **WHEN** the selected plugin stage of an approved close executes
- **THEN** exact owned plugin commits preserve unrelated staged content and leave primary HEAD unchanged during that stage
- **AND** source identities, applicable spec synchronization, terminal checks and native archive precede the separately shown canonical-record commit; only its successful persistence permits advancement

### Requirement: Queue ownership and recovery

#### Scenario: Advance after archive interruption

- **WHEN** an exact approved completed, abandoned or superseded closure has fully persisted its required Git stages but queue registration was interrupted
- **THEN** the controller can register that actual closure kind and advance within its authorized range without repeating completed work
- **BUT** an archive with pending Git or withdrawal stages cannot advance and does not authorize its replacement

## ADDED Requirements

### Requirement: Explained lifecycle closure decisions

Harness SHALL present the accepted design, final implementation, deviations, exact proving evidence, durable-spec disposition, owned Git selections and remaining workspace state before consuming an actual version-bound closure decision. One shown decision MAY cover archive and the exact local commits; it MUST NOT imply push, integration or workspace removal. Public archive mutations MUST require the matching decision as well as terminal integrity. A prior explicit decision remains usable only for its exact target, content, range and conditions.

#### Scenario: Insufficient explanation returns to the same decision

- **WHEN** the user requests a clearer explanation at Create, Replan or closure
- **THEN** the agent enters the explanation-driven improvement loop, resolves an identifiable gap or uses a contextual diagnostic question when the gap is unclear, then re-presents the complete relevant design
- **AND** it retains the candidate if unchanged or refreshes the preview when material content changes
- **BUT** understanding, silence and an unsubmitted question are not approval

#### Scenario: Actually submit the selectable Gate

- **GIVEN** a fully explained Create, Replan, arrangement or closure decision and an available popup whose host contract permits that decision
- **WHEN** Harness asks for the decision
- **THEN** it invokes that actual selectable form with concrete options and records only the real submitted answer and its source
- **BUT** prose options, an unsent payload, a preselected option, elapsed time or a pending/cancelled form do not approve the operation

#### Scenario: Respect popup capability and delivery limits

- **WHEN** the host form prohibits approval, is unavailable, fails or is reported invisible
- **THEN** Harness explains the concrete limit and delivers the actual question through the permitted visible fallback without repeated failed probes
- **AND** dependent mutation remains pending until an actual answer arrives

#### Scenario: Resume after archive and before canonical commit

- **WHEN** archive validation succeeds but the canonical-record commit fails
- **THEN** Harness reports archived/commit-pending, preserves immutable records and successful prior commits, and resumes only the remaining approved stages
- **BUT** archive existence alone is not successful workspace closure

### Requirement: Honest incomplete closure and code disposition

Abandoned and superseded closure SHALL preserve incomplete task dispositions and a shown owned incomplete Git checkpoint without pretending verification passed. Abandoned code SHALL then be withdrawn only through the shown attributable selection with applicable verification and a traceable commit. Superseded work SHALL follow its named replacement's accepted carryover. Mixed ownership, unresolved dependencies or rejecting hooks MUST block the affected operation rather than trigger broad restoration or bypass.

#### Scenario: Abandonment preserves other work

- **GIVEN** an abandoned implementation with unrelated live and staged edits
- **WHEN** the accepted incomplete checkpoint and withdrawal complete
- **THEN** the checkpoint remains in Git history, only the abandoned owned code is withdrawn, unrelated edits remain and unfinished tasks keep their real dispositions

#### Scenario: Poor implementation is triaged before disposition

- **WHEN** the user says implementation is poor
- **THEN** the agent distinguishes an ordinary local correction, invalidated planning that needs Replan and an actual decision to stop or replace the objective
- **BUT** the feedback alone does not authorize abandonment, deletion or a new Change

### Requirement: Explanation-driven improvement

Understanding feedback SHALL inform a sourced improvement loop across ordinary module explanations and lifecycle Gates. Explaining-work owns source-grounded causal explanation and knowledge lookup; Grill owns necessary contextual clarification and consequential choices; the matching topic draft owns improvement findings and disposition. Reusable explanation-method changes belong to explaining-work, intended behavior belongs to the owning specification, and verified module knowledge belongs to that capability's indexed knowledges directory. Feedback MUST NOT automatically create a Change, authorize unrelated edits, prove a defect or silently terminate the original discussion.

#### Scenario: Explain and continue the user's original work

- **WHEN** the user says an existing module explanation is unclear or requests another explanation
- **THEN** the agent identifies the understanding goal and original return point, inspects relevant source/specification/knowledge and explains the complete relevant mechanism with a concrete example
- **AND** it asks Grill questions only for genuine unresolved understanding needs or choices, records the improvement signal in its owning topic draft and resumes the original discussion or work
- **BUT** an initial question about an unfamiliar module does not itself prove a Skill defect or require a comprehension quiz

#### Scenario: Distinguish method, specification and knowledge gaps

- **WHEN** investigation establishes the reason an explanation is insufficient
- **THEN** missing narrative connections improve explaining-work, ambiguous intended behavior improves the owning Requirement/Scenario, and missing source-backed mechanisms or examples improve owning capability knowledge
- **AND** accepted behavior changes return through the actual design/Replan boundary; current implementation alone does not establish the intended contract

#### Scenario: Existing knowledge was not used

- **GIVEN** relevant current knowledge already exists
- **WHEN** explanation feedback reveals that it was not found or applied
- **THEN** the agent reuses that content and improves the relevant index or reading path within selected authority instead of creating a duplicate article

#### Scenario: Conflicting evidence and authority remain explicit

- **WHEN** source/specification/knowledge conflict or a proposed improvement exceeds current scope
- **THEN** the draft retains the sourced question, hypothesis, proposed destination and disposition until evidence and actual scope selection permit improvement
- **AND** verified reusable results may later enter capability knowledge while the draft keeps the process record; neither becomes a duplicate transcript or parallel issue ledger
