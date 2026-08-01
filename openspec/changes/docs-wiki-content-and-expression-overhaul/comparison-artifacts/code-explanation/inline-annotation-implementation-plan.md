# Single-Column Inline Annotation HTML Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build four independent, offline, single-column HTML experiments that attach fully expanded explanations directly to AngelScript or C++ source.

**Architecture:** Each HTML owns its CSS, source model, annotation model, UI, validation hook, and interaction code. All four use the same observable contract (`data-action`, `data-source-id`, `data-annotation-id`, `window.__CODE_EXPLANATION_PREVIEW__`) so one Playwright validator can test them without introducing a shared runtime dependency.

**Tech Stack:** Standalone HTML/CSS/JavaScript, inline SVG only where a local bracket or underline needs it, Playwright from `Wiki/node_modules/@playwright/test`, Node.js ESM validator.

## Global Constraints

- Work in the current `main` checkout; do not create or switch worktrees.
- Do not modify `Wiki/` or any plugin submodule.
- Create exactly four new numbered HTML experiments: `05`–`08`.
- Keep source and annotations in one vertical reading axis at every viewport.
- Show all primary annotations by default.
- Keep source text separate from annotation DOM and expose clean copy text.
- Use no external fonts, scripts, images, CDNs, or network resources.
- Keep motion finite and limited to local `120–180ms` emphasis; honor reduced motion.
- Do not mark the experiments as formal Wiki `built` or `tested` components.
- Do not commit from the dirty shared `main` checkout unless the user separately requests a commit.

---

### Task 1: Add the acceptance validator and establish RED

**Files:**
- Create: `openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/validate-inline-annotations.mjs`
- Reference: `openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/inline-annotation-design.md`

**Interfaces:**
- Consumes: target filenames `05-as-interlinear-notes.html`, `06-as-expression-footnotes.html`, `07-cpp-block-commentary.html`, `08-as-runtime-annotations.html`
- Produces: one executable validator that exits `0` only when all four standalone artifacts satisfy the shared contract

- [ ] **Step 1: Write the failing validator**

Create a Node ESM script with this target contract:

```javascript
const targets = [
  { file: "05-as-interlinear-notes.html", expectedAnnotations: 5 },
  { file: "06-as-expression-footnotes.html", expectedAnnotations: 5 },
  { file: "07-cpp-block-commentary.html", expectedAnnotations: 5 },
  { file: "08-as-runtime-annotations.html", expectedAnnotations: 6, expectedScenarios: 3 }
];
```

For every target, statically require:

```javascript
{
  doctype: /^<!doctype html>/i,
  inlineStyle: /<style>[\s\S]*<\/style>/i,
  inlineScript: /<script>[\s\S]*<\/script>/i,
  noExternalAssetTag: !/<(?:script|img|link)\b[^>]*(?:src|href)\s*=/i
}
```

In Chromium with `reducedMotion: "reduce"`, require:

```javascript
audit.errors.length === 0
audit.annotationCount === expectedAnnotations
document.querySelectorAll("[data-annotation-id]").length === expectedAnnotations
root.dataset.annotations === "visible"
document.documentElement.scrollWidth === document.documentElement.clientWidth
```

Then click `[data-action="toggle-notes"]`, verify every annotation is hidden, click again, and verify all annotations return. Validate `sourceText()` contains the displayed function signature but none of `WHY`, `RESULT`, `OWNERSHIP`, or annotation prose. Focus the first annotation button, press Enter to pin its relation, then press Escape and require zero pinned elements. Repeat page overflow and audit checks at `390×844`. For `08`, click all three `[data-scenario-id]` controls and require one `aria-pressed="true"` plus a matching `selectedScenario`.

- [ ] **Step 2: Run the validator and verify RED**

Run:

```powershell
node openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/validate-inline-annotations.mjs
```

Expected: non-zero exit with `missing 05-as-interlinear-notes.html` as the first contract failure.

### Task 2: Implement 05 AS interlinear notes

**Files:**
- Create: `openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/05-as-interlinear-notes.html`
- Test: `openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/validate-inline-annotations.mjs`

**Interfaces:**
- Consumes: exact `ApplyDamageToTarget` source from `Script/Examples/Extended/Example_InterfaceDispatch.as`
- Produces: five fully expanded annotations with IDs `contract`, `guard`, `dispatch`, `decision`, `side-effect`

- [ ] **Step 1: Implement the minimal standalone page**

Use one centered source paper. Render every explanation immediately before its related code range:

```html
<button class="annotation annotation--guard"
        data-annotation-id="guard"
        data-source-ids="src-guard src-return"
        type="button">
  <span class="annotation-kind">GUARD</span>
  <strong>先证明对象存在，再允许方法分派</strong>
  <span>条件成立时直接结束；后面的调用不再需要重复处理空值。</span>
</button>
```

Expose:

```javascript
window.__CODE_EXPLANATION_PREVIEW__ = {
  audit,
  sourceText: () => SOURCE
};
```

Implement visible-by-default notes, hide/show, copy source with a textarea fallback, local hover/focus relation emphasis, Enter/click pin, Escape clear, and reduced-motion CSS.

- [ ] **Step 2: Run the validator**

Expected: `05` passes, then the validator exits non-zero with `missing 06-as-expression-footnotes.html`.

### Task 3: Implement 06 AS expression footnotes

**Files:**
- Create: `openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/06-as-expression-footnotes.html`
- Test: `openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/validate-inline-annotations.mjs`

