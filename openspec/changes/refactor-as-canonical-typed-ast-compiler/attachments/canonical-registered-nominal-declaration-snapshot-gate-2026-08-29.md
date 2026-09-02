# Canonical registered nominal declaration snapshot gate (CTA-S65)

Date: 2026-08-29

## Scope

This gate advances Tasks 4.3 and 13.2 by removing the three remaining
ordinary non-template `GetTypeInfoByDecl` decisions from
`as_sema_decl.cpp`. Canonical Sema must resolve a host/imported nominal type
and authored record base from translation-unit-local, pointer-free
declaration facts rather than reparsing a declaration through Builder or
observing a live Runtime registry during an individual Sema action.

Standalone remains explicitly deferred by user direction and is neither
changed nor run. The product default remains `LEGACY`; the native
`asCScriptNode`/Builder/Compiler graph remains available to LEGACY,
syntax/recovery, differential/reference and rollback paths. HIR remains
physically absent. This slice does not introduce production `dual` or a
silent LEGACY fallback.

## Evidence-backed defect

After CTA-S64, `as_sema_decl.cpp` still performs three live declaration
queries:

1. qualified nominal type lookup in `ResolveQualifiedNominalType`;
2. ordinary named fallback in `ActOnQualType`;
3. authored host/imported base lookup in `ProjectRuntimeBaseType`.

`asIScriptEngine::GetTypeInfoByDecl` is not a pure lookup in this maintained
fork. It constructs `asCBuilder` through `const_cast`, parses the declaration,
and may create template instances. Even for a non-template spelling, reading
the live registry during a Sema action makes the result depend on registrations
that occurred after the translation unit began. The resulting
`asITypeInfo*`, object flags and numeric TypeId are generation-local Runtime
state, not Canonical declaration identity.

The global registry also contains more than application host types: previously
published script-module types and template-generated types can be present.
Blindly copying one arbitrary same-key entry would preserve old-generation
reverse pollution under a different API. Therefore the gate must define
precedence and conflict behavior, not merely replace one function call.

## Locked authority boundary

1. At Sema construction and again at translation-unit start, the Engine copies
   every ordinary registered nominal declaration required for source lookup
   into owned facts containing only an exact stable key, Canonical type kind,
   intrinsic object flags, interface projection and a deterministic ambiguity
   marker. Template declarations/instances, template-subtype placeholders and
   list-pattern implementation types are excluded; CTA-S64 remains the
   authority for template declarations and template-parent child funcdefs.
2. Stable keys are formatted from `asCDataType` against the root namespace in
   the same qualifier-free form used by the Runtime type bridge. Facts contain
   no `asCTypeInfo*`, `asCObjectType*`, module pointer, Parser node, numeric
   TypeId, property offset or callback/function pointer.
3. Current-translation-unit lexical declarations are authoritative before any
   registered fact. This prevents a previous same-name module generation from
   overwriting the current authored enum/funcdef/class/interface meaning.
4. Relative names search the current and enclosing Canonical namespace scopes,
   then the root key. A leading `::` uses only the exact global/qualified key.
5. Equal same-key semantic facts are deduplicated. Same-key facts whose kind,
   intrinsic qualifier, value/reference category or interface projection
   conflicts are marked ambiguous independent of registry iteration order.
   Ambiguous facts fail closed; Sema must not select an arbitrary Runtime
   pointer and must not silently fall back to LEGACY.
6. Type Sema interns only the fact's stable key, Canonical kind and effective
   qualifiers. Record-base Sema may create a read-only
   `canonical-native-type-view` projection from the same copied fact; it does
   not need a live type pointer to decide the base edge or value trait.
7. `PreClassData::ShadowType` remains an explicitly separate build-only UE
   preprocessor input in this slice. Its current pointer projection and later
   layout consumption are not evidence that ordinary source type lookup may
   consult live Runtime state.
8. Runtime binding/install may resolve the stable identity to a
   current-generation pointer and numeric TypeId. Those dynamic values never
   become AST, snapshot, Cache, AOT or cross-generation identity.

## AST-first gate cards

Owning suite:

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

### `SemaRegisteredNominalSnapshotIsTranslationUnitLocal`

The test registers an early implicit-handle reference type, begins one
Canonical translation unit, then registers a distinct late type. It requires:

