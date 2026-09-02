# Wave B — LLVM/Clang construct intern (shape only)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-llvm-construct-intern**. Research only. No UBT. No `Plugins/` edits.
Do **not** edit `async-work.md`, `async-dispatch.md`, `tasks.md`, or `wave-b-ctor-green.md`.
Do **not** propose checking OpenSpec 13.2.

LLVM/Clang is a **shape reference only**. This project does **not** link Clang/LLVM. Local tree: `D:\as-cta\Reference\llvm-project` (commit in `attachments/clang-ast-reference.md`: `9bc4fd0fafb58ff1fb50231e39a882a678542dac`). Quote paths below are `clang/...` relative to that tree.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Shape map: Clang construction → native VALUE ctor vs REF factory intern |
| Companion exclusive UBT | `wave-b-ctor-green.md` (n-arg intern mutex) |
| 0-arg intern | later bite — not this mutex |

---

## Mapping (one sentence)

VALUE native construct is AngelScript ctor **CALLSYS** (this-object is dest, like Clang `this`). REF native construct is a **factory** (**CALLSYS + STOREOBJ**), often with a hidden type-id / first `int&in` on a template factory. Sema interns those natives as `DECL_CONSTRUCTOR` children and `SetResolvedDecl` on `EXPR_CONSTRUCT`. CodeGen must `FindFunc(resolvedDecl)` only — no arity re-lookup.

---

## 1. `CXXConstructExpr` holds `CXXConstructorDecl*` (not name+arity)

`clang/include/clang/AST/ExprCXX.h` **1547–1611**:

```cpp
/// Represents a call to a C++ constructor.
class CXXConstructExpr : public Expr {
  /// A pointer to the constructor which will be ultimately called.
  CXXConstructorDecl *Constructor;
  // ...
  /// Get the constructor that this expression will (ultimately) call.
  CXXConstructorDecl *getConstructor() const { return Constructor; }
```

Create takes the selected decl (`ExprCXX.h` **1599–1605**): `Create(..., CXXConstructorDecl *Ctor, ..., ArrayRef<Expr *> Args, ...)`.

The constructor **declaration** is a `CXXMethodDecl` (`clang/include/clang/AST/DeclCXX.h` **2601–2604**), not a spelling+arity key.

Adopted analogue: `asCExpr` of kind `asAST_EXPR_CONSTRUCT` stores `resolvedDecl` → interned `asAST_DECL_CONSTRUCTOR`. Trailing args are `children`, not a second lookup key.

---

## 2. Sema selects the constructor, then builds the expr

There is **no** `Sema::ActOnCXXConstructExpr`. Parser construction of a spelled type is `ActOnCXXTypeConstructExpr` → `BuildCXXTypeConstructExpr`.

Parser (`clang/lib/Parse/ParseExprCXX.cpp` **1806**, **1847**) calls `Actions.ActOnCXXTypeConstructExpr(...)`.

Sema (`clang/include/clang/Sema/Sema.h` **8501–8515**; impl `clang/lib/Sema/SemaExprCXX.cpp` **1499–1541**):

- `ActOnCXXTypeConstructExpr` unwraps `ParsedType` and calls `BuildCXXTypeConstructExpr`.
- Empty arg list → `InitializationKind::CreateValue` (value-init, still a construct).
- Non-empty → `CreateDirect` or `CreateDirectList`.

Overload resolution lives on `InitializationSequence`, not on CodeGen:

| Step | File:line | What it stores |
| --- | --- | --- |
| Default-init of a class | `SemaInit.cpp` **5878–5895** `TryDefaultInitialization` | `TryConstructorInitialization(..., Args={})` — still a **default constructor decl** |
| Value-init of a class | `SemaInit.cpp` **5801–5871** `TryValueInitialization` | `LookupDefaultConstructor` then `TryConstructorInitialization` (optional preceding zero-init step) |
| Overload pick | `SemaInit.cpp` **4680–4789** | `CXXConstructorDecl *CtorDecl = cast<CXXConstructorDecl>(Best->Function)` then `AddConstructorInitializationStep(Best->FoundDecl, CtorDecl, ...)` |
| Perform | `SemaInit.cpp` **7497–7555** `PerformConstructorInitialization` | `cast<CXXConstructorDecl>(Step.Function.Function)` then `CompleteConstructorCall` then `BuildCXXConstructExpr` |
| Default args | `SemaDeclCXX.cpp` **16413–16446** `CompleteConstructorCall` | `GatherArgumentsForCall` against **that** `Constructor` proto |
| AST node | `SemaDeclCXX.cpp` **16325–16347** `BuildCXXConstructExpr` | `CXXConstructExpr::Create(..., Constructor, ..., ExprArgs, ...)` |

`BuildCXXConstructExpr` (`Sema.h` **5410–5436**) is documented as “Creates a complete call to a constructor, including handling of its default argument expressions.” Every overload takes `CXXConstructorDecl *Constructor`.

