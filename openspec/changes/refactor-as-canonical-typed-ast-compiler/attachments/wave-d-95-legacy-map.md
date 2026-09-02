# Wave D 9.5 — legacy `asCCompiler` / `asCBuilder` map for VALUE `struct FValue`

Worktree: `D:\as-cta`. Research only. Do **not** copy `asCCompiler` into Generate. Match **VM-observable** behavior.

Fixture:

```angelscript
struct FValue {
  int Value;
  FValue() { Value = 41; }
}
int F() {
  FValue Object;
  return Object.Value + 1;
}
```

Temporary form: `return FValue().Value + 1;`

This fixture has a **user 0-arg ctor with a body**. Sema still always synthesizes a **generated destructor** if the script omitted `~FValue`. Builder does **not** always emit that destructor. Both facts matter.

Default `ep.canonicalCompilerPipeline` stays LEGACY. 9.5 is not claimed closable.

---

## 1. Script `struct` registration — VALUE, not REF

Parser: `struct` vs `class` is `node->tokenType`.

- `D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_parser.cpp:3925` — `bool isStruct = (t.type == ttStruct);` then `node->SetToken(&t)`.
- `as_parser.cpp:2688` path in builder: `D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_builder.cpp:2688` — `bool isStruct = node->tokenType == ttStruct;`

Builder `RegisterClass` (`as_builder.cpp:2681`):

1. New `asCObjectType` (`2831`).
2. Default flags (`2842`): `asOBJ_REF | asOBJ_SCRIPT_OBJECT | asOBJ_NOCOUNT`.
3. **If struct** (`2861–2867`):
   - `flags &= ~(asOBJ_REF | asOBJ_NOCOUNT)`
   - `flags |= asOBJ_VALUE`
   - `flags |= asOBJ_NOINHERIT`
4. **If class** (`2868–2872`): `flags |= asOBJ_IMPLICIT_HANDLE` (REF stays).
5. `st->size = -1` until layout (`2874`).
6. Push `module->classTypes`, `module->allLocalTypes` (`2897–2898`).
7. `st->beh = engine->scriptTypeBehaviours.beh` (`2907`).
8. **If struct** (`2909–2913`): `beh.factory = 0`; `beh.factories` cleared. **No factory.**
9. Else: AddRef default factory (`2916`).
10. Always AddRef default `beh.copy` and `beh.construct` (`2927–2928`).
11. `engine->allScriptDeclaredTypes.Add(st)` (`2932`). **Not** `allRegisteredTypesByName`.

Canonical Sema does **not** distinguish struct vs class on the decl:

- Parser `snClass` for both (`as_parser.cpp:3919`).
- `WalkOne` `snClass` → `ActOnClassDecl` (`as_sema_decl.cpp:956–968`, `1232–1237`) → `asAST_DECL_CLASS`.
- Unresolved named types default to `asAST_TYPE_VALUE_OBJECT` (`as_sema_decl.cpp:368–373`).

Wave D fixtures are `struct` only. Legacy class would stay `asOBJ_REF | asOBJ_SCRIPT_OBJECT | asOBJ_IMPLICIT_HANDLE`. Do not emit ALLOC/factory for this fixture.

---

## 2. Properties: `byteOffset` / size / alignment

### Add (offsets still `-1`)

`asCBuilder::AddPropertyToClass` (`as_builder.cpp:4678–4714`):

- Rejects `!dt.CanBeInstantiated()`.
- Queues `decl->propInits` if there is an initializer node.
- Delegates to `asCObjectType::AddPropertyToClass`.

`asCObjectType::AddPropertyToClass` (`as_objecttype.cpp:638–678`):

- Asserts `flags & asOBJ_SCRIPT_OBJECT`.
- `prop->byteOffset = -1` (`657`).
- `propAlignment = dt.GetAlignment()`; if larger than `ot->alignment`, raise `alignment` (`659–662`).
- Default `asCObjectType::alignment` is **8** (`as_objecttype.cpp:51`, `60`).
- Push `properties` / `localProperties` / `propertyTable`.

`int` alignment (`as_datatype.cpp:743–765`): primitive non-bool/int8/int16/int64/float64 → **4**. `4 > 8` is false, so `FValue.alignment` stays **8**.

### Layout pass

