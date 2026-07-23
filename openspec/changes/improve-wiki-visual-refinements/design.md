## Context

AngelscriptWiki uses a TDGameStudio-maintained migration of the itonnote document theme, the fixed Notion light palette, Vanilla ViewTemplates, and selected third-party document plugins. The accepted desktop layout now keeps the sidebar on the left and uses the focused story view. The first refinement pass corrected a faint idle resize rail, an overlaid More-sidebar divider, and detached SDK tag metadata. A subsequent visual review found that the right-to-left move still relies on relocated `.tc-topbar-right` controls, layered legacy padding, and a hover state that makes a full-height line appear from an otherwise undecorated boundary. The sidebar and tiddler therefore still read as adjacent implementations instead of one document system.

This change is deliberately a long-lived, lightweight record for visual refinements of the existing Wiki. It is not a new design-system migration and must remain small enough that later corrections can be appended without reopening unrelated capabilities.

The `Wiki/` directory is a Wiki development project, not a plugin-release workflow. Its local build may compile the enabled theme and support-plugin sources solely to validate browser delivery. Those generated bundles are not publication artifacts, must not be described as releases, and must not be published, distributed, or otherwise delivered externally unless the user explicitly asks for that separate action.

## Goals / Non-Goals

**Goals:**

- Keep the sidebar resize target easy to acquire while making its visible rail contextual: absent at rest, clear on hover, and stronger during drag.
- Keep a clear More-sidebar content divider, while moving it out of the category-column bounds so it no longer overlaps “全部 / 最近 / 标签” controls or creates a duplicated rail.
- Preserve the existing SDK-document order of title, description, tag metadata, then body, while tightening only the excessive description-to-tag gap; the normal tag-to-body reading break and ordinary TiddlyWiki tiddlers remain unchanged.
- Compare three conservative left-sidebar systems against identical real Wiki content without changing the accepted type, palette, tiddler card, or content structure.
- Make the previewed open/close and resize behavior directly testable with pointer, keyboard, reduced-motion, and narrow-drawer coverage.
- Capture each later visual refinement with its user-visible intent and focused browser coverage in this same OpenSpec change.

**Non-Goals:**

- Redesigning the overall Notion palette, focused story view, tiddler surface, or document content.
- Changing WikiText authoring fields, AngelScript documentation content, responsive navigation behavior, external-plugin registration, or the existing SDK metadata order.
- Editing generated plugin sources, changing the underlying sidebar-resizer drag calculation, or adding a broad CSS reset.
- Applying any of the three sidebar experiments to production TiddlyWiki source before a visual selection is approved.
- Publishing Wiki plugin bundles, changing the publication workflow, or treating a local validation build as a release.

## Decisions

### Keep the resize hit target stable and hide only the idle decoration

The enabled sidebar-resizer plugin already provides a fixed, full-height, 12px desktop pointer target and a drag-state class. Its pseudo-element rail will have zero opacity at rest, a restrained visible hover state, and a clearer active-drag state. The target's size, position, `ew-resize` cursor, pointer behavior, and drag logic remain unchanged.

This is preferred to shrinking the target to the line width: a one-pixel interaction target would violate the existing forgiving-pointer interaction design. It is also preferred to removing the plugin, because manual width adjustment remains an intentional desktop capability.

This decision describes the currently shipped production behavior. The later preview phase does not silently replace it; instead it tests three alternatives that keep the forgiving hit target while avoiding a line that appears from nowhere: a permanent quiet seam, a short persistent grip over a stable surface boundary, and a persistent narrow control rail. The selected alternative will replace this production decision only after visual review.

### Position the More-sidebar divider outside the category column

Vanilla applies `border-right: 1px solid #ccc` to each More-sidebar secondary tab button and `border-left: 1px solid #ccc` to the vertical More content panel. The panel begins slightly before the category buttons end, so its left border is painted over the category-column edge in the reviewed layout. The local theme removes the category-button right borders to avoid a duplicate line, retains the content-panel divider, and gives that panel a `0.5rem` left margin. This keeps one intentional divider while placing it to the right of the category controls. Existing horizontal separators, selected-tab treatment, hover feedback, and `:focus-visible` outlines remain provided by the current theme and Vanilla rules.

The override belongs in `src/angelscript-theme/desktop-refinement.tid`, not in imported TiddlyWiki core or the third-party sidebar-resizer plugin. Keeping it local preserves a reviewable theme-owned delta and avoids coupling an unrelated vendor plugin to More-sidebar presentation.

### Preserve SDK metadata order and tune only its scoped spacing

The accepted SDK metadata order is title, description, tag metadata, then body. The visual defect is the large empty interval between the description and the existing tag wrapper, not an incorrect order. The reviewed reference presentation likewise keeps tags immediately after its secondary page information. In AngelscriptWiki the description is that secondary information, so the local theme will use a narrowly scoped CSS override for `.tc-tiddler-frame:has(.as-sdk-title)`: reduce the description's lower margin and, only if required by the computed layout, neutralize the tag wrapper's inherited upper gap. The existing lower margin beneath tags remains the normal reading break before body content.

No ViewTemplate, tag filter, or tag renderer will be added or altered. This preserves DOM and screen-reader order, adapts to multiple and long tags, and avoids changing ordinary tiddlers. It is preferred to template reordering because the screenshot confirms that the existing semantic order is intentional; it is preferred to negative margins or absolute positioning because normal document flow remains responsive.

### Compare standalone previews before changing production source

