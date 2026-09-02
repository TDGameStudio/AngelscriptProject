# Canonical class-default typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-15 — class `default <statement>` and generated `__InitDefaults` body ownership |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Source fixture | a class with a field, a complete `default Value = 37;`, and a later malformed member so the record itself cannot finish |
| Construction/sealed-AST assertion | the generated `__InitDefaults` method, generated/origin traits, exact field assignment and method-owned body exist before the later record error |
| Architecture assertion | Parser starts/reuses `__InitDefaults` before parsing the statement, parses under that exact DeclContext, finishes by exact owner/range, performs no class-default whole-node callback, and declaration Sema contains no `case snClassDefaultStatement:` decoder |
| Expected RED | current Parser parses the statement under the record context and then calls `NotifySema` on a completed `snClassDefaultStatement`; `WalkOne` reconstructs the generated method and replays the child statement |
| Production edit allowed after RED | yes, limited to typed class-default start/finish actions, exact statement routing, generated-method/body ownership and deletion of the old decoder/callback |

## Locked design

1. `default` remains a syntax/recovery shell for LEGACY parsing only.
2. After the `default` token is accepted, Parser calls a typed start action
   under the exact current class. Sema creates or reuses one generated
   `void __InitDefaults()` with origin `canonical-init-defaults`, updates its
   source range monotonically, and returns its DeclId.
3. Parser pushes that exact method DeclContext before parsing the authored
   statement. Nested expression/control/declaration actions therefore own the
   generated method directly rather than being built under the class and
   re-parented afterward.
4. After a complete statement, Parser supplies only its exact source range to
   the finish action. Sema resolves one statement with the exact method owner
   and range, attaches it once to the generated method body in source order,
   and fails closed with `class-default-statement-action-missing` if no exact
   typed statement exists.
5. Neither action persists Parser/Engine pointers, numeric TypeId, or
   snapshot-local type references. The Parser node remains transitional syntax
   and is not semantic input to declaration Sema.

## Required evidence

1. test-only build and valid RED before production edits;
2. early-recovery semantic test and static architecture mutation test;
3. Runtime/Editor build after repair;
4. focused class-default construction plus Canonical compile/execute GREEN;
5. complete SemaAuthority and ProductionCodeGen GREEN;
6. source scan proving no class-default declaration replay/case;
7. strict OpenSpec validation and parent/plugin `git diff --check`;
8. every RED, invalid runner, root cause, repair and non-claim copied to the
   final issue/progress/task ledgers.

## Mutation checks

The permanent tests must fail if a future change:

- restores `NotifySema(node->lastChild)` for the class-default shell;
- restores `case snClassDefaultStatement:` in declaration Sema;
- parses the authored statement before entering the generated method context;
- routes only by statement kind/range without checking the exact method owner;
- silently drops a statement when the exact typed action is absent;
- duplicates a statement when multiple `default` clauses extend one body.

## Non-claims

- This does not migrate arbitrary class properties, access groups, funcdefs,
  lambdas, or general statement/expression actions.
- This does not complete all generated lifecycle/default-argument semantics.
- This does not change the LEGACY-default/Cache-default-disabled migration
  baseline.
- This does not prove detached CodeGen or TypedASTJIT completeness.

## TDD and implementation result

The test-only build passed before any production edit:

`Saved/Build/cta-class-default-typed-action-red-test-build/20260827_120856_013_da8009b9/RunMetadata.json`

The first valid focused run was the intended **0/2 RED**:

`Saved/Tests/cta-class-default-typed-action-red/20260827_120918_710_136a5017/Report/index.json`

The recovery fixture already contained a generated `__InitDefaults`, body and
assignment statement, but the body/statement owner remained the class rather
than the generated method. The architecture assertion simultaneously proved
that Parser had no typed start/finish actions and the completed
`snClassDefaultStatement` was still replayed by declaration Sema. This is a
valid semantic and architecture RED, not a stale-binary or runner failure.

