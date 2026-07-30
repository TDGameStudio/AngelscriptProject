## Why

The Wiki currently treats any external file dropped over the page as an import request, which is disruptive during ordinary reading and visual review. The standard global TiddlyWiki setting disables that importer but also disables useful internal drag-to-reorder interactions.

## What Changes

- Replace only the page-wide import `$dropzone` in the local `$:/core/ui/PageTemplate` override with an ordinary layout container.
- Keep `$:/config/DragAndDrop/Enable` unset so core sidebar, tag, and list drag-to-reorder interactions retain their default behavior.
- Add browser regression coverage for the disabled page importer, retained layout container, and retained core sidebar drop target.
- Document the deliberate core-template override and the need to compare it against upstream PageTemplate changes when upgrading TiddlyWiki.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `wiki-document-experience-integration`: The document experience must prevent accidental page-level external-file importing without globally disabling internal core drag-and-drop behavior.

## Impact

- **Wiki source:** `Wiki/src/angelscript-wiki-config/page-template-without-file-drop-import.tid` shadows the TiddlyWiki core page template but preserves its layout, navigator, variables, and PageTemplate transclusion contract.
- **User behavior:** External file and cross-Wiki payload drops on the normal page no longer launch `$:/Import`; explicit import controls remain available. Internal core drag-to-reorder remains enabled.
- **Maintenance:** A future TiddlyWiki core upgrade requires a focused comparison of this local PageTemplate override with the upstream template. Normal Wiki verification remains preview/test based and does not produce plugin-package artifacts.
