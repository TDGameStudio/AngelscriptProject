## 1. Scope and regression contract

- [x] 1.1 Identify the page-wide core importer, the broad global drag-and-drop switch, and the editor-specific import setting. <!-- Non-TDD -->
- [x] 1.2 Add browser assertions for a non-dropzone page container and retained core sidebar droppable behavior. <!-- TDD -->

## 2. Narrow page-import removal

- [x] 2.1 Remove the broad `$:/config/DragAndDrop/Enable = no` experiment and shadow `$:/core/ui/PageTemplate` with only its outer importer dropzone removed. <!-- TDD -->
- [x] 2.2 Preserve `tc-page-container-inner` and document the source-owned override plus TiddlyWiki upgrade maintenance rule. <!-- Non-TDD -->

## 3. Verification and maintenance record

- [x] 3.1 Verify that the focused browser regression fails before each configuration/template boundary is implemented, then passes with the narrow override. <!-- TDD -->
- [x] 3.2 Run type checking, linting, the full Playwright suite, and a focused regression against the running local preview. <!-- TDD -->
- [x] 3.3 Compare the RefWiki reference and the official/community implementation guidance; record the scope and trade-offs. <!-- Non-TDD -->