- the early type resolves from the copied facts as an exact
  `REFERENCE_OBJECT` with its intrinsic handle qualifier;
- the already-started Sema does not observe the late registration and retains
  the unresolved spelling as a value-shaped recovery type without an implicit
  handle;
- a new Sema/translation unit started after registration resolves that same
  stable key as an exact implicit-handle `REFERENCE_OBJECT`.

Expected RED on the pre-CTA-S65 implementation: the old Sema calls live
`GetTypeInfoByDecl` and incorrectly observes the late registration.

### `SemaRegisteredBaseSnapshotIsTranslationUnitLocal`

The test begins a translation unit, registers a distinct host base afterward,
and submits a pointer-free record-base action. It requires:

- the already-started Sema records the stable dependency but does not project
  or attach the late base;
- a new Sema/translation unit started after registration projects exactly one
  `canonical-native-type-view` and attaches that exact base edge;
- neither AST retains a Runtime pointer or numeric TypeId.

Expected RED on the pre-CTA-S65 implementation: `ProjectRuntimeBaseType`
queries the live registry and attaches the late base to the old translation
unit.

### Existing parity gates

The existing bare implicit-handle, qualified lexical scope and
`PreClassData::ShadowType` tests remain green. Additional focused assertions
will cover a namespace-qualified registered type and the unchanged exact host
base projection. Static architecture evidence supplements, but does not
replace, the two causal behavior gates.

## Required evidence

- test-only Runtime/Editor build;
- exact causal RED for both new methods before production changes;
- focused GREEN for snapshot isolation, implicit-handle type lookup,
  qualified registered lookup and host base projection;
- complete SemaAuthority prefix;
- Parser declaration, Frontend type, ProductionCodeGen, Module Snapshot and
  TypedASTJIT cross-surface regression matrix;
- Runtime/Editor build after implementation;
- static scan proving the three ordinary declaration queries are gone and the
  fact/action structures contain no live pointer or numeric TypeId;
- strict OpenSpec validation and plugin/parent `git diff --check`;
- plugin commit first, then parent gitlink/OpenSpec commit.

## Encountered risks and non-claims

- Copying all visible ordinary registered facts for every Sema/build generation
  is correctness-first and may add compile-time string/memory cost in a UE
  Engine with thousands of types. Review found the first implementation used
  a linear duplicate scan plus linear Sema lookup, which would make registry
  capture O(n-squared). Before final evidence, it was replaced by a StableKey-
  ordered `asCMap` merge and binary Sema lookup: capture is O(n log n), output
  order is deterministic, and lookup is O(log n). A later Engine-owned
  immutable/versioned shared snapshot and stable string pool can still remove
  duplicate per-Sema string copies without weakening translation-unit
  immutability through lazy live lookup.
- Registry facts can include script-module types needed by another module, so
  filtering to `module == nullptr` would break cross-module source semantics.
  Lexical precedence plus deterministic same-key ambiguity is the bounded
  migration rule until module-generation dependency snapshots are complete.
- The maintained fork currently implements `asCObjectType::IsInterface()` as
  an unconditional `false` (its old script-object/zero-size heuristic is
  commented out). CTA-S65 snapshots that existing Runtime projection and does
  not invent a replacement heuristic, so cross-module registered-interface
  classification is not proven by this gate. Interface identity needs its own
  stable declaration fact from module publication rather than guessing from
  mutable layout size.
- Same-key conflict reduction is deterministic by construction and its
  fail-closed consumer branches are source-audited, but ordinary registration
  APIs reject most duplicate declarations before the registry can expose the
  state. A controlled old/current-generation registry fixture is still needed
  for a direct ambiguity-injection behavior test; this gate does not claim one.
- Removing these three queries does not close every Task 4.3/13.2 dependency.
  `PreClassData::ShadowType` still enters through a live build-only pointer,
  `as_sema_expr.cpp` still has a live enum-scope declaration query, and native
  member/ABI projection still consumes generation-local Runtime views. The
  earlier phrase "last three queries" applies only to ordinary non-template
  declaration lookup in `as_sema_decl.cpp`; Task 4.3 stays open until a
  post-gate audit proves its full text.
- This gate does not make CANONICAL the default, complete Bytecode CodeGen,
  delete the native AngelScript AST, restore HIR, or claim Standalone evidence.

