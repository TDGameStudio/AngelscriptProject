# CTA-S60: qualified lexical type-scope gate

Date: 2026-08-29
OpenSpec: `refactor-as-canonical-typed-ast-compiler`
Primary task: 4.3
Status: closed slice; Task 4.3 remains open

## Scope

This slice closes one remaining namespace/type-parity gap in Canonical type
Sema. A type declared by the current script is not yet present in the Engine
Runtime registry while Parser actions are being consumed. Qualified type
syntax must therefore resolve against the Canonical declaration environment:

- `Types::CRef` authored inside `Outer::Use` searches the current namespace
  and then enclosing namespaces, selecting `Outer::Types::CRef`;
- `Outer::Types::FValue` authored inside `Outer::Use` may resolve after
  enclosing-namespace search reaches the translation-unit root;
- `::Outer::Types::EKind` starts at the translation-unit root and publishes
  stable identity without the authored leading `::` marker;
- the selected declaration, not punctuation or a missing Runtime lookup,
  determines enum/reference/value kind and intrinsic implicit-handle
  qualifiers.

This does not change the retained native `asCScriptNode` tree or the explicit
LEGACY Builder path. It must not put a Runtime pointer or dynamic numeric
TypeId into Parser actions, the Canonical AST, snapshots or backend DTOs.

## AST-first gate card

Test source:
`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

Test method:
`ParserQualifiedTypeScopesResolveLexicalNamespaceDeclsBeforeRuntimePublication`

Fixture facts:

1. `Outer::Types` declares script-only `class CRef`, `struct FValue`, and
   `enum EKind`.
2. `Outer::Use` declares variables using relative, parent-qualified and
   absolute type scopes.
3. All three Engine `GetTypeInfoByDecl` probes remain null before and after
   parsing, proving that Runtime registration cannot supply the answer.

Required sealed/public AST facts:

- `RelativeClass`: `REFERENCE_OBJECT`, stable key
  `Outer::Types::CRef`, intrinsic handle true;
- `ParentQualifiedValue`: `VALUE_OBJECT`, stable key
  `Outer::Types::FValue`, handle false;
- `AbsoluteEnum`: `ENUM`, stable key `Outer::Types::EKind`, handle false;
- the graph verifies and seals.

Expected RED before implementation:

- the current implementation flattens the recognized scope to an authored
  string and calls `ActOnQualType`;
- no Engine type is available;
- relative lookup does not replay Builder's enclosing-namespace search;
- absolute lookup retains the leading `::` in fallback identity;
- at least the exact stable-key/kind/handle assertions fail while the graph
  remains structurally sealable.

## Non-goals and remaining Task 4.3 work

- contextual lambda-to-funcdef signature inference;
- fully AST-local template declaration/instance authority;
- final Builder comparison-adapter reconciliation;
- Standalone adaptation, which is explicitly deferred by the user;
- default CANONICAL cutover.

## RED evidence

The pre-edit test build passed:

- `Saved/Build/cta-s60-qualified-lexical-type-red-build/20260829_103606_495_f5dd0e55`

The complete SemaAuthority prefix then produced the intended semantic RED:

- `Saved/Tests/cta-s60-qualified-lexical-type-sema-red/20260829_103717_690_71d9f502`
- total `411`, passed `410`, failed `1`, skipped `0`;
- the only failure was
  `ParserQualifiedTypeScopesResolveLexicalNamespaceDeclsBeforeRuntimePublication`.

The failure dump proved three distinct missing semantics rather than a graph
construction error:

- `RelativeClass` retained fallback type `Types::CRef` with qualifiers `0`, so
  it did not select the enclosing `Outer::Types::CRef` declaration or derive
  the class implicit handle;
- `ParentQualifiedValue` printed `Outer::Types::FValue`, but the spelling was
  an unresolved fallback rather than the selected lexical value declaration;
- `AbsoluteEnum` retained `::Outer::Types::EKind` with qualifiers `0`, so the
  authored absolute-scope marker leaked into identity and the type was not
  classified as an enum.

## Encountered issues

### I1: the first focused command matched no test and is excluded from evidence

The first attempted exact prefix omitted the CQTest class segment:

- `Saved/Tests/cta-s60-qualified-lexical-type-red/20260829_103639_547_0be001bf`

The runner reported that no tests matched. This is an invocation error, not a
semantic RED or GREEN, and is intentionally excluded from the gate counts. The
correct full path is:

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.ParserQualifiedTypeScopesResolveLexicalNamespaceDeclsBeforeRuntimePublication`.

