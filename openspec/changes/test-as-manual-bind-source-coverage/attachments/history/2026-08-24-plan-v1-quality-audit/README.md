# Plan V1 quality-audit snapshot

`plan-v1` was the first exhaustive normalized projection. It was never user-accepted and never authorized TestSource implementation.

Frozen identifiers before supersession:

- sources: 3,041;
- current owner-qualified callables: 11,987;
- normalized rows: 12,624;
- proposed callables: 12,327;
- retirements: 48;
- source assertions: 249;
- total checkboxes: 31,975;
- manifest-content SHA-256: `5FB310CF3CA5C5EA470337A473382A42A350B76891EA3F177F7BABBA44F44203`;
- semantic-plan SHA-256: `83FD7412B22357904392335EE8E8082192E1BE5F8903F95987080404692AE914`;
- generated `tasks.md` SHA-256: `C43301111D37477FE30571AF97A2B1619AE756C6395CFDD297E740178E611D57`.

The post-generation semantic audit proved that schema/identity completeness was not sufficient for execution readiness:

- 2,780 comparison-derived `ObservedCondition` writeback findings remained instead of raw values/state/API results;
- 6,240 adjacent comments described only a generic callable "surface owned by" an owner rather than the concrete purpose;
- 2,773 review-ready rows had typed parameters but no vector that structurally supplied all arguments;
- 721 preprocessing/compiler/metadata evidence rows lacked an explicit source/external-driver classification;
- 14 fixed-name rows lacked a protocol-specific `requiredNameReason`.

Representative root cause: `TestSource/Definitions/Meta/Test_AddFileEmitsGameVirtualPathMetadata.as` mirrored a C++ preprocessor metadata fixture, but V1 planned runtime-style observer replacements, including `bool&out FirstObservedCondition`, rather than deciding source/external-driver ownership and exposing only relevant raw channels. This violates the user's raw input/output and no-pseudo-coverage requirements.

V1 is therefore preserved only as an audit baseline. Plan V2 adds semantic-quality blockers and must resolve the affected signature/comment/vector/external-oracle decisions before any row can become user-accepted.
