## Why

The integrated TiddlyWiki product is visually usable and its current tests pass, but its runtime still contains unowned serialized plugins, its CI follows the old plugin-package template, test fixtures leak into reader-facing lists, and sidebar/theme responsibilities are spread across several plugins. These hidden boundaries make routine styling and dependency upgrades riskier than the visible UI suggests.

## What Changes

- Make the product runtime an explicit allowlist with no unsolicited initial network requests, and remove the CPL, unload-warning monkey patch, and superseded vendor resizer from the shipped Wiki.
- Keep product test targets in a stable system-tiddler namespace and remove the unused Modern.TiddlyDev template fixture so it cannot reappear in ordinary content, search, or More lists.
- Replace plugin-library build/release defaults with one Wiki-product verification and offline build flow; keep Pages deployment deferred and manual.
- Guard the narrow core `PageTemplate` override, then upgrade the TiddlyWiki bug-fix baseline independently from visual refactoring.
- Keep the accepted left-sidebar/document appearance while separating theme tokens/styles, navigation behavior, product defaults, and vendor provenance.
- Stabilize sidebar resizing, localized SDK metadata, host-baseline data, artifact budgets, and browser/a11y regression coverage.

## Capabilities

### New Capabilities

- `wiki-product-architecture`: Defines the product source manifest, runtime/network boundary, hidden test-content policy, module ownership, core-override guards, and artifact budgets.

### Modified Capabilities

- `angelscript-wiki-theme`: Changes the theme contract from independently published plugin artifacts to a modular, accessible theme included in the integrated Wiki product.
- `tw-angelscript-tools`: Adds product-owned navigation/sidebar behavior while preserving the code widget contract.
- `wiki-document-experience-integration`: Replaces the historical fixed plugin set with an auditable product manifest and removes superseded or unsafe runtime integrations.
- `reliable-offline-publish`: Removes plugin-library generation from the offline product build while retaining complete, validated HTML output.
- `wiki-repository-publishing`: Replaces the obsolete MkDocs/plugin-release assumptions with a deferred TiddlyWiki offline-artifact Pages contract.

## Impact

- Affects `Wiki/` product manifests, scripts, workflows, TiddlyWiki plugin sources, content fixtures, dependency baseline, browser tests, and offline artifact validation.
- Adds a parent-repository OpenSpec record and later updates the `Wiki` submodule gitlink; unrelated dirty parent paths remain untouched.
- Does not publish plugin packages, deploy GitHub Pages, change remote settings, archive existing Wiki OpenSpecs, or redesign the accepted home/document layout.
