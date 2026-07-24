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
- Promote the approved compact-control-rail direction through native TW5 extension points while keeping live Open/Recent/Tools/More/AS data and behavior, with product-scoped line icons that do not replace core shadows.

**Non-Goals:**

- Redesigning the overall Notion palette, focused story view, tiddler surface, or document content.
- Changing WikiText authoring fields, AngelScript documentation content, responsive navigation behavior, external-plugin registration, or the existing SDK metadata order.
- Editing generated plugin sources, changing the underlying sidebar-resizer drag calculation, or adding a broad CSS reset.
- Applying any of the three sidebar experiments to production TiddlyWiki source before a visual selection is approved.
- Publishing Wiki plugin bundles, changing the publication workflow, or treating a local validation build as a release.

## Decisions

### Keep the resize hit target stable and make the selected boundary persistent

The product-owned left-sidebar resizer provides a fixed, full-height, 12px desktop pointer target and a drag-state class. The approved compact-control-rail direction replaces the earlier zero-opacity idle decoration with a persistent `1px` neutral seam, a stronger neutral hover state, and a `2px` blue active-drag state. The forgiving target geometry, pointer capture, `240px` lower bound, and `min(520px, 40vw)` upper bound remain unchanged.

The resize tiddler also becomes a real keyboard-focusable `role="separator"` surface. Arrow keys adjust by `8px`, Home selects the minimum, End selects the current effective maximum, and `aria-valuenow` follows pointer and keyboard changes. This retains manual width adjustment while eliminating the line that previously appeared from an otherwise undecorated boundary.

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

The production refinement intentionally keeps the utility zone smaller than the preview: Language appears above Control Panel, while Palette is removed as an independent rail control because palette selection remains available inside the native control panel. Language is the utility zone's only popup and is anchored upward beside the rail so the native menu remains inside the viewport. Control Panel preserves its native navigation contract and opens `$:/ControlPanel` as the focused tiddler instead of introducing a second settings popup. Home receives the preview's selected presentation only while `$:/HistoryList!!current-tiddler` is `AngelscriptWikiHome`; More, Language, and Control Panel continue to use their native selected state.

The representative tiddler also retains the original view-toolbar action set — More, Edit, Close, and New Diagram — and provides a separate item-level More menu containing representative current actions such as Info, Clone, Export, Delete, Permalink, Close Others, and Fold. Page-level and tiddler-level menus remain distinct because they have different command scopes in TiddlyWiki.

This faithful high-fidelity approach is preferred to the first redesigned Tools cards, switch controls, and horizontal More chips because those changed the current Wiki's information architecture before visual review. Recent remains curated because the production Recent panel is empty, but Tools, More, page actions, and tiddler controls now retain their original semantics and hierarchy. It is also preferred to a simplified decorative mock because every important control state needs to be judged before formal TiddlyWiki adaptation.

### Promote the selected rail through native TiddlyWiki surfaces

Production uses an additive `$:/tags/PageTemplate` tiddler before the core sidebar rather than copying `$:/core/ui/PageTemplate`. The new component renders only while `$:/themes/angelscript` is selected and transcludes the real PageControl buttons in three visual zones. The existing TopRightBar sidebar toggle is positioned into the rail; `$:/state/sidebar` and the core sidebar reveal behavior remain authoritative.

The default desktop total width becomes `264px`: the rail owns the first `40px`, the core `.tc-sidebar-scrollable` content owns the remaining `224px`, and the story river starts after the total width. When closed, the content panel and resizer disappear, the rail remains, and the story river starts after `40px`. At the configured mobile breakpoint the desktop rail is hidden and the existing left drawer plus bottom page controls remain unchanged.

