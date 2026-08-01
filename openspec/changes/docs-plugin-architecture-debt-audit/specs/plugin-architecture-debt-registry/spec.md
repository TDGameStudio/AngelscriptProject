## ADDED Requirements

### Requirement: Architecture findings carry current-state evidence

A recorded architecture finding SHALL cite evidence from the current source tree — file path plus line reference, or a measured count — not a citation of the report that first raised it. A finding whose only evidence is a prior report MUST be marked unverified and MUST NOT be used to scope implementation work.

#### Scenario: Finding is recorded from a historical report

- **WHEN** a finding originates in a report older than the current tree
- **THEN** it is re-checked against the source before recording, and the recorded evidence is the current `file:line` or count

#### Scenario: Finding cannot be re-verified

- **WHEN** re-checking is not feasible because the finding depends on an external environment, third-party plugin, or upstream report
- **THEN** the finding is recorded in a section marked as unverified leads, and is listed as requiring reproduction before any change is scoped

### Requirement: Findings carry a verification verdict and date

Every recorded finding SHALL carry a verification date and one verdict from the set: still-true, regressed, partly-fixed, fixed, not-found. A finding whose measured magnitude exceeds the originally reported magnitude MUST be recorded as regressed and MUST state both values.

#### Scenario: Reported problem no longer exists

- **WHEN** the construct a finding describes has been split, removed, or renamed away
- **THEN** the finding is recorded as fixed or not-found, with the superseding structure named, so it is not re-proposed as new work

#### Scenario: Problem grew since it was reported

- **WHEN** a countable finding measures larger than the reported figure
- **THEN** it is recorded as regressed with both the original and current counts

#### Scenario: Report claim proves inaccurate

- **WHEN** verification shows a reported claim was wrong at the time it was written
- **THEN** the registry records the correction explicitly rather than silently dropping the claim

### Requirement: Findings map to OpenSpec coverage

Every recorded finding SHALL name the OpenSpec change that covers it, or be marked not-covered. A finding marked not-covered SHALL appear in the follow-up candidate list, and each candidate SHALL identify the finding IDs it would resolve.

#### Scenario: Finding is already tracked

- **WHEN** an active or archived change addresses the finding
- **THEN** the registry names that change instead of proposing duplicate work

#### Scenario: Finding has no coverage

- **WHEN** no change addresses the finding
- **THEN** it is marked not-covered and rolled into a named follow-up candidate carrying its finding IDs

### Requirement: The registry does not authorise remediation

An audit change SHALL record and triage findings only. It MUST NOT modify the source the findings describe. Remediation SHALL be scoped as separate changes carrying their own tasks and verification.

#### Scenario: Audit identifies a confirmed defect

- **WHEN** verification confirms a defect such as a data race
- **THEN** the audit records it with evidence and names a follow-up change, and the fix lands under that change rather than in the audit
