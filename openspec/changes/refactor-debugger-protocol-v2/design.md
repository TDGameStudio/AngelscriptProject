## Context

`Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h` currently owns the debugger message enum, message DTOs, wire-format operators, and the global `AngelscriptDebugServer::DebugAdapterVersion`. `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp` owns envelope framing, socket IO, session state, pause/step/breakpoint state transitions, and debug database emission.

The current protocol is a custom binary protocol layered over TCP. It is DAP-like in workflow but not DAP JSON: each packet is `int32 MessageLength`, `uint8 EDebugMessageType`, then an Unreal `FArchive`-serialized body. V2 is the active adapter version. V1 support remains only as compatibility branches, most visibly in `FAngelscriptVariable`, where V2 appends `ValueAddress` and `ValueSize` for data breakpoint support.

That compatibility shape creates three maintenance problems:

1. Protocol schema choices are mixed into server state-machine code.
2. Version decisions are made through global mutable state, which is fragile for multi-client sessions and tests.
3. Protocol contract tests live under `Source/AngelscriptTest/Temp/`, which is explicitly a temporary migration area.

## Goals / Non-Goals

**Goals:**

- Make debugger protocol V2 the minimum supported adapter protocol.
- Remove V1 variable payload compatibility and require variable address metadata in V2 variable/evaluate responses.
- Move protocol framing and message serialization behind focused runtime protocol helpers that the debug server and tests can use directly.
- Replace global adapter-version-dependent serialization with per-client or per-session protocol state.
- Preserve V2 debugger behavior for existing current clients, including breakpoints, stepping, variables, evaluate, data breakpoints, debug database, asset database, and ping events.
- Move protocol/transport tests into the Debugger test layer and align their automation prefixes with project conventions.
- Document the wire format and the breaking V2 baseline.

**Non-Goals:**

- This change will not implement a full standard DAP JSON server.
- This change will not redesign the VS Code adapter architecture.
- This change will not change script debugging semantics outside protocol parsing/serialization and session negotiation.
- This change will not introduce a new external serialization dependency.

## Decisions

### Decision: Make V2 the protocol floor

Debugger clients must send `StartDebugging` with `DebugAdapterVersion >= 2`. The server will reject, disconnect, or report a clear protocol failure for older adapter versions instead of silently entering a degraded V1 mode.

Rationale: current reference adapter sends V2, data breakpoints rely on V2 variable address metadata, and keeping V1 creates risk in every variable serialization path.

Alternative considered: keep V1 indefinitely. This minimizes external breakage but preserves the global-version and schema-branch complexity that this change is intended to remove.

### Decision: Keep the binary transport, refactor its boundary

The wire transport remains the current binary envelope plus `FArchive` DTO body format. The refactor should extract protocol helpers, not replace the transport.

Expected boundary:

- Envelope helpers remain responsible for length/type/body framing and max-size validation.
- Message DTO serialization remains native C++/Unreal `FArchive` based.
- Version negotiation and client capability checks are represented by explicit protocol state instead of reading a global during DTO serialization.
- `FAngelscriptDebugServer::HandleMessage()` keeps high-level message dispatch but delegates parsing/serialization decisions to the protocol boundary where practical.

Rationale: this keeps the change focused and preserves behavior for V2 clients while making future protocol changes less invasive.

### Decision: Remove global adapter-version-dependent serialization

Protocol serialization should not depend on `AngelscriptDebugServer::DebugAdapterVersion` as a mutable global. The implementation should either:

- store negotiated protocol state per client socket and pass it into protocol serialization helpers, or
- store a session-level protocol state only if the implementation intentionally supports one active adapter version for the whole server.

Per-client state is preferred because the current server already tracks client-specific debugger and debug-database participation. If a session-level state is chosen for implementation simplicity, it must be documented and tests must prove reconnect and multi-client behavior remains deterministic.

### Decision: Convert `Temp` protocol tests into Debugger protocol contract tests

The existing `AngelscriptDebugProtocolTests.cpp` and `AngelscriptDebugTransportTests.cpp` cover useful protocol contracts, but their location and `CppTests.Debug.*` prefixes no longer match the desired Debugger test layer.

The refactor should move or rewrite them under `Plugins/Angelscript/Source/AngelscriptTest/Debugger/` as focused tests with `Angelscript.TestModule.Debugger.Protocol.*` and `Angelscript.TestModule.Debugger.Transport.*` prefixes. V1 round-trip tests should be removed or converted into negative negotiation tests.

### Decision: Treat full protocol modernization as a later change

A deeper modernization could introduce a schema-driven codec, a documented versioned binary schema, or a standard DAP JSON-facing server boundary. That work is intentionally deferred.

Rationale: the immediate maintenance problem is not that the transport is binary; it is that the current V2 contract is implicit and coupled to global state. A full DAP or schema rewrite should be proposed separately because it changes client integration, documentation, and testing scope.

## Risks / Trade-offs

- **Old external clients break** -> The proposal marks V2-only as breaking, and docs must give the migration path: send `DebugAdapterVersion = 2` and read `ValueAddress`/`ValueSize` in variable payloads.
- **Multi-client behavior changes accidentally** -> Add session tests around two V2 clients, reconnect, and version-state cleanup.
- **Protocol helper extraction churns `HandleMessage()` too broadly** -> Keep the first pass focused on framing, DTO serialization, negotiation, and variable/callstack version paths; do not split every debug command handler unless needed.
- **Test renaming hides coverage regressions** -> Preserve or improve the old protocol/transport assertions while changing their directory and prefixes.
- **Docs overpromise standard DAP compatibility** -> Documentation must explicitly say the runtime protocol is custom binary and DAP compatibility, if any, belongs in the external adapter layer.

## Migration Plan

1. Add or move tests that describe V2-only negotiation, V2 variable payloads, transport framing, and multi-client adapter-version behavior.
2. Extract protocol helpers and replace global-version-dependent DTO branches with explicit V2 serialization.
3. Update server handshake handling to reject adapter versions lower than 2 with deterministic behavior.
4. Move `Temp` protocol tests into `Debugger/` and remove obsolete V1 round-trip coverage.
5. Update documentation and test catalog entries.
6. Run targeted debugger protocol tests, the debugger suite, and a standard build.

Rollback is straightforward if the change causes client integration problems: restore V1 negotiation branches and the previous global adapter-version behavior, then keep the moved protocol tests adjusted to the restored compatibility contract.

## Open Questions

- Should unsupported adapter versions receive a protocol response before disconnect, or should the server close the socket after logging a clear error? The implementation should choose the least risky behavior based on existing test-client support.
- Should negotiated protocol state be strictly per-client in this change, or is session-level V2 state acceptable after V1 removal? Per-client is preferred unless it causes disproportionate churn.
- Which project document should become the canonical public description of the debugger binary protocol: an existing guide under `Documents/Guides/`, a knowledge document under `Documents/Knowledges/`, or a new debugger protocol guide?
