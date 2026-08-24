# Authored Contract V2 alignment baseline

This note preserves the exact SHA-256 identities of the four existing artifacts immediately before the narrow authored-export alignment on 2026-08-24. The alignment does not rewrite the generated inventory or the thousands of per-fixture tasks; it changes only the shared authored-export gate and its two implementation tasks.

- `proposal.md`: `6B8BFC705A5CB744669E74E20B8298A09B3DA2312680BBB12DE34FD0B693E8FC`
- `design.md`: `E101FC30B3426BBCD30B5B52925074EC64DC4AA697874680E8F9420FCB9B13BE`
- `tasks.md`: `5C3739CF831E519360D4A801178642DC8E8236E528DA2A71170263C9E8C0C7D4`
- `specs/as-test-source-generation-rules/spec.md`: `926C60B7E5E413CDD6D050671EF0F922063437B4569F112E920985985FC104FA`

The pre-alignment Task 1.27 requested parity for 614 authored CaseKeys and said their exported result retained observation/comment/reference fields. Task 1.28 read `TestSource/Generation/Rules/Authored/index.json` and described the manual AS as source of truth, but neither task required Contract V2 review, exact source declarations, typed invocation vectors, writeback/exception oracles, or source/contract parity. The amendment below adds those gates and forbids declaration inference from legacy `plannedSymbols`.