The six rail actions reuse `$:/core/ui/Buttons/home`, `more-page-actions`, `new-tiddler`, `CommandPalette`, `language`, and `control-panel` as the behavior source. A product-owned JSON map resolves those action titles to scoped line-icon tiddlers under `$:/plugins/TDGameStudio/angelscript-tools/icons/sidebar/`; the native buttons stay in the DOM and continue to own messages, popup state, labels, and keyboard behavior. The scoped icons are visual siblings with `pointer-events: none`, not replacements for core/plugin SVG shadows. Existing PageControl visibility tiddlers remain the control plane for retained controls, while the production rail owns its deliberately smaller utility list.

Open, Recent, Tools, More, AS, the page-level More menu, and the tiddler ViewToolbar all retain live TiddlyWiki data, widgets, messages, and popup state. The selected preview's panel hierarchy is adapted through narrow product-owned shadow overrides for the five sidebar surfaces rather than copied fixture HTML or JavaScript. Those overrides still read `$:/StoryList`, `$:/HistoryList`, `$:/tags/PageControls`, `$:/core/Filters/AllTags`, and product navigation tiddlers at render time and continue to send the corresponding native messages. Production CSS adapts their spacing and states to the selected preview. The five main tab buttons use the preview's `34px` height, `13px` gap, neutral text, accent selected text, and a non-layout-shifting `::after` underline instead of the inherited selected background and button border.

### Adapt the five expanded panels without static production fixtures

The formal Wiki may shadow the five presentation tiddlers, but it does not replace their runtime contracts:

- Open renders the live `list<tv-story-list>` inside the core droppable/storyview context, keeps insert-before and drag/drop variables, and sends `tm-close-tiddler` or `tm-close-all-tiddlers`. The 03 row, current, count, hover-close, empty, and close-all treatments are presentation only.
- Recent parses the real `$:/HistoryList` JSON, removes duplicates and system/missing entries, reverses it to newest-first order, and groups the first five entries as “本次访问” with the remainder as “较早”. It exposes real title, current state, and the first real tag; it deliberately invents no timestamps.
- Tools declares sixteen frequently used PageControl titles in stable order, retains each native visibility checkbox and PageControl transclusion, and discovers every additional current or future `$:/tags/PageControls` shadow/tiddler into a collapsed “其他工具” group. The product icon map supplies known line icons and a generic fallback without changing the native action.
- More retains the core eleven-category vertical tab set. Only `$:/core/ui/MoreSideBar/Tags` is shadowed so the native tag manager, `$:/core/Filters/AllTags`, `TagTemplate`, and `UntaggedTemplate` stay authoritative while receiving the selected compact heading treatment.
- AS uses product WikiText procedures, links, and state tiddlers for the user and maintainer groups. Collapse state and current-item state remain native TiddlyWiki state/history behavior rather than static DOM state.

This approach is preferred to a CSS-only pass because the reviewed difference includes hierarchy, row structure, and empty/batch states that selectors cannot introduce. It is preferred to copying the standalone HTML because every item remains derived from real Wiki state and every action remains a TiddlyWiki widget/message. Dotted custom filter operators are used because hyphenated custom function names are parsed as ordinary filter syntax in this runtime.

### Retain only the selected 03 reference and finish its typography/icon details

Once `03-compact-control-rail.html` is selected and adapted, `01-quiet-seam.html` and `02-soft-surface.html` no longer serve the normal review workflow. The comparison directory therefore retains only the selected self-contained 03 reference; the two rejected tracked alternatives and the untracked 03 backup are removed. Preview coverage is narrowed from a three-way comparison to the selected reference's standalone, resize, drawer, panel, toolbar, accessibility, and reduced-motion contracts.

The final production typography pass follows the computed 03 tokens instead of relying on inherited TiddlyWiki button/tag text:

