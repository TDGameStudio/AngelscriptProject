## MODIFIED Requirements

### Requirement: Progressive skill routing

Hardness SHALL remain the single short entry for project workflow and SHALL load only the selected leaf module or focused reference. Workspace lifecycle, Git mutation, OpenSpec primitives, task status, Hardness observation, and Unreal development SHALL retain separate routes and authority boundaries. Default context MUST NOT bulk-load command documentation, attachments, historical observations, Replans, or leaf implementations.

#### Scenario: Route one project command
- **WHEN** a caller requests one installed Hardness command
- **THEN** the dispatcher loads only the owning leaf, returns the common result envelope, and does not acquire unrelated workflow authority

#### Scenario: Route an Unreal operation
- **WHEN** a caller requests a verified `ue.*` route
- **THEN** Hardness supplies the exact WorkspaceRoot context to the Unreal leaf and the leaf enforces its own engine/process authority
