## Why

AngelscriptWiki's accepted document theme is visually coherent overall, but small inherited TiddlyWiki and third-party plugin defaults can leave uneven metadata spacing and interaction cues that compete with the document. Moving the sidebar from the original right-side layout to the left also exposed a larger visual question: the relocated toggle, inherited spacing, and hover-only resize rail do not yet read as one system with the tiddler canvas. Keeping these corrections and experiments in one lightweight change makes the visual system easier to maintain without reopening broad theme migrations for each refinement.

## What Changes

- Establish a reusable, narrowly scoped record for small AngelscriptWiki visual and interaction refinements.
- Refine the desktop sidebar resize affordance so its visible rail is reserved for hover and active drag states while its hit target remains available.
- Remove unintended inherited structural borders from the More sidebar's secondary navigation while retaining clear selected and keyboard-focus states.
- Tighten the excessive gap between SDK-document descriptions and tag metadata without changing their rendering order, tiddler content, the normal tag-to-body reading break, or the accepted left-sidebar / focused-story layout.
- Provide three conservative, standalone HTML experiments for the accepted left-sidebar layout before changing production theme source: a quiet permanent seam, a soft sidebar surface with a short resize grip, and a compact persistent control rail.
- Keep each experiment self-contained, interactive, keyboard accessible, responsive at the drawer breakpoint, and visually anchored to the current Notion-light tiddler presentation.
- Refine the preferred compact-control-rail experiment with working Open, Recent, Tools, More, and AS panels, while preserving the original Tools visibility-list and More vertical-category structures instead of inventing replacement information architecture.
- Complete the experiment's production-reference surfaces with the persistent control rail, the real page-level “更多操作” menu, and the tiddler view toolbar plus its distinct item-level “更多” menu.
- Treat experiment review as an explicit selection checkpoint: production TiddlyWiki styles and resize logic remain unchanged until one option or a deliberate mix is approved.
- Promote the approved `03-compact-control-rail` direction to the production Wiki as the direct desktop default: a persistent `40px` control rail within a `264px` total sidebar, native TiddlyWiki button/icon tiddlers, a stable quiet resize seam, and a `40px` collapsed desktop footprint.
- Keep the production adaptation on TiddlyWiki's PageTemplate, PageControls, SideBar, MoreSideBar, and ViewToolbar extension points instead of copying the preview's fixture data, inline menu logic, hand-written SVG paths, or Unicode menu glyphs.
- Add or extend focused browser coverage for each visual behavior as the change grows.

## Capabilities

### New Capabilities

- `wiki-visual-refinement`: Defines the maintained visual-quality contract for small, scoped AngelscriptWiki theme and interaction adjustments, including sidebar affordances and document metadata rhythm.

### Modified Capabilities

- `angelscript-wiki-theme`: Refines existing theme requirements for desktop sidebar affordances and SDK-document metadata presentation.

## Impact

- Wiki submodule: primarily `src/angelscript-theme/`, `src/angelscript-tools/navigation/`, `src/angelscript-wiki-config/config/`, standalone comparison artifacts, and Playwright visual-regression tests.
- Host repository: this OpenSpec record under `openspec/changes/improve-wiki-visual-refinements/`.
- No public AngelScript API, WikiText authoring syntax, content model, runtime dependency, or publication workflow changes are expected.
- The selected production migration changes the integrated Wiki's local theme/tools/config sources but does not generate, release, or publish standalone plugin packages.