## Evidence log

### RED and discovery hygiene

- Test-only Runtime/Editor build passed before production changes:
  `Saved/Build/cta-s65-registered-nominal-red-build/20260829_134821_377_3f80a446`.
- The first exact-name invocation omitted the CQTest class segment and selected
  zero tests. It is retained as invalid discovery evidence and excluded from
  acceptance:
  `Saved/Tests/cta-s65-registered-nominal-red/20260829_134852_692_6c3eda1e`.
- Correct fully-qualified causal RED selected both tests and failed both target
  assertions (**0/2**): the old Sema observed the late nominal registration and
  attached the late host base:
  `Saved/Tests/cta-s65-registered-nominal-red-exact/20260829_134954_624_f1e17404`.

### Implementation and review corrections

- `asSCanonicalRegisteredTypeDeclarationFact` owns only StableKey, Canonical
  kind, semantic flags, interface projection and ambiguity. Engine capture
  excludes templates, template subtypes/list patterns and template-parent child
  funcdefs, then deterministically merges by StableKey. Equal facts deduplicate;
  conflicting facts become ambiguous independent of registry iteration order.
- `ActOnQualType`, qualified syntax actions and record-base actions now resolve
  current lexical declarations first and then the copied facts. Base projection
  publishes only `canonical-native-type-view` plus Canonical type/value facts.
- Review replaced the initial O(n-squared) duplicate scan and linear Sema lookup
  with O(n log n) ordered capture and O(log n) binary lookup before final gates.
- The final Runtime/Editor build after that correction passed:
  `Saved/Build/cta-s65-registered-nominal-ordered-green/20260829_140828_421_872f1e3b`.

### GREEN and regression evidence

- The direct lifecycle pair first changed to **2/2 PASS** at
  `Saved/Tests/cta-s65-registered-nominal-green-exact/20260829_135738_579_b96b8a03`.
- Final ordered-snapshot focused matrix passed **6/6**. It includes both new
  lifecycle tests plus implicit-handle, lexical-qualified scope precedence,
  PreClass native base and CTA-S64 template-snapshot parity:
  `Saved/Tests/cta-s65-registered-nominal-ordered-focused/20260829_140843_902_7485ff7d`.
- Complete final SemaAuthority passed **425/425**, with zero failure/skip:
  `Saved/Tests/cta-s65-sema-authority-ordered-final/20260829_140918_235_6a3186ed`.
- Final Parser Declarations + Frontend Canonical Type + ProductionCodeGen +
  Module Snapshot + TypedASTJIT matrix passed **224/224**, with zero
  failure/skip:
  `Saved/Tests/cta-s65-cross-surface-ordered-final/20260829_141010_198_30cdd105`.

### Static boundary evidence and remaining live inputs

- An exact-call scan reports zero `GetTypeInfoByDecl(`/`GetTypeInfoByName(`
  invocations in `as_sema_decl.cpp`.
- A bounded structure scan reports no `asITypeInfo`, `asCTypeInfo`,
  `asCObjectType*`, `asCScriptNode`, `typeId`/`TypeId` or pointer member in
  `asSCanonicalRegisteredTypeDeclarationFact`.
- `git diff --check` passes for the plugin. Line-ending notices are Git's
  existing LF-to-CRLF checkout warning, not whitespace errors.
- Remaining non-claims are source-located rather than hidden: expression Sema
  still queries an enum/qualified scope at `as_sema_expr.cpp:5588-5591`, while
  build-only `PreClassData::ShadowType` is consumed by native base/layout
  projection in `as_sema_decl.cpp`. These are the next authority boundaries;
  this gate does not count them as fixed.
- Strict OpenSpec validation passed:
  `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict`
  returned `Change 'refactor-as-canonical-typed-ast-compiler' is valid`.
  The required plugin-first source commit is `a5f5842` (`[CanonicalAST]
  Refactor: snapshot registered nominal declarations in Sema`). The parent
  identity is preserved by the commit that contains this attachment rather
  than by an impossible self-referential parent hash in the file itself.

## Accounting

CTA-S65 is a bounded slice of Tasks 4.3 and 13.2. The formal task ledger remains
`101/136 = 74.3%` until a complete task requirement—not merely this internal
query boundary—is proven and checked.
