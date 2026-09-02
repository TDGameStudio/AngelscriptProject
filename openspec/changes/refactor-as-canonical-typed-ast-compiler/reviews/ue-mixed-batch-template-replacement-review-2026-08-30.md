# UE mixed-batch template/replacement transaction review — 2026-08-30

## Verdict

CTA-S71 is accepted for the reviewed non-Standalone mixed-batch boundary. The
implementation now treats a UE source batch as a real candidate transaction at
three previously disconnected layers:

1. old active Engine visibility is a suppression that must be restored on
   aggregate failure;
2. old-to-new pointer replacement is candidate-sensitive and cannot mutate a
   module already known to be failed;
3. deferred template work is partitioned by complete request provenance and
   retired with explicit ownership handling.

This is materially stronger than the prior “keep the old module pointer in the
module map” behavior. The old executable could remain callable while Engine
lookup indexes, candidate dependency references and deferred template callback
state were already inconsistent. CTA-S71 closes those reviewed leaks.

The review does not accept the complete Task 13.6 sentence or authorize the
CANONICAL default flip.

Reviewed plugin implementation commit:
`7d3ce33110a53478e980518b41fe11830e43e8e5`.

## Findings and disposition

| Finding | Severity | Disposition |
|---|---|---|
| Same-name candidate suppression removed old type/function visibility with no failure restore | Critical | Fixed; all candidates reset first, then every suppressed old active module is restored |
| A successful candidate's replacement map could rewrite a failed candidate | High | Fixed; failed modules are excluded from replacement-template generation and broad reflection replacement |
| Deferred template queue lacked requesting-module provenance | Critical ownership/semantic risk | Fixed with transaction-local requestor tracking and two partition points |
| Blindly skipping all deferred work would starve healthy/shared requests | High | Avoided; healthy, shared and unknown-provenance entries are processed conservatively |
| Removing a failed-only raw queue pointer could cause UAF during candidate reset | Critical ownership risk | Fixed with a temporary internal rollback hold |
| Keeping the hold without distinguishing module and bucket ownership could leak/double-release | Critical ownership risk | Fixed with post-reset module/registry classification and balanced release |
| A later request can change a failed-only template into a shared template | High ordering risk | Fixed; the instance is requeued and reclassified at the Stage 4 partition |
| Existing or null-requestor template requests cannot be attributed safely | Compatibility risk | Conservatively marked unknown and processed, never discarded as failed-only |
| Retained LEGACY output-type determination still passed a null requestor | Shared-path gap | Fixed by passing `builder->module`; native AST/Builder/Compiler remain retained |
| Public/durable type identity could accidentally capture candidate pointers | Architectural risk | No new durable field; tracking is Engine-transaction-local and pointer-based only within that generation/build |

## Architecture assessment

### What is now sound

The compile lifecycle now has a coherent order:

```text
begin aggregate build + template provenance tracking
  -> suppress old same-name modules from Engine lookup
  -> run Stage 1/2 for staged candidates
  -> isolate candidates already known to be failed
  -> produce replacement maps only from healthy candidates
  -> partition failed-only new template instances
  -> layout/validate healthy, shared and unknown template work
  -> publish all candidates only if the aggregate batch succeeds
  -> otherwise reset/discard every candidate
  -> restore all suppressed old active modules
  -> retire failed-only templates and drop rollback holds
  -> end with a drained queue and one coherent last-good generation
```

This resembles the useful part of Clang's candidate/diagnostic/lowering
discipline: a rejected semantic unit is not lowered or published, and failure
cleanup restores the previous accepted state. It does not import Clang's C++
access-control complexity or require deleting AngelScript's native AST.

The template provenance map belongs in `asCScriptEngine`, not Public AST or a
dump, because it describes a mutable aggregate build transaction and stores
generation-local module/type pointers. The stable Canonical identity model
continues to use complete type/function/property keys and relocations; current
numeric TypeIds are projected only when installing into one Engine generation.

### Why two template partitions are required

