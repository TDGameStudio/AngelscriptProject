# draw.io Plugin Integration Plan

**Goal:** Enable the audited `$:/plugins/Gk0Wk/drawio` plugin in AngelscriptWiki while retaining its source as ordinary Wiki-repository files.

**Architecture:** The draw.io package remains nested beneath the existing imported TiddlySeq source root. The external-plugin manifest drives the existing generated-source bridge, so ordinary Wiki development, tests, builds, and offline publish all include the plugin. The editor continues to use the approved `https://embed.diagrams.net/` iframe; saved SVG diagrams remain viewable offline.

**Constraints:**

- Source remote: `git@github.com:Gk0Wk/TiddlySeq.git`.
- Audited baseline: `96e48da076b86b475948a930ab5f60abe5961d77`.
- Expected plugin title: `$:/plugins/Gk0Wk/drawio`.
- Copy only the `drawio` package, not other TiddlySeq plugins or repository scaffolding.
- Do not enable the separately retained CodeMirror 6 package.

## File map

- Create: `Wiki/src/tiddlyseq/src/drawio/` — audited draw.io source package, including its `plugin.info` and in-plugin license tiddler.
- Modify: `Wiki/external-plugins.json` — declare draw.io as a selected runtime plugin.
- Modify: `Wiki/scripts/external-plugin-sources.test.mjs` — prove the real manifest validates draw.io and generates a flat copy.
- Modify: `Wiki/scripts/publish-offline.test.mjs` — prove offline library output contains draw.io.
- Modify: `Wiki/wiki/tiddlers/tests/playwright/document-experience.spec.ts` — prove the browser Wiki store loads draw.io.
- Modify: `Wiki/Agents.md` and `Wiki/Agents_ZH.md` — list draw.io among selected document plugins and state its online editor requirement.

## Task 1: Specify draw.io as a runtime integration

- [ ] Add a failing test in `Wiki/scripts/external-plugin-sources.test.mjs` that loads `external-plugins.json`, requires a `drawio` entry with `$:/plugins/Gk0Wk/drawio`, and calls `validateExternalPlugins` plus `prepareExternalPluginSources`.

```js
const drawio = manifest.plugins.find(({ name }) => name === 'drawio');
assert.deepEqual(drawio, {
  name: 'drawio',
  repository: 'git@github.com:Gk0Wk/TiddlySeq.git',
  baselineCommit: '96e48da076b86b475948a930ab5f60abe5961d77',
  repositoryPath: 'src/tiddlyseq',
  sourcePath: 'src/drawio',
  title: '$:/plugins/Gk0Wk/drawio',
});
```

- [ ] Run `npm run test:external-plugins` in `Wiki`; it must fail because the manifest and active source do not yet contain draw.io.
- [ ] Move the audited package from the local retired TiddlySeq source into `Wiki/src/tiddlyseq/src/drawio/` without copying unrelated packages.
- [ ] Add the manifest entry above and re-run `npm run test:external-plugins`; it must pass and create `.generated/plugin-sources/drawio/plugin.info`.

## Task 2: Verify published and browser-visible behavior

- [ ] Add `$:/plugins/Gk0Wk/drawio` to the offline-library assertion in `Wiki/scripts/publish-offline.test.mjs`.
- [ ] Add `$:/plugins/Gk0Wk/drawio` to the required loaded plugin titles in `Wiki/wiki/tiddlers/tests/playwright/document-experience.spec.ts`.
- [ ] Run `npm run test:publish:offline` and require its single Node test to pass.
- [ ] Run `npm run test:playwright` and require all Playwright tests to pass.

## Task 3: Document and commit the source integration

- [ ] Update both Wiki agent guides to list draw.io as selected and state that creating or editing diagrams accesses `https://embed.diagrams.net/`, while saved SVG diagrams remain offline-viewable.
- [ ] Run `npm run check`, `npm run test:external-plugins`, `npm run build`, `npm run test:publish:offline`, `npm run test:playwright`, and `git diff --cached --check` from `Wiki`.
- [ ] Commit only the draw.io source, manifest/bridge test, publish/browser coverage, guide updates, and deletion of the mistakenly placed Wiki-local design document:

```text
[Wiki] Feat: add draw.io diagram plugin
```
