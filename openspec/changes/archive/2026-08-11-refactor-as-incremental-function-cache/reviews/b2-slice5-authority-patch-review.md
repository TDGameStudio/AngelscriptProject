# B2 Slice 5 exact authority-patch review

Date: 2026-08-09 (Asia/Shanghai)

Reviewed packet SHA-256:
`88B55F94470919BB5A01F151CF2F5653AB31D95686E9A463297D0C9D02EA31A3`.

Reviewed atomic candidates:

```text
type-schema-matrix-v1.md
AB9B294C293C7929EE92CA61DF44DDF5827C94666705AF7E57A67B87421B8CD8

type-layout-authority-v1.md
0F336B77A01AABA5C4A05B807126974770EB159C0CFB3C18D97061DA48A406B7

record-wire-v1-remaining.md
A2BAD67CD937CB8FCF039FED1FB53BD8B471AD7D24EE2DF323A1F9CC14A8D1CE

producer-b2-coverage-audit.md
C972C1C1F9E99FA0872BA549376E5B610BDDEE0B4A86AFBFD96EBC0004693C59
```

Independent read-only disposition: **HOLD — 0 Critical / 1 Important /
0 Minor**. No source or ready-packet work is authorized from these identities.

## Important — locally derivable dependency coverage had two semantic owners

`type-schema-matrix-v1.md` section 10 still said local validation owns only
canonical set/reference presence, while graph validation owns exact derived
dependency coverage and returns `MissingCoverage`/`UnexpectedRecord`. The same
file's local-order section placed “locally derivable dependency coverage” after
relation/LayoutInput pairing and before layout replay. Both co-normative wire/
layout authorities and the producer audit also require that local phase.

This is executable ambiguity: a producer/decoder implementer cannot decide whether
a missing/extra Dependency row derivable entirely from the TypeSchema DTO must
fail local serialization/decode or wait for ModuleSnapshot graph.

Current code evidence confirms the intended split:

- approved normal-producer B1 rows expect missing derived Dependency as
  `MissingCoverage` and extra derived Dependency as `UnexpectedRecord`;
- decoder rows expect an unsupported extra Dependency at
  `LocalSemantic/Dependencies`; and
- `type-layout-authority-v1.md` already freezes dependency presence/equality as
  the local cross-field phase following relation/input pairing.

## Required correction

- Field-local Dependency validation owns raw row/reference/canonical-set and
  duplicate/conflict structure.
- After every field-local pass plus earlier reflection/alias/flag/pairing
  closures, local cross-field validation derives the exact Dependency set from
  the TypeSchema DTO and compares it. Missing is `MissingCoverage/LocalSemantic`;
  extra is `UnexpectedRecord/LocalSemantic`; a same-coordinate content/ABI conflict
  remains the earlier canonical conflict literal.
- ModuleSnapshot graph owns target existence, entity/category, actual owner/module,
  stored declaration ABI and schema/declaration record coverage. It does not repeat
  the already-proven DTO-derived set-equality rule.
- Distinguish the local missing-row physical Dependencies-array/enclosing-field
  error offset from a nonexistent public missing-row coordinate; an extra row may
  use its physical indexed Dependency coordinate.

Every other packet question had no reported Critical/Important finding. The
separate eleven-form/captured-coordinate audit returned 0C/0I/0M. A repaired
four-file candidate requires new identities, a refreshed packet and fresh atomic
review.
