# Verified staged Builder batch — 2026-09-05

This is task 4.1 implementation evidence, not full task or Change completion. `tasks.md` remains the sole execution state. See `language-coverage.md` for the maintained grammar that still needs implementation.

## Selected proof

Run through Harness in the selected primary workspace's current PowerShell 7 process:

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{
    Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'
    NoWait = $true; TimeoutMs = 3600000
}
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true
    NoWait = $true; TimeoutMs = 600000
}
```

Each asynchronous operation was observed through `ue.run.status` until terminal. Only the coordinator launched UE, and source writers were frozen before each build/test lease. The complete NativeEngine prefix is justified by shared AST/type/definition/registration changes and the user's requested batch strategy, not a default full-suite gate.

## Fresh GREEN evidence

- Final Editor build `03d7e7766db04b26ba7ebbfbad43b9f2`: exit 0, 11937 ms.
- Final NativeEngine run `4f81647dc43a44748ad97820a040899c`: exit 0, 32096 ms; **339 succeeded, 0 failed, 0 in process, 0 not run**, with zero test warning/error entries.
- Report: `Saved/Harness/Unreal/Runs/4f81647dc43a44748ad97820a040899c/AutomationReport/index.json`.
- Report SHA-256: `21CA0699DE5549A34BDA2FB91809C086FDE22A15660FC31BE8322144B841FE3C`.
- Reported test execution totals 2.851099 seconds. The 32.096-second operation includes launch, discovery, reporting and shutdown; the difference is **not** a measurement of pure UE startup.
- The preceding verified selection had 274 tests; this batch has 339, a net increase of 65. There were two combined Automation launches, not one process per test or area.
- Strict Change validation through `openspec.validate` with `--strict --json` passed without issues (Harness run `1665f330926e48f9aebede3fb85c108d`); TaskPlan remains 8 complete / 13 total.

| Directly affected group | Final passing cases |
|---|---:|
| Builder | 16 |
| DefinitionConsumer | 13 |
| ASTContext / ASTTraversal / ASTCodec / ASTTypeAndAttr / ASTTypedNodes | 15 / 11 / 18 / 6 / 6 |
| BodiesCore / BodiesExpressions / BodiesControlFlow / BodiesFinalization | 12 / 15 / 8 / 7 |
| Lexer | 15 |
| ReflectionDescriptors | 17 |
| MetadataImage / EngineRegistration | 23 / 23 |

Other existing declaration, identity, source/diagnostic, preprocessor and module-graph scenarios are included in the same 339-case passing report; the table is not an additive replacement total.

## Failure and correction history

1. Build `9f59d590af094562af01aadae0a20969` failed, exit 6, 160664 ms. Concrete errors: missing complete `asCType` include in `as_body_lifetime.cpp` (C2027); private Context validator access from file-local AST verifier helpers (C2248); repeated codec if-initializer names (C4456); CQTest `AreEqual<double,double>` assertion at `Bodies/BodySemanticTests.cpp` (C2338). Repairs added the direct type include, used a narrow verifier friend bridge without exposing unchecked sealing, renamed codec locals, and retained exact literal-value checking with `IsTrue(Expected == Actual)`. No warning level or verifier contract was weakened.
2. Build `0ae12711ca6346b5a4506a39a6e18247` failed, exit 6, 29821 ms, at test-DLL linking. New Builder tests independently deserialize JSON, but Json linkage existed only under the disabled legacy gate. `AngelscriptTest.Build.cs` now declares a replacement-test-private Json dependency. Legacy gates remain disabled.
3. Build `3ef0dbc865c74808b4550bf83dcb370d` failed, exit 6, 1183 ms, before C++ compilation: UBT reported a sharing violation opening `Intermediate/Build/BuildRules/AngelscriptProjectModuleRules.dll` after the rule change. `ue.process.list` run `67d7eae25ab048ddb37cc58d6129d24e` succeeded with no process records. No owner was identified, no unknown process was killed and no build directory was deleted. The unchanged-source retry `42abaf7a41e04783993a07d35ba00424` passed, exit 0, 15883 ms. This proves the lock no longer blocked that retry, not its cause or a Harness defect. Retained UBT log SHA-256: `27B418E87242E905A97C77A007DBA62465A34F8AB859868D2ECAC446A93DEC06`.
4. First combined Automation run `93d3943c2fa34aa2903412f3583ef4bd`: exit 255, 32853 ms; 338 pass / 1 fail, no incomplete/not-run cases. The sole failure was `Angelscript.UnitTest.NativeEngine.ReflectionDescriptors.ResolvedProjectionAllowsBodyResume`, line 144: the old assertion expected body analysis to seal the AST. The accepted staged contract separates analysis from explicit verification. The scenario now proves analyzed-but-unsealed state, calls `VerifyAST()`, proves verified-and-sealed state, and retains its same-node/body/descriptor assertions. Report SHA-256: `B8927D834C9D1915D7DDCFD9F4E9DF269790051C6C0302F66E00FBEB01142432`.
5. The final build and complete NativeEngine report above verify that correction and all adjacent scenarios.

## User-requested reusable knowledge

The CQTest floating-point restriction is recorded in `.agents/skills/angelscript-test-guide/SKILL.md`, separate from this run history. UE 5.8's `Engine/Source/Developer/CQTest/Public/Assert/NoDiscardAsserter.inl` rejects floating operands to both `AreEqual` and `AreNotEqual`; `IsNear(Expected, Actual, Epsilon)` is appropriate for approximate results, while deliberately exact numeric contracts use `IsTrue(Expected == Actual)` with a reason. The literal fixtures here are exactly representable, so changing matcher syntax does not relax their assertions. Numeric equality is distinguished from bitwise identity. `skill-creator/scripts/quick_validate.py .agents/skills/angelscript-test-guide` passed.

## What this proves and does not prove

The actual no-Engine Builder drives separate observable phases into real detached type/function images; split/full runs and serial/eight-worker body analysis produce deterministic observations. AST v4 retains typed syntax payload, semantic type references and control-flow target cross-references. Derived cleanup obligations remain in the separate body/lifetime projection, not the AST wire payload. Metadata layout/freeze and later Engine registration remain distinct operations, not VM execution.

Task 4.1 remains incomplete because maintained expression/statement/declaration forms still need coverage. Both obsolete ASTs still await the explicit 6.1 cutover. Standalone, legacy/full UE suites, VM/cache/JIT execution, Baseline (reserved for 7.1), and Harness Quick/Performance/Integration were intentionally omitted: they do not establish this batch's scoped frontend/metadata contracts. No commit, archive, workspace change or restored legacy startup is claimed.

The separately indexed stale OpenSpec UE-version prompt issue remains open; the transient build-rule file lock above is recorded without inventing a proven Harness root cause.

## Continued declaration/expression batch

The next coherent slice adds actual global metadata and template specializations, frozen host type environments, typedef/default-argument integration and forward-default dependency validation; parser/Sema and AST v5 observation cover member/index/cast/construction, named/default/indirect calls, strings/null and recursive authored type syntax. This section does not supersede the preceding 339-case evidence until a fresh report is recorded.

- Strict Change validation `d6a97ef1af7c412790f067d36f3a643d` passed with no issues before the batch.
- Initial Editor build `19c33494025142d0abac344c5cb88923` failed, exit 6, 82926 ms. The two new GenericDefinitionTests fixtures used unqualified `asCSourceManager`; retained old and replacement frontend names made it ambiguous (C2872 and consequent C2665). Both now explicitly name `frontend::asCSourceManager`. No production rule, compiler diagnostic or test assertion was weakened.
- Fresh corrected Editor build `48e5235c84f445068720b24b7b2c8ea7` passed, exit 0, 13995 ms.
- Combined NativeEngine run `2016737bedc0464fb7a02d6728f864f3`: exit 255, 26919 ms, 397 pass / 2 fail out of 399, zero incomplete/not-run/warning cases. Reported test execution 4.023682 seconds is not pure startup time. Report SHA-256 `333A615DBEAF1780BEA7CEBE55D5621AFEF7FB70EFF56730CDBB1DD3122C87E7`.
- The failing scenarios are `ASTTypedNodes.RepresentativeNodesDoNotCarryUniversalWidePayload` (integer-literal node exceeded the unchanged 64-byte budget after adding an expression qualifier byte) and `DeclarationsMaintainedSyntax.RequiredParameterAfterDefaultIsRejectedAndLaterDeclarationSurvives` (test incorrectly expected the collection barrier itself to return a semantic failure). The latter now follows the actual stage contract: successful fragment merge, recorded fragment error, failed declaration resolution, missing invalid function and surviving later declaration. The compact-expression production fix and fresh verification remain pending.

All source owners froze before the build and remain frozen throughout Automation. These compile errors are local test integration defects, not evidence of a Harness defect. The full maintained grammar and single-AST removal remain required; 4.1 is not marked complete by this slice.

### Continued batch GREEN

- Corrected Editor build `377634f89f4742a4939fed778ba26e43`: exit 0, 32251 ms.
- Combined NativeEngine `3abd0546ac0a49ce9506f2cbe95cfa7e`: exit 0, 27181 ms; **401 succeeded, 0 failed, 0 warnings, 0 in process, 0 not run**. Reported test execution totals 3.389201 seconds, not pure startup time.
- Report: `Saved/Harness/Unreal/Runs/3abd0546ac0a49ce9506f2cbe95cfa7e/AutomationReport/index.json`; SHA-256 `A13BD84DDAA00084F900802B22160DCADBC27C3A7D2F6F53F1A834F132E3A8C7`.
- The compact fix packs expression qualifiers into unused existing AST-header bits; the 64-byte integer-literal limit remains unchanged. Adjacent verifier tests prove reference default arguments have value-form type and deferred initializers must be materialized before final seal. These add two cases beyond the first 399-case report.
- Net increase from the preceding green batch: 62 tests (339 to 401). This slice used two combined Automation launches, not one launch per scenario. GlobalDefinitions 7/7, GenericDefinitions 7/7, Builder 23/23, BodiesPostfix 19/19, DeclarationsMaintainedSyntax 7/7, ASTTraversal 23/23, ASTCodec 19/19 and Lexer 17/17 pass alongside all adjacent groups.
- No Harness execution defect was established. Source writers were released only after the green report; enum expressions, remaining control-flow/declaration forms and final single-AST cutover continue in the same Ready task/later DAG nodes. TaskPlan remains 8/13 complete, not a completed Change.

## Continued grammar and semantic-definition batch (verification in progress)

- Initial Editor build `78ef569e2342413ebd7040b41d7d2ad9` failed, exit 6, 94144 ms. New foreach/constant code hid member or if-initializer names, verifier used a nonexistent record query, projection had an unmatched parenthesis, and the constant test TU used ambiguous legacy/new AST names. Bounded repairs renamed locals, used the actual stable-key query, corrected syntax and explicitly selected frontend names; no warning level or assertions were suppressed.
- Corrected Editor build `86f506122eb14136bfe9c6ca4a43c993` passed, exit 0, 33284 ms.
- Combined NativeEngine run `988dddf2cd26450c8f5b4eadc3742cb6` discovered 477 selected tests, but **failed with process exit 3**, 34304 ms. A test-local `TArray::Add` used an element from the same array while constructing an invalid repeated list pattern. The direct test call stack identifies `ListInitializerDefinitions.InvalidRepetitionAndTemplateSlotsDoNotPublishAContract`; the fixture now takes a value copy before insertion. This is not an engine or Harness crash cause.
- No complete `AutomationReport/index.json` was produced. Harness correctly reported missing/incomplete evidence, so discovery and preceding completion log lines are not a passing batch count. Retained `Unreal.log` SHA-256: `A0AC4C4C97741A8677C813C429BAB93BF4BEAC6298C5048A538655191B6D5EFD`.
- Earlier logged failures cover implicit member/this semantics, enum conversion verification, ClassDefault stage completion and list pattern observation. The list implementation correctly maps repeated elements to a shared pattern slot; validators must treat those mappings as references, not unique owning slots. Repairs and fresh complete verification remain required.
- Direct Session recovery may inspect otherwise valid bodies after a declaration error, but sticky failure forbids successful later results, AST sealing or publication. The newly overrestrictive no-worker guard was removed to preserve existing recovery behavior; the regression now proves the actual failed-publication boundary. Builder still stops at the failed required stage.

The most recent fully verified corpus remains 401/401 above. This section does not complete task 4.1 or supersede missing grammar/cutover work. All source owners remained frozen during both build and Automation; no legacy gates or unrelated aggregate suites were enabled.

### Complete retry with one remaining constant-expression failure

- Editor build `5d0a066f340b407ea7ef13547e62e68b`: exit 0, 15378 ms.
- NativeEngine `f1d999a2b07748a2b3deb54d4f415ee7`: exit 255, 28218 ms; 476 succeeded / 1 failed, zero warnings, incomplete or not-run tests. Reported test execution: 4.732331 seconds, not pure startup time. Report SHA-256 `2EE85FCA81A646E28D5316A45F75253316D726EB764EB16FC2CFC68C94518B76`.
- All earlier this/member/lambda, enum numeric seal, ClassDefault, list repetition and recovery scenarios now pass. The ordinary unnamed parameter fixture retains valid authored type syntax; only inferred lambda parameters may omit it. Verification authenticates This as a nominal handle PRValue and its narrow object-reference binding, and treats only registry-proven enum nominals as numeric.
- Sole remaining failure: `Builder.EnumExplicitFloatConversionRetainsTypedConstantSemantics`. Enriched stage evidence identifies declaration resolution and the exact `int(21.25 * Scale)` source range (45–63), followed by the dependent enumerator's unresolved cascade. Its pure constant-expression repair and fresh batch verification remain pending; do not report 477/477 from this run.

### Grammar/semantic-definition batch GREEN

- The remaining root cause was representation coverage: builtin `int(expr)` is `asCConstructExpr`, not `asCExplicitCastExpr`. The pure evaluator now recognizes only builtin, one-argument constructions without an actual user constructor, through its existing checked conversion logic. Floating-result nesting is covered too. Direct tests prove const-float references/product, truncation and rejection of invalid/user constructor folding.
- The retained compiler requires exactly one positional argument for primitive conversion. Sema now diagnoses zero/multiple/named arguments with recovery; actual record zero-argument construction remains valid and is separately proved.
- Build `73580a9dd8bd42f8af933e43d6afc8d0` failed, exit 6, 10490 ms: the new const-float fixture passed a QualType to the raw-type setter. The fixture now uses `SetExpressionQualType`, retaining const; production semantics were unchanged by this compile repair.
- Fresh Editor build `8b500d0c18be4c968038d2756591cd73`: exit 0, 14388 ms.
- Complete NativeEngine `df8e2e24acba4e0ebaa17a1412449c2a`: exit 0, 28795 ms; **481 succeeded, 0 failed, 0 warnings, 0 in process, 0 not run**. Reported test execution 4.070580 seconds is not pure startup time.
- Report SHA-256: `B3ACED1EE48C357C667763826FE543DFA0E9BE99946392EB2CE93DC97AB550E2`. Net increase from the preceding green corpus: 80 tests (401 to 481). Three combined Automation launches were used: the initial fixture crash, the complete 476/1 report and this complete green report.
- This proves the v6 typed controls/this/lambda/list/enum observations and their actual implicit-function/list-factory/constant/definition integration. Custom access, destination-aware user conversion selection, complete frozen-host semantic inputs and the final single-AST cutover remain required. Task 4.1 stays unchecked; no VM execution or complete Change closure is claimed.
