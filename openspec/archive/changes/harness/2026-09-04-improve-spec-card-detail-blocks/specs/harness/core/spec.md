## MODIFIED Requirements

### Requirement: Flexible Scenario Card authoring

Maintained Harness specifications SHALL express durable behavior through `Requirement` and `Scenario` headings, with one `WHEN` trigger and one `THEN` result in an ordinary behavioral scenario. Authors MAY add `GIVEN`, `AND`, or `BUT` clauses and SHALL treat the Scenario heading as the owner of one optional progressive detail block after those clauses. That block MAY combine quoted `Context`, `Inputs`, `Observables`, `Boundaries`, `Verification`, or `Details` labels with useful prose, ordered or unordered lists, examples, and tables when the information materially clarifies a complex behavior for a zero-context reader. Every optional clause and detail element SHALL remain ordinary Markdown and MUST NOT become a parser field, ordering rule, required placeholder, scenario identifier, checkbox, dependency edge, Ready state, or execution record.

Scenario Cards MUST retain the existing artifact ownership boundaries. Specs own durable externally observable behavior, stable behavioral or proof boundaries, protocol order, rule precedence, and durable examples; design owns technical choices and rationale; tasks own affected paths, implementation steps, dependencies, and exact execution commands; attachments own one-off observations, run output, investigation history, and closure evidence. An ordered spec list MAY clarify durable behavior order or rule precedence but MUST NOT prescribe implementation execution. A `Verification` detail MAY identify a stable invariant, test family, or acceptance route, but MUST NOT embed transient output or impersonate task execution state. When the required `WHEN` and `THEN` already make a scenario clear, the author MUST omit the entire unused detail block.

#### Scenario: Enrich a complex behavior scenario

- **GIVEN** a durable behavior has multiple relevant preconditions, outputs, exclusions, proof boundaries, ordered results, or examples
- **WHEN** an author records that behavior in a Harness specification
- **THEN** the Scenario Card retains one clear behavioral flow and adds one Scenario-owned detail block containing only the quoted metadata and ordinary Markdown that materially help a zero-context reader
- **AND** each added detail remains durable, externally meaningful, and owned by the specification
- **BUT** the card does not acquire task state, implementation steps, transient evidence, or a second machine-readable schema

> Context: Rich detail is progressive authoring guidance for complex behavior, not a required field matrix.
>
> Observables: Requirement and Scenario headings, the `WHEN` trigger, and the `THEN` result remain recognizable exactly as they are in a compact scenario.
>
> Boundaries: Optional labels, prose, lists, examples, and tables may be omitted, reordered, or combined without changing OpenSpec parser behavior.
>
> Verification: OpenSpec authoring-contract fixtures and strict specification validation cover both rich and compact cards while preserving complete detail blocks.
>
> Details:
>
> 1. Establish the durable behavioral spine with `WHEN` and `THEN`.
> 2. Add only the context, sequence, rules, examples, or proof boundaries a zero-context reader needs.
> 3. Keep implementation order and completion evidence in tasks and attachments.

#### Scenario: Keep a simple behavior scenario compact

- **WHEN** one trigger and one observable result completely express the durable behavior
- **THEN** the Scenario Card keeps only its useful `WHEN` and `THEN` clauses instead of adding an empty or boilerplate detail block

### Requirement: Unified workspace context

Harness MUST use one Git-derived workspace model in both the primary checkout and any registered linked worktree. The exact selected Context SHALL be authoritative for every dispatcher-owned workspace, repository, primary-root, and internal-context argument; caller parameters MAY repeat a matching root but MUST NOT retarget the operation. Codex `/goal` is an external continuation facility only and MUST NOT select a repository mode, imply worktree creation, constrain branch names, or change Git authority. New worktrees default to `.worktrees/<name>` on branch `<name>`, while existing registered worktrees remain valid at their current path and branch. Integration, non-force push, and worktree removal MUST remain three separate operations requiring explicit user intent.

#### Scenario: Interpret Codex Goal continuation

- **WHEN** work is running under Codex `/goal`
- **THEN** repository selection still comes from the explicit or discoverable WorkspaceRoot and no repository-mode state is created

> Details:
>
> - Repository identity remains the explicit or current-directory-discovered `WorkspaceRoot`.
> - `/goal` contributes continuation only; it does not choose a branch, create a worktree, or expand Git authority.
> - Repeated continuation observes the same selected-workspace contract as an interactive call.