The repair adds `ActOnClassDefaultStartAction` and
`ActOnClassDefaultStatementAction`. The start action creates or reuses exactly
one generated `void __InitDefaults()` beneath the exact current class. Parser
then pushes that returned DeclId before parsing the authored statement. The
finish action accepts only the complete statement range, requires exactly one
method-owned statement with that range, and emits
`class-default-statement-action-missing` if no such typed action exists. It
creates one method-owned wrapper body and appends later statements exactly
once in source order. The ParseClass callback and declaration-Sema
`case snClassDefaultStatement:` decoder are deleted.

The first production build and focused GREEN passed at:

- `Saved/Build/cta-class-default-typed-action-first-fix-build/20260827_121449_636_7fd165be/RunMetadata.json`;
- `Saved/Tests/cta-class-default-typed-action-first-green/20260827_121515_121_dc7a5bce/Report/index.json` — **2/2 PASS**.

The existing complete class-default compile/execute fixture remained **1/1
PASS** at
`Saved/Tests/cta-class-default-existing-green/20260827_121556_969_e4e566a8/Report/index.json`.
Before the additional multiple-statement oracle, complete SemaAuthority was
**323/323 PASS** at
`Saved/Tests/cta-class-default-sema-authority-green/20260827_121633_386_1858df0b/Report/index.json`
and ProductionCodeGen was **114/114 PASS** at
`Saved/Tests/cta-class-default-production-codegen-green/20260827_121717_853_2d88cb23/Report/index.json`.

The permanent `MultipleClassDefaultsAttachOnceInSourceOrder` regression was
then added to exercise the mutation rule directly. Its build and focused run
passed:

- `Saved/Build/cta-class-default-multiple-order-build/20260827_122141_707_a8355a33/RunMetadata.json`;
- `Saved/Tests/cta-class-default-multiple-order-green/20260827_122207_821_62040798/Report/index.json` — **1/1 PASS**.

The final complete SemaAuthority group is **324/324 PASS** at
`Saved/Tests/cta-class-default-sema-authority-final-green/20260827_122244_926_55762a97/Report/index.json`.
The existing TypedSemanticIR synthesized-default boundary remains **1/1
PASS**—capture still records the stable unsupported disposition while VM and
bytecode execution are unchanged—at
`Saved/Tests/cta-class-default-typed-semantic-boundary-final-green/20260827_122012_882_7468ac66/Report/index.json`.

## Tooling and diagnostic issues

The following invocations changed no repository state and are not product
failures:

1. Early read-only searches guessed an obsolete private source path, included
   a nonexistent `as_ast.h`, used forward-slash-specific regex assumptions,
   and passed Windows wildcard filenames such as `as_sema*.cpp` directly to
   `rg`. The maintained source was then located under
   `ThirdParty/angelscript/source` and searched by directory.
2. The first TypedSemanticIR boundary prefix omitted the CQTest class segment,
   so UE found zero tests. Metadata:
   `Saved/Tests/cta-class-default-typed-semantic-boundary-green/20260827_121931_733_af6e431b/RunMetadata.json`.
3. The first post-test `RunBuild.ps1` invocation used the test runner's
   unsupported `-LabelPrefix` option. PowerShell treated its value as a target
   and UBT rejected the nonexistent target before compilation. Metadata:
   `Saved/Build/build/20260827_122128_171_0dd3db8a/RunMetadata.json`.
4. A final combined validation/location-report command used `"$d:..."`
   instead of delimiting the PowerShell variable as `"${d}:..."`. The script
   failed during parsing, so no nested validation command ran and no state
   changed. Final validation was rerun separately afterward.

A source precheck also found that `asCSourceRange` exposes `operator==` but no
`operator!=`; the comparison was written as `!(a == b)` before the first
production build. No compile failure occurred.

## Final boundary

Static scans find zero semantic `case snClassDefaultStatement:` and zero
`case snDeclaration:` decoders. Direct line-bearing `asCScriptNode` references
remain declaration **84**, expression **42**, statement **20**, and core Sema
**3**. Those remaining adapters keep action-only Sema incomplete. The compiler
default remains LEGACY, Cache V2 remains default-disabled, and this gate does
not close Tasks `4.2`–`4.5` or `13.2`.

Final record validation passes: `openspec validate
refactor-as-canonical-typed-ast-compiler --strict` exits **0**, and separate
parent/plugin `git diff --check` commands both exit **0**. Their only output is
the pre-existing LF-to-CRLF conversion notices.
