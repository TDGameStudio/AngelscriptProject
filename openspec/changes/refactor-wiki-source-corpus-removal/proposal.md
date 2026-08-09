## Why

The Wiki currently carries a 1,158-file, 16.87 MiB copy of the AngelScript plugin source, plus synchronization, registry, excerpt-generation, and test infrastructure, while only three documentation pages consume generated excerpts from it. The duplicated source—especially the 645-file, 10.15 MiB `AngelscriptTest` snapshot—adds repository and maintenance cost that is disproportionate to its current documentation value.

The snapshot and all of its unpublished integration history are still local-only, so this is the last low-risk point to remove the subsystem without publishing large, immediately obsolete source objects.

## What Changes

- **BREAKING**: Retire the complete Wiki source-corpus capability rather than narrowing it to selected Runtime, Editor, or UHT paths.
- Remove the committed plugin snapshot, manifest, synchronization reports, public source-reference registry, synchronization and excerpt scripts, generated source tiddlers, package commands, and corpus-specific tests.
- Remove the three generated-excerpt references from their consuming documents while leaving the surrounding articles and their broad project/source metadata intact.
- Keep the generic `AS/Docs/Data/SourceRegistry`, the `as-sources` document field, and non-corpus source keys so future authors may choose ordinary links or manually reviewed inline examples in later changes.
- Preserve the private Hazelight rule as a content-architecture requirement: private source remains revisioned metadata and paraphrased findings only, never public source bodies, excerpts, payloads, fabricated public links, or runtime network input.
- Rewrite only the unpublished Wiki and parent-repository history that introduced or referenced the corpus, guarded by refreshed remote checks, local backup refs, explicit path scopes, and post-rewrite object/reference audits.
- Do not introduce a replacement synchronizer, citation registry, excerpt generator, source browser, or new source-copy mechanism.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `wiki-source-reference-corpus`: Remove the entire seven-requirement source snapshot, synchronization, provenance, stable-key, validation, and packaging capability.
- `wiki-content-architecture`: Make the private Hazelight metadata-only boundary independent of the removed public source-corpus subsystem.

## Impact

- Wiki repository paths: `source-corpus/`, `source-corpus*.json`, `source-corpus-sync-report.md`, `source-references/angelscript.json`, corpus scripts, `package.json`, generated source tiddlers, three Chinese internals pages, source registry data, tests, and Wiki contributor guidance.
- Git history: unpublished commits in both the `Wiki` submodule and the parent repository must be rewritten locally so the removed snapshot and obsolete Wiki gitlink do not enter either public branch history.
- Publishing and normal authoring remain offline. Existing generic source metadata and restricted Hazelight comparison metadata remain supported.
- No Angelscript plugin source, runtime behavior, public API, package dependency, or host-project implementation is changed.
