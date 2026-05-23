## Context

The binding test suite already has a strong CQTest foundation, but nine files still carry 34 placeholder or skipped binding cases. Some of those cases are genuine binding gaps, some are headless or environment-limited, and some are really test-shape problems. The current structure does not distinguish those categories clearly enough, which makes the suite noisy and less useful as a regression signal.

## Goals / Non-Goals

**Goals:**
- Turn the covered binding-gap cases into explicit, testable outcomes.
- Keep the existing `Bindings` directory structure and Automation prefix family stable.
- Make headless or environment-limited cases explicit instead of silent.
- Keep the binding coverage aligned with the current test catalog and test guide.

**Non-Goals:**
- Do not introduce a new Automation group or rename the existing binding theme prefixes.
- Do not attempt a broad binding-layer refactor beyond what is needed to support the restored coverage.
- Do not convert this into a general runtime feature change plan.

## Decisions

### 1. Update the affected binding files in place

The covered cases stay in their current thematic files rather than being moved into a new helper layer or a fresh directory. That keeps discovery stable and lets the existing CQTest patterns continue to do the work.

Alternatives considered:
- Create new companion files for every gap cluster. Rejected because it would fragment the existing binding themes and increase review overhead.
- Fold everything into one mega binding test file. Rejected because it would erase the theme boundaries that already make the suite readable.

### 2. Treat gaps in three buckets

The change will classify the current placeholders as one of three things:
- a missing runtime binding that should be exercised directly once present,
- a headless or environment-limited behavior that should remain an explicit negative boundary, or
- a test-shape issue that should be rewritten into an executable assertion.

Alternatives considered:
- Mark every skipped case as disabled forever. Rejected because it hides real binding debt.
- Force every case into a positive assertion. Rejected because some cases are true environment boundaries and should remain honest about that.

### 3. Keep the coverage harness unchanged

The current CQTest + `FCoverageModuleScope`-style coverage pattern remains the harness for these files. The change should stay compatible with the existing `Angelscript.TestModule.Bindings.*` discovery path and the project standard `RunTests.ps1` entry point.

Alternatives considered:
- Introduce a new binding-specific harness. Rejected because the current harness already fits the suite and the change is about coverage, not infrastructure.

## Risks / Trade-offs

- [Risk] Some cases may still require runtime binding additions, not just test rewrites. → Mitigation: split the work by file cluster so the spec can distinguish coverage restoration from missing runtime surface additions.
- [Risk] Headless environment limits may prevent some cases from becoming fully positive tests. → Mitigation: keep those cases as explicit negative contracts with concrete reasons instead of silent skips.
- [Risk] Test catalog drift if the coverage surface changes without documentation. → Mitigation: include docs sync in the tasks and verify the binding prefix run after each cluster.

## Migration Plan

1. Classify the current placeholder cases by binding cluster and outcome type.
2. Restore the geometry/math cases first, because they are the clearest binding-shape gaps.
3. Restore the platform/path/profiler cases next, then the string/delegate/memory/component-adjacent cases.
4. Update the test catalog and guide after the code changes land.
5. Run the targeted bindings prefix and the standard build to confirm the suite still discovers cleanly.

## Open Questions

- Which of the currently skipped cases should remain explicit negative boundaries because the branch still lacks the underlying runtime behavior?
- Which of the string/delegate and memory/component cases should be solved by runtime binding additions versus test rewrites?
