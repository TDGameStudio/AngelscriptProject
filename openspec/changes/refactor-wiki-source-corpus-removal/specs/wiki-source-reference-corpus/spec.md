## REMOVED Requirements

### Requirement: Plugin source snapshots are immutable and reproducible

**Reason:** The Wiki will no longer store or synchronize a plugin source snapshot.

**Migration:** Remove the snapshot manifest and synchronization workflow. Documentation authors may choose ordinary reviewed links or inline examples in later page-specific changes; this change defines no replacement.

### Requirement: Source synchronization is explicit and absent from normal Wiki commands

**Reason:** All source-corpus synchronization and excerpt-generation commands are being retired.

**Migration:** Remove the dedicated commands and their command-graph coverage. Normal Wiki development, test, verification, and build commands remain offline.

### Requirement: Private Hazelight source is restricted comparison metadata, not corpus content

**Reason:** The source-corpus capability is being removed, but its private-source safety boundary must remain.

**Migration:** Preserve the metadata-only, paraphrase-only, and no-network behavior as an independent `wiki-content-architecture` requirement and retain `source-references/hazelight-restricted.json`.

### Requirement: License and provenance boundaries are preserved

**Reason:** The manifest, copied plugin files, generated excerpts, and their dedicated license classifications are being removed together.

**Migration:** Existing repository-level licenses and ordinary document-source metadata remain governed by their current project rules. Any future copied-source mechanism requires a separate capability and license review.

### Requirement: Documents cite stable source-reference keys

**Reason:** The three `as-source.*` keys are owned entirely by the retired corpus and excerpt generator.

**Migration:** Remove those three keys from their consumers and registries. Keep generic `as-sources` metadata and broad non-corpus source keys; do not add replacement links or excerpts in this change.

### Requirement: Corpus updates detect stale and broken references

**Reason:** There will be no corpus update, excerpt hash, anchor rebinding, or corpus consumer graph to validate.

**Migration:** Remove corpus-specific validation and tests. Existing document-link and content-contract validation continues to cover the retained Wiki content model.

### Requirement: Raw source stays outside the initial Wiki boot payload

**Reason:** The complete raw source snapshot and generated excerpt payload are being removed from the repository.

**Migration:** Verify that no raw corpus path or generated `as-source.*` tiddler enters the offline artifact. A future source browser or copied-source feature requires a new measured capability.
