# Change identity migration

Recorded at 2026-09-10T08:17:51.0713121+00:00 for the user's explicit rename request.

| Field | Before | After |
| --- | --- | --- |
| Canonical ID | angelscript/feature-types-external-ownership | angelscript/feature-types-explicit-ownership |
| Root | openspec/changes/angelscript/feature-types-external-ownership/ | openspec/changes/angelscript/feature-types-explicit-ownership/ |
| UID | change_6f58d4ea-1ff3-48f6-8680-df1b32635270 | unchanged |

The portable OpenSpec change move route performed the rename (run 615c89b65f2343bf935f9ae0ad388a55); the manifest retains the former ID as an alias. Current SDK task paths, binding prerequisite references, active/archived producer lookup and attachment navigation use the new name. The title now names explicit metadata ownership and unified identity registration.

Historical Review, Replan, issue, assessment and snapshot files were moved byte-for-byte without rewriting their content or digests. To locate a historical workspace-relative reference beginning with openspec/changes/angelscript/feature-types-external-ownership/, replace that root prefix with openspec/changes/angelscript/feature-types-explicit-ownership/ and preserve the suffix. This mapping also applies to snapshot_ref and manifest part paths. Embedded source paths and Change names remain evidence of the original reviewed state. The old logical ID resolves through OpenSpec; it is not a filesystem symlink or a second active Change.

All preexisting historical file hashes in both Changes were compared before and after the move. Candidate tasks differ only by the Change-name substitution; task IDs, DAG, states, test selectors and the producer UID are unchanged. All 37 proving commands passed PowerShell syntax parsing before mutation. Strict validation and alias/UID resolution are checked after the move; no SDK/UE tests are implied by these planning checks.

Harness issues remain open and deferred. This rename does not resolve earlier evolution diagnostics, alter ownership behavior, start a new Review or implement product code. Existing review verdicts bind the preserved snapshots; this record explains their relocated paths.
## Completed verification

Strict validation passed for the renamed SDK Change (run a30f2f94d4fd46919318faaca130336e) and binding Change (run 0a34a75972664926935e25c75620a3c6). task.status reports 0/13 and 0/24 complete. Both old and new IDs resolve through change show to the same new canonical ID and unchanged UID. Both attachment indexes have valid targets, exact-once membership and at most 120 lines. Current proposal/design/tasks contain no old name. Before/after review snapshot part digests still match when resolved through the relocation mapping. The old directory is absent.
