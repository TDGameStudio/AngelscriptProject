# Add-on and license audit brief

Read-only task. Do not edit files, copy third-party code, commit, or change OpenSpec checkboxes.

Inspect the maintained fork, `Reference/angelscript-v2.38.0`, and repository license conventions.

Report:

1. whether `scriptstdstring`, `scriptarray`, `scriptdictionary`, and `scriptmath` exist locally and their exact paths;
2. upstream version/revision/license evidence available locally;
3. their source/include dependencies and whether they compile under `AS_MAX_PORTABILITY`;
4. any incompatibility with the maintained 2.33-based fork API;
5. the minimum license-preserving import layout and files required by task 1.4;
6. which add-ons are required for the first native-runtime smoke versus safe to defer.

Write the detailed report to `.superpowers/sdd/feature-ue-angelscript-standalone-compiler/audit-addons-report.md`. Return only status plus a one-line summary and concerns.

