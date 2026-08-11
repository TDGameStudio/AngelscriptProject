# B2 Slice 5 authority-correction proposal review

Date: 2026-08-09 (Asia/Shanghai)

Reviewed proposal:
`b2-slice5-authority-correction.md`

Reviewed exact identity:

```text
SHA-256 31491B8837618B5B7957AEDE0C8EA9DB230707A253F86455B01E3D6E80370A98
bytes   14667
LF      310
CR      0
final LF yes
```

Independent read-only disposition: **HOLD — 0 Critical / 6 Important / 1 Minor**.
No normative authority or source edit was authorized from this SHA.

## Findings and required dispositions

1. **Duplicate FunctionKey classification** — one Method/VFT array uses
   FunctionKey as the complete duplicate coordinate. Any second row with the same
   key and distinct valid ordinal is `DuplicateKey`; owner/ABI differences do not
   create `ConflictingKey` locally.
2. **Behavior optional owner priority** — Script absent is `InvalidPresence`,
   Script present-zero is `ZeroStableKey`, Environment absent is admissible, and
   Environment present with any value is `InvalidPresence` without interpreting
   the inactive value.
3. **Cross-field closure order** — `ReflectionFormClosure` cannot precede
   Dependencies. Every field-local check through Dependencies must pass before any
   form/flag cross-field closure. The statics checklist and deterministic first
   captured coordinate must be complete.
4. **Flag/Behavior literals and coordinates** — select exact errors and decoder
   captured fields for HasDefault necessary conditions and both HasDestructor
   directions; reconcile approved Slice-1 `InvalidQualifierCombination` rows with
   older decoder `InvalidPresence` expectations.
5. **Ordinal and row-subfield precedence** — provide one phased algorithm covering
   raw enum preflight, stored-row key/ABI validation, duplicate/gap/order scans,
   role/owner rules, duplicate FunctionKey and aliases, including paired winners.
6. **Final-hash single-fault discipline** — every representable non-hash mutation,
   including raw/zero/wrong-kind rows, must recompute TypeLayoutHash. Earlier error
   priority does not authorize a second stale-hash fault owned by Slice 6.
7. **Minor evidence wording** — cardinality-zero expected validity varies with
   unencoded Kind/target; the four owner cases are identical repetitions but do not
   themselves flip the expectation. The 952 count and removal remain correct.

The review otherwise accepted the direction of IC-172/173, presence-only local
script owner validation, graph-owned exact owner and zero-parameter semantics,
copy alias rules, and capture-time NotCacheable versus explicit-DTO
`InvalidPresence` for TemplateCallback.

## Repair state

The primary agent repaired all seven findings after this review completed. The
repaired proposal is a new, independently reviewable identity; this review does
not approve it. A fresh exact-file review must return 0 Critical / 0 Important
before any normative authority patch is authored.
