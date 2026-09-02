# Canonical lifetime compatibility accessor gate — 2026-08-28

## Outcome

CTA-S53 Task 15.6 is complete. Canonical Bytecode and TypedASTJIT no longer
interpret the retained `scope-exit` / `scope-release` spellings or the
`ForeachStmt` child positions themselves. Both consumers first build the one
verified `asCASTLifetimeView` and access compatibility facts through named,
authenticated projections:

- `asSASTLifetimeCleanupBinding` plus `GetCleanupBinding()` /
  `FindCleanupBinding()`;
- `asSASTForEachPhases` plus `GetForEachPhases()` /
  `FindForEachPhases()`;
- `asEASTLifetimeCompatibilityRole` distinguishes normal block exit,
  transfer exit and foreach exit without exposing literal spelling to a
  backend.

The old normal/transfer cleanup statements and foreach child remain in the
Canonical graph for the migration period. They are compatibility encodings,
not independent semantic authorities. `asCASTBuildLifetimeView()` accepts a
Frozen/Publishable snapshot only when the lifetime protocol and every retained
compatibility encoding agree exactly in both directions. The verifier uses the
same view and therefore rejects disagreement before Bytecode, AOT, sidecar or
provider publication can consume it.

This task does not delete `asCScriptNode`, `asCBuilder`, `asCCompiler`, Parser
recovery or explicit LEGACY compilation. Function-owned TypedSemantic HIR
remains physically absent. The product default remains LEGACY. Standalone was
neither changed nor run and remains deferred to its future OpenSpec.

## Authenticated compatibility boundary

`as_ast_lifetime.h/.cpp` now owns the only decoding boundary for the temporary
compatibility syntax. Its derived view records, for every cleanup statement:

- the exact statement and cleanup expression IDs;
- lifetime subject and exact action target;
- action kind (`DESTROY_VALUE` or `RELEASE_REFERENCE`);
- compatibility role and structural owner;
- supported exit mask and the exact lifetime-record index.

For every foreach it exposes named `initializer`, `condition`, `body`,
`increment` and optional `cleanup` phases plus the associated lifetime-record
index. Bytecode and AOT code no longer know that the retained syntax used
`children[0..3]`.

The view authenticates all of the following before it becomes valid:

1. every lexical destroy/release and foreach-iterator protocol record maps to
   exactly one compatible cleanup encoding;
2. every compatible cleanup encoding maps back to exactly one protocol record;
3. subject, exact action target, action kind, semantic region/phase and exit
   mask agree;
4. normal cleanup statements occupy the trailing block suffix in reverse
   lifetime order;
5. transfer children contain exactly the live-through cleanup set for the
   transfer's target and exit kind;
6. `continue` does not clean a foreach iterator that remains live through the
   increment/condition phase;
7. foreach normal exit, targeted `break`, outer `return` and nested transfer
   coverage use the same exact iterator record;
8. missing, extra or duplicate compatibility statements are rejected instead
   of being silently ignored.

The typed `LTV1` digest now includes these named bindings/phases. It does not
depend on `asCASTDump()`, JSON, DOT or cleanup literal text as an identity
authority.

## Producer and consumer changes

### Sema

`as_sema_stmt.cpp` authors success-sensitive lexical lifetime records for
owning references and value objects, then produces compatibility cleanup
statements from that already-selected protocol action. Foreach iterator
lifetime is authored only after the exact iterator assignment succeeds.

For value objects the compatibility statement now uses the exact destructor
selected by `FindLexicalValueDestructor()` and writes that Decl directly as
the cleanup expression's resolved target. It no longer calls the generic
`asCSema::ActOnCleanup()` path and performs a second unqualified lookup.

### Canonical Bytecode

`as_bytecode_codegen.cpp` builds the shared lifetime view during CodeGen
admission and fails closed when it is invalid. Normal and transfer cleanup
routing uses `FindCleanupBinding()`. Foreach lowering uses
`FindForEachPhases()` and named fields; the positional branch is limited to
ordinary `ForStmt`.

