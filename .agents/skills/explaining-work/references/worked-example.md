## When this example helps

- Use this example when an explanation lists functions but does not connect architecture, annotated code, state and evidence. It demonstrates one complete path; it is not a required output template.
- The subject is a real Harness query at commit `20c9b7df949be76e264a76e588f64cdef6027f2e`. Reinspect the target version before reusing its behavior. These are PowerShell functions and returned records, not invented C++ classes.
- Source: [workspace lifecycle module](../../workspace-lifecycle/scripts/WorkspaceLifecycle.psm1), [Harness route dispatch](../../harness/scripts/Harness.psm1), [query regression](../../workspace-lifecycle/tests/WorkspaceQueryPerformance.Tests.ps1) and [measured comparison](../../../../openspec/specs/harness/core/knowledges/query-performance.md).

## Start with a question and the responsibilities

- Example question: "Why is workspace status faster now, and can it still notice a branch or configuration change?"
- A status query needs the selected repository's identity and configuration. The repair removes repeated root discovery within one call. It still obtains current information on the next call; a result already held by a caller does not update itself.

| Actual function or record | Responsibility in this path |
|---|---|
| `Invoke-Harness` | Dispatch the requested route under the selected workspace context and enforce its invocation boundary. |
| `Get-HarnessWorkspaceStatus` | Assemble the public status result; include repository scan details only for `Detailed`. |
| `Get-HarnessWorkspaceConfigStatus` | Read/check `AgentConfig.ini` against the current identity and expose configuration errors. |
| `Get-WorkspaceIdentity` | Resolve the root, choose Git registration or replica metadata and construct current identity data. The Git path also covers retained Git worktrees. |
| `configStatus.Identity` | The result already obtained in this invocation; the outer status function reuses it. |

## Keep dispatch, calls and returned data distinct

```text
Harness route registration
workspace.status --[maps to]--> Get-HarnessWorkspaceStatus
  // This is a dispatch mapping, not evidence that a query has executed.

After Invoke-Harness validates this invocation and dispatches the route:
Get-HarnessWorkspaceStatus
└─[calls] Get-HarnessWorkspaceConfigStatus
   └─[calls] Get-WorkspaceIdentity
      ├─[calls] Resolve-WorkspaceRepository
      │  // Finds the canonical root from the supplied/selected location.
      └─[selects] Git registration or replica metadata path
         // Produces identity under the applicable workspace topology.

Returned data, moving back to the caller:
Identity -> configStatus.Identity -> status.Context
                                  -> status.Branch / status.Head / other fields
  // The arrows here mean result composition, not another function call.
```

- This view focuses on the workspace leaf. The dispatcher retains an independent context check; the whole public route therefore has more work than the leaf alone. Do not use a leaf count to describe total public-route cost.
- Git registration and replica metadata take different internal paths. A count measured in the primary fixture is not a universal count for every topology.

## Put the causal explanation beside faithful code

```powershell
# Selected statements from the cited version, in their original order.
# This is a non-executable excerpt: parameter blocks, checks, fields and
# the Detailed branch are omitted. Read the source for complete behavior.

function Get-HarnessWorkspaceConfigStatus {
    # ... actual parameter block omitted ...
    $identity = Get-WorkspaceIdentity -ProjectRoot $ProjectRoot
    # Identity resolution has already established the repository root.
    $root = $identity.WorkspaceRoot
    $path = Join-Path $root 'AgentConfig.ini'
    # ... read/check this file and construct the actual result ...
    # The actual returned record contains: Identity = $identity
}

function Get-HarnessWorkspaceStatus {
    # ... actual parameters and optional Refresh handling omitted ...
    $configStatus = Get-HarnessWorkspaceConfigStatus -ProjectRoot $ProjectRoot
    $identity = $configStatus.Identity
    $root = $identity.WorkspaceRoot
    # These lines reuse this invocation's returned data. They do not load
    # an identity saved from an earlier status query.
    # ... compose the actual result; Fast returns before the Detailed scan ...
}
```

- Previously the outer functions also resolved the root before delegating to a function that resolved it again. The current composition removes those duplicate native operations. This explains the mechanism; the measured results, rather than the code shape alone, support the performance claim.
- Do not interpret `ConfigurationReady` as proof that an Unreal build will succeed. In this version it means a nonblank configured `EngineRoot`; `IdentityValid` and the listed errors describe other checks. Reading a field name without its assignment would give the wrong explanation.

## Carry one scenario through the path

| Moment | Input or state | What the reader can conclude |
|---|---|---|
| First query | A nested directory inside the selected repository | Identity resolution finds the repository root; status uses the identity returned by its configuration query. |
| Between queries | The branch/HEAD or configuration changes | The already-returned object still contains its earlier values. It is not a subscription. |
| Next query | Same request, changed repository/configuration | The query reads again; the regression observes the new values without a Refresh flag. |
| Missing configuration | `AgentConfig.ini` is absent | Status reports the missing configuration; reading status does not create the file. |
| Fast result | `Detailed` was not selected | Absence of dirty-file evidence does not establish a clean repository; that scan was not requested. |

- This scenario is a source-derived account, backed by the cited fixture. It is not a newly observed query of the user's current repository, nor a claim of an atomic snapshot across concurrently changing files.
- The regression bounds the three leaf queries to one root probe each and checks current branch/HEAD/configuration and Detailed dirty-file evidence. It establishes this resource/freshness boundary, not all workspace behavior.
- The recorded local comparison shows fewer actual Git calls and lower median status latency. Its small samples and isolated repositories do not establish a full UE checkout's tail latency. Report that limit alongside the benefit.

## Use the same approach when the reader is still unsure

- If "reuse" sounds like "stale cache", return to the two-query example and point to where the new `$identity` comes from. Repeating "no cache" with more terminology would not expose the distinction.
- Reconnect that concrete state change to the same architecture and real names. Do not discard the surrounding path or invent another abstraction to explain the first one.
- Explanation alone requests no approval and changes no repository state. In a design discussion, return this understanding to Grill's actual pending choice; a reader understanding the example is not a handoff decision.
