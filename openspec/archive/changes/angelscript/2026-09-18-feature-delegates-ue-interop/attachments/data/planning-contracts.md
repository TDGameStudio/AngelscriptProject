# Planning contracts — 2026-09-18

Inspected at `38e1b7a4fe9bbc540106f28d7858ccd5d899868f` (workspace dirty only with this Change's planning files). No product C++ was mutated for this record.

## Confirmed names (exist today)

| Name | Location | Role |
|---|---|---|
| `asCParser::ParseCallableDeclaration` | `as_parser.cpp:668` | Keyword-only `delegate`/`event` parser. 1.2 replaces the body with one DECLARE table; 1.5 keeps the keyword branch as reject-only. |
| `asCParser` keyword dispatch | `as_parser.cpp:202` | `KwDelegate` / `KwEvent` still enter `ParseCallableDeclaration`. |
| `asCSema::ActOnCallableType(bool bMulticast, …)` | `as_sema.cpp:129` | Creates `asCEventDecl` or `asCDelegateDecl`. No Flavor argument yet. |
| `asCCallableTypeDecl::IsMulticast` | `as_decl.h:444` | Multicast == `asEDeclKind::Event`. Flavor is not stored. |
| `FAngelscriptDescriptorConsumer` callable projection | `as_descriptor_consumer.cpp:256` | Copies name, `bIsMulticast`, Signature shells, `Function` left null. No `bIsDynamic`. |
| `asCDefinitions::CreateCallableType` | `as_definitions.cpp:631` | Definition-graph callable type from a `asFUNC_CALLABLE_SIGNATURE`. |
| `asCDefinitionConsumer` callable arm | `as_definition_consumer.cpp:176` | `CreateCallableSignature` then `CreateCallableType`. |
| `FAngelscriptPreprocessor::ProcessDelegates` | `AngelscriptPreprocessor.cpp:1167` | Builds `struct Name { _FScriptDelegate/_FMulticastScriptDelegate _Inner; Execute/Broadcast; }` and blanks the authored text. |
| Keyword scan (not `DetectClasses`) | `AngelscriptPreprocessor.cpp:4281` | `ParseIntoChunks` `'d'`/`'e'` arm collects `delegate`/`event` into `File.Delegates`. |
| `FAngelscriptPreprocessor::DetectClasses` | `AngelscriptPreprocessor.cpp:1341` | Class/struct/enum only. Does not own callable collection. |
| `FAngelscriptClassGenerator::CreateFullReloadDelegate` | `AngelscriptClassGenerator_FullReload.cpp:253` | `NewObject<UDelegateFunction>`. |
| Analyze signature inference | `AngelscriptClassGenerator_Analyze.cpp:1520` | `GetMethodByName("Broadcast"\|"Execute")` then overwrites `Desc.Signature`. 3.2 must stop this. |
| `asCSema::ActOnIndirectCall` | `as_sema_postfix.cpp:471` | Types `Handler(2)` from the callable's resolved signature. Already returns `int`. |
| `asCSema::ActOnMember` / `ActOnMemberCall` | `as_sema_postfix.cpp:106` / `:391` | Record-member lookup. Callable Bind/Execute are not members today. |
| `asEmitCall` | `as_bytecode_emitter_calls.cpp:135` | Direct `CALL`/`CALLSYS` only. No CallPtr lowering. |
| `asCByteCode::CallPtr` | `as_bytecode.cpp:1722` | VM opcode helper. Hand-assembled tests already return 42. |
| `FAngelscriptDelegateOperations` | `Bind_Delegates.h:21` | Native `FScriptDelegate` construct/bind/clear. 3.1 adapter surface. |
| `ClassGenUClassReloadTests::MakeHostEngine` | `ClassGenUClassReloadTests.cpp:32` | Isolated `FAngelscriptEngine::Create`, `bSkipInitialCompile`, CacheV2 off. 2.1+ host. |
| `DeclarationSemanticTests::FSessionRun` | `DeclarationSemanticTests.cpp:20` | Isolated Sema session. 1.2/1.5 fixture. |
| `VoidParameterSpellingMeansAnEmptySignature` | `DeclarationSemanticTests.cpp:168` | Existing void-parameter control. Source currently also declares keyword callables; 1.2 keeps the `void Run(void)` assertion and rewrites the keyword lines. |
| `FDetachedDefinitionFixture::DefineFunction` | `NativeDetachedDefinitionTestSupport.h:54` | 1.4 definition-graph functions. |
| `FuncPtrCallPtrReturnsFortyTwo` | `VMDispatchTests.cpp:193` | Hand-assembled CallPtr returns 42. 1.4 control, not this card's RED. |
| `DelegateVariableCallUsesCanonicalSignatureWithoutEngine` | `BodySemanticTests.cpp:884` | Sema types `Handler(2)` as `int` from `delegate int Callback(int X)`. 1.5 must migrate that source to `DECLARE_*` or the case becomes a keyword reject. |

## Names that do not exist yet (confirmed assumed)

| Name | Owner | Reason |
|---|---|---|
| `asECallableFlavor { Ordinary, Dynamic }` | 1.2 on `asCCallableTypeDecl` | Design.md. Current AST has only Delegate/Event kinds. |
| `asCCallableTypeDecl::GetFlavor` / `SetFlavor` | 1.2 | Needed so 1.2 tests can read flavor without ClassGen. |
| `FAngelscriptDelegateDesc::bIsDynamic` | 1.7 | Beside `bIsMulticast` at `AngelscriptDescriptors.h:286`. |
| `asEDeclarationDiagnostic::RemovedDelegateEventKeyword` = 3244 | 1.5 | Catalog reason `removed-delegate-event-keyword`. Next free syntax id after 3243. |
| `asEDeclarationDiagnostic::UnsupportedDelegateDeclarationForm` = 3245 | 1.5 | Catalog reason `unsupported-delegate-declaration-form`. |
| `TEST_CLASS` names in design.md | each product card | NativeEngine convention `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>`. |

## Script Bind / Execute / Broadcast spellings

Recorded for 1.3 and 2.1. Ordinary DECLARE forms do **not** use the preprocessor `BindUFunction` / `AddUFunction` wrappers.

| Form | Methods |
|---|---|
| Ordinary / dynamic single-cast | `Bind`, `Execute`, `ExecuteIfBound`, `IsBound`, `Clear` |
| Ordinary / dynamic multicast | `Add` → `FDelegateHandle`, `Remove`, `RemoveAll`, `Clear`, `Broadcast`, `IsBound` |
| Dynamic UFUNCTION path (3.3 only) | `BindDynamic`, `AddDynamic`, plus existing reflected `BindUFunction` / `AddUFunction` |
| Payload (2.2) | `Bind`/`Create` trailing value arguments after the named target; stored by copy on the callable instance |

`BindUFunction` remains a native/reflected name on `FAngelscriptDelegateOperations` (`Bind_Delegates.cpp:40`) and on the old generated wrappers (`ProcessDelegates` 1312). Script named-target Bind is the 1.3/2.1 spelling.

Builder-owned CallPtr emission for 1.4 is `asEmitCall` gaining an indirect path that emits `asBC_CallPtr` plus `asBC_CpyRtoV4` for a 32-bit return. No new opcode name.

## Cook route (required before 4.1 is Ready)

Editor half of 4.1 uses the card prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateLifecycle`.

Cooked-load proof, when 4.1 adds plugin assets under `Plugins/Angelscript/Content/Tests/Delegates/`:

```powershell
Invoke-Harness -Command ue.commandlet -Context $context -Parameters @{
    Commandlet = 'Cook'
    ExtraArguments = @('-TargetPlatform=Windows')
    TimeoutMs = 3600000
}
```

Do not call root `Tools` wrappers. `PlanOnly = $true` is allowed to inspect the request before the real cook.

## Existing keyword fixtures 1.2/1.5 must migrate

These still parse `delegate`/`event` and will fail once 1.5 rejects the introducers:

- `DeclarationSemanticTests.VoidParameterSpellingMeansAnEmptySignature`
- `DeclarationSemanticTests.CallableDefaultOwnsAnAnalyzedExpression`
- `DeclarationSemanticTests.RemovedImportDiagnosesItsAuthoredRangeAndRecovers` (`delegate void Good()` recovery target)
- `BodySemanticTests.DelegateVariableCallUsesCanonicalSignatureWithoutEngine`

1.2's `ExistingVoidParameterControl` is the `void Run(void)` empty-signature assertion, not the keyword callable lines in the same method.