The Bytecode backend still owns mechanical VM state: cleanup/EH stacks,
labels, patches, slots and activation bits. Task 15.7 will remove the remaining
dependency on compatibility statements as executable routing carriers and
make semantic cleanup protocol/view-only.

### TypedASTJIT

`AngelscriptTypedASTJITCanonical.cpp` builds the same authenticated view.
Lifetime analysis and foreach phase proof use named cleanup bindings and named
foreach phases. No `scope-exit` / `scope-release` spelling or foreach child
position is interpreted in the AOT consumer.

This is not Task 15.8 closure: TypedASTJIT still has lifetime type-family and
activation heuristics that must be removed, and native object-frame ABI still
needs an explicit typed fallback boundary.

## TDD and issue log

### 1. Named API compile RED

The first consumer migration deliberately referenced the desired named view
API before it existed. The Runtime/Editor build failed on the missing cleanup
binding and foreach phase methods:

- `Saved/Build/cta-s53-15-6-named-accessor-red/20260828_190837_394_af308c19/Build.log`

Adding the smallest lifetime-view projection API and keeping its construction
inside `asCASTBuildLifetimeView()` made the consumer code compile.

### 2. Protocol/compatibility parity RED and normal ordinal defect

The first strict verifier run was **39/40 PASS**:

- `Saved/Tests/cta-s53-15-6-verifier-parity/20260828_191701_636_404c4bc8/Report/index.json`

`BuildsDeterministicLifetimeViewWithCommittedLiveSets` had a valid lifetime
protocol but no retained compatibility actions, proving the new view rejected
one-sided input. After migrating the fixture, a second defect showed that the
expected normal cleanup location was calculated from the full region child
count without first subtracting the protocol cleanup suffix. The corrected
formula is:

```text
region.children.length - regionRecordCount + cleanupOrdinal
```

This preserves reverse cleanup order even when non-cleanup statements precede
the suffix. The final verifier group is **41/41 PASS**, including the new
`RejectsLifetimeProtocolCompatibilityEncodingDisagreement` cases for:

- protocol record without compatibility statement;
- compatibility statement without protocol record;
- duplicate compatibility statements.

Evidence:

- `Saved/Tests/cta-s53-15-6-verifier-final/20260828_193909_830_4e9ed103/Report/index.json`

### 3. Namespaced value destructor lookup defect

The complete ProductionCodeGen run was initially **118/119 PASS**. The failing
source used `Tools::Utilities::FValue`. Sema had already selected the exact
qualified destructor, but compatibility cleanup creation called generic
`ActOnCleanup()` again. That route repeated an unqualified lookup and rejected
the otherwise-valid namespaced owner.

Focused RED:

- `Saved/Tests/cta-s53-15-6-namespaced-lifetime-red/20260828_193108_703_ce8c417d/Report/index.json`

The fix keeps one semantic decision: `FindLexicalValueDestructor()` selects
the destructor once, the lifetime record stores it, and the compatibility
cleanup copies that exact Decl. The new
`NamespacedValueLocalLifetimeMatchesExactQualifiedDestructorOwner` assertion
proves the cleanup and protocol action target both belong to
`Tools::Utilities::FValue`.

Focused GREEN and complete gates:

- `Saved/Tests/cta-s53-15-6-namespaced-lifetime-green/20260828_193239_625_a961f6c1/Report/index.json`
- `Saved/Tests/cta-s53-15-6-sema-authority-final/20260828_194030_166_eb0425a2/Report/index.json` — **401/401 PASS**
- `Saved/Tests/cta-s53-15-6-production-codegen-green/20260828_193949_464_8f8b66dd/Report/index.json` — **119/119 PASS**

The older generic `asCSema::ActOnCleanup()` lookup remains a separately
auditable route for temporary cleanup forms. This task does not claim that
every future temporary-cleanup producer is covered by the lexical-local fix.

### 4. Unauthenticated TypedASTJIT manual fixtures

The first complete TypedASTJIT run was **43/45 PASS**:

