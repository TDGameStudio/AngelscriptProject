# B2 Slice 5 authority-correction proposal final review

Date: 2026-08-09 (Asia/Shanghai)

Reviewed proposal:
`b2-slice5-authority-correction.md`

Reviewed exact identity:

```text
SHA-256 D48D94CF54288A09E12400AAA830A0063285D9AAE23D7E7F55E9DE9C746C18E1
bytes   23066
LF      432
CR      0
final LF yes
```

Independent read-only disposition: **RELEASE — 0 Critical / 0 Important /
1 Minor**.

This releases only the combined normative-authority and non-normative producer-
audit amendment described by proposal section 10. It does not authorize Runtime
or test-source edits, approve a Slice-5 ready packet, close B2, claim focused RED
or authorize B3.

## Independently verified boundaries

- Actual DTO/header SHA-256:
  `CE9BF77DE6C4AD969ADC7E3F8754FBBE78C7ADDAEA15D1F9E9EB818C3426FDD7`.
- Producer SHA-256:
  `DB2E14808A533B8BF279A8FDDEECCA1C42973BD90543DECBDBCA97F3F26C6FC4`.
- Frozen test-source frontier SHA-256:
  `9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32`.
- No fictional captured container remains. The proposal uses only actual
  `TypeSemanticFlags`, indexed `Relation`, indexed `LayoutInput`,
  `LayoutExpectation`, indexed `OrderedProperty`, indexed `OrderedMethod`,
  indexed `VirtualFunctionSlot`, indexed `BehaviorSlot`, `Reflection` and indexed
  `ReflectedFunctionMember` coordinates.
- Present forbidden rows use their physical array index; Class count mismatch
  uses the first unmatched physical Behavior row; missing form-selected rows use
  `Reflection` because the absent row has no coordinate. The fallback covers
  ordinary UClass, UStruct, statics and every other legal form.
- Base-relation-driven LayoutInput pairing remains outside reflection-form closure
  and uses the requiring `Relation` or extra `LayoutInput` row.
- Behavior optional-owner validation has one active-value phase and one later tag
  phase. Script present-zero wins before ordinal faults; Script absent and
  Environment present lose to ordinal faults, then return `InvalidPresence`;
  inactive Environment owner values are never interpreted.
- Earlier arrays remain form-independent. Reflection and Dependencies local
  validation finish before `ReflectionFormClosure`; aliases, flag coupling,
  existing pairing/coverage/layout replay and final TypeLayoutHash remain later.
- IC-172/173, presence-only script owner routing, duplicate FunctionKey,
  TemplateCallback, finalizer discipline and Slice-6 stale-hash ownership have no
  regression.

## Accepted Minor and mandatory transcription rule

The proposal table's “too many rows of a required singleton Relation kind” and
“too many rows of a required singleton LayoutInput kind” entries are unreachable
after the required field-local canonical pass. A second singleton authority
coordinate already returns `DuplicateKey` or `ConflictingKey` at the second
matching physical row before `ReflectionFormClosure`.

The normative patch must therefore replace those two rows with that explicit
pre-closure rule. It must not preserve or implement them as closure failures. This
Minor does not hold the proposal release, but the next exact authority patch must
incorporate it and receive its own independent review.
