## MODIFIED Requirements

### Requirement: Flexible Scenario Card authoring

Maintained Harness specifications SHALL express durable behavior through `Requirement` and `Scenario` headings, with one `WHEN` trigger and one `THEN` result in an ordinary behavioral scenario. Authors MAY add `GIVEN`, `AND`, or `BUT` clauses. For every behavior clause that is created or modified, the author SHALL actively evaluate whether clause-owned detail would improve a zero-context reader's understanding and SHOULD retain the smallest useful combination of quoted `Context`, `Inputs`, `Observables`, `Boundaries`, `Verification`, or `Details` notes, short prose, ordered or unordered lists, examples, and tables. Each retained detail block SHALL be immediately indented beneath the exact behavior-clause list item it qualifies.

All clauses and detail forms SHALL remain optional ordinary Markdown and MUST NOT become parser fields, ordering rules, required placeholders, scenario identifiers, checkboxes, dependency edges, Ready state, or execution records. An author MAY omit any form only when it adds no durable information, and MUST omit empty or boilerplate forms. Scenario Cards MUST retain the existing artifact ownership boundaries: specs own durable externally observable behavior, stable behavioral or proof boundaries, protocol order, rule precedence, and durable examples; design owns technical choices and rationale; tasks own affected paths, implementation steps, dependencies, and exact execution commands; attachments own one-off observations, run output, investigation history, and closure evidence. Clause-specific detail MUST NOT drift into an ambiguous Scenario-wide trailing block.

#### Scenario: Enrich individual behavior clauses
- **GIVEN** a durable behavior has a precondition that benefits from extra context
  > Context: This note belongs only to the `GIVEN` clause immediately above it.
- **WHEN** an author creates or modifies a `GIVEN`, `WHEN`, `THEN`, `AND`, or `BUT` behavior clause
  > Details: The author evaluates the whole progressive-detail palette rather than treating blockquotes as the only enrichment form.

  The smallest useful combination may include:

  1. a quoted label or short paragraph for a semantic boundary;
  2. an ordered list for durable sequence or precedence;
  3. an unordered list for rules, examples, or edge cases; or
  4. a table for repeated-field comparison.

  - Example: use a table when several inputs map to distinct durable outcomes.
  - Example: use prose when a label would obscure the relationship being explained.
- **THEN** useful durable information is retained directly beneath the exact clause it qualifies
  > Observables: A zero-context reader can distinguish inputs, results, boundaries, examples, ordering, and proof expectations without consulting task execution history.

  | Card content | Ownership |
  |---|---|
  | Quoted note, prose, list, example, or table | Immediately preceding behavior clause |
  | Scenario-wide trailing detail | Invalid when it qualifies only one clause |
- **AND** synchronization preserves every complete clause-owned block
  > Verification: Authoring-contract fixtures cover the priority rule, the complete Markdown palette, clause ownership, and the no-boilerplate boundary.
- **BUT** the Scenario does not acquire Task state, implementation steps, transient evidence, or a shared unowned detail tail
  > Boundaries: Optional detail explains durable behavior; it never records execution progress.

#### Scenario: Keep a simple behavior scenario compact
- **WHEN** an author actively evaluates a self-contained trigger and finds that every optional detail form adds no durable information
  > Inputs: The clause is already unambiguous to a zero-context reader and has no hidden boundary, example, ordering, or proof expectation.
- **THEN** the Scenario Card keeps only its useful behavior clauses instead of adding empty or boilerplate nested content
  > Observables: Compactness follows the completed evaluation; it is not assumed from the clause's apparent simplicity.

### Requirement: Impact-scoped verification by default

Harness lifecycle guidance SHALL begin task execution, Change completion verification, and post-archive checking with the smallest reliable scope that directly proves the affected behavior. Verification MUST expand only when an affected shared contract, cross-component boundary, observed failure, release gate, or explicit user request provides a concrete reason.

#### Scenario: Verify a ready task
- **WHEN** an agent implements one ready task
  > Inputs: The task's declared outcome, exact or bounded paths, and impact-related verification command define the initial proof surface.
- **THEN** it runs the task's exact impact-related verification before and after the smallest implementation change
  > Observables: The same focused check demonstrates the expected RED and the resulting GREEN whenever a reproducible failing state is available.
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

### Requirement: Consistent maintained project guidance

The root `AGENTS.md` SHALL be the sole canonical project-level agent entry and SHALL contain only stable, cross-capability invariants needed to route work safely. Detailed architecture, commands, lifecycle procedures, validation selection, implementation rules, mutable counts, reference inventories, and history MUST remain in their owning Skills, OpenSpec specifications, source, or existing indexes rather than being copied into the root entry. A second root language mirror MUST NOT be required.

The canonical entry and live Harness-facing Skills SHALL agree that project Skills are enabled, Harness is the project workflow entry, the selected Git workspace is authoritative, Codex `/goal` is continuation rather than a repository mode, Review begins only on explicit request, ordinary routes run in the current PowerShell 7 process, intentional child `pwsh` hosts are bounded exceptions, and Unreal operations use `ue.*` routes without a root `Tools` wrapper fallback.

#### Scenario: Enter the project through maintained guidance
- **WHEN** an agent opens the root project guidance
  > Inputs: The root entry supplies stable cross-capability policy and links, not a snapshot of mutable implementation detail.
- **THEN** the sole root `AGENTS.md` provides the stable routing and authority boundaries needed to select the owning Skill, current Change, specification, or index
  > Observables: The entry routes to `.agents/skills/README.md`, Harness and OpenSpec Skills, `openspec/specs/`, and `Reference/README.md` without reproducing their volatile detail.
- **AND** focused static checks reject a second root Agent guide and representative architecture inventories, mutable test counts, reference-repository catalogs, historical milestones, or detailed command tutorials in the canonical entry
  > Verification: The project-entry fixture checks both required routing anchors and prohibited heavyweight content.
- **BUT** immutable OpenSpec archives and subsystem-owned guidance such as `Wiki/Agents_ZH.md` remain outside this single-entry cleanup
  > Boundaries: Historical evidence and subsystem documentation are not alternate root project instructions.
