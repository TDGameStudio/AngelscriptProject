## MODIFIED Requirements

### Requirement: Per-run lifecycle and evidence

Real operations SHALL use stable Request and Run schema names in a unique physical directory under `Saved/Harness/Unreal/Runs/<run-id>` with `Request.json`, `RunMetadata.json`, and `Command.log`, plus operation-specific reports. Build, generic UBT, test, and commandlet requests SHALL accept an optional semantic display label, derive the existing route-specific default when it is omitted or blank, and expose the effective label in plans, status, and recognized process observations. Labels MUST be bounded and free of control characters. Records MUST distinguish physical identity/paths from execution identity/paths. The label MUST NOT participate in RunId generation, filesystem paths, process correlation, locks, executor arguments, or ownership decisions. State transitions SHALL use `Queued`, `WaitingWorkspace`, `WaitingExecutionDrive`, optional `WaitingEngine`, `Running`, and one terminal state from `Succeeded`, `Failed`, `TimedOut`, or `Cancelled`; status MAY report `Orphaned` when a non-terminal recorded process no longer exists. The worker SHALL acquire workspace, drive, and optional engine leases in that order, create and validate the mapping only after those leases, and release mapping and leases in reverse order. Cancellation and timeout MUST remove only an exact Harness-owned mapping. A synchronous call SHALL wait for its worker, while NoWait SHALL return the run identity for later status or explicit cancellation.

#### Scenario: Label one Unreal operation

- **WHEN** a caller supplies a valid `Label` to `ue.build`, `ue.ubt.invoke`, `ue.test`, or `ue.commandlet`
  > Inputs: A display label containing at most 128 UTF-16 code units, no control characters, and any route-specific execution inputs.
- **THEN** the effective trimmed label is returned by PlanOnly, stored in the run request, and returned by `ue.run.status`
  > Observables: `Label` has one identical value in the plan, `Request.json`, new run metadata, and the status projection.
- **AND** a recognized managed build returned by `ue.process.list` reports the same label
  > Verification: The focused RunLabels fixture exercises all four public routes and a contained recognized-build process view.
- **BUT** changing the label does not change the generated RunId, run directory, lease identity, native argument array, or process-correlation evidence
  > Boundaries: Labels are repeatable display metadata rather than identity or authority.

#### Scenario: Derive a default run label

- **WHEN** a caller omits `Label` or supplies only whitespace to a single-operation Unreal route
  > Inputs: The normalized build target, UBT capability, test prefix or group, or commandlet name that already identifies the operation.
- **THEN** the route derives its existing stable label from the build target, UBT capability, test selection, or commandlet name and exposes it through the same observation surfaces
  > Observables: Callers receive a non-empty effective label without having to provide new input, preserving current route behavior.

#### Scenario: Reject an unsafe run label

- **WHEN** a caller supplies a label longer than the supported bound or containing a control character
  > Inputs: A label longer than 128 UTF-16 code units or containing characters such as a newline, carriage return, tab, or NUL.
- **THEN** planning fails before a run directory, mapping, lease, or native process is created
  > Observables: The diagnostic identifies the label boundary and the workspace run root remains unchanged.
