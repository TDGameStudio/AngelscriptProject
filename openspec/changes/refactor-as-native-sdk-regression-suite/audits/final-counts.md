# Final Native SDK Counts

Generated from the final focused reports and full SDK report on 2026-07-23.

| Scope | Active discovered | Passed | Failed | Disabled future cases | Evidence |
| --- | ---: | ---: | ---: | ---: | --- |
| Full native SDK prefix | 412 | 412 | 0 | 7 | `Saved/Tests/as-native-sdk-regression-full/20260723_032711_529_774230db/Report/index.json`; Disabled future owners are intentionally omitted by Automation discovery. |
| Engine | 19 | 19 | 0 | 0 | focused domain report |
| Frontend | 129 | 129 | 0 | 0 | focused domain report |
| Compiler | 105 | 105 | 0 | 0 | focused domain report |
| Runtime | 25 | 25 | 0 | 0 | focused domain report |
| Module | 38 | 38 | 0 | 0 | focused domain report |
| TypeSystem | 32 | 32 | 0 | 0 | focused domain report |
| Language | 39 | 39 | 0 | 0 | focused domain report |
| Embedding | 21 | 21 | 0 | 0 | focused domain report |
| Conformance | 4 | 4 | 0 | 7 | focused domain report plus source registration audit |

The source tree has 95 raw-SDK source files and 92 registering sources according to `AuditNativeSdkTests.ps1 -Phase Complete`. The moved-method ledger remains 433 rows with 12 explicit replacements, as independently validated by `ValidatePlanningRecords.ps1 -AllowMovedSources`.
