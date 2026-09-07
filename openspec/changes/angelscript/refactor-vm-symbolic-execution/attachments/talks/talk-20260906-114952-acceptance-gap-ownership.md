# Acceptance-gap ownership decisions

## Context and evidence

The user requested Replan with finer missing sub-tasks and an audit Review. The fixed-snapshot External Review review-20260906-112533-acceptance-gaps-reviewer.md records ten open Required findings. Historical 19 checked cards and two 704/704 runs coexist with explicit unproved required Cases. Planning state and residual ownership must change; the accepted requirements remain valid.

## Options

- Rewrite old completed cards as pending: loses the permanent task/evidence history and violates the task contract.
- Treat family-level GREEN as complete acceptance: leaves verifier, publication, lifecycle and source failures outside accountable proof.
- Preserve historical work and add bounded follow-up owners: retains progress while making each independent missing contract executable.

## Settled decision

Choose the third option. Preserve IDs, checkboxes, case text and original RunIds. Metadata/fingerprint groups 1.1-1.3 remain preserved; affected later groups receive needs_followup with new IDs. tasks.md alone owns state; the Review and acceptance matrix carry findings and proof relationships.

Keep the already accepted immutable-declaration contract by placing code/frame/unwind/native data in asCExecutableFunction sidecars owned by the snapshot. A clone or post-freeze scriptData/sysFuncIntf patch would make declaration identity and failed-link rollback ambiguous. Private candidate preparation plus one Engine-generation publication is the selected implementation boundary.

Advance incomplete bytecode wire FormatVersion=1 to 2 when adding the required canonical/frame/source data. Explicit rejection is preferable to silently interpreting missing contracts. Cache mode one is unchanged: destination definitions and mutable resources are supplied independently. This is not a definition loader or a cache migration project.

Keep one actual interpreter and the minimal SDK Engine runtime owner. Header recovery is restricted to established SDK allocation domains; native handles and funcdefs use declared type-domain dispatch. Source production continues to consume canonical AST/types and the same image contract, with no second AST, VM, source parser or diagnostics framework.

## Consequences and flip condition

Twenty-three follow-ups separate image contracts, verification, publication, runtime services, opcode execution, source lowering and cache acceptance. They are feature groups with complete positive/negative/boundary oracles, not one-test tasks. Shared builds are allowed for compatible Ready groups with stopped writers and exact proof mapping.

No requirement is weakened, legacy subsystem is enabled or product file is edited by this decision. A discovered impossible maintained ABI, unsupported required opcode or need for a second runtime owner would invalidate an accepted boundary and require evidence-backed Replan; a local assertion failure does not.

The original Review remains open with CHANGES_REQUIRED. New task assignment is not a verified repair or a reason to close the Review.