**Interfaces:**
- Consumes: the same exact `ApplyDamageToTarget` source as Task 2
- Produces: five fully expanded, token-ordered footnote groups for `Target`, `ApplyDamage`, `Remaining`, `IsAlive`, and the formatted death log

- [ ] **Step 1: Implement the minimal standalone page**

Mark tokens without inserting explanatory text into their copy value:

```html
<span class="annotated-token" data-source-id="src-apply" data-note-ref="apply">
  ApplyDamage<sup aria-hidden="true">②</sup>
</span>
```

Place each full footnote group immediately after the code line that owns it:

```html
<button class="footnote" data-annotation-id="apply"
        data-source-ids="src-apply" type="button">
  <span class="footnote-mark">②</span>
  <span><strong>动态分派点</strong>运行时对象决定实际实现，并可能修改目标状态。</span>
</button>
```

Reuse the shared observable contract without importing Task 2.

- [ ] **Step 2: Run the validator**

Expected: `05` and `06` pass, then the validator exits non-zero with `missing 07-cpp-block-commentary.html`.

### Task 4: Implement 07 C++ block commentary

**Files:**
- Create: `openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/07-cpp-block-commentary.html`
- Test: `openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/validate-inline-annotations.mjs`

**Interfaces:**
- Consumes: control-flow excerpt of `FAngelscriptRuntimeModule::InitializeAngelscript()`
- Produces: five semantic blocks for gate, test seam, subsystem delegation, ambient adoption, and module ownership

- [ ] **Step 1: Implement the minimal standalone page**

Each annotation precedes exactly one contiguous C++ block and contains:

```html
<button class="block-commentary" data-annotation-id="test-seam"
        data-source-ids="src-test-start src-test-push src-test-return"
        type="button">
  <span class="block-label">TEST SEAM</span>
  <dl>
    <div><dt>WHY</dt><dd>让自动化测试替换主引擎并隔离生产启动路径。</dd></div>
    <div><dt>OWNERSHIP</dt><dd>test-provided</dd></div>
    <div><dt>INVARIANT</dt><dd>命中覆写后必须从函数返回。</dd></div>
  </dl>
</button>
```

Preserve exact branch and ownership semantics while labeling the code as a control-flow excerpt.

- [ ] **Step 2: Run the validator**

Expected: `05`–`07` pass, then the validator exits non-zero with `missing 08-as-runtime-annotations.html`.

### Task 5: Implement 08 AS runtime annotations

**Files:**
- Create: `openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/08-as-runtime-annotations.html`
- Test: `openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/validate-inline-annotations.mjs`

**Interfaces:**
- Consumes: exact `ApplyDamageToTarget` source and three scenario models
- Produces: six always-expanded runtime annotations whose fields update for `missing`, `survives`, and `dies`

- [ ] **Step 1: Implement the minimal standalone page**

Define scenario data:

```javascript
const scenarios = {
  missing: {
    target: "nullptr",
    guard: "true · return",
    call: "skipped because Target is null",
    alive: "skipped",
    print: "skipped",
    final: "no observable change"
  },
  survives: {
    target: "AExampleDamageableActor",
    guard: "false · continue",
    call: "CurrentHealth 100 → 75 · Remaining 75",
    alive: "true · skip death branch",
    print: "skipped because IsAlive() is true",
    final: "Health = 75"
  },
  dies: {
    target: "AExampleDamageableActor",
    guard: "false · continue",
    call: "CurrentHealth 20 → 0 · Remaining 0",
    alive: "false · enter death branch",
    print: "\"AExampleDamageableActor is dead!\"",
    final: "Health = 0 · death log emitted"
  }
};
```

Each `RESULT` annotation remains in the document and updates its `[data-field]` text plus `data-execution="executed|skipped"`.

- [ ] **Step 2: Run the validator and verify GREEN**

Expected: exit `0`, four files pass, twelve total interaction paths pass (`4` base pages plus `3` runtime scenarios and responsive/visibility checks).

### Task 6: Perceptual review, final verification, and OpenSpec completion

**Files:**
- Modify: `openspec/changes/docs-wiki-content-and-expression-overhaul/tasks.md`
- Review: all four new HTML files

**Interfaces:**
- Consumes: validator-green standalone pages
- Produces: screenshot-reviewed artifacts and completed OpenSpec task `2.8`

- [ ] **Step 1: Capture eight full-page screenshots**

Capture desktop `1440×1000` and mobile `390×844` screenshots for `05`–`08`, with reduced motion enabled.

- [ ] **Step 2: Inspect screenshots**

Check source hierarchy, annotation adjacency, code-container-only horizontal scrolling, default expanded density, readable labels, and absence of a reconstructed second column. Perform at most two focused visual correction rounds.

- [ ] **Step 3: Re-run the complete validator**

Run:

```powershell
node openspec/changes/docs-wiki-content-and-expression-overhaul/comparison-artifacts/code-explanation/validate-inline-annotations.mjs
```

Expected: exit `0`, zero audit errors, zero runtime errors, zero external requests, zero desktop/mobile page overflow.

- [ ] **Step 4: Mark OpenSpec task 2.8 complete**

Change only the `2.8` checkbox from `[ ]` to `[x]` after Step 3 passes.

- [ ] **Step 5: Report truthful delivery receipt**

Report:

```text
validation: passed
visual_review: passed
correction_rounds: <0..2>
```

Also report that the broader OpenSpec change remains open and that no commit, submodule edit, worktree, or branch integration was performed.