The three alternatives live as independent HTML files under `Wiki/comparison-artifacts/left-sidebar/`. Each file duplicates the small amount of required CSS, JavaScript, SVG, and semantic fixture markup so it can be opened or copied independently without a server, dependency, shared asset, or full TiddlyWiki runtime. The duplication is intentional: these are review artifacts, not a new reusable UI framework.

All previews use the same home-tiddler fixture and the same interaction contract: `--sidebar-width`, `data-sidebar-state`, stable sidebar/main/resizer/toggle hooks, pointer capture, `240px` to `min(520px, 40vw)` bounds, keyboard width adjustment, visible focus, reduced-motion handling, and a mobile left drawer. They reset to their declared width on reload so comparisons are repeatable.

This is preferred to editing the live theme three times because production state, persisted sidebar width, and core TiddlyWiki controls would make side-by-side evaluation slower and rollback noisier. It is also preferred to one combined switcher page because the user explicitly requested three independent files.

### Turn the compact control rail into the high-fidelity candidate

Visual review selected `03-compact-control-rail.html` as the leading experiment. Its five main sidebar tabs therefore become working, keyboard-navigable panels rather than labels over one shared placeholder:

- Open uses five representative open tiddlers to exercise realistic density, with one clear current item, stable one-line truncation, per-item close affordances, a live item count, and a restrained close-all action.
- Recent uses representative Wiki documents grouped into “今天” and “本周” because the current production Recent panel is empty and cannot exercise real density.
- Tools preserves the core TiddlyWiki presentation of one visibility checkbox, its corresponding page-control button, and a quiet description per row. The experiment only regularizes row height, truncation, neutral surfaces, accent color, hover, and focus so the long list remains recognizable while fitting the `224px` content area.
- More preserves the real two-column geometry: the “全部 / 最近 / 标签 / 缺失 / 草稿 / 孤立 / 类型 / 系统 / 默认 / 探索 / 插件” taxonomy remains a narrow vertical tab column, a single separated divider remains visible, and the selected category renders in the adjacent content panel. It does not replace that structure with wrapping category chips.
- AS preserves the user and maintainer information architecture, adds collapsible groups and current-item treatment, and does not navigate the main fixture while the layout is being compared.

The `40px` rail becomes a production-reference surface with three deliberate zones: the persistent top collapse control, primary navigation actions, and bottom utility actions. Icon buttons use one geometry and the existing neutral/blue palette; selected, hover, pressed, and focus states remain distinct. Labels appear as right-side tooltips on hover or focus and remain available through `aria-label`. Separators encode the zone boundaries. When the sidebar is closed, the rail and all zones remain available while the content panel disappears. Its page-level More control opens a styled but structurally faithful sample of the current TiddlyWiki page-action menu rather than acting as a decorative icon.

The representative tiddler also retains the original view-toolbar action set — More, Edit, Close, and New Diagram — and provides a separate item-level More menu containing representative current actions such as Info, Clone, Export, Delete, Permalink, Close Others, and Fold. Page-level and tiddler-level menus remain distinct because they have different command scopes in TiddlyWiki.

This faithful high-fidelity approach is preferred to the first redesigned Tools cards, switch controls, and horizontal More chips because those changed the current Wiki's information architecture before visual review. Recent remains curated because the production Recent panel is empty, but Tools, More, page actions, and tiddler controls now retain their original semantics and hierarchy. It is also preferred to a simplified decorative mock because every important control state needs to be judged before formal TiddlyWiki adaptation.

## Risks / Trade-offs

- [The resizer is an imported plugin and its styles can be revised upstream] → Keep the change limited to its visible pseudo-element state and preserve the existing Playwright behavior test for hit target, hover, and drag.
- [A broad More-sidebar selector could disturb useful tab geometry elsewhere] → Target only its secondary tab-button path and vertical More-content-panel path, assert an explicit gap between category column and divider, and retain the ordinary selected/focus interaction.
- [Spacing changes could make tags collide with a multiline description] → Keep elements in normal flow, adjust only the description-to-tag margins, and cover a title/description/tag fixture at desktop and narrow widths.
- [A long-lived OpenSpec could accumulate unrelated work] → Each later addition must remain a small Wiki visual or interaction refinement; feature, content-model, dependency, and publishing changes use their own change.
- [Static previews can drift from real TiddlyWiki markup] → Use real AngelscriptWiki content, keep the production theme unchanged during selection, and treat the chosen preview as a design reference rather than code to paste wholesale.
- [Three self-contained files duplicate interaction code] → Keep the contract deliberately small and cover every file with one parameterized Playwright suite; remove the experiment artifacts after selection only if the user explicitly requests cleanup.

## Migration Plan

1. Add failing/updated Playwright assertions for idle, hover, and active resizer presentation; the More-sidebar border; and the SDK description-to-tag spacing while preserving DOM order and the normal tag-to-body break.
2. Apply the smallest scoped stylesheet changes that satisfy those assertions.
3. Run the focused browser tests, type checking/linting, the full Playwright suite, and the Wiki build.
4. Add failing browser contracts for three standalone left-sidebar previews, implement them without touching production theme source, and inspect their idle, hover, closed, and mobile states.
5. Pause after the preview artifacts are committed; select one alternative or a deliberate mix before adding a production migration task.
6. Append future visual corrections to this change with their requirement/test record before implementation.

If a future request would require `publish`, external deployment, package distribution, or release-oriented artifact generation, stop and obtain explicit user direction first. A normal local `build` remains a validation command only.

Rollback is a normal Wiki-submodule commit revert. No user tiddler data, WikiText syntax, or persisted browser state is migrated.

## Open Questions

The production sidebar option remains intentionally open until the three standalone previews are reviewed. SDK metadata order and the existing production theme remain unchanged during this checkpoint.
