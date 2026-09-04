## Why

Current Harness specifications demonstrate only a minimal `WHEN` / `THEN` scenario shape. That shape is sufficient for simple behavior, but it gives authors no shared way to preserve the context, inputs, observable boundaries, or stable verification oracle needed by a complex behavior. Authors either compress important detail into an overloaded sentence or risk inventing a second rigid schema.

The workspace specifications also contain four discovery/status scenarios under the adjacent configuration-migration requirement. Correcting that ownership while introducing richer examples makes the authoring contract both clearer and self-demonstrating.

## What Changes

- Define a flexible Scenario Card convention: `GIVEN`, `WHEN`, `THEN`, `AND`, and `BUT` remain behavioral clauses, while optional quoted detail lines may capture context, inputs, observables, boundaries, and verification.
- Keep every detail field optional and require authors to delete unused fields so simple scenarios remain compact.
- Document the ownership boundary between durable specs, technical design, executable tasks, and one-off evidence attachments.
- Teach the convention through the project spec template, workflow/config guidance, and the OpenSpec lifecycle Skills that create, revise, synchronize, and verify specs.
- Add two self-hosting authoring scenarios and selectively enrich 27 existing Harness scenarios where the extra detail improves execution or verification.
- Move four Git-derived workspace discovery/status scenarios back under their owning requirement.
- Preserve the current `record-v1` validation profile and existing parser behavior.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/core`: Define flexible Scenario Card authoring and enrich complex lifecycle scenarios.
- `harness/workspace`: Correct discovery/status scenario ownership and enrich selected workspace safety scenarios.
- `harness/git`: Enrich selected commit, integration, and publication scenarios with explicit boundaries and verification oracles.
- `harness/unreal`: Enrich selected planning, run-lifecycle, drive-mapping, process-discovery, and concurrency scenarios without overstating live Unreal evidence.

## Impact

This is a parent-repository authoring and specification change. It updates project-local OpenSpec workflow/configuration files, OpenSpec Skills and tests, and current Harness specifications. It does not change `Tools/openspec`, the packaged OpenSpec executable, any plugin or Unreal implementation, any submodule gitlink, or UE execution behavior.

The richer detail is ordinary Markdown and remains backward-compatible with `record-v1`: the portable parser continues to recognize requirements and scenario counts without treating optional detail labels as schema fields.

## Non-Goals

- Do not adopt or modify `requirements-v1`, require delta specs for every future Change, or introduce a new validation profile.
- Do not add scenario IDs, checkboxes, dependency graphs, required empty fields, or another machine-readable Scenario Card schema.
- Do not bulk-expand every existing scenario.
- Do not move technical rationale into specs, implementation commands into scenarios, or one-off run evidence out of attachments.
- Do not claim that fixture-level Unreal concurrency tests prove two real UBT builds executing end to end.
