# Native-call installed inventory implementation notes

## Purpose

Task 5.3 cannot be closed by scanning `Bind_*.cpp` or by exporting only the
functions referenced by one Typed HIR graph. The authoritative inventory is the
set of functions that one final `StaticJITGeneration` Engine actually accepted
while replaying the sealed Bind providers. The source scanner remains the
human-readable C++ side of a later join; it is not installation authority.

## Authoritative capture seam

`FAngelscriptBinds::OnBindForTarget()` is the common successful-registration
seam. At that point all of the following are simultaneously known:

- the exact target `FAngelscriptEngine` and returned Engine-local FunctionId;
- the current `asCScriptFunction` and canonical declaration;
- `FAngelscriptBindState::ActiveBindOwnerModule`;
- `ActiveBindProvider`, `ActiveBindPhase`, `ActiveBindSourceFile` and
  `ActiveBindSourceLine` established by `ExecuteRegisteredBindPhases()`; the
  latter two identify the `FAngelscriptBind` provider declaration, not the
  individual registration expression inside its callback/helper;
- origin classification (`Manual`, `Generated`, `Reflective`, or an existing
  explicit non-Bind origin).

The existing `FAngelscriptRegisteredFunctionProvenance` retains only origin and
provider. Do not enlarge every ordinary Runtime row with strings/native-form
facts. Add a separate optional generation-capture state owned by
`FAngelscriptBindState` (or its generation Engine) and allocate/populate it only
when `FAngelscriptEngine::GetPurpose() == StaticJITGeneration`. That state copies
owner, phase, normalized provider source file and line into Engine-owned values.
It must never retain `ActiveBindSourceFile` as a pointer: that pointer is
provider registration storage and is not an immutable snapshot contract.
Ordinary Runtime Engines keep the existing lightweight origin/provider map,
hold no per-function generation strings/rows, and never construct the broad
inventory.

The optional generation state is mutable only during sealed Bind replay and is
consumed/frozen into the immutable generation snapshot after source compilation.
It is not process-global and is not shared across Engines.

Origin mapping must be complete rather than preserving today's intentional
`Unknown` hole:

- `UHT.FunctionBinding.*` remains `Generated`;
- the reflective `Bind_BlueprintType*` providers become `Reflective`;
- ordinary sealed `FAngelscriptBind` providers become `Manual`;
- an already explicit `NativeModule`/other origin is not overwritten.

Successful repeated observation of the same FunctionId must retain one
deterministic provenance owner. A conflicting second owner/provider/source for
the same current function is an inventory error rather than last-writer-wins.
Separate overloads or dynamic-loop expansions have different FunctionIds and
remain separate rows even when they share one provider source line.

## Immutable generation row

The generation snapshot needs a separate broad row from
`FAngelscriptStaticJITNativeCallTarget`. The latter intentionally contains only
HIR-referenced, descriptor-backed, scalar-direct candidates and rejects absent
descriptors/unsupported ABIs. The installed inventory must contain every
Bind-produced function, including bridge, compile-out and unsupported rows.

A row requires these pointer-free owned fields:

```text
EngineLocalFunctionId          transient join only; never artifact identity
CanonicalDeclaration          copied from the accepted asCScriptFunction
StableReference               CacheV2 EnvironmentSymbol key + expected ABI;
                              pointer-free dispatch/reconciliation identity
Origin
OwnerModule
Provider
Phase
NormalizedProviderSourceFile
ProviderSourceLine
CallableKind                  global/method/constructor/destructor/behavior/generic
NativeFormKind                explicit absent/known kind
NativeCallableDisplay         optional; copied when native form/descriptor knows it
NativeHeader                  optional
ExternalDescriptor            optional, copied from current Engine state
ExpectedScalarABI             optional valid value plus typed unsupported reason
Compile/routing/trait facts   copied, no source or UFunction pointer
```

Absence is data. An inventory row without a native form, external descriptor or
supported scalar ABI remains present and is later classified `bridge`,
`compile-out`, or `unsupported`; it must not make the entire generation snapshot
incomplete.

## Native-form join

The current native-form state is already per Engine:

```text
FAngelscriptNativeFormState::Forms
FAngelscriptNativeFormState::ExternalCallDescriptors
```

The current debug description is compiled only under
`WITH_DEV_AUTOMATION_TESTS` and may carry a `UFunction*`. Generation needs a
production pointer-free description seam. Move the stable kind/name/custom
form/header/trivial/target-type facts into a small value view available when
`AS_CAN_GENERATE_JIT`; convert any `UFunction` to stable path/routing facts while
the Engine is alive, and never store the pointer in the inventory. The legacy
BytecodeJIT form classes may implement the description virtual, but the broad
inventory contract belongs under `StaticJIT/NativeCalls`, not in the legacy
emitter API.