### I2: qualified lexical lookup is currently a linear declaration scan

The correctness-first resolver scans Canonical declarations for each exact
candidate stable key. It runs during build-time Sema, publishes no mutable
lookup cache, and the qualified path is bounded by the enclosing namespace
depth. This is acceptable for the present migration gate, but a stable-key
symbol index is a possible later compile-time optimization if profiling shows
this path to be material. It is not a reason to restore Builder or Runtime
identity as Canonical authority.

### I3: existing network-probe warnings are not test failures

The combined run logged timeouts for `https://www.google.com/generate_204`.
The automation runner still completed with exit code `0` and `224/224`; these
are existing environment connectivity warnings and are not attributed to this
change.

## Implementation

`as_sema_decl.cpp` now resolves a scoped nominal type in this order:

1. For a relative scoped spelling, walk the current declaration context to
   each enclosing namespace and test `<namespace-stable-key>::<spelling>`.
2. For an absolute spelling, skip enclosing namespaces.
3. Test the translation-unit/global candidate without the authored leading
   `::` marker.
4. For each exact candidate, prefer a Canonical declaration already owned by
   the current `asCASTContext`; only then accept an exact Runtime declaration
   as an input view.
5. Intern only the stable key, Canonical type kind and effective qualifiers.
   No Runtime pointer or numeric TypeId is published.

Lexical enum, class, interface, struct and funcdef declarations are classified
from their Canonical declaration kind/traits. Class and interface declarations
derive their declared effective implicit-handle qualifier; structs remain
value objects. The retained LEGACY Builder path is unchanged.

## GREEN and regression evidence

The implementation build passed:

- `Saved/Build/cta-s60-qualified-lexical-type-first-fix-build/20260829_103925_678_3adf7b17`

The corrected focused test passed:

- `Saved/Tests/cta-s60-qualified-lexical-type-focused-green/20260829_103938_889_54690322`
- total `1`, passed `1`, failed `0`, skipped `0`.

The complete SemaAuthority prefix passed:

- `Saved/Tests/cta-s60-qualified-lexical-type-sema-green/20260829_104014_929_d0d58c5d`
- total `411`, passed `411`, failed `0`, skipped `0`.

The cross-surface regression matrix passed:

- `Saved/Tests/cta-s60-qualified-lexical-type-regression/20260829_104113_376_6601671c`
- Parser Declarations + Frontend Type/TypeIdentity/TypeSema + Canonical
  ProductionCodeGen + Module Snapshot + TypedASTJIT;
- total `224`, passed `224`, failed `0`, skipped `0`;
- process exit code `0`.

Static boundary checks after the implementation established:

- both plugin and parent `git diff --check` pass;
- the QualType syntax action contains no `asCScriptNode`, `asCBuilder`,
  `asCScriptEngine`, `asITypeInfo`, pointer field or numeric `typeId`;
- no production Canonical Sema call remains to `CreateDataTypeFromNode`,
  `GetNameSpaceFromNode`, `GetTemplateInstanceFromNode`, or
  `ModifyDataTypeFromNode`; the sole textual hit is an explanatory comment;
- HIR file count remains zero;
- retained native `as_parser.cpp`, `as_builder.cpp`, and `as_compiler.cpp`
  remain present for LEGACY/reference/rollback use;
- the default remains LEGACY unless `canonicalCompilerPipeline` is enabled;
- production dual selection remains absent; only cutover-test sentinels mention
  `asCOMPILER_PIPELINE_DUAL`.

## Closure and remaining work

CTA-S60 closes qualified lexical namespace-type lookup before Runtime
publication, including relative, parent-qualified and absolute stable identity
plus class/struct/enum kind and handle semantics. It does not close Task 4.3.
The remaining named work is:

- contextual lambda-to-funcdef signature inference;
- fully AST-local template declaration/instance authority;
- any type-parity cases exposed by those two closures;
- final Builder comparison-adapter reconciliation.

Standalone adaptation and default CANONICAL cutover remain explicitly outside
this slice. The formal OpenSpec count therefore stays `101/136` (`74.3%`).
