## Why

The current debugger protocol is a custom binary transport whose message schemas, compatibility branches, and session state are concentrated in `FAngelscriptDebugServer`. This makes protocol evolution risky: V1 compatibility logic still shapes variable serialization, `DebugAdapterVersion` is global state, and protocol unit tests are parked in the temporary C++ test area instead of the Debugger test layer.

The project should make the current V2 debugger protocol the explicit supported baseline before more debugger, IDE, or data-breakpoint work lands.

## What Changes

- **BREAKING**: Retire debugger protocol V1 support and require debugger clients to negotiate `DebugAdapterVersion >= 2`.
- **BREAKING**: Treat V2 variable payloads, including `ValueAddress` and `ValueSize`, as mandatory fields for debugger variables and evaluate responses.
- Split debugger protocol concerns into a small protocol boundary for envelope framing, message DTO serialization, version negotiation, and per-client protocol state.
- Remove the runtime dependency on a global adapter-version value for message serialization decisions.
- Move the protocol and transport tests out of `Source/AngelscriptTest/Temp/` into the `Debugger/` test layer with stable `Angelscript.TestModule.Debugger.*` prefixes.
- Preserve current debugger behavior for V2 clients: handshake, breakpoints, callstack, variables, evaluate, data breakpoints, break filters, debug database, asset database, and ping/continued/stopped events.
- Document that a fuller protocol modernization, including a possible schema-driven codec or DAP-facing transport redesign, was considered but is intentionally out of scope for this change.

## Capabilities

### New Capabilities

- `debugger-protocol-v2`: Defines the supported debugger wire protocol baseline, V2 negotiation requirements, message compatibility expectations, and test coverage for V2-only debugger clients.

### Modified Capabilities

- None.

## Impact

- Runtime code under `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/`, especially `AngelscriptDebugServer.h` and `AngelscriptDebugServer.cpp`.
- Test code under `Plugins/Angelscript/Source/AngelscriptTest/Debugger/`, `Plugins/Angelscript/Source/AngelscriptTest/Shared/`, and the temporary test files currently under `Plugins/Angelscript/Source/AngelscriptTest/Temp/`.
- External debugger clients: clients still sending V0/V1 `StartDebugging` handshakes or expecting V1 variable payloads must be updated to V2.
- Documentation under `Documents/Guides/` or `Documents/Knowledges/` that describes debugger protocol behavior, test entry points, or debugger adapter compatibility.
- Verification uses the project standard build and debugger test runners: `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, and `Tools\RunTestSuite.ps1`.
