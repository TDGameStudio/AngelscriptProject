# Both bytecodes hang on asCScriptFunction; runtime only at Link

## Context

Reconstructed VM ran `asCExecutableFunction.scriptData` looked up by StableKey. Emit produced `asCByteCodeImage`. That split declaration from executable and added Snapshot leases.

## Evidence

- Metadata Function ctor does not allocate `scriptData`.
- `asLinkByteCodeImage` / `LowerFunction` is the only writer of lowered DWORDs.
- `Prepare` returns `asNO_FUNCTION` if no published executable; it does not Link.
- User: hang stable and runtime bytecode on `asCScriptFunction`; delete public executable/snapshot/byte-code-image types.

## Options

| Option | Result |
| --- | --- |
| A. Both layers on Function | One object per Engine |
| B. Keep public asCExecutableFunction | Extra lifetime |
| C. Generate runtime on first Prepare | Hides Link errors |

## Settled Decision

Option A. Runtime bytecode is written only in `asCEngineCompileRegistration` Link, after Install, before the function is callable.

## Consequences and Flip Condition

`asCByteCodeEmitter` stays public; RunThrough also calls it. Flip if Contexts must keep executing an old body after a replacement Link.

## Sources

- attachments/drafts/findings/runtime-bytecode-timing.md
- attachments/drafts/design.md
- draft log.md Round 5 Q15; runtime-bytecode timing pin
