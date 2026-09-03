## MODIFIED Requirements

### Requirement: Hardness-managed local configuration

Each workspace SHALL use one ignored root `AgentConfig.ini`. Schema v2 SHALL reserve `[Hardness] SchemaVersion`, `WorkspaceRoot`, `PrimaryRoot`, and `GitCommonDir` plus `[Paths] ProjectFile`; `WorkspaceKind` and `GoalName` MUST NOT be written or accepted as v2 identity. Topology, WorktreeName, Branch, Head, engine classification, and run state remain runtime facts. Explicit bootstrap SHALL copy machine-shared values only from the canonical primary workspace, preserve other non-managed local fields and comments, bind the target's unique root `.uproject`, and remove the obsolete `[References] HazelightAngelscriptEngineRoot` key. Configuration status MUST reject that obsolete key when it remains. Generic mutation MUST reject managed fields and malformed multiline data. A trusted leaf MAY request a bounded batch of exact keys after one live status or execution-guard check, but that projection MUST NOT cache safety facts or become a bulk-value Hardness route.

#### Scenario: Migrate schema v1 in place
- **WHEN** explicit bootstrap finds a valid schema v1 AgentConfig in a registered workspace
- **THEN** it atomically writes schema v2, removes `WorkspaceKind`, `GoalName`, and the obsolete Hazelight path, rebinds ProjectFile, and preserves other user-controlled content

#### Scenario: Bootstrap without a primary configuration
- **WHEN** the canonical primary workspace has no `AgentConfig.ini`
- **THEN** Hardness writes a minimal valid v2 identity/project binding and reports that consumer configuration is still required

#### Scenario: Query or update local configuration
- **WHEN** a caller uses configuration status/get/set
- **THEN** status avoids bulk value disclosure and reports stale managed or removed keys, get reads one exact key, set atomically updates one non-managed key, and unrelated content remains unchanged

#### Scenario: Project configuration for a trusted leaf
- **WHEN** a leaf needs several exact values for one operation
- **THEN** workspace lifecycle performs one fresh status or execution guard, returns at most 64 requested entries, and does not cache identity, configuration bytes, authorization, or mutation preconditions
