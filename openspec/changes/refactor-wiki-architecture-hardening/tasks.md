## 1. Product Boundaries

- [x] 1.1 Add failing manifest tests for product/reference profiles, unique plugin titles, runtime policies, and safe relative paths <!-- TDD -->
- [x] 1.2 Replace the external-only manifest and hard-coded local array with one product source manifest <!-- TDD -->
- [x] 1.3 Add failing runtime/content tests for unknown serialized plugins, initial off-origin requests, and ordinary test-tiddler leakage <!-- TDD -->
- [x] 1.4 Remove CPL and prevent-edit runtime payloads and migrate internal fixtures to the system test namespace <!-- TDD -->
- [x] 1.6 Remove the unused Modern.TiddlyDev `plugin-name` template fixture, its dedicated Playwright config/tests, and stale workflow exclusions <!-- TDD -->
- [x] 1.5 Record current vendor source deltas and reject unrecorded vendor modifications <!-- TDD -->

## 2. Wiki Product Workflow

- [x] 2.1 Add failing offline-artifact tests for complete HTML, the runtime allowlist, size budget, and absence of plugin packages/library <!-- TDD -->
- [x] 2.2 Refactor the offline builder to compile product plugins directly into the Wiki without `buildLibrary` output <!-- TDD -->
- [x] 2.3 Replace plugin-template scripts with `build:wiki`, `test:artifact`, and aggregate `verify` product commands <!-- Non-TDD -->
- [x] 2.4 Consolidate PR/push CI on Node 24 and frozen pnpm install; retire plugin release and automatic Pages deployment workflows <!-- Non-TDD -->
- [x] 2.5 Update repository guidance and the deferred Pages OpenSpec to describe the Wiki-first workflow <!-- Non-TDD -->

## 3. Core Compatibility Baseline

- [x] 3.1 Add failing PageTemplate contract and file-drop/internal-drag behavior tests <!-- TDD -->
- [x] 3.2 Document and test the lingo compatibility patch against the installed core baseline <!-- TDD -->
- [x] 3.3 Upgrade TiddlyWiki to 5.4.1 and align Node 24 types in an isolated dependency change <!-- Non-TDD -->
- [x] 3.4 Run source, TiddlyWiki, browser, and offline artifact verification after the dependency upgrade <!-- Non-TDD -->

## 4. Navigation and Theme Modularity

- [ ] 4.1 Add failing resizer tests for clamp, single terminal persistence, cancellation, lost capture, blur, and no auto-hide <!-- TDD -->
- [x] 4.2 Move left-sidebar resize/segment behavior from config to the tools navigation module and remove the vendor resizer runtime entry <!-- TDD -->
- [ ] 4.3 Split tools code presentation and navigation styles/modules into named feature files <!-- Non-TDD -->
- [ ] 4.4 Introduce ordered theme token, foundation, document, SDK, sidebar, editor, highlight, and compatibility stylesheets <!-- Non-TDD -->
- [ ] 4.5 Replace SDK `:has()` detection with a class-filter contract and remove duplicated SDK body headings <!-- TDD -->
- [ ] 4.6 Remove global focus suppression, low-contrast controls, dead legacy selectors, duplicate breakpoints, and unjustified high-specificity rules <!-- TDD -->
- [x] 4.7 Preserve desktop/mobile geometry, More divider spacing, document typography, and accepted left-sidebar behavior in visual tests <!-- TDD -->

## 5. Content, Status, and Quality Gates

- [ ] 5.1 Add localized SDK caption/description field selection with schema and fallback tests <!-- TDD -->
- [x] 5.2 Add a parent-host baseline sync command and render revision-stamped generated data in `AS/Status` <!-- TDD -->
- [ ] 5.3 Split browser tests by shell/document/code/content concerns and introduce semantic helpers <!-- TDD -->
- [ ] 5.4 Add Firefox/WebKit critical smoke coverage and focused accessibility checks <!-- TDD -->
- [x] 5.5 Add deterministic artifact/plugin-size reporting with a 5,800,000-byte decoded ceiling <!-- TDD -->

## 6. Verification and Integration

- [x] 6.1 Run `pnpm run verify`, product build, artifact checks, and viewport screenshots from a clean Wiki state <!-- Non-TDD -->
- [x] 6.2 Validate `refactor-wiki-architecture-hardening` with OpenSpec strict validation and record verification evidence <!-- Non-TDD -->
- [x] 6.3 Review the final diff for unrelated parent/Wiki changes and keep publication/deployment disabled <!-- Non-TDD -->
- [ ] 6.4 Commit the Wiki repository first, then record only the OpenSpec and Wiki gitlink in the parent repository <!-- Non-TDD -->