- Tools action labels use `11px / 400`, descriptions use `10px / 400` with compact line height, and rows use the reference `29px` rhythm.
- More category labels use `10px / 400` in production because the active Noto Sans face has a larger visual body than the standalone 03 reference's `11px` fallback stack. Selected labels use `600`, the tag-manager heading uses `11px / 600`, and rendered tag labels use `10px / 400`.
- The native sidebar show/hide button remains the behavior and accessibility owner, but its double filled chevron is visually suppressed on desktop and a product-scoped single line chevron is layered above it. The line chevron reverses when the sidebar is closed.
- Open rows remove their leading document glyph and the close-all action removes its leading file glyph. The current marker, title, close control, count, native messages, and empty-state guidance remain unchanged.

The icon overlay is preferred to shadowing the core show/hide button or core image tiddlers because it preserves native messages, labels, state changes, and mobile behavior. Explicit panel selectors are preferred to global button or tag resets because only the selected compact sidebar should inherit these 03 typography tokens.

### Simplify the Command Palette glyph at its real rail size

The original 03-derived Command symbol joins four rounded loops and their connecting stems into one path. Its meaning is recognizable at a larger size, but the geometry becomes dense and visually heavier than the neighboring Home, More, New, Language, and Settings icons when rendered at the production rail's `17px` size.

The approved replacement is an unframed command-prompt glyph: one right-facing chevron followed by one short baseline, visually reading as `>_`. It keeps the existing `24×24` view box, `17px` rendered size, `fill="none"`, `stroke="currentColor"`, rounded caps/joins, and the product-owned `data-as-icon="command"` contract. Two independent paths keep the small-size silhouette open and legible. The existing `$:/core/ui/Buttons/CommandPalette` transclusion remains the behavior, accessible-name, focus, popup, and keyboard owner; the JSON icon map and tiddler title do not change.

This direction is preferred to a reduced Command-loop symbol because even fewer loops remain dense at `17px`, and to a command-list glyph because three horizontal rows would be too similar to Tools, List, and More actions. The static 03 reference remains a historical selected-layout reference and is not silently rewritten for this production-only review correction.

### Prototype a compact native-shape tag popup in 03 before production adaptation

The production tag popup currently comes from the native `$:/core/ui/TagTemplate` reveal and retains the Vanilla dropdown's `380px` minimum width, `14px` text, square border, and unrefined bold links. Its content contract is useful — the tag target link, one divider, and the list of tiddlers carrying that tag — but its surface no longer matches the selected compact rail or the refined page/tiddler menus.

The selected `03-compact-control-rail.html` reference will prototype the approved compact native-list direction before any production WikiText or theme change. Its existing `ASWiki/Home` pill becomes a semantic button that toggles an anchored `260px` menu. The menu keeps the native content order: a `11px / 600` tag-target row, a restrained divider, and representative `29px`, `11px / 400` tagged-tiddler rows. The current tiddler receives the same pale-blue surface and `2px` accent edge as the compact Open panel. The popup uses the selected menu's `#d9dde2` border, `6px` radius, white surface, and two-layer shadow; it adds no file/document glyphs.

The standalone interaction owns only preview behavior: the tag button updates `aria-expanded`, click toggles the popup, outside click closes it, `Escape` closes and restores focus, and opening a page/tiddler action menu closes it. Its width is capped to the viewport for narrow layouts, and existing reduced-motion behavior remains authoritative. Links remain ordinary anchors inside the popup. The formal TiddlyWiki `$:/core/ui/TagTemplate`, theme source, live filters, drag/drop list, popup state, and navigation behavior stay unchanged until the preview is reviewed and explicitly approved for production migration.

This direction is preferred to styling the popup exactly like the `218px` action menu because tagged-tiddler titles need slightly more room and current-item hierarchy. It is preferred to a `300px` information card with count/header controls because that would add a new content model rather than refine the native tag-link/divider/list structure.

### Reuse the body tag popup for tags inside 03 More/Tags

The first interpretation of the More/Tags follow-up replaced the existing tag pills with an inline single-open disclosure directory. User review clarified that this changed the wrong surface: the desired result is not an accordion inside the sidebar, but the same floating tag popup already approved for the body tag.

