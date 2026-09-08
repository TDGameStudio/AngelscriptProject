# Acceptance-gap proof ownership

This is an acceptance mapping, not a second task list or completion authority. tasks.md retains all 19 historical completed nodes and owns 23 pending follow-ups. The fixed-snapshot External Review review-20260906-112533-acceptance-gaps-reviewer.md remains CHANGES_REQUIRED with F01-F10 open. Cases below are planned proof, not newly executed results.

## Finding-to-proof mapping

| Finding | Historical owner | Follow-up | Minimum independent closure oracle |
|---|---|---|---|
| F01 operand/frame/CFG/unwind admission | 2.1, 2.2, 2.3 | 6.3, 6.4, 6.5 | Direct and decoded wrong-tag JMP and negative local reject; width/slot/CFG/call/live-state errors identify failing instruction; valid terminating loops and guarded cleanup pass. 6.5 adds unterminated fallthrough, signature-derived CALLSYS effects and Normal/Exception-disjoint cleanup. |
| F02 immutable executable ownership and atomic link | 2.3, 3.1, 3.2 | 7.1, 7.2, 7.3 | Original declarations/witnesses unchanged; F-good/G-late-failure installs nothing; corrected retry succeeds; resource/global counts unchanged and one publication winner. 7.3 adds Context/publication snapshot leases and non-recursive native/no-code Prepare. |
| P01 Context snapshot lease | 7.1 | 7.3 | Prepare, release caller snapshot, Execute still 42; Context teardown then allows snapshot destroy. |
| P02 ActiveScriptData self-recursion | 7.1 | 7.3 | Bound native Prepare/Execute does not recurse; missing script body returns asNO_FUNCTION. |
| P03 call-effect and termination | 6.4 | 6.5 | CALLSYS without argument pushes rejects; PshC4-only body rejects fallthrough. |
| P04 path-sensitive cleanup | 6.4 | 6.5 | Disjoint Normal/Exception destroys of one slot succeed; out-of-range InstructionIndex and empty-Requirements TypeSlot reject. |
| P05 adjacent dispatch destructor | 8.2 | 8.3 | Two distinct delegate receivers each destroy exactly once; BoundCallUnboundNativeThrows remains MissingBinding at link. |
| F03 each maintained opcode | 3.1-3.6, 4.2 | 9.1, 9.2, 9.3, 11.3 | 213 assigned rows each name full test identity and actual executed/rejected path with literal value/state/lifetime/error oracle; all reserved/pseudo values reject. |
| F04 complete native ABI/dispatch targets | 3.2, 3.4 | 8.1, 8.2 | Full supported return/argument widths/modes, object-first/last and adjusted receiver guards; authentic interface/funcdef plus script/native/delegate CALLBND target acceptance/rejection. |
| F05 object domains and lifecycle | 3.3, 3.5, 3.6 | 8.3, 8.4, 8.5, 8.6 | Native handle never becomes function/header; partial constructors unwind completed members only; atomic held refs, suspended-cycle roots, Context limits/hooks and callback shutdown drain preserve exact ownership. |
| F06 authenticated definition-free cache | 1.1/1.2 consumers, 2.1, 2.3, 4.1, 5.5 | 6.1, 7.2, 11.1, 11.2 | Full signature/qualifier/mode/schema/layout/witness/dependency mismatches reject; same nominal key is not sufficient; manual fresh B executes with its pointers after A destruction. |
| F07 source admission and typed lowering | 5.1, 5.2, 5.3 | 10.1, 10.2, 10.3 | Unverified/foreign/unsupported source has no artifact; double subtraction/multiplication/division produce 6.5/10/4.5, all source shapes agree; references/defaults preserve actual addresses and effects. |
| F08 source normal/exception cleanup | 5.2, 5.4, 5.5 | 10.3, 10.4, 10.5, 11.2 | Constructor ordinals roundtrip; nested scope trace [2,3,1], correct while/for transfers; completed-only reverse unwind, owned source/call-site and subsequent Recovery=97. |
| F09 completion/provenance | 4.2 and all residual required Cases | 11.3 | No unfulfilled required Case hidden behind a checked historical card; new source/binary digest manifest, exact NativeEngine/Baseline reports and resolved Review evidence. |
| F10 bounded complete deterministic wire | 2.1 | 6.2 | Declared-length UTF-8 read, no input overread; complete witness/frame/unwind/source roundtrip, independent golden bytes, remapped deterministic order and version/target/resource rejection. |