Fork analogue: `asCSema::ActOnConstruct` (`as_sema.cpp` **1023–1088**) is `ActOnCXXTypeConstructExpr` + `BuildCXXConstructExpr`. `SelectConstructor` is the cheap `InitializationSequence` walk over interned `DECL_CONSTRUCTOR` children. `SetResolvedDecl(id, ctor)` is `getConstructor()`.

---

## 3. Default-init / value-init still produce a construct expr with a ctor

Uninitialized C++ variable (`clang/lib/Sema/SemaDecl.cpp` **14662–14675**):

```cpp
InitializationKind Kind = InitializationKind::CreateDefault(Var->getLocation());
InitializationSequence InitSeq(*this, Entity, Kind, {});
ExprResult Init = InitSeq.Perform(*this, Entity, Kind, {});
if (Init.get())
  Var->setInit(MaybeCreateExprWithCleanups(Init.get()));
```

For a class type, `TryDefaultInitialization` (**5892–5895**) calls `TryConstructorInitialization` with an **empty** arg list. Perform still builds `CXXConstructExpr` with the selected default `CXXConstructorDecl*` (`PerformConstructorInitialization` **7519–7528** even **defines** a trivial implicit default ctor so the decl exists).

Value-init of a class (`TryValueInitialization` **5818–5871**) also ends in `TryConstructorInitialization` after optional `AddZeroInitializationStep`. `BuildCXXTypeConstructExpr` with **zero exprs** uses `CreateValue` (**1540–1541**) — `T()` is still a construct with a ctor, not “no callable”.

Clang CodeGen still reads that decl (`clang/lib/CodeGen/CGExprCXX.cpp` **603–607**):

```cpp
void CodeGenFunction::EmitCXXConstructExpr(const CXXConstructExpr *E, AggValueSlot Dest) {
  const CXXConstructorDecl *CD = E->getConstructor();
```

Trivial default may emit nothing after the decl is known (**626–628**). It does **not** re-search constructors by arity.

Fork hole (AS-specific, not Clang): dummy VALUE `STMT_DECL` construct uses **invalid** `resolvedDecl` and 0-arg `FindConstructorId(0)` / `FindFactoryId(0)` (`as_bytecode_codegen.cpp` **2007–2020**, **2701–2708**). Clang would still have interned the 0-arg ctor. **Do not intern 0-arg in this mutex** (pollutes bind table; see § intern recipe).

---

## 4. `CXXNewExpr`: allocation function vs constructor (REF factory analogue)

`CXXNewExpr` (`ExprCXX.h` **2351–2462**) stores **two** selected decls:

```cpp
FunctionDecl *OperatorNew;     // allocation function
FunctionDecl *OperatorDelete;  // error-path dealloc; may be null
// initializer (often a CXXConstructExpr) is a trailing Stmt*
FunctionDecl *getOperatorNew() const;
```

Sema `BuildCXXNew` (`SemaExprCXX.cpp` **2174–2183**, **2625–2653**): omitted new-initializer → **default-init** of the allocated object; then `CXXNewExpr::Create(..., OperatorNew, OperatorDelete, ..., Initializer, ...)`. If `Initializer` is a `CXXConstructExpr`, the ctor is on that child (`CCE->getConstructor()`, **2643–2647**), **not** on the new-expr as a name+arity.

CodeGen (`CGExprCXX.cpp` **1563–1669**): **first** call `E->getOperatorNew()` (size / optional type-identity / align / placement args); **then** construct into the returned storage via the initializer’s constructor. Allocation and construction are distinct selected decls.

| Adopt (shape) | Exclude |
| --- | --- |
| Two selected callables can exist around “make an object”: allocator vs constructor. | `operator new` / `operator delete` lookup, placement new, global `::new` |
| REF factory is the **combined** AS allocator+construct SYSTEM function; intern it as `DECL_CONSTRUCTOR` so `EXPR_CONSTRUCT.resolvedDecl` names it. | Array cookies, `shouldNullCheckAllocation`, vector deleting dtors |
| Hidden type-id on template factory ≈ Clang type-aware new’s implicit type-identity arg (`ImplicitAllocationParameters`, `ExprCXX.h` **2283–2302**; CodeGen **1627–1633**) — **CodeGen injects it**, it is **not** an `EXPR_CONSTRUCT` child. | `std::type_identity`, aligned new, destroying-delete, LLVM IR `heapallocsite` |
| VALUE ctor `this` is dest (PSF), not an AST arg — same as Clang `EmitCXXConstructorCall` pushing `this` (`CGClass.cpp` **2293–2337**) from `Dest`, then `EmitCallArgs(..., E->arguments(), E->getConstructor(), ...)`. | C++ `this` as a first `DECL_PARAM` on interned native ctors |

AngelScript REF native construct is **not** `asBC_ALLOC` + VALUE ctor. Live emit (`as_bytecode_codegen.cpp` **1999–2050**): `SYSTEM && !isValue` → treat `FindFunc` result as **factory**, `CALLSYS`/`CALL`, `STOREOBJ`. VALUE → PSF dest + `CALLSYS`. ALLOC remains the non-SYSTEM REF ctor path — do not ALLOC a factory id.

---

## 5. Hidden / implicit arguments vs AS template factory type-id