The corrected preview keeps the compact More/Tags tag controls in the sidebar and makes each one a semantic popup button. Activating a tag opens one shared, page-level popup that directly reuses the body popup's `.tag-popup`, `.tag-popup-target`, `.tag-popup-divider`, `.tag-popup-list`, and `.tag-popup-item` classes. The selected tag updates the target row and representative tagged-tiddler rows while retaining the same `260px` surface, `6px` radius, border, two-layer shadow, `11px` type, `29px` rows, pale-blue current state, and absence of file/document glyphs.

The popup must live outside the sidebar DOM because `.sidebar` and `.sidebar-panels` intentionally clip horizontal overflow; nesting a `260px` popup in the narrow More content column would crop it. A small positioning adapter places the shared popup to the right of the desktop sidebar and clamps it into narrow viewports. It owns only geometry and current trigger state, not a second visual component.

Only one More-tag popup exists. Activating a different tag retargets the same popup and clears the previous button's expanded state; activating the current tag again closes it. Outside click, `Escape`, page/tiddler action menus, More-category changes, sidebar-tab changes, and viewport/sidebar resizing close it. `Escape` restores focus to the triggering tag. The existing body popup remains unchanged, and opening either popup closes the other.

This direction is preferred to the rejected inline directory because it matches the user's requested interaction and preserves the More/Tags layout. It is preferred to duplicating one popup under every tag because a shared portal prevents clipping, avoids repeated menu markup, and keeps mutual exclusion and focus restoration deterministic. Formal TiddlyWiki TagTemplate, filters, popup state, navigation, and theme source remain unchanged until separate production approval.

### Migrate the approved tag-popup surface without replacing native popup behavior

User review approved the compact popup surface for production but explicitly rejected carrying the standalone prototype's positioning adapter into the formal Wiki. Knot's `tw5` knowledge base and the locked local TiddlyWiki `5.4.1` source agree that body tags, More/Tags, the `<<tag>>` macro, and TagManager all reach `$:/core/ui/TagTemplate`; its `$button popup=...` and `$reveal type="popup"` pair remains the authoritative state, positioning, dismissal, filtering, navigation, and draggable-list implementation.

Production therefore adds one theme-owned stylesheet tiddler scoped to `span.tc-tag-list-item[data-tag-title] > .tc-drop-down.tc-reveal`. It adapts the native surface to the approved `260px` maximum-width-aware menu, `6px` radius, white background, selected border/shadow tokens, `11px` type, restrained divider, `29px` target/tagged rows, and compact hover/focus states. The stylesheet does not shadow `$:/core/ui/TagTemplate`, introduce a startup module or portal, or assign `position`, inset, or transform properties. The native `$:/tags/TagDropdown` extension area and `.tc-tagged-draggable-list` wrappers remain intact.

This scope deliberately excludes `$:/core/ui/UntaggedTemplate`, `$:/core/ui/TagPickerTagTemplate`, `.tc-block-dropdown`, generic page/tiddler action menus, and tag pills that do not transclude TagTemplate. The 03 current-row treatment is also excluded from this production pass: the standalone reference supplied `aria-current="page"` itself, while the native tagged list exposes no equivalent marker. Adding one would require WikiText behavior rather than the approved CSS-only adaptation.

### Correct the production More/Tags overflow and include Untagged

The first production pass intentionally retained native Reveal geometry, but inspection of the real Wiki and `临时图片.jpg` showed that this does not work inside the left sidebar. The width audit found no duplicate persistence or resizer arithmetic bug: at a persisted `320px`, the rail is `40px`, `.tc-sidebar-scrollable` is `280px`, and both the separator center and story start are exactly `320px`; the drag-only CSS variable is removed after persistence. The selected 03 contract deliberately treats `sidebarwidth` as the total rail-plus-content footprint.