`asCBuilder::LayoutClass` (`as_builder.cpp:4094–4198`):

- `bIsStruct = (ot->flags & asOBJ_VALUE) != 0` (`4102`).
- No base / no shadow / `basePropertyOffset == 0` → `ot->size = 0` (`4121–4122`). **No `asCScriptObject` header for VALUE.**
- For each property with `byteOffset == -1`:
  - Nested VALUE script objects recurse `EnsureClassLayouted` (`4130–4136`).
  - Size: VALUE object → `GetSizeInMemoryBytes()`; REF → stack dwords × 4; primitive → `GetSizeInMemoryBytes()` (`4139–4151`).
  - Align: `ot->size += (propAlignment - (ot->size & (propAlignment-1)))` (`4154–4157`).
  - `prop->byteOffset = ot->size`; `ot->size += propSize` (`4159–4160`).
- POD: if struct and every object member is POD (primitives have no `TypeInfo`), set `asOBJ_POD` (`4163–4183`). **`FValue` with only `int Value` is POD even with a user ctor.**
- Final size pad to `ot->alignment` (`4196–4198`): `(size + alignment - 1) & ~(alignment - 1)`.

For this fixture: `Value.byteOffset = 0`, `propSize = 4`, then pad 4 → **8**. `GetSizeInMemoryDWords()` (`as_datatype.cpp:719–728`) is **2**.

Type id for `ADDSi` is assigned lazily: `asCTypeInfo::GetTypeId` → `engine->GetTypeIdFromDataType` (`as_typeinfo.cpp:239–251`, `as_scriptengine.cpp:4994–5041`). Script objects get `asTYPEID_SCRIPTOBJECT`.

---

## 3. Constructor bind: `beh.construct` / `constructors` + Sema lifecycle

### User ctor (this fixture)

Parser: function whose first child is **not** a datatype and **not** `~` is a constructor (`as_builder.cpp:5257–5275`). `asTRAIT_CONSTRUCTOR`, `returnType = void`.

Register (`as_builder.cpp:5872–5891`) for **VALUE**:

- 0 parameters: **replace** default construct:
  - `ReleaseInternal` old `beh.construct`
  - `beh.construct = funcId`
  - `beh.constructors[0] = funcId`  ← **index 0, not PushLast**
- Extra ctors: `beh.constructors.PushLast(funcId)`
- **No factory** on VALUE.

`objectType` is set when `module->AddScriptFunction(..., objType, ...)` (`as_builder.cpp:5855`). `CalculateParameterOffsets` (`as_scriptfunction.cpp:695–723`) adds `AS_PTR_SIZE` for `objectType` into `totalSpaceBeforeFunction`. Ctor `DoesReturnOnStack()` is false (void).

`asTRAIT_CONSTRUCTOR` is also set on generated default ctor (`as_builder.cpp:4792`).

### If the user omitted a ctor (not this fixture)

After methods are registered (`as_builder.cpp:1303–1309`):

- If `ot->beh.construct == engine->scriptTypeBehaviours.beh.construct` (still the placeholder):
  - If only that placeholder, or `ep.alwaysImplDefaultConstruct`: `AddDefaultConstructor`.
  - Else: drop placeholder construct (user provided other overloads, no 0-arg).

`AddDefaultConstructor` (`as_builder.cpp:4748–4792`):

- New script function named like the type, void, no params, `objType` set.
- Replace `beh.construct` / `constructors[0]`.
- `functions` entry with `node = 0`, `asBUILD_ARTIFACT_INVOCATION_GENERATED_DEFAULT_CONSTRUCTOR`.
- VALUE: **no factory** (`4795`).

Compile path (`as_builder.cpp:1617–1632`): `node == 0` and name == type name → `asCCompiler::CompileDefaultConstructor` (`as_compiler.cpp:2937–3010`): member default-init, optional base `PSF 0 / RDSPtr / CALL`, `Ret(AS_PTR_SIZE)`. No user body.

### Sema `EnsureGeneratedLifecycle`

`as_sema_decl.cpp:534–571`, called after walking class children (`967`):

- Only `asAST_DECL_CLASS` / `INTERFACE`.
- If no `asAST_DECL_CONSTRUCTOR` child: `ActOnConstructorDecl` + `asAST_TRAIT_GENERATED` (`561–565`). **No statement body.**
- If no destructor: same for dtor (`566–570`).

