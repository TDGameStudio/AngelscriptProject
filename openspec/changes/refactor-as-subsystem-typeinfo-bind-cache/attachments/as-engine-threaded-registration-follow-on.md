# Follow-on: threaded AngelScript registration

Out of scope for `refactor-as-subsystem-typeinfo-bind-cache`. Recorded so TypeInfo is shaped for it.

## Why apply stays sequential now

`asCScriptEngine` registration (`RegisterObjectType`, `RegisterObjectMethod`, string pool, type-id allocation) is not atomic. Two threads calling `Register*` on one engine is undefined. A process lock around all `Register*` would not beat sequential apply.

## What TypeInfo already gives a later change

- One row per type, so independent types are an obvious parallel unit after templates exist.
- `DeclarationOrder` encodes "templates before values before objects".
- Member callable identities are already pointer-free of `asIScriptFunction*`.

## What a later OpenSpec would still have to do

- Make type-id / name maps on `asCScriptEngine` safe for concurrent insert, or shard them.
- Prove no registration reads a half-inserted type.
- Keep script compilation itself on one thread unless the compiler is separately audited.

Until that fork work exists, extra-engine speedup is: expand once, apply many times, skip reflection walks — not concurrent `Register*`.