The conflict is instead between that valid variable-width contract and two native overflow containers. TiddlyWiki's Vanilla stylesheet applies `overflow: auto` to both the outer `.tc-sidebar-scrollable` and inner `.tc-tab-content.tc-vertical`. After the persistent rail, sidebar padding, `42px` More category column, gap, border, and content padding are removed, the More/Tags inner client width is effectively `total sidebar width - 125px`: `115px` at the `240px` minimum, `139px` at the `264px` default, and `395px` at the `520px` maximum. The approved real-tag popup needs about `269px` of inner scroll width including its native anchor offset, so widths below about `394px` produce horizontal overflow; `ASWiki/Workflow` also increases inner scroll height from `274px` to `382px`. Untagged is a direct Reveal sibling and uses the sidebar as its offset parent, so its native `380px` surface instead expands the outer `224px` sidebar scroll width to `457px`. Resizing changes the severity and can hide the issue above the threshold, but the default compact width necessarily exposes it. Raising the resizer minimum to roughly `394px` would remove the selected compact layout and is rejected.

A separate theme-owned baseline overflow was also found before any popup opened: `.as-more-tags-heading > button` combines `width: 100%` with the native button's `2px` inline margins, making a `139px` client area report `143px` scroll width. The production correction resets that heading button margin to zero. Opening a popup must then leave both inner and outer scroll widths at their closed-state client widths.

The correction adds one browser-only startup adapter for popups whose trigger is inside `.tc-sidebar-scrollable`. It waits for native `$button popup=...` handling, moves the existing open Reveal node to `document.body`, adds product-owned portal and variant classes, and computes only fixed viewport geometry. It does not clone popup content, write popup state tiddlers, replace `$:/core/ui/TagTemplate` or `$:/core/ui/UntaggedTemplate`, synthesize rows, or intercept link navigation. Native TiddlyWiki remains responsible for opening, closing, outside-click dismissal, `aria-expanded`, filtering, drag/drop, navigation, and DOM disposal.

On desktop, the adapter aligns the popup top with its trigger row and places its left edge `8px` beyond the sidebar's right edge. On narrow viewports, it places the popup below the trigger when space permits, otherwise above it, and clamps all edges to a `16px` viewport inset. Resize and capture-phase scroll events recompute geometry while the popup remains connected. A subsequent native refresh or dismissal removes the node normally and the adapter clears its active reference. Body tiddler tags, `<<tag>>`, and TagManager stay in their native parent and retain absolute positioning.

The same compact surface now includes the sibling Reveal emitted by `$:/core/ui/UntaggedTemplate` inside More/Tags. Untagged is a flat tiddler list rather than a TagTemplate target/divider/list structure, so every row uses the normal `29px`, `11px / 400` treatment with no synthetic bold target and no divider. This keeps the visual language consistent without pretending Untagged is a real tag.

This narrow portal is preferred to overriding `.tc-tab-content.tc-vertical { overflow: visible; }`, which would change scrolling and clipping for all eleven More categories, and to raising the resizer minimum until the menu fits. It is also preferred to shadowing core templates because moving the one live Reveal preserves core markup and state ownership. This follow-up explicitly supersedes the earlier CSS-only decision only for left-sidebar TagTemplate and Untagged popups; all non-sidebar consumers keep the original CSS-only/native-geometry behavior.

### Make the document directory the sidebar entry point

The fifth main tab was introduced as `AS` because its content originates from `AS/Navigation`, but that label describes the implementation domain rather than the panel's Wiki role. It also placed the durable document map after transient Open, Recent, Tools, and More panels, while the product now serves primarily as a documentation Wiki.

The product keeps the existing `as-outline` tiddler and `AS/*` document titles but changes its caption to the core localized `$:/language/SideBar/Contents/Caption`, orders it immediately before core Open, and sets `$:/config/DefaultSidebarTab` to that existing tiddler. The resulting order is `目录 / 开启 / 最近 / 工具 / 更多` under `zh-Hans`. Core tab state remains authoritative during a session; because `$:/state/` is excluded by the core saver filter, a fresh load returns to the configured directory without a startup script or forced runtime reset.