This fixture **has** `FValue()` so Sema does **not** synthesize a ctor. It **does** synthesize `asAST_DECL_DESTRUCTOR` with `TRAIT_GENERATED`.

Builder destructor policy is stricter (`CreateDefaultDestructors`, `as_builder.cpp:1470–1541`): add `AddDefaultDestructor` only if a base dtor exists, a handle/funcdef member exists, or a nested object has `beh.destruct`. **`int Value` does not qualify.** Legacy VM for this fixture typically has **`beh.destruct == 0`**.

---

## 4. Ctor body `Value = 41` — `this` addressing

VM frame (`as_context.cpp:1709–1745`):

- `stackFramePointer = stackPointer` (args already on the stack).
- Then `stackPointer -= variableSpace` (locals).
- `asBC_PSF` (`as_context.cpp:1943–1946`): push `l_fp - offset` (address of slot).
- Method `this` is the **object pointer** at **frame offset 0** (`as_compiler.cpp:2702`, `10044–10048`, `14647–14654`).
- User parameters start at **`-AS_PTR_SIZE`** (`as_compiler.cpp:3306–3308`). Locals start at **1**.

VALUE methods still receive a **pointer** to the in-place object (caller did `PSF` of the stack slot). Slot 0 holds that pointer, not the bytes of `FValue`.

### Implicit `this.Value`

`CompileVariableAccess` with no local named `Value` (`as_compiler.cpp:14716–14810`):

```
PSF ThisObjectStackOffset        // 0
type = FValue&, isVariable
Dereference → RDSPtr             // pointer value = &object
ADDSi prop->byteOffset, typeId
if primitive: PopRPtr            // address of int in value register
```

`ThisObjectStackOffset` is **0**, not `-AS_PTR_SIZE`.

Dot form is the same ADDSi after the object pointer is on the stack (`as_compiler.cpp:18922–18938`):

```
ADDSi byteOffset, typeId
if primitive: PopRPtr
```

Temps used as the object of `.Value` become `deferredParams` (`18941–18951`).

### Store `= 41`

Primitive reference lvalue (`as_compiler.cpp:10460–10484`): `WRTV4` of the rvalue local into the address in the register (4-byte `int`).

Equivalent constructor-member default-init for structs (`as_compiler.cpp:3827–3848`) uses `PshVPtr 0 / ADDSi / PopRPtr / SetV4 / WRTV4` (zero). User assignment uses the identifier path above.

**RDSPtr (or `PshVPtr 0`) is required.** `PSF 0` + `ADDSi` without dereference adds `byteOffset` to the **address of the this slot**, then `WRTV4` overwrites the this pointer with `41`. `Object.Value` stays uninitialized → execute **1**, not **42**.

`CompileFunction` detects ctor because `returnType` is void and `outFunc->name == objectType->name` (`as_compiler.cpp:3325–3331`). Before the user body it still runs `CompileMemberInitialization` (`4038–4040`). `int Value` has no initializer node: struct primitives are zeroed (`3827–3856`). Then the statement block runs `Value = 41`.

---

## 5. Local `FValue Object;` — construct in place

`CompileDeclaration` (`as_compiler.cpp:6366`):

- `AllocateVariable(type, false, false, true)` (`6456`).
- VALUE and not `forceOnHeap` → **`isOnHeap = false`** (`as_compiler.cpp:9977–9983`). Stack storage, not a heap pointer.
- No initializer → `CompileInitialization(0, …, isVarGlobOrMem=0)` (`6604–6605`).

`CallDefaultConstructor` VALUE, not on heap, local (`as_compiler.cpp:4502–4570`):

```
func = beh->construct                    // user FValue()
PSF (short)offset                        // address of stack object
PerformFunctionCall(func, isConstructor=false)
ObjInfo(offset, asOBJ_INIT)
```

`PerformFunctionCall` with `isConstructor=true` emits **`asBC_ALLOC`** (`22198–22206`). The VALUE-on-stack path **must** pass `false` so it emits **`asBC_CALL`** (`22245–22246`) with `argSize + AS_PTR_SIZE` (this pointer).

REF locals take `beh->factory` and `ALLOC` (`4393–4499`, `as_context.cpp:2723–2754` heap `AllocScriptObject` + ctor). **Do not ALLOC this fixture.**