- `Saved/Tests/cta-s53-15-6-typedastjit-red/20260828_194117_718_01a3a516/Report/index.json`

The two old manual fixtures contained a cleanup statement but no
success-sensitive assignment activation and no lifetime protocol record. The
strict view correctly rejected them at `Context.Seal()`. The verifier was not
loosened. The fixtures were migrated to contain:

- an explicit initializer assignment activation point;
- the exact lifetime subject/action target/region/order record;
- normal/transfer compatibility statements that exactly match the record.

The reverse-live-only fixture now proves an early return before activation has
no cleanup, while the later return and normal exit contain the exact cleanup.
The foreach source fixture additionally asserts the named phases and proves
that `continue` has no cleanup binding.

Focused final:

- `Saved/Tests/cta-s53-15-6-typedastjit-canonical-final/20260828_194704_802_cc03ff2a/Report/index.json` — **16/16 PASS**

Complete final:

- `Saved/Tests/cta-s53-15-6-typedastjit-final/20260828_195052_949_13e810fe/Report/index.json` — **45/45 PASS**

### 5. Build initialization-order warning

MSVC reported C5038 because `asCBytecodeCodeGen` initialized
`lifetimeViewValid` after members declared later in the class. The initializer
was moved next to its declaration order. This was warning cleanup only and did
not alter admission behavior. The fresh build no longer reports this warning.

## Final verification

| Gate | Result | Evidence |
| --- | ---: | --- |
| Runtime/Editor build | PASS | `Saved/Build/cta-s53-15-6-final/20260828_195649_673_72fc7380/RunMetadata.json` |
| Frontend CanonicalAST | **165/165 PASS** | `Saved/Tests/cta-s53-15-6-frontend-final/20260828_195339_188_d9f23c58/Report/index.json` |
| SemaAuthority | **401/401 PASS** | `Saved/Tests/cta-s53-15-6-sema-authority-final/20260828_194030_166_eb0425a2/Report/index.json` |
| ProductionCodeGen | **119/119 PASS** | `Saved/Tests/cta-s53-15-6-production-codegen-green/20260828_193949_464_8f8b66dd/Report/index.json` |
| StaticJIT TypedASTJIT | **45/45 PASS** | `Saved/Tests/cta-s53-15-6-typedastjit-final/20260828_195052_949_13e810fe/Report/index.json` |
| Cache ASTBodySidecar V6 | **22/22 PASS** | `Saved/Tests/cta-s53-15-6-cache-sidecar-final/20260828_195429_104_713d3c37/Report/index.json` |
| Cache default-disabled / shutdown | **7/7 PASS** | `Saved/Tests/cta-s53-15-6-cache-default-off-final/20260828_195508_806_ea1ab72c/Report/index.json` |

Static checks:

- zero `scope-exit` / `scope-release` matches in the Bytecode and TypedASTJIT
  consumer files;
- every foreach-specific Bytecode/AOT branch resolves
  `FindForEachPhases()`; positional children remain only for ordinary
  structural expression/statement forms and `ForStmt`;
- zero TypedSemantic HIR production-symbol matches;
- `bUseCanonicalStagedCompiler = false` and
  `ep.canonicalCompilerPipeline = false` remain unchanged;
- `git diff -- Standalone` is empty;
- parent and plugin `git diff --check` pass. The only messages are Git's
  existing LF-to-CRLF working-copy notices.

## Explicit non-claims and next gate

- This gate authenticates and names the compatibility boundary; it does not
  remove the boundary.
- Task 15.7 must make Canonical Bytecode semantic cleanup protocol/view-only.
- Task 15.8 must remove TypedASTJIT destructor/type/activation
  reclassification and publish only a pointer-free stable-key/ABI-key summary.
- Constructor partial construction and array/aggregate committed-count cleanup
  remain Tasks 15.9 and 15.10.
- The combined Provider/detached identity and final CTA-S53 regression boundary
  remains Task 15.11.
- Section 13 Sema-authority, full Production CodeGen and multi-publisher
  cutover umbrellas remain open; this result must not flip the product default.
