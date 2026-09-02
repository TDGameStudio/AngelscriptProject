# Wave B closure — 12-byte POD copy and return ABI

Worktree: `D:\as-cta`.
Change: `refactor-as-canonical-typed-ast-compiler`.
Date: 2026-08-23.

## Scope

This closes three connected, narrow but real CodeGen ABI holes for POD `VALUE`
objects larger than the VM's eight-byte value register:

- assignment between local values; and
- a direct resolved script-function return, including the caller-provided hidden
  return object used by `DoesReturnOnStack()`; and
- a by-value formal parameter on a direct CANONICAL CodeGen-to-CodeGen script
  call, while retaining the public generic object-parameter ABI used by an
  external `asIScriptContext`.

It does **not** claim arbitrary large value passing through constructor/factory,
native/system, imported, or indirect/function-handle calls; nor indirect return
lowering or copy semantics for non-POD objects. Those are separate backend
surfaces and remain open.

## Failure reproduced first

`CanonicalPODTripleAssignmentCopiesAllTwelveBytes` registers a native
`FProdTriple { int First; int Second; int Third; }`, initializes a source local
to `(1, 2, 3)`, assigns it to a second local, and returns the decimal encoding
of the target fields. The expected result is `123`.

Before the change, `CopyVar` emitted one `CpyVtoV8` for every `dwords >= 2`.
The third dword was never written, and the focused CANONICAL execution test
failed with `got=120`:

```text
cta-pod-triple-red / 20260823_013815_795_8805ccdf
total=1 passed=0 failed=1 skipped=0
```

That is a behavioral regression, not merely an opcode-shape concern.

## Implemented rule

`asCBytecodeCodeGen` now distinguishes the supported POD value-object case:

```text
large local POD VALUE assignment
    PSF(source)
    PSF(destination)
    COPY(byteSize, exactTypeId)
    PopPtr
```

The order is the VM `asBC_COPY` contract: source is below destination on the
stack. `COPY` leaves its lvalue result on the stack, so `PopPtr` is mandatory.
The implementation validates `asOBJ_VALUE | asOBJ_POD`, a positive `short`
representable byte size, and the presence of an Engine. Any large non-POD value
copy fails closed with `asNOT_SUPPORTED`; it cannot silently become a `memcpy`
substitute for a sealed copy-constructor/copy-assignment plan.

`CopyVar` also now emits all `8 + … + 4` dword chunks instead of treating
`dwords >= 2` as exactly eight bytes. This removes the primitive/register-level
truncation primitive, while the typed `COPY` route is what the POD object
assignment test requires and asserts.

The local declared-value assignment route in `EmitAssign` now calls this typed
copy path. The regression checks both execution (`123`) and that the emitted
function actually contains `asBC_COPY`.

## Hidden return-object ABI

`DoesReturnOnStack()` is not a value-register return: the caller must make the
destination object address the deepest outgoing stack item, before receiver and
formal arguments. The callee receives that hidden pointer at stack offset `0`
(or `-AS_PTR_SIZE` for an object method), writes the local return value through
it, and `Ret` consumes the hidden pointer as part of its pop count.

The supported direct script-function POD route is therefore:

```text
caller
    PSF(caller-owned destination)     // hidden return pointer, before args
    ... receiver / formal args ...
    CALL
    ObjInfo(destination, asOBJ_INIT)  // result is the caller's local object

callee
    PSF(local return value)
    PshVPtr(hidden return pointer)
    COPY(byteSize, exactTypeId)
    PopPtr
    RET(pop includes hidden pointer)
```

`CanonicalPODTripleReturnUsesHiddenReturnStorage` exercises
`FProdTriple MakeTriple()` followed by `Output = MakeTriple()` and returns
`123`. Before this work the caller never supplied a hidden destination and the
callee used the eight-byte return-register path, so the focused test correctly
failed its required hidden-storage opcode assertion. The green case verifies
both `asBC_COPY` in `MakeTriple`, `asBC_PSF` in the caller, and actual VM
execution.