On function exit, locals with `stackOffset > 0` get `CallDestructor` (`as_compiler.cpp:4056–4066`). VALUE + not on heap (`4631–4677`): if `beh.destruct` CALL it via `PSF offset`; else only `ObjInfo UNINIT`. **No `FREE`.** This fixture’s builder dtor is usually 0.

---

## 6. Load `Object.Value`

Local VALUE is not primitive (`as_compiler.cpp:14614–14619`):

```
PSF Object.stackOffset     // address of in-place FValue
SetVariable; onHeap is false → type is the object, not a handle ref
```

Then `.Value` (`as_compiler.cpp:18804–18938`):

```
Dereference if non-primitive (RDSPtr only if the expr was a reference/handle)
ADDSi Value.byteOffset (0), FValue typeId
PopRPtr                    // primitive member
```

Then `+ 1` on that int. Offset 0 still needs ADDSi so the typeId metadata is on the instruction (`18928–18930`).

---

## 7. Temporary `FValue()` — materialize and destroy

`CompileConstructCall` (`as_compiler.cpp:16221`):

- VALUE (`16334–16360`): `AllocateVariable(dt, true)` → **temporary**, still **not on heap**.
- Match `beh.constructors` (0-arg → `beh.construct`).
- `onHeap == false` (`16510–16538`):

```
PrepareFunctionCall / MoveArgsToStack
PSF tempObj.stackOffset
PerformFunctionCall(ctor, isConstructor=false)   // CALL, not ALLOC
ObjInfo(temp, asOBJ_INIT)
type = tempObj; MakeReference(false) if !onHeap
PSF tempObj.stackOffset                          // address stays on expr stack
```

Then `.Value` as in §6. Because `ctx->type.isTemporary`, member access records deferred release of the **object** temp (`18941–18951`).

`ProcessDeferredParams` (`as_compiler.cpp:16189–16217`) → `ReleaseTemporaryVariable` (`10185–10210`) → `CallDestructor`. VALUE: CALL `beh.destruct` if present, else `ObjInfo UNINIT`. **Not `asBC_FREE`.** `FREE` is the heap/handle path (`4646–4652`).

Lifetime: destroy after the member primitive has been read (deferred), not before. Destroying before the load yields uninitialized `Value`.

---

## 8. What `asCRuntimeTypeBridge::Resolve` must see for `FValue`

`D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_runtime_type_bridge.cpp`:

`FindRuntimeTypeInfo` (`13–50`), key = `asCType*::stableKey` (Sema interned name `"FValue"`, `as_sema_decl.cpp:338–373`, `as_sema_expr.cpp:869`):

1. `engine->GetTypeInfoByDecl(key)` (`as_scriptengine.cpp:5097–5110`) — silent `asCBuilder` with **module = 0**. Finds **registered** types, not `module->classTypes`.
2. `engine->GetTypeInfoByName(key)` (`6122–6124`) — **`allRegisteredTypesByName.FindFirst` only**.
3. `GetObjectTypeByIndex` — `registeredObjTypes`, not script classTypes.
4. `engine->funcDefs`.

Legacy script types are in `engine->allScriptDeclaredTypes` (`as_builder.cpp:2932`) and `module->classTypes` / `allLocalTypes`. They are **not** in `allRegisteredTypesByName`. That is why Generate already does `engine->allRegisteredTypesByName.Add(st)` in `RegisterCanonicalScriptTypes` (`as_bytecode_codegen.cpp:1559`).

`Resolve` (`52–93`):

- Primitive / void: `CreatePrimitive`.
- Else: `CreateType(info, const)`. If `asOBJ_REF` or `asOBJ_FUNCDEF` → `MakeHandle(true)` (`78–81`). VALUE must **not** take that branch.
- Then apply AST handle/reference quals.

If `FindRuntimeTypeInfo` returns 0, `Resolve` returns empty `asCDataType()` (`73–74`). Then `FValue Object` cannot type, ctor bind cannot set `objectType`, member `Value` cannot `AddPropertyToClass`.

Order: **register `FValue` (name, flags, properties, layout, `allRegisteredTypesByName` + `module->classTypes`) before any function signature/body `Resolve`.**