The first partition protects `CalculateTemplateSize()` in the Layout phase.
The second protects `EvaluateTemplateInstances(false)` in Stage 4 and accounts
for instances created or newly requested between those points. One partition
would leave an ordering hole; a permanent rejected set would mishandle a later
healthy/shared request. Requeue-on-new-request plus a final partition makes the
decision monotonic with the complete information available at each phase.

### Why rollback cleanup is after candidate reset

The candidate module is one possible owner of a generated template instance.
Trying to fully discard the instance before `InternalReset()` can fight module
ownership and double-release. Waiting without a hold can free the raw pointer.
The temporary internal hold bridges exactly that interval. Post-reset cleanup
then observes whether module or registry ownership remains and releases the
corresponding owner before dropping the hold.

## Static review conclusions

- `CollectFailedScriptModules()` is evaluated at both deferred-work phase
  boundaries; it does not cache an earlier failure set.
- pre-existing and missing-provenance queue entries fail open to validation,
  not to deletion. This is the conservative compatibility behavior.
- successful/shared instances are drained by the existing Stage 4 Builder;
  failed-only instances are removed from the raw queue and retired later.
- the rollback restore executes only on aggregate failure. Successful
  compilation continues to retire the old generation through the existing
  success path.
- there are no early returns between tracking begin and end in the reviewed
  `CompileModules` body.
- external references can keep a retired template type alive, but it is no
  longer registered, queued or eligible for callbacks.
- no Public AST V1, Cache/Sidecar, provider ABI or stable-key format changed.

## Test and fixture quality review

The permanent tests target observable transaction invariants rather than
private implementation names:

- old Engine-wide lookup and automatic-import function visibility are restored;
- an exact dependency on B1 is not rewritten to doomed B2;
- healthy template size/callback work executes;
- failed-only template size/callback work does not execute;
- the queue count returns to zero;
- the last-good module pointers and executable results remain current.

The template test intentionally uses real `TOptional` behavior and script
payloads. Earlier syntax-, script-field- and primitive-instance fixtures were
discarded because they failed at a different phase or could reuse pre-existing
instances. Those explorations are recorded in the attachment rather than
being presented as production bugs.

The TDD cadence is appropriate for this risk cluster: one **3/6** RED, one
coherent implementation, one **6/6** GREEN and then broad gates. It preserves
test-first evidence without paying one UE startup per assertion.

## Verification reviewed

- build: **PASS**, 164 actions;
- BuilderIntegration: **6/6 PASS**;
- Compiler events: **7/7 PASS**;
- project Compiler: **85/85 PASS**;
- ProductionCodeGen: **150/150 PASS**;
- Compiler CanonicalAST: **631/631 PASS**;
- Frontend CanonicalAST: **175/175 PASS**;
- HotReload CanonicalAST: **12/12 PASS**;
- all listed runs have zero failures and zero skips;
- Standalone was not run, changed or claimed.

Exact RED/GREEN paths, ownership protocol and fixture exploration are in
`attachments/ue-mixed-batch-template-replacement-transaction-gate-2026-08-30.md`.

## Remaining risks

1. Full module publication is still not one universally detached transaction
   for every type/funcdef/global/import/function and every failure-injection
   phase.
2. Full-language Canonical Sema/CodeGen coverage remains incomplete; green
   prefixes are not authority to check 9.1/9.5/10.4/13.6.
3. The final default-selection, commandlet/generation entry-point and broad All
   gates remain open.
4. Standalone adaptation/verification is deferred to a separate future
   OpenSpec and is no longer a completion condition for this change's open
   cutover/final-gate tasks.
5. A direct shared healthy+failed requestor test is not presently separate;
   the implementation handles it conservatively because any non-failed
   requestor prevents quarantine. Unknown/pre-existing provenance follows the
   same process-don't-discard rule. This is a coverage opportunity, not an
   observed defect in the reviewed implementation.

## Progress conclusion

Formal task progress remains **101/136 = 74.3%**. The percentage does not move
because CTA-S71 is a substantial correctness closure under the still-open
umbrella Task 13.6. Architecturally, however, one of the most dangerous
remaining UE transaction gaps from CTA-S70 is now closed and fully recorded.