## Direct script by-value-parameter ABI

This needed a separate protocol from the hidden result object. The maintained
AngelScript ABI deliberately represents an object formal as one pointer (two
dwords on this 64-bit build). `asIScriptContext::SetArgObject()` writes exactly
that pointer into `parameterOffsets[arg]`; changing a generated script
function's parameter metadata to an inline three-dword object layout therefore
breaks public external invocation even if direct script-to-script tests pass.

The final implementation keeps `CalculateParameterOffsets()` and the normal
function record untouched. It establishes value semantics with two typed copies:

```text
direct CANONICAL caller
    COPY(source local, caller-owned temporary)
    PSF(caller-owned temporary)             // standard object pointer argument
    CALL SumTriple

CANONICAL callee entry
    PshVPtr(incoming object pointer)
    PSF(callee-owned local parameter value)
    COPY(byteSize, exactTypeId)
    PopPtr
    ... read the callee-local value normally ...
    RET(pop uses maintained pointer-sized argument metadata)

external asIScriptContext caller
    SetArgObject(0, &Input)                 // same standard pointer ABI
    Execute()
    // callee entry copies Input into its local parameter value
```

The caller temporary makes the parameter truly by-value: a callee mutation
cannot alias the caller's source local. The callee materialization lets the
existing canonical value-expression lowering operate on all twelve bytes.
This path admits only `asOBJ_VALUE | asOBJ_POD` objects with a positive,
short-representable byte size; a non-POD wide value fails closed.

`CanonicalPODTripleByValueParameterPreservesAllTwelveBytes` first failed with
`got=121`, proving the pre-fix call had lost part of the object. The final
regression makes two calls, changes the third field between them, and requires
`123124`; it asserts the caller contains both `COPY` and `PSF`. The separate
`CanonicalPODTripleByValueParameterAcceptsExternalContextObject` regression
prepares the emitted function through `asIScriptContext`, calls
`SetArgObject(0, &Input)`, and requires the result `123`. This is the guard
against silently changing the public ABI again.

## External-call ownership boundary

During the first attempt to extend the preceding direct-call route to a native
`asCALL_GENERIC` function, the focused execution result looked correct, but the
complete `ProductionCodeGen` process later terminated with a mimalloc access
violation. This was treated as memory corruption, rather than as an unrelated
test-process failure.

The cause is an ownership mismatch in the maintained runtime ABI. A generic
system call's cleanup plan releases a by-value object argument after the
callback. `EmitPODValueArgument`, by contrast, intentionally materializes a
typed **frame-local** temporary and passes its address. A frame-local pointer
is correct for the supported script-to-script route, where no callee assumes
ownership, but it must never be transferred to a system/imported/indirect ABI
that can free or otherwise retain it.

CodeGen therefore enforces this explicit rule:

```text
wide POD by-value argument
    direct asFUNC_SCRIPT callee         -> supported: copy to caller local, pass pointer
    system / generic / imported callee  -> reject: asNOT_SUPPORTED
    indirect / function-pointer call    -> reject: asNOT_SUPPORTED
```

`CanonicalPODTripleByValueParameterRejectsSystemCallWithoutOwnedTransfer`
registers a twelve-byte POD and an `asCALL_GENERIC` global `int Sum(FProdTriple)`.
The CANONICAL build must fail and must not record `asCCompiler` publication.
This makes the boundary executable and prevents a future apparent green result
from reintroducing a use-after-free / invalid-free path.

Supporting this in the future is a distinct ABI feature, not a one-line call
emission relaxation. It needs a sealed lowering that allocates a real engine
heap object, copies/constructs it with the right behavior, transfers exactly
one ownership token to the callee cleanup protocol, and prevents the caller's
normal local cleanup from destroying or freeing it again. Non-POD objects need
their own constructor/copy/destructor plan as part of that work.

## Verification