`GetTypeIdFromDataType` still works once the `asCObjectType*` exists (`typeId == -1` assigns one).

---

## 9. Gotchas (wrong execute value)

| Failure | Symptom | Legacy fact |
| --- | --- | --- |
| Treat `struct` as REF | ALLOC / factory / handle | `as_builder.cpp:2861–2913` |
| Skip user ctor CALL | `Value` is 0 (or uninit) → return 1 | Local/temp VALUE: `PSF` + `asBC_CALL` `beh.construct` (`4551–4570`, `16522–16528`) |
| `PerformFunctionCall(..., isConstructor=true)` for stack VALUE | `asBC_ALLOC` (`22206`) | ALLOC is REF / heap VALUE (`as_context.cpp:2723`) |
| `thisOffset = -AS_PTR_SIZE` for ctor store | writes 41 into first **arg** slot (ctor has none) | VM this is **offset 0** (`as_compiler.cpp:14654`, `as_context.cpp:1732`) |
| `PSF this` + `ADDSi` **without** `RDSPtr` / `PshVPtr` | overwrites the this **pointer** with 41 | Need load of pointer then ADDSi (`14793–14810`, `3796–3798`) |
| Uninitialized stack object, no ctor | garbage or 0 | Compiler does not memcpy-zero the whole VALUE; ctor + member init do the writes |
| Publish ctor as `module->globalFunctions` | ctor looks like global `FValue` | Builder puts ctor on `objectType->beh.*` / methods, not the global list (`5872–5891`). `Commit()` currently pushes every artifact function (`as_bytecode_codegen.cpp:1676–1687`) |
| `beh.constructors.PushLast` on leftover `scriptTypeBehaviours.construct` | CALL C++ ScriptObject construct | VALUE user 0-arg **replaces** `[0]` (`5884–5886`). Generate currently does not copy `scriptTypeBehaviours`; if it does, replace `[0]` |
| `FREE` the temp / local VALUE | heap free of stack bytes | VALUE: CALL dtor or `ObjInfo UNINIT` only (`4654–4677`) |
| Destroy temp before `.Value` | uninit load | Deferred destroy after member read (`18941–18951`) |
| Register types after `FillFunctionSignature` | `Resolve(FValue)` empty | Bridge cannot see the name (`as_runtime_type_bridge.cpp:13–24`, `71–74`) |
| `objectType` unset before Emit | `thisOffset` stays sentinel; member assign fail-closes | `FillFunctionSignature` must bind ctor `objectType` from registered `FValue` **before** `Emit` (`as_bytecode_codegen.cpp:1576–1592`, `139`) |
| Size 0 object | `AddProperty` then layout; `size<=0` clamped to 1 in current Generate (`1555–1558`) | Legacy: start 0, int → 4, pad to alignment 8 |
| Generated empty dtor CALL vs none | extra CALL, still 42 if empty | Sema always synthesizes dtor; builder often does not for this POD struct (`1475–1533`) |
| `asOBJ_POD` means “skip ctor” | return 1 | POD only affects copy (`as_compiler.cpp:10518–10521`) and alignment/copy helpers. **Ctor still runs.** |

---

## Minimal VM sequence to match (named local)

**`FValue::FValue` (this at 0):**

```
JitEntry
; optional: zero int member (compiler does this for struct defaults)
PshVPtr 0 / ADDSi 0 / PopRPtr / SetV4 / WRTV4     ; or skip if user body always writes
; body Value = 41
PSF 0
RDSPtr
ADDSi Value.byteOffset (0), FValue typeId
PopRPtr
WRTV4 <local 41>
Ret AS_PTR_SIZE
```

**`int F()`:**

```
JitEntry
PSF ObjectOffset
CALL FValue::FValue
ObjInfo ObjectOffset INIT
PSF ObjectOffset
ADDSi 0, FValue typeId
PopRPtr
; load int, add 1, return
; cleanup: ObjInfo UNINIT (no FREE; CALL dtor only if beh.destruct)
Ret 0
```

**`FValue().Value`:** same construct into a **temp** stack slot, member load, then deferred VALUE cleanup (not ALLOC/FREE).

---

## Out of scope

- Do not flip default CANONICAL.
- Do not claim task 9.5 closable from this map.
- Do not port Compiler control-flow into Generate; only the VALUE construct/load/store contract above.