| Mechanism | Clang | This fork |
| --- | --- | --- |
| Object identity for VALUE construct | Implicit `this` added in CodeGen from dest slot (`CGClass.cpp` **2314–2315**). **Not** a `CXXConstructExpr` argument. | `PSF` dest then `CALLSYS` ctor. Interned `DECL_CONSTRUCTOR` user params = visible args only. |
| Allocator type cookie | Type-aware `operator new`: `PassTypeIdentity` adds a leading implicit arg (`ExprCXX.h` **2296–2301**; `SemaExprCXX.cpp` **2948–2949** reserve `IAP.getNumImplicitArgs()`). | Template / hidden factory: `hiddenArgumentIndex` or first non-primitive `int&in` / template first param skipped in intern (`as_sema_expr.cpp` **565–582** `InternNativeBehaviourList`). CodeGen may `SetV8` type pointer when `hiddenArgumentIndex >= 0` or factory arity > user args (`as_bytecode_codegen.cpp` **2030–2036**). |
| Default arguments | Sema `CompleteConstructorCall` / `GatherArgumentsForCall` fills them **on the selected ctor** before Create. | Not this mutex. `SelectConstructor` matches interned user arity only. |
| VTT / inheriting ctor / CUDA | Extra CodeGen / Sema paths | **Exclude** |

Do **not** intern the hidden type-id as an `EXPR_CONSTRUCT` child. User arity 1 for `h(3)` stays one child; factory match skips the hidden first param (`FindExactRegisteredConstructor` **296–318**).

---

## Adopt vs exclude

Adopt:

- Construct expr **owns the selected constructor decl**, not a name+arity key.
- Parser/Sema action (`ActOnCXXTypeConstructExpr` / `ActOnConstruct`) performs lookup; backend reads `getConstructor()` / `resolvedDecl`.
- Default-init and value-init of a class still select a constructor decl (Clang always; this mutex only intern when user arity **> 0**).
- REF “make object” is a **factory** callable (shape of new’s allocator+init split, implemented as one SYSTEM factory).
- Hidden type-id / `this` are CodeGen injections, not extra AST args.
- Generate-local bind table maps `asASTDeclId` → live `asCScriptFunction*` for the duration of CodeGen only.

Exclude:

- Concrete Clang classes (`CXXConstructExpr`, `CXXNewExpr`, `CXXConstructorDecl`, `InitializationSequence`, …).
- Linking Clang or LLVM; storing `llvm::Value*` / `clang::*`.
- LLVM IR lowering, ORC, object files.
- `operator new`/`delete`, placement new, array new cookies, type-aware `std::type_identity`, aligned allocation.
- C++ copy-elision / trivial-ctor skip as a substitute for intern.
- Storing `asCScriptFunction*` on sealed `asCDecl` (or public snapshot / Cache).
- Interning 0-arg factories/ctors in this mutex; calling `InternNativeCallablesForType` from `InternNativeMethods`.
- Reintroducing 1-arg `FindConstructorId(argCount)` / `FindFactoryId(userArgCount)` once `resolvedDecl` is valid.

---

## How this worktree should intern (this mutex only)

Call `InternNativeCallablesForType` **only** for n-arg construct. 0-arg is a later bite.

1. `ActOnConstruct`: if `args.GetLength() > 0`, call `InternNativeCallablesForType(type)` (`as_sema.cpp` **1025–1028**). Never from `InternNativeMethods` / insertLast / opIndex.
2. That function synthesizes a `DECL_CLASS` for the native type if needed, then `InternNativeBehaviourList` on `beh.constructors` (`isFactory=false`) and `beh.factories` (`isFactory=true`) as **`DECL_CONSTRUCTOR` children** (`as_sema_expr.cpp` **642–667**, **538–637**). Skip hidden/template first param so interned param count = **user** arity.
3. `SelectConstructor` walks those children by user arity + type rank. `SetResolvedDecl` on the `EXPR_CONSTRUCT`. Empty ctor id is allowed for 0-arg / no class — do not intern 0-arg natives to fill it.
4. Generate: `FindExactRegisteredConstructor` unique-matches interned `DECL_CONSTRUCTOR` (no body, not `GENERATED`) against constructors **and** factories, same hidden skip. Push `asSCodeGenFuncBind { decl, func }` — **Generate-local** (`as_bytecode_codegen.cpp` **520–526**, **3549–3557**). Native miss `continue` (no `asNEW`).
5. `EmitConstructInto`: `ctor = FindFunc(expr->resolvedDecl)` only for n-arg. If `SYSTEM && !isValue` → factory CALLSYS + STOREOBJ. VALUE → CALLSYS ctor. `children.GetLength()==0` may still `FindConstructorId(0)` / `FindFactoryId(0)` until the later 0-arg bite. Dummy VALUE `STMT_DECL` must set `resolvedDecl = asASTDeclId()` (garbage DeclId hits a bind).
6. Never store `asCScriptFunction*` on sealed `asCDecl`. `FindFunc` is the only n-arg lookup; arity re-walk is the Clang anti-pattern this map forbids.
