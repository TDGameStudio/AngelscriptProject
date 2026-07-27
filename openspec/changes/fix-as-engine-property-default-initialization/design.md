## Context

The engine property profile tests read a baseline, apply both legal values,
restore the baseline, and compare independent engines. An omitted constructor
assignment made `typeCheckSwitchEnums` depend on allocator memory rather than a
fork policy.

## Goals / Non-Goals

**Goals:**

- Give every engine-property field an explicit deterministic constructor value.
- Preserve per-engine set/read/restore behavior and cross-engine isolation.

**Non-Goals:**

- Change the selected semantic default from the fork's intended behavior.
- Add or remove public engine properties.

## Decisions

1. Initialize `typeCheckSwitchEnums` to `false` beside the other property
   defaults, matching the current fork's intended baseline.
2. Keep a table-driven audit/test for all properties touched by the raw engine
   profile rather than a one-property smoke test.
3. Test both applied values and restore on two independently created engines.

## Risks / Trade-offs

- **[Wrong assumed default]** Initialization could formalize the wrong policy. →
  correlate with current switch-enum behavior and fork documentation.
- **[Future property omission]** A later field may be added uninitialized. →
  retain complete constructor/profile reconciliation.

## Migration Plan

1. Confirm the intended default and full property field list.
2. Retain the failing profile/isolation regression.
3. Apply the one-field constructor repair and audit adjacent fields.
4. Build once with the coherent stage and run focused Engine plus full SDK.
5. Roll back the assignment if policy evidence contradicts `false`.

## Open Questions

None after the current-fork policy is confirmed by the existing profile
regression and documentation.
