# Canonical AS namespace replan validation

## Scope

User-authorized planning-only update of angelscript/refactor-builder-engine-independent. The new final target removes nested frontend C++ qualification while preserving the existing outer AS namespace macros, source/frontend organization, semantic identities and dormant runtime boundaries.

## Candidate proof before writes

- Before: 17 nodes, 8 complete; result: 18 nodes, 8 complete; sole Ready remains 4.2.
- All old IDs, completed checkbox state and unrelated dependency edges are preserved.
- Replace 7.1's direct predecessor 6.1 with 6.2; new 6.2 depends on 6.1.
- Candidate body IDs and generated edges agree with the portable TaskPlan-based graph; cycle/missing/done-prerequisite checks pass.
- Before tasks SHA-256: e8fa76a3e2541976f0b6ad07a59853cbe663e8bd2318f4030b823c52c764dd38.
- Result tasks SHA-256: 0062a1bb971eb91605bb9e664d3ec1561f0eb807b9476427651c1a2277c3d07f.

The new task's future structural test, C++ fixture, rebuild and NativeEngine run are planned acceptance, not executed results. Missing compile/link names are not misreported as behavioral RED.

## Contract preservation

Three current owner specs are read, not edited. Change deltas modify the AST context and single-authority requirements, the Parser/Sema declaration requirement and the explicitly renamed compilation-facade requirement. All existing Scenario Cards in those requirements are retained, with only the accepted naming/owner/signature corrections. The existing codec and added grammar/host-output deltas remain intact.

The outer macros still select AngelScript scope when AS_USE_NAMESPACE is defined and global scope otherwise. No alternate whole-fork build configuration is newly certified. C++ exported symbols require rebuilt consumers; script namespaces, key input/version and pointer-free wire data are not renamed.

Current knowledge examples are assigned to 7.2 synchronization; archives, old evidence and generated diagrams remain historical. The preceding 481/481 report and both open AS issues retain their original limits.

## Executed post-write checks

- Command: `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-builder-engine-independent','--strict','--json')`.
  - Run ID: 593e63ae78004ef283e95dc8c002825b; Succeeded, exit 0, valid with zero issues.
- Command: `Invoke-Harness -Command task.status -Context $context -Parameters @{Change='angelscript/refactor-builder-engine-independent'}`.
  - Run ID: d495f8ef768d4ca08717d0902b289b7d; 8/18 complete, 10 pending, sole Ready 4.2. Derived predecessors confirm 6.1 <- 5.2, 6.2 <- 6.1, 7.1 <- 6.2, 7.2 <- 7.1.
- Command: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths @('openspec/changes/angelscript/refactor-builder-engine-independent')`.
  - PASS, including package/protocol/authoring/link/hermetic assertions and the selected Change's complete language/attachment owner audit. No unrelated full-scan baseline is claimed green.
- Command: `& ./.agents/skills/harness/tests/Protocol.Tests.ps1`.
  - PASS; applied replan structure, exact attachment indexes and existing issue contracts remain valid.
- Command: `Get-FileHash openspec/changes/angelscript/refactor-builder-engine-independent/tasks.md -Algorithm SHA256`.
  - Matches the precomputed result digest exactly: 0062a1bb971eb91605bb9e664d3ec1561f0eb807b9476427651c1a2277c3d07f.
- In-memory artifact preservation checks: all eight completed task blocks remain byte-equal after line-ending normalization; all eleven existing Scenario Cards retain their names/owners through the explicit rename and modified deltas; the three current specs remain unchanged. The actual task file matches the validated candidate.

These are planning/static checks, not namespace implementation GREEN. No UE build or Automation, plugin/Standalone test, Harness Quick/Performance/Integration, source edit, Git commit, current-spec synchronization or archive ran. Existing 481-case evidence cannot certify this future naming cutover.