The site subtitle is removed from the product surface by deleting the local `$:/SiteSubtitle` override and hiding the complete native site-subtitle SideBar segment through its visibility config. This avoids retaining an empty `20px` block while leaving SDK-document `description` fields and their title/tag/body rhythm unchanged. The ordinary `dev` command remains intentionally read-only; browser-to-filesystem authoring continues to require the existing explicit `dev:wiki` entry point.

### Replace the browser favicon through the native TiddlyWiki system tiddler

The reviewed `Wiki/angelscript-icon.svg` is the approved browser-page icon. It is currently an untracked standalone file, while the product still loads a tracked `256×256` ICO through the `$:/favicon.ico` system tiddler. TiddlyWiki `5.4.1` already owns the runtime contract: `$:/core/modules/startup/favicon.js` reads `$:/favicon.ico`, converts its `text`, `type`, and optional canonical URI to a data URI, and updates the existing `<link id="faviconLink">`.

The product will retain that native title and startup behavior but change the physical source to `Wiki/wiki/tiddlers/system/$__favicon.svg`, with metadata declaring `title: $:/favicon.ico` and `type: image/svg+xml`. The former `$__favicon.ico` payload and metadata will be removed. The SVG body is moved without redrawing paths or creating a generated ICO derivative. The integrated offline build will therefore serialize the SVG inside the existing system tiddler and the browser will receive it as a `data:image/svg+xml` favicon after TiddlyWiki startup.

Runtime review of the first SVG integration showed that its full-canvas white rectangle remained completely opaque and that the wide wing artwork still read slightly small at normal favicon sizes. An intermediate follow-up changed that surface to `fill-opacity="0.72"` and tightened the view box by six percent, but `临时图片3.jpg` demonstrated that browser chrome still presented the rectangle as a conspicuous grey-white square while the full wing span continued to constrain the central mark.

The accepted correction therefore removes the background rectangle entirely and uses the favicon-specific square `viewBox="236 207 780 780"`. This enlarges the unchanged source paths by approximately thirty percent and intentionally clips a small portion of the outer wing tips so the central roundel, halo, and inner wings remain identifiable at normal tab sizes. It is the selected middle ground between retaining the complete but undersized wings and a tighter central-only crop that would discard too much of the AngelScript silhouette. The SVG paths themselves remain unchanged; only the viewport selects a more useful favicon composition.

This approach is preferred to converting the source to ICO because the reviewed vector remains the single source of truth. It is preferred to adding a RawMarkup `<link>` because that would duplicate and compete with the core `faviconLink` lifecycle. The change affects only the browser tab, bookmark, and related user-agent favicon surfaces; compact-rail icons, sidebar controls, Command Palette, tiddler toolbar icons, and document content remain unchanged.

Source, artifact, and browser contracts will cover three boundaries: the physical SVG tiddler retains the approved AngelScript title/view box and system-tiddler metadata; the single offline HTML serializes `$:/favicon.ico` with `image/svg+xml` and does not emit a separate favicon asset; and a running Wiki changes `link#faviconLink` to an SVG data URI. This keeps the favicon independent of plugin packaging and external file delivery.

## Risks / Trade-offs