`FAngelscriptStaticJITNativeCallRegistry::Find()` remains the exact per-function
external-descriptor authority. Symbol spelling or a private header visible to
the Runtime module never synthesizes an external descriptor.

## Determinism and source join

Engine-local FunctionId is useful only to join the same live Engine's HIR and
native state. It is not a stable sort key. Freeze the inventory in this order:

```text
normalized provider source file
provider source line
owner module
provider
canonical declaration
callable kind
```

Provider source paths are diagnostic metadata but still need machine-independent
normalization. Convert separators first, then prefer the stable suffix beneath
`Source/<OwnerModule>/`. Generated/UHT providers use an explicit generated-source
category plus stable shard filename/provider rather than preserving drive,
workspace, configuration, or intermediate-directory prefixes. A path that
cannot be reduced without ambiguity remains a typed provenance error for the
complete inventory; it is not silently serialized as `V:/...` or another
machine-local path.

Reject duplicate rows with the same current FunctionId. The offline join with
`research/native-call-source-callsites.csv` must not equate provider source line
with registration-callsite line. It uses owner/provider + normalized provider
source file, then canonical declaration and native-form/target facts to select
the registration expression. Literal declarations provide the strongest source
match; dynamic loop/template expansions may intentionally map multiple
installed rows to one source expression. Source schema v11 follows inline
Provider callbacks through a conservative same-file named-`void` helper call
graph. A registration is attributed through that graph only when exactly one
Provider reaches its containing helper; shared, overloaded, cross-file, or
otherwise ambiguous paths remain explicitly unattributed until the Runtime
join. Every installed row must ultimately match one source/provider authority
or receive a typed generated/reflective explanation.

The source scanner now recognizes both explicit fluent forms and implicit macro
forms:

```text
explicit .Native*() sites        147
implicit METHOD*/FUNC* sites    1509
effective native-form sites     1656
```

It also emits `native-call-source-providers.csv` with all 253 source provider
declarations and 247 distinct BindName + phase identities. Inline callbacks are
represented by a marker; named callback symbols are retained. Mutually
exclusive source variants remain separate source rows, while the final Engine
inventory determines the one actually installed for the selected target.

Source schema v11 retains the v10 non-authoritative review queue over all 2,920 call
sites. The fields `SourceEvidenceDisposition`, `SourceEvidenceReason` and
`RequiredInstalledAuthority` make absence of proof explicit:

```text
direct-descriptor-candidate       1
bridge-candidate               1655
bridge-or-unsupported-review   1231
compile-out-rule-review          33
```

These values deliberately end in candidate/review. They are not the final
`direct-export|inline|exported-callable|bridge|compile-out|unsupported`
disposition. All 2,920 rows still require installed-Engine authority. In
particular, a `.CompileOut*()` fluent method is a rewrite rule, not proof that
the target always disappears. `CompileOutIfNoLog` depends on target/profile
conditions, while the non-rewritten `Print` path is still expected to use its
exported callable. Schema v10 therefore records the exact `CompileOutMethods`
and requires both the target-profile rewrite decision and the fallback call
disposition. The generator must never let the presence of a compile-out rule
hide the direct/bridge/unsupported analysis required when the rule does not
fire.

The source-side provider join is now nearly complete without guessing:

```text
lexical preceding Provider            2593
single-Provider file                     7
unique same-file helper call graph      306
intentionally unattributed               14
```

The 14 retained rows are the cross-file/dynamic BlueprintCallable direct
registration helpers, BlueprintCallable reflective fallback registrations and
generated bool-property accessors. Their actual Provider depends on the
current initialized Engine surface, so task 5.3/5.3a must resolve them from
installed provenance rather than teaching the source scanner a speculative
cross-translation-unit call graph.

The final installed reconciliation closes all fourteen without changing that
source-scanner rule: four legacy `BindBlueprintCallable` sites are inactive for
the current `WITH_EDITOR=1`, `AS_USE_BIND_DB=0` profile; four active direct
BlueprintCallable sites and four reflective fallback sites resolve through
`BlueprintType.ReflectionBindings`; and the two bool accessor sites resolve
through the installed `BlueprintType.ReflectionBindings` and
`UStruct.ReflectionBindings` expansions. The local row-level reconciliation
reports zero unresolved source sites, and its compact counts/hash live in
`native-call-export-summary.json`.