| Check | Evidence | Result |
| --- | --- | --- |
| C++ build | `cta-pod-triple-green-build/20260823_013956_696_774b58be` | PASS |
| Focused red | `cta-pod-triple-red/20260823_013815_795_8805ccdf` | expected FAIL, `120` |
| Focused green | `cta-pod-triple-green/20260823_014015_368_94573988` | `1/1 PASS` |
| ProductionCodeGen | `cta-pod-triple-production-codegen/20260823_014058_991_d50504ce` | `49/49 PASS` |
| Compiler prefix | `cta-pod-triple-compiler/20260823_014139_127_c6b9cbdc` | `514/514 PASS` |
| Focused return red | `cta-pod-return-red/20260823_014536_697_2da88541` | expected FAIL; no hidden-return route emitted |
| C++ build (return route) | `cta-pod-return-green-build/20260823_014747_054_9114598a` | PASS |
| Focused return green | `cta-pod-return-green/20260823_014801_449_a236afee` | `1/1 PASS`, execution `123` |
| ProductionCodeGen (final) | `cta-pod-return-production-codegen/20260823_014851_772_e8017117` | `50/50 PASS` |
| Compiler prefix (final) | `cta-pod-return-compiler/20260823_015106_940_06c60262` | `515/515 PASS` |
| Focused by-value red | `cta-pod-byvalue-red/20260823_015506_531_63209c78` | expected FAIL, `121` |
| C++ build (generic-ABI route) | `cta-pod-generic-abi-build/20260823_022026_494_e9e09e3e` | PASS |
| Focused direct by-value green | `cta-pod-generic-direct-green/20260823_022135_535_3f92be77` | `1/1 PASS`, two calls yield `123124` |
| Focused external Context green | `cta-pod-generic-external-green/20260823_022214_473_ecc8188c` | `1/1 PASS`, `SetArgObject` yields `123` |
| ProductionCodeGen (final) | `cta-pod-generic-production-codegen/20260823_022306_949_b14d2653` | `52/52 PASS` |
| Compiler prefix (final) | `cta-pod-generic-compiler/20260823_022450_894_fde0bc1e` | `517/517 PASS` |
| C++ build (external-call boundary) | `cta-pod-system-reject-build/20260823_023454_276_13ec9a50` | PASS |
| Focused system rejection | `cta-pod-system-reject-focused/20260823_023526_310_e051ab07` | `1/1 PASS`; CodeGen rejects with `asNOT_SUPPORTED` and no legacy publication |
| ProductionCodeGen (boundary final) | `cta-pod-system-reject-production-codegen/20260823_023605_842_61bf8b6c` | `53/53 PASS`; normal editor shutdown |
| Compiler prefix (boundary final) | `cta-pod-system-reject-compiler/20260823_023646_185_f946b6f6` | `518/518 PASS` |

## Explicit non-claims / next ABI work

- A large POD **formal parameter** is now supported for direct CANONICAL
  script-to-script calls and for direct external `asIScriptContext` invocation
  of that emitted function, both through the maintained object-pointer ABI.
  Constructor/factory lowering has no sealed formal-parameter mapping in this
  CodeGen slice and explicitly fails closed for a wide value argument rather
  than emitting an invalid raw pointer payload. Native/system (including
  `asCALL_GENERIC`), imported, and indirect calls remain outside this closure:
  they require an owned heap-object transfer protocol, and now explicitly
  reject rather than receiving a frame-local pointer.
- Indirect `funcdef` / function-variable returns have not been given this
  hidden-return lowering, and indirect function calls do not establish the
  sealed direct-callee parameter ABI required for a wide POD by-value payload.
- Large non-POD value copies on this new wide path fail closed and need a sealed
  callee/copy plan. Existing small-object register paths and untested
  constructor/factory argument routes are outside this closure and are not
  being reclassified as safe POD copying.
- This local CodeGen closure does not make Task 9.5, 10.4, 13.2, or 13.6
  complete. The production default remains LEGACY.