- [Page refresh can replace the product-owned separator element] → Attach pointer and keyboard listeners idempotently from the existing page-refreshed hook, recompute ARIA bounds after viewport changes, and retain Playwright coverage for hit target, hover, drag, persistence, and keyboard behavior.
- [A broad More-sidebar selector could disturb useful tab geometry elsewhere] → Target only its secondary tab-button path and vertical More-content-panel path, assert an explicit gap between category column and divider, and retain the ordinary selected/focus interaction.
- [Spacing changes could make tags collide with a multiline description] → Keep elements in normal flow, adjust only the description-to-tag margins, and cover a title/description/tag fixture at desktop and narrow widths.
- [A long-lived OpenSpec could accumulate unrelated work] → Each later addition must remain a small Wiki visual or interaction refinement; feature, content-model, dependency, and publishing changes use their own change.
- [Static previews can drift from real TiddlyWiki markup] → Use real AngelscriptWiki content, keep the production theme unchanged during selection, and treat the chosen preview as a design reference rather than code to paste wholesale.
- [Three self-contained files duplicate interaction code] → Keep the contract deliberately small and cover every file with one parameterized Playwright suite; remove the experiment artifacts after selection only if the user explicitly requests cleanup.
- [A PageTemplate rail can duplicate the existing sidebar PageControls segment] → Hide only `$:/core/ui/SideBarSegments/page-controls` in the integrated Wiki defaults while retaining Tools and the mobile bottom control surface.
- [Core theme rules can fill line SVGs or restyle tiddlylinks after the product stylesheet] → Scope every icon with `data-as-icon`, explicitly restore `fill: none` and `stroke: currentColor`, and use panel-qualified link selectors covered by computed-style Playwright assertions.
- [A future PageControl is omitted from the curated Tools list] → Treat the sixteen-item list only as the common section and derive “其他工具” from all remaining real PageControl shadows/tiddlers at runtime.
- [A generic prompt glyph could be mistaken for a terminal launcher] → Retain the native Command Palette tooltip and accessible label, keep the glyph only inside the established Command Palette control, and avoid adding a surrounding terminal window that would strengthen the wrong interpretation.
- [A polished standalone tag popup could imply that production semantics have already changed] → Keep the preview DOM aligned with the native tag-link/divider/tagged-list order, label the task as preview-only, and do not touch production `TagTemplate` or theme source until a separate approval.
- [The anchored `260px` popup could leave a narrow viewport] → Cap its width to `calc(100vw - 32px)`, keep it left-aligned under the pill, and cover its bounding box at both desktop and `390px` widths.
- [A portal popup could detach visually from its side-panel trigger] → Align it to the trigger row while keeping its desktop left edge beyond the sidebar boundary, and close it whenever tab/category/size changes invalidate that geometry.
- [A shared popup could leave stale expanded state when retargeted] → Track exactly one More-tag trigger, clear its `aria-expanded` before each retarget/close, and cover switching plus second-activation collapse in Playwright.
- [A broad dropdown rule could restyle unrelated controls] → Qualify every production selector through the native `tc-tag-list-item[data-tag-title]` wrapper and cover Untagged, TagPicker, and ordinary dropdown exclusions.
- [The native popup can still inherit sidebar overflow geometry] → Preserve core Reveal positioning exactly as requested; reduce the Vanilla `380px` minimum to the approved `260px` surface, record the remaining geometry as native behavior, and treat any later portal/reposition request as a separate interaction change.
- [The standalone current row could be mistaken for a production requirement] → Record that native TagTemplate has no current marker and omit the pale-blue/accent state until a separate semantic-template change is approved.
- [Moving a live Reveal could accidentally replace native popup ownership] → Move only the existing connected node after core opens it, never clone rows or write popup state, and cover native `aria-expanded`, outside-click close, navigation, retarget, and cleanup behavior in Playwright.
- [A sidebar-only portal selector could leak into body tags or generic menus] → Require a trigger below `.tc-sidebar-scrollable`, add explicit real-tag/Untagged variant classes, and assert that body, macro, and TagManager TagTemplate reveals remain native absolute children.
- [Fixed geometry could leave the viewport after resize or scroll] → Recompute against current trigger/sidebar bounds, prefer below/above placement on narrow screens, clamp every edge to `16px`, and cover both `1440×960` and `390×844`.
- [Changing the default tab could break tests or features that implicitly expect Open to be visible] → Select Open, Recent, Tools, and More by their semantic captions in behavior-specific tests, and separately cover directory-first load/reload behavior.
- [Clearing only the subtitle text could leave a blank header band] → Hide the entire native site-subtitle SideBar segment and assert that `.tc-site-subtitle` is absent while the SDK description remains visible.
- [The detailed wing artwork can lose fine detail at very small browser-tab sizes] → Preserve the user-approved source exactly for this replacement and treat any later simplified small-size glyph as a separate visual decision.
- [A browser can temporarily retain a cached favicon after the source changes] → Verify the actual `link#faviconLink` SVG data URI in a fresh browser context; use a hard reload only for manual comparison and do not add cache-busting product logic.
- [Changing the physical extension while retaining the canonical `$:/favicon.ico` title can look surprising in the repository] → Keep explicit metadata beside the SVG and cover the title/type mapping in a source contract.
- [A transparent background can reduce black-artwork contrast on dark browser chrome] → Accept native chrome blending for the user-approved transparent favicon, inspect both light and dark samples, and treat any future adaptive/light-stroke favicon as a separate visual design rather than reintroducing a full square.
- [The favicon-specific crop intentionally clips the outer wing tips] → Lock the reviewed `780×780` middle crop, preserve the complete path source, and reject the tighter central-first crop unless the user later approves a simplified small-size mark.

