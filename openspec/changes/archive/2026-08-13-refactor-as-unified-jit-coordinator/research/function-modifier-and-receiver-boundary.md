# Function modifier and effective-receiver boundary

## Conclusion

Runtime JIT backends are bytecode consumers. They must not parse AngelScript
source modifiers, inspect parser nodes, or depend on maintained-fork
`asEFuncTrait` numeric values. The coordinator owns the translation from the
live function into a versioned, backend-neutral function profile before it
queues an immutable snapshot.

This is intentionally different from `feature-as-typed-semantic-aot`:

- typed Semantic Static AOT observes post-typecheck source semantics and must
  retain the complete raw trait set, receiver operands, final resolved calls,
  hidden/default argument origins, and compile-out rewrites in HIR;
- Runtime MIR/LLVM JIT consumes the authoritative bytecode/frame/control-flow
  result and only needs normalized information that affects entry ABI,
  eligibility, host helpers, lifetime, cleanup, or dispatch.

The maintained-fork trait inventory and full source-known policy are recorded
in `feature-as-typed-semantic-aot/research/function-traits-and-effective-receiver.md`.

## Snapshot split

Keep two layers instead of exporting raw fork traits to optional plugins.

Coordinator-owned diagnostic/snapshot state may retain:

- raw declared trait bits;
- `funcType`, object type/profile, call-convention/return-on-stack state;
- compile-out and generated/profile metadata useful for diagnostics;
- the exact declared parameter/frame layout.

The versioned worker/backend view carries neutral fields only:

```text
InvocationKind = Global | NativeObjectMethod | OtherUnsupported
ReceiverKind   = None | NativeObjectSlot | DeclaredParameterAlias |
                 MixinDispatch | OtherUnsupported
ReceiverParameterIndex
FunctionProfileFlags = OrdinaryScript | Generated | Constructor |
                       Destructor | Suspend | Cleanup | OtherUnsupported
```

The exact enum spelling may change during implementation, but the invariants
may not:

1. neutral profile values are ABI-versioned and have explicit unknown values;
2. an unknown value fails before backend code generation;
3. declared parameters and native object slots are separate;
4. backend code never interprets raw `asTRAIT_*` bits;
5. the first scalar slice queues only ordinary script functions with
   `ReceiverKind=None`, scalar frame entries, and no managed lifetime.

## `external_implicit_this`

The maintained fork implements:

```angelscript
int Evaluate(Receiver Target, int Delta) external_implicit_this
```

as a global function. Declared parameter `0` remains a real VM/call/frame
argument and is also used by the callee compiler for unqualified member/method
lookup. It is not a hidden native object slot.

The coordinator therefore normalizes this shape as:

```text
InvocationKind=Global
ReceiverKind=DeclaredParameterAlias
ReceiverParameterIndex=0
DeclaredParameterCount=unchanged
NativeObjectSlot=absent
```

The first Runtime scalar slice rejects it before invoking MIR/LLVM because the
receiver parameter and body require an object/managed-lifetime profile. The
whole function stays on VM. A future object-capable Runtime slice must extend
the neutral helper/reference and lifetime ABI, then prove VM differential
behavior; it must not erase parameter `0` or introduce an additional `this`.

The executable characterization probe is:

```powershell
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-ExternalImplicitThisRuntime.ps1
```

It uses the same maintained fork through Standalone, with no Unreal Engine,
and proves the named parameter plus unqualified property/method receiver
behavior. It does not prove a Runtime JIT backend supports the object shape.

## Mixin, hidden arguments, and compile-out calls

- A function mixin is a source call rewrite: the source receiver becomes
  formal parameter `0`. It is not the same callee-body implicit receiver as
  `external_implicit_this`. First-slice script calls/object parameters already
  reject it for the whole function.
- WorldContext/default/native ABI-only arguments are reflected in the final
  bytecode/frame/helper requirements. The snapshot records their neutral
  origin/profile only where eligibility or host marshalling needs it; no
  backend reconstructs them from declaration text.
- `CompileOutEntirely`, `ReplaceWithFirstParam`, and
  `CompileOutAsMethodChain` have already changed or removed the executable
  call before Runtime JIT sees bytecode. The backend treats bytecode as
  authoritative and must never re-create a source-level call from metadata.

## Test-first matrix

Add coordinator/fake-backend tests before concrete backend work:

| Case | Expected snapshot/profile outcome | Backend calls | Route |
| --- | --- | ---: | --- |
| ordinary global scalar | `Global/None`, unchanged scalar parameters | 1 | Runtime when compiled |
| ordinary instance method | `NativeObjectMethod/NativeObjectSlot` | 0 in v1 | VM / `UnsupportedReceiver` |
| valid external implicit this | `Global/DeclaredParameterAlias(0)`, parameter 0 retained | 0 in v1 | VM / `UnsupportedReceiver` |
| malformed alias | snapshot validation failure | 0 | VM / `InvalidInput` |
| mixin/script-call body | neutral mixin/call requirement retained | 0 in v1 | VM / `UnsupportedCall` or receiver reason |
| unknown neutral profile value | ABI validation failure | 0 | VM / `InvalidInput` |
| compiled-out source call | no executable call opcode/helper token | 1 if otherwise scalar | Runtime parity with VM |

Concrete MIR and LLVM conformance tests additionally feed a deliberately
non-`None`/unknown profile view directly to the backend session and require a
typed rejection with no native entry. This is defense in depth; normal
coordinator eligibility should prevent such a request from reaching them.
