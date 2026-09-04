## MODIFIED Requirements

### Requirement: Per-run lifecycle and evidence

Real operations SHALL use stable Request and Run schema names in a unique physical directory under `Saved/Harness/Unreal/Runs/<run-id>` with `Request.json`, `RunMetadata.json`, and `Command.log`, plus operation-specific reports. Records MUST distinguish physical identity/paths from execution identity/paths. State transitions SHALL use `Queued`, `WaitingWorkspace`, `WaitingExecutionDrive`, optional `WaitingEngine`, `Running`, and one terminal state from `Succeeded`, `Failed`, `TimedOut`, or `Cancelled`; status MAY report `Orphaned` when a non-terminal recorded process no longer exists. The worker SHALL acquire workspace, drive, and optional engine leases in that order, create and validate the mapping only after those leases, and release mapping and leases in reverse order. Cancellation and timeout MUST remove only an exact Harness-owned mapping. A synchronous call SHALL wait for its worker, while NoWait SHALL return the run identity for later status or explicit cancellation.

#### Scenario: Time out a process
- **WHEN** a native child exceeds the request's total timeout
  > Inputs: The total timeout covers queueing, lease waits, and native execution rather than restarting for each phase.
- **THEN** the worker stops the child tree, records `TimedOut`, preserves bounded evidence, releases every lease, and returns a non-zero result
  > Details:

  1. The contained native process tree is no longer live before the run is reported terminal.
  2. `RunMetadata.json` and bounded command evidence identify the timeout and final `TimedOut` state.
  3. Only an ownership-verified execution mapping is removed, and all acquired leases become available again.
