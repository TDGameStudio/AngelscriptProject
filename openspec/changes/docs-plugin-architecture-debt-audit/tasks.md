## 1. Extract findings from reports

- [x] 1.1 Read the 13 substantive reports in `Documents/Reports/` and extract architecture-level findings with their cited identifiers.
- [x] 1.2 Exclude the 2,653 auto-generated `FunctionReview_*` files as per-function machine output rather than architectural analysis.
- [x] 1.3 Group findings by architectural theme rather than by source report, so duplicates across reports collapse.

## 2. Survey existing OpenSpec coverage

- [x] 2.1 Survey all 29 active changes for the architectural problem each addresses and its task completion state.
- [x] 2.2 Survey the 104 archived changes by theme to identify findings already resolved.
- [x] 2.3 Build the theme-to-change coverage mapping and mark uncovered themes.

## 3. Re-verify findings against current source

- [x] 3.1 Re-measure all file-size and god-object claims; record current line counts and any decomposition that landed.
- [x] 3.2 Re-check every thread-safety and global-state claim by reading the surrounding code, not by identifier presence alone.
- [x] 3.3 Re-count naming, boundary, and export-surface claims; record current figures instead of the reported ones.
- [x] 3.4 Re-check the hook/extension architecture given the four archived hook changes; determine the current design.
- [x] 3.5 Adjudicate the two claims automated checking left ambiguous (A6 `ParallelFor` race, B7 missing header) by direct reading.
- [x] 3.6 Record every instance where a report claim proved inaccurate or where the magnitude regressed.

## 4. Record the registry

- [x] 4.1 Write `findings.md` with one row per finding: current evidence, verdict, coverage mapping.
- [x] 4.2 Separate third-party-sourced leads (section H) from re-verified findings (A–G) so they cannot be mistaken for verified.
- [x] 4.3 Write `verification.md` with method, manual adjudications, report inaccuracies, verdict distribution, confidence, and limits.
- [x] 4.4 Write the `plugin-architecture-debt-registry` spec delta requiring current-state evidence, verdict plus date, coverage mapping, and no-remediation-in-audit.
- [x] 4.5 Derive the ordered follow-up candidate list, each naming the finding IDs it would resolve.

## 5. Close out

- [ ] 5.1 Add a superseded notice to the reports in `Documents/Reports/` pointing at this registry as the current source of truth, retaining report content for history.
- [ ] 5.2 Confirm with the maintainer which follow-up candidates to record as changes, starting with `fix-as-hot-reload-thread-safety` (carries the confirmed A6 race).
- [ ] 5.3 Run `openspec validate docs-plugin-architecture-debt-audit --strict` and resolve any findings.
- [ ] 5.4 Archive this change once the follow-up candidates are recorded, so the registry becomes the historical audit and the follow-ups carry the live work.
