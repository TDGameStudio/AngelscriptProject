## ADDED Requirements

### Requirement: Inactive editor reference snapshots remain outside the Wiki repository

The Wiki repository SHALL NOT track the retired CodeMirror 6 or preview-glass editor source snapshots under `Wiki/vendor/` or `Wiki/src/`. The selected product sources declared by the product manifest SHALL remain the only vendor sources admitted to normal Wiki lint, development, verification, and offline-build workflows. Parent-repository `Reference/` checkouts MAY retain upstream research sources without making them Wiki product dependencies.

#### Scenario: Maintainer inspects retired editor integration boundaries

- **WHEN** a maintainer runs the Wiki source-boundary and offline artifact checks
- **THEN** neither the CodeMirror 6 nor preview-glass vendor directory SHALL be present in the Wiki repository
- **AND** neither corresponding plugin title SHALL be serialized into the offline Wiki artifact

### Requirement: Superseded and unshipped Wiki sources remain absent

The Wiki repository SHALL NOT retain the superseded `vendor/tiddlyseq/src/sidebar-resizer` source snapshot or the unshipped `src/doc` Modern.TiddlyDev tutorial bundle. The selected source manifest SHALL NOT declare the retired sidebar-resizer or Modern.TiddlyDev documentation plugin. The product-owned `src/angelscript-tools/navigation/left-sidebar-resizer.ts` implementation SHALL remain the sole in-repository sidebar-resizing source.

#### Scenario: Maintainer verifies inactive source cleanup

- **WHEN** a maintainer runs the Wiki source-boundary and product-source checks
- **THEN** the vendor sidebar-resizer and `src/doc` directories SHALL be absent
- **AND** the product manifest SHALL contain no `sidebar-resizer` or `doc` entry
- **AND** the product-owned left-sidebar resizer source SHALL be present
