# 09 — Networking Corpus And Script Tests

| ID | User scenario / AS surface | Corpus target | Script-test target | Existing evidence to audit | Fixture / log policy | Initial disposition |
|---|---|---|---|---|---|---|
| NET-01 | Replicated property declaration and role-aware mutation | `Script/Networking/ReplicatedState.as` | `Script/Tests/Networking/Test_ReplicatedState.as` | Coverage Networking; current NetworkReplication | real participants for delivery; compile shape separate | `CorpusGap`, `ScriptTestGap`, `EnvironmentBound` |
| NET-02 | RepNotify declaration, previous/new state, callback | `Script/Networking/RepNotifyState.as` | `Script/Tests/Networking/Test_RepNotifyState.as` | Coverage Networking/property tests | network topology; assert participant state/callback | `CorpusGap`, `ScriptTestGap`, `EnvironmentBound` |
| NET-03 | Server RPC authority route | `Script/Networking/ServerRpc.as` | `Script/Tests/Networking/Test_ServerRpc.as` | Compiler/Functional Network RPC tests | real client/server; structured route logs plus assertions | `CorpusGap`, `ScriptTestGap`, `EnvironmentBound` |
| NET-04 | Client RPC owner route | `Script/Networking/ClientRpc.as` | `Script/Tests/Networking/Test_ClientRpc.as` | RPC compilation/network tests | real server/owning client | `CorpusGap`, `ScriptTestGap`, `EnvironmentBound` |
| NET-05 | Reliable and unreliable NetMulticast behavior | `Script/Networking/MulticastRpc.as` | `Script/Tests/Networking/Test_MulticastRpc.as` | Network RPC tests; Coverage Networking | server plus multiple clients; do not assert unreliable delivery as guaranteed | `CorpusGap`, `ScriptTestGap`, `EnvironmentBound` |
| NET-06 | WithValidation accept/reject behavior | `Script/Networking/ValidatedServerRpc.as` | `Script/Tests/Networking/Test_ValidatedServerRpc.as` | current NetworkReplication; compiler RPC coverage | real server/client; assert accepted state and rejected boundary | `CorpusGap`, `ScriptTestGap`, `EnvironmentBound` |
| NET-07 | Network roles, authority and local control checks | `Script/Networking/AuthorityAndRoles.as` | `Script/Tests/Networking/Test_AuthorityAndRoles.as` | Coverage Networking roles | network participants; per-role state logs | `CorpusGap`, `ScriptTestGap`, `EnvironmentBound` |
| NET-08 | Replicated Actor/Component lifecycle and ownership | `Script/Networking/ReplicatedActorLifecycle.as` | `Script/Tests/Networking/Test_ReplicatedActorLifecycle.as` | Networking module tests; Actor/Component lifecycle | network World; assert spawn/owner/destruction visibility | `CorpusGap`, `ScriptTestGap`, `EnvironmentBound` |
| NET-09 | Network delegate/latent advanced command compatibility | No general corpus unless a production network pattern is taught | `Script/Tests/Networking/Test_NetworkLatentCommands.as` | script-test advanced network command infrastructure | test framework/network harness only | `ScriptTestGap`, `EnvironmentBound` |
| NET-10 | RPC declaration compile coverage without live route | Troubleshooting/API table note in related corpus files | focused compile tests remain in Compiler/Coverage | existing NetworkRPCTests | no local direct call used as route proof | `Covered` for declaration only; never satisfies NET-03..06 |

## Network Completion Rule

Rows NET-01 through NET-09 become `Covered` only through a real network-capable execution path or remain `EnvironmentBound` with the exact unavailable topology. A local single-World function call, reflection invocation, or successful compilation is not RPC/replication behavior evidence.