## Migration Plan

1. Add failing/updated Playwright assertions for idle, hover, and active resizer presentation; the More-sidebar border; and the SDK description-to-tag spacing while preserving DOM order and the normal tag-to-body break.
2. Apply the smallest scoped stylesheet changes that satisfy those assertions.
3. Run the focused browser tests, type checking/linting, the full Playwright suite, and the Wiki build.
4. Add failing browser contracts for three standalone left-sidebar previews, implement them without touching production theme source, and inspect their idle, hover, closed, and mobile states.
5. Record `03-compact-control-rail` as the selected direct production default.
6. Add failing production browser contracts, implement the native PageTemplate rail/config/layout/resizer adaptation, and visually inspect real Wiki panels and menus.
7. Append future visual corrections to this change with their requirement/test record before implementation.
8. Add failing production contracts for the shared TagTemplate surface and exclusion boundaries, implement one theme-scoped CSS module, and verify the native popup contract across body and More/Tags without changing the selected 03 positioning prototype.
9. Add failing source/browser contracts for the observed More/Tags overflow, implement one sidebar-only live-Reveal portal adapter plus Untagged surface rules, and verify that non-sidebar consumers retain native geometry.
10. Add failing directory-first sidebar contracts, apply only native SideBar visibility/order/default-tab configuration plus aligned visible wording, and verify fresh-load behavior without a startup module.
11. Add failing source, artifact, and browser contracts for the approved SVG favicon; replace the old ICO-backed `$:/favicon.ico` with the metadata-mapped SVG source; then verify the integrated single-HTML build and native runtime data URI.
12. Add failing source/artifact/runtime contracts for the screenshot-corrected transparent `780×780` crop, remove the rejected full-canvas rectangle, and inspect the favicon at `16px`, `20px`, `32px`, and `64px` in a realistic browser-tab surface.

If a future request would require `publish`, external deployment, package distribution, or release-oriented artifact generation, stop and obtain explicit user direction first. A normal local `build` remains a validation command only.

Rollback is a normal Wiki-submodule commit revert. No user tiddler data, WikiText syntax, or persisted browser state is migrated.

## Open Questions

The production selection is closed: `03-compact-control-rail` is the direct default, native TiddlyWiki PageControl tiddlers are the required behavior source, and product-scoped line-icon tiddlers are the visual source. No runtime old/new switch is planned. SDK metadata order and the accepted document theme remain unchanged. The browser-favicon choice is also closed: use the supplied AngelScript SVG exactly through the native `$:/favicon.ico` system-tiddler lifecycle, without changing internal Wiki icons.
