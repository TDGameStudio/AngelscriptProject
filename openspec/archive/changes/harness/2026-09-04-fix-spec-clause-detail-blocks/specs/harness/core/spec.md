## MODIFIED Requirements

### Requirement: Unified workspace context

Harness MUST use one Git-derived workspace model in both the primary checkout and any registered linked worktree. The exact selected Context SHALL be authoritative for every dispatcher-owned workspace, repository, primary-root, and internal-context argument; caller parameters MAY repeat a matching root but MUST NOT retarget the operation. Codex `/goal` is an external continuation facility only and MUST NOT select a repository mode, imply worktree creation, constrain branch names, or change Git authority. New worktrees default to `.worktrees/<name>` on branch `<name>`, while existing registered worktrees remain valid at their current path and branch. Integration, non-force push, and worktree removal MUST remain three separate operations requiring explicit user intent.

#### Scenario: Interpret Codex Goal continuation
- **WHEN** work is running under Codex `/goal`
  > `/goal` contributes unattended continuation only; it does not choose a branch, create a worktree, or expand Git authority.
- **THEN** repository selection still comes from the explicit or discoverable WorkspaceRoot and no repository-mode state is created
  > The same selected-workspace contract applies to interactive and repeated continuation calls.
  >
  > - Repository identity remains the explicit or current-directory-discovered `WorkspaceRoot`.
  > - No repository mode or machine-global Goal selection is created.

### Requirement: Flexible Scenario Card authoring

Maintained Harness specifications SHALL express durable behavior through `Requirement` and `Scenario` headings, with one `WHEN` trigger and one `THEN` result in an ordinary behavioral scenario. Authors MAY add `GIVEN`, `AND`, or `BUT` clauses. Each behavior-clause list item SHALL independently own any optional progressive detail immediately indented beneath it, using the same readable composition shape by which a Task node owns its supporting detail. A clause-owned block MAY combine quoted `Context`, `Inputs`, `Observables`, `Boundaries`, `Verification`, or `Details` labels with useful prose, ordered or unordered lists, examples, and tables when the information materially clarifies that exact clause for a zero-context reader. Every optional clause and detail element SHALL remain ordinary Markdown and MUST NOT become a parser field, ordering rule, required placeholder, scenario identifier, checkbox, dependency edge, Ready state, or execution record.

Scenario Cards MUST retain the existing artifact ownership boundaries. Specs own durable externally observable behavior, stable behavioral or proof boundaries, protocol order, rule precedence, and durable examples; design owns technical choices and rationale; tasks own affected paths, implementation steps, dependencies, and exact execution commands; attachments own one-off observations, run output, investigation history, and closure evidence. An ordered spec list MAY clarify durable behavior order or rule precedence but MUST NOT prescribe implementation execution. A `Verification` detail MAY identify a stable invariant, test family, or acceptance route, but MUST NOT embed transient output or impersonate task execution state. When a clause is already clear, the author MUST omit its entire optional block; clause-specific detail MUST NOT be detached into an ambiguous Scenario-wide trailing block.

#### Scenario: Enrich individual behavior clauses
- **GIVEN** a durable behavior has a precondition that needs extra context
  > Context: This note belongs only to the `GIVEN` clause immediately above it.
- **WHEN** an author records a complex trigger whose durable order needs clarification
  > Details: The indented block belongs only to this `WHEN` clause.

  1. Establish the trigger's durable behavioral order.
  2. Keep source edits and execution order in tasks instead.
- **THEN** each useful detail remains visually and semantically attached to the exact clause it qualifies
  > Observables: Quoted notes, prose, lists, examples, and tables remain inside the owning list item.
- **AND** synchronization preserves every complete clause-owned block
  > Verification: Authoring-contract fixtures and strict specification validation cover both detailed and compact clauses.
- **BUT** the Scenario does not acquire Task state, implementation steps, transient evidence, or a shared unowned detail tail
  > Boundaries: Every optional block may be omitted without adding an empty placeholder.

#### Scenario: Keep a simple behavior scenario compact
- **WHEN** one trigger and one observable result completely express the durable behavior
- **THEN** the Scenario Card keeps only its useful `WHEN` and `THEN` clauses instead of adding empty or boilerplate nested content
