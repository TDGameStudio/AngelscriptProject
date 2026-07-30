## 1. Change Record

- [x] 1.1 Record the inactive CodeMirror 6 and preview-glass cleanup scope, retained parent references, and unchanged product boundary.

## 2. Retired Source Boundaries

- [x] 2.1 Add failing source-boundary assertions that the two retired vendor directories and CodeMirror-only theme selectors are absent. <!-- TDD -->
- [x] 2.2 Remove the CodeMirror 6 and preview-glass vendor snapshots and align the vendor ignore allowlist and lint inputs. <!-- Non-TDD -->
- [x] 2.3 Remove the inactive CodeMirror-only theme selectors and make the source-boundary test pass. <!-- TDD -->
- [x] 2.4 Add failing boundary and product-manifest assertions for the superseded sidebar-resizer and unshipped Modern.TiddlyDev documentation bundle. <!-- TDD -->
- [x] 2.5 Remove the vendor sidebar-resizer and `src/doc` bundle, then align the manifest, TypeScript scope, theme remnant, and README assets. <!-- TDD -->

## 3. Documentation and Verification

- [x] 3.1 Update Chinese then English Wiki maintenance guidance to describe the active product source boundary. <!-- Non-TDD -->
- [x] 3.2 Update Chinese then English Wiki maintenance guidance and README references for the retired sidebar-resizer and documentation bundle. <!-- Non-TDD -->
- [x] 3.3 Run source-boundary, offline artifact, browser, and complete Wiki verification. <!-- Non-TDD -->
- [x] 3.4 Review scoped diffs, commit the Wiki submodule, then commit the parent OpenSpec record and Wiki gitlink. <!-- Non-TDD -->
