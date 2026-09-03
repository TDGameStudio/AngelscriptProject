## ADDED Requirements

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