## Original task dispositions

| Original ID | Disposition | Remaining owner or preserved boundary |
|---|---|---|
| 1.1 | preserved | Retain actual metadata/fingerprint cases; downstream executable/cache guarantees are separately owned. |
| 1.2 | preserved | Retain actual metadata/fingerprint cases; downstream executable/cache guarantees are separately owned. |
| 1.3 | preserved | Retain actual metadata/fingerprint cases; downstream executable/cache guarantees are separately owned. |
| 2.1 | needs_followup | 6.1, 6.2, 6.3 |
| 2.2 | needs_followup | 6.3, 6.4, 6.5 |
| 2.3 | needs_followup | 7.1, 7.2, 7.3 |
| 3.1 | needs_followup | 9.1, 9.2, 9.3 |
| 3.2 | needs_followup | 8.1 |
| 3.3 | needs_followup | 8.3 |
| 3.4 | needs_followup | 8.2 |
| 3.5 | needs_followup | 8.4 |
| 3.6 | needs_followup | 8.5, 8.6 |
| 4.1 | needs_followup | 11.1 |
| 4.2 | needs_followup | 11.3 |
| 5.1 | needs_followup | 10.1, 10.2 |
| 5.2 | needs_followup | 10.2, 10.4 |
| 5.3 | needs_followup | 10.3 |
| 5.4 | needs_followup | 10.3, 10.4, 10.5 |
| 5.5 | needs_followup | 11.2 |

A needs_followup annotation does not remove the original checkbox, command, case list or evidence. Existing metadata groups 1.1-1.3 remain preserved; follow-up consumers complete executable admission and richer dispatch without relabeling their old proof. No requirement has been dropped or converted into an optional future feature.

## Independent handoffs and scheduling

| Producer | Handoff | Consumers |
|---|---|---|
| 6.1 | Existing requirement type carries full canonical witness/signature/dependency contracts | 6.3, codec/link/cache |
| 6.3 | One opcode descriptor authority and DWORD frame/live/unwind/source representation | 6.2, 6.4, 7.1 |
| 6.2 / 6.4 / 7.1 | Complete wire, verified immutable image, separately owned executable records | 7.2 publication |
| 7.2 | Atomic compatible Engine bindings and leases | Runtime groups, opcode matrices, source admission |
| 8.3 / 8.5 | Partial-construction lifetime and runtime cleanup/Context observations | 10.4 lexical destroy; 10.5 consumes those services |
| 10.5 | Source-emitted exception pipeline (emit, Finish remap, linker objVariable*/lineNumbers, EXCEPTION CleanStack, SCRIPT/SDK dtor) | 11.2 source cache |
| 10.5 / 11.1 | Complete bounded source unwind records and fresh-Engine cache contracts | 11.2 integration |
| All follow-ups | Exact executed cases and unchanged source/binary identity | 11.3 final reconciliation |

Dependencies mean a consumed contract must be proven first. Overlapping Files are serialized separately; no dependency is invented solely to order writers. Compatible Ready groups can share a build and proving process with exact case maps. Implementing dependent services before their prerequisites pass merely to fill one batch is not grouped TDD.

## Evidence retained and not claimed

- Historical NativeEngine RunIds bf8cfb03ed9a4607b347c40a1442660f and 6f4ed80cd8fa46369d45f2e6bf6f4049 each report 704/704. Actual interpreter/source/cache progress is retained.
- Historical Baseline 93bdb999a8174b809010337c778ba330 has three successful cases, including warning-bearing success and 2,436 LogMetaSound warnings; these are not silently converted to zero-warning proof.
- The materialized Review snapshot authenticates reviewed files, not historical binary provenance. No new runtime counterexample, RED/GREEN, build or Automation run is claimed by this planning update.
- Review task ownership is accepted triage only. Findings stay open until original resolution conditions and fresh evidence are appended and re-evaluated.