The final generation capture uses
`FAngelscriptCacheEnvironmentIdentity::TryBuildFunctionReference()` for every
installed row. Its case-sensitive 256-bit `EnvironmentSymbol` stable key and
expected ABI are the authoritative offline identity; provider/name/display
strings remain provenance only. This matters for legal case-distinct global
functions such as `throw(...)` and `Throw(...)`: an intermediate test that used
`TMap<FString, ...>` over a hand-composed display string treated those spellings
as one Unreal string key, while the existing CacheV2 keys correctly remain
distinct. The inventory therefore does not invent a second identity algorithm
and never substitutes `EngineLocalFunctionId`.

It does not reverse native addresses into C++ names. `Print` originally had
only source spelling `&FAngelscriptLoggingBinds::Print` and no native-form
display; task 5.5 now registers the reviewed exported Runtime callable and
explicit descriptor, so the installed inventory may advertise that exact
symbol without guessing it from an address.

The installed interface also records the exact pointer-free VM dispatch kind.
The current final Engine contains 72,240 `FunctionCaller`, 1,175
`GenericFunction`, and 4,667 `GenericMethod` rows, with no platform-native
fallback row. This mirrors `CallSystemFunction` precedence and deliberately
does not copy either the target or caller pointer. It also prevents a generic
`void(asIScriptGeneric*)` callback from being mistaken for the AS-visible
`Return(Args...)` native ABI; later generic support requires the separate VM
bridge marshalling contract in `typed-native-call-vm-bridge.md`.

## TDD and verification order

1. Official UBT must compile the new
   `GenerationNativeCallInventoryOwnsCompleteBindProvenance` test and reproduce
   the missing-`NativeCallInventory` RED. The current redirected unity compile
   is only pre-RED evidence because unrelated Live Coding blocks UBT admission.
2. Add generation-only provenance capture and the broad immutable rows.
3. Make the focused test GREEN, then add table-driven kind coverage for global,
   method, constructor, destructor, generic and dynamic-loop rows plus
   conflicting duplicate behavior.
4. Add two-Engine/teardown and ordinary-Runtime-no-payload coverage, including
   proof that ordinary provenance rows do not allocate/copy provider source or
   native-form inventory strings.
5. Rebuild, export the fresh final Engine surface, join it to source/native
   facts, and require zero Bind-produced `origin=unknown` rows before task 5.3
   is checked.

This capture work does not yet implement direct exported calls or the typed
current-slot bridge. It provides the complete reviewed authority those later
classifiers consume.

## Local full-export policy

The complete one-row-per-installed-function CSV remains valuable for ad-hoc
grouping, provider audits, and later ABI expansion analysis, but it is a large
deterministic derived artifact rather than source. `Build-NativeCallExportInventory.ps1`
therefore writes the full CSV only beneath the ignored
`Saved/TypedSemanticAOT/NativeCallInventory/<run>/` tree (or outside the
repository). Git retains the generator, compact summary/hash, source
reconciliation, and this analysis. The exact OpenSpec research-path CSV is
also ignored as a safety net; no full dump is staged or committed.

This repository-size boundary must never be interpreted as permission to skip
the export. Every authoritative inventory/audit run first materializes and
retains the complete row-level CSV so developers can query and re-analyze it;
the compact count/size/hash is derived from that full local artifact only
afterwards. “Do not commit the CSV” does not mean “do not generate the CSV.”

The separate-consumer contract regenerates the complete CSV after its
production snapshot validator has accepted the installed rows. A direct
descriptor backed by `GenericFunction` or `GenericMethod` terminates both
snapshot capture and the offline join with
`DirectDescriptorUsesGenericDispatch`; it cannot be counted as a DLL/inline
success. A reflected UFunction now also snapshots authoritative `FUNC_Net`,
`FUNC_Event`, and `FUNC_BlueprintEvent` facts into the pointer-free
`NativeUFunctionRouteFlags` field. Any nonzero flag combined with raw-direct
linkage terminates capture/join with `DirectDescriptorBypassesUnrealRoute`.

The current accepted v4 run is local at
`Saved/TypedSemanticAOT/NativeCallInventory/20260815_1135_final_callsite_mapping/`:

```text
rows                         78,082
bytes                    90,579,196
sha256  9aba620e0efaf176f4d49de12bedf542a1a1fdb26b5ce66bf1ed56da87048dc0
direct-export                     1
bridge                          834
routed UFunctions               593
RPC/net                          138
BlueprintEvent                   455
routed/raw-direct conflicts        0
```

This full CSV is retained under ignored `Saved` for analysis. The repository
stores its generator and compact v4 summary, not the large row-level artifact.
The earlier `20260815_1029_route_safety` full export also remains available;
the newer run adds the reviewed `FDateTime::DaysInMonth` direct-export
descriptor, moving exactly one installed scalar callable from `bridge` to
`direct-export` without changing the 78,082-row Engine surface.
