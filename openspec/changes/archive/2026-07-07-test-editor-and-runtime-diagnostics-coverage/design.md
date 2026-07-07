## Context

The test module has a few very dense theme families, but some of the thin ones are still important because they cover editor-facing navigation, runtime dump output, GC and memory lifecycle, and validation rules. Those areas are easy to miss because there are only one or two files in each bucket, but they matter because they anchor behaviors that are hard to diagnose once they regress.

## Goals / Non-Goals

**Goals:**
- Add a first-wave coverage plan for the thin editor and diagnostics-adjacent themes.
- Keep each theme’s ownership visible and separate.
- Make the verification path explicit for each theme family.
- Keep the change focused on test coverage and documentation.

**Non-Goals:**
- Do not rework the full editor module or the runtime dump architecture.
- Do not fold these themes into the bindings or functional runtime changes.
- Do not introduce a new test infrastructure layer.

## Decisions

### 1. Keep the coverage expansion theme-owned

Each theme remains in its current directory and keeps its current Automation prefix family. The point is to fill in missing coverage, not to reshuffle the suite taxonomy.

Alternatives considered:
- Create a new umbrella diagnostics layer. Rejected because it would obscure the current ownership model.
- Move all thin themes into one cross-cutting file. Rejected because that would make them harder to maintain.

### 2. Treat the editor and diagnostics themes separately from the runtime behavior themes

Editor navigation, dump export, performance, memory, GC, and validation are all different enough that a combined change would be hard to review. They stay in one OpenSpec change because they are all thin and underrepresented, but they keep their own files and verification prefix boundaries.

Alternatives considered:
- Split every theme into its own change. Rejected because the result would be too many tiny OpenSpecs for a first-wave coverage pass.

### 3. Prefer first-wave coverage over completeness

The goal is not to fully populate every thin directory in one pass. The goal is to establish a credible baseline in each underrepresented bucket so future contributors have a clear place to continue.

Alternatives considered:
- Try to make every thin directory complete immediately. Rejected because the scope would become too large and would drag in unrelated runtime work.

## Risks / Trade-offs

- [Risk] The change may mix several small themes under one change. → Mitigation: keep the tasks separated by directory and verify each prefix independently.
- [Risk] Some themes, especially editor-facing ones, may depend on headless/editor context differences. → Mitigation: make the verification entry points explicit and keep headless limitations documented.
- [Risk] The thin themes are varied enough that one set of tasks may not fit all of them. → Mitigation: use the design as a coverage umbrella and let the tasks stay file-specific.

## Migration Plan

1. Add the first-wave tests for the editor, networking, and dump themes.
2. Add the thin-theme diagnostics and lifecycle cases for performance, memory, GC, and validation.
3. Update the test catalog and test guide with the new coverage map and verification entry points.
4. Run the themed prefixes, then the build gate, to confirm the suite still discovers cleanly without pulling unrelated suites into this change.

## Open Questions

- Which thin-theme files should receive positive assertions immediately, and which should remain explicit boundary tests for now?
- Do any of the editor-facing cases need a special harness beyond the current `EditorContext` patterns?
