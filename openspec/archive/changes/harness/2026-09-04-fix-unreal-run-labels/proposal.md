## Why

The legacy Unreal build wrapper accepted a caller-defined `Label`, but the Harness migration retained only an internal automatically derived label. `ue.build`, `ue.ubt.invoke`, `ue.test`, and `ue.commandlet` cannot currently accept a semantic run label, while `ue.run.status` and `ue.process.list` do not expose the label already stored in `Request.json`. This makes concurrent and historical runs harder to distinguish during focused refactor work.

## What Changes

- Add an optional caller-defined `Label` to the four single-operation Unreal execution routes.
- Normalize and validate the label as bounded display metadata, defaulting to the route's current derived label when omitted.
- Preserve the effective label in the existing run request and expose it through run status and managed-process observation.
- Keep the generated `RunId` as the sole execution identity and the only run-directory key.
- Keep suite entry labels under the existing declarative suite contract.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/unreal`: Unreal runs accept and report optional semantic labels without changing execution identity or artifact paths.

## Impact

The parent repository Harness Unreal Skill, its direct tests, and the current `harness/unreal` specification change. No Unreal plugin source, UBT public command, build product, suite catalog, workspace lease, executor choice, or external dependency changes.

## Non-goals

- Do not place labels in filesystem paths, lock identities, RunIds, process-correlation evidence, or executor arguments.
- Do not add labels to suite entries beyond their existing declarative labels.
- Do not restore any legacy root `Tools` wrapper.
