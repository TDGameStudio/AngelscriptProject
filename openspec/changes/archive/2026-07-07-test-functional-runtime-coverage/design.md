## Context

The functional theme directories are the right place to validate behavior that needs an actual `FAngelscriptEngine` and, in some cases, real object lifecycle or runtime dispatch. A subset of the current tests already do that. The problem is the remaining placeholder cases: they read like success but only prove compilation, or they explain a runtime limitation in a way that is easy to overlook when scanning the suite.

## Goals / Non-Goals

**Goals:**
- Turn supported functional cases into explicit runtime assertions.
- Keep unsupported cases explicit, named, and documented as negative boundaries.
- Preserve the existing theme-based automation layout and file ownership.
- Keep the change small enough that each themed file can be reviewed independently.

**Non-Goals:**
- Do not rename the `Functional` prefix family or move these cases into a different layer.
- Do not add a new test harness or automation group.
- Do not attempt to rewrite the functional suite outside the four audited themes.

## Decisions

### 1. Update the themed files in place

The supported and unsupported cases stay inside the existing `Objects`, `Operators`, `Handles`, and `Inheritance` files. That keeps the runtime behavior close to the existing coverage and avoids creating a second parallel functional taxonomy.

Alternatives considered:
- Split each runtime case into a new file. Rejected because the existing files already own the theme and the work is about clarifying behavior, not expanding the directory tree.
- Fold the cases into a new generic runtime file. Rejected because it would blur the theme boundaries that make these tests easy to find.

### 2. Use runtime assertions whenever the branch can actually execute the code

When a case can run successfully, the test should assert the runtime result rather than only checking that compilation succeeded. When a case still cannot run on this branch, the test should remain an explicit negative contract with a concrete reason.

Alternatives considered:
- Leave compile-only placeholders in place. Rejected because they weaken the suite as a runtime contract.
- Force every case to become positive. Rejected because the branch still has real runtime gaps and the suite should remain honest about them.

### 3. Keep the existing helper model

The current `FAngelscriptEngine`-based runtime test patterns stay in use. Some files only need `CompileModuleFromMemory` or `BuildModule`; others may keep using the current helper wrappers if a case needs stronger lifetime control.

Alternatives considered:
- Introduce a new runtime helper abstraction. Rejected because it would add surface area without solving the actual coverage problem.

## Risks / Trade-offs

- [Risk] Some cases may still be blocked by real runtime branch gaps. → Mitigation: keep those cases as named negative boundaries rather than pretending success.
- [Risk] Runtime assertions may require slightly more setup than compile-only checks. → Mitigation: keep the changes local to each themed file and avoid introducing shared harness churn.
- [Risk] Functional tests can become ambiguous if they mix positive and negative cases without clear naming. → Mitigation: keep each case name explicit about what is being proven.

## Migration Plan

1. Audit the four targeted files and classify each placeholder as executable or intentionally negative.
2. Replace the executable placeholders with runtime assertions.
3. Keep any remaining unsupported cases explicit and documented.
4. Update the catalog and guide to reflect the runtime behavior surface.
5. Run the functional theme prefixes and then the broader functional prefix to confirm the discovery set stays stable.

## Open Questions

- Which of the current compile-only placeholders can be upgraded immediately without any runtime changes?
- Which remaining unsupported cases should stay as explicit negative contracts until a separate runtime change lands?
