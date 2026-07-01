# UE Macro / UENUM / UFUNCTION / UINTERFACE / Meta-Specifier Coverage Matrix

> **This matrix is the design specification ("header") for reflection macro tests** (excluding USTRUCT; see `06-ustruct.md`): each row is a concrete verifiable scenario. ⬜ = pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 = fork rejection boundary.
>
> - Test files: `UEnum`(13) / `UFunction`(44) / `UInterface`(12) / `Macros`(19) / `MetaSpecifier`(13) Tests.cpp
> - Automation prefix: `Angelscript.TestModule.Coverage.<UEnum|UFunction|UInterface|Macros|MetaSpecifier>`
> - See `../coverage-matrix.md` for the legend; see `../coverage-gaps.md §2.3` for interface boundaries.

## 1. UENUM (UEnumTests 13)

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Basic declaration | ✅ | `UEnumBasicDeclaration` |
| Specifiers / meta / bitflags meta | ✅ | `UEnumSpecifiers` `UEnumMeta` `UEnumMetaBitflags` |
| enum class usage / reflection query / general usage | ✅ | `UEnumClassUsage` `UEnumReflectionQuery` `UEnumUsage` |
| switch / conversion / bitflag operations | ✅ | `UEnumSwitch` `UEnumConversion` `UEnumBitflags` |
| In containers | ✅ | `UEnumInContainers` |
| Bitflags specifier rejection / invalid diagnostics | 🚫 | `UEnumBitflagsSpecifierRejected` `UEnumInvalidDiagnostics` |

## 2. UFUNCTION (UFunctionTests 44)

### 2.1 Specifiers and Metadata

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Specifiers and metadata / parameter metadata | ✅ | `UFunctionSpecifiersAndMetadata` `UFunctionParameterMetadata` |
| UParam display name and ref matrix | ✅ | `UParamDisplayNameAndRefMatrix` |
| Specifier flag edges | ✅ | `UFunctionSpecifierFlagEdges` |
| Editor/Exec/Authority specifier combinations | ✅ | `EditorExecAndAuthoritySpecifierCombinations` |
| BlueprintCallable suppression and specifier-order matrix | ✅ | `BlueprintCallableSuppressionAndSpecifierOrderMatrix` |
| Access-modifier function-flag matrix | ✅ | `AccessModifierFunctionFlagMatrix` |
| Property accessor callback UFUNCTION matrix | ✅ | `PropertyAccessorCallbackUFunctionMatrix` |
| ThreadSafe dispatch subclass matrix | ✅ | `ThreadSafeDispatchSubclassMatrix` |
| WorldContext metadata reflects parameter name | ✅ | `WorldContextMetadataReflectsParameterName` |
| Advanced function metadata and runtime matrix | ✅ | `AdvancedFunctionMetadataAndRuntimeMatrix` |

### 2.2 Dispatch and Invocation

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Function dispatch subclass shape matrix | ✅ | `FunctionDispatchSubclassShapeMatrix` |
| Basic member and const reflection call | ✅ | `BasicMemberAndConstReflectionCall` |
| Recursion and virtual override dispatch | ✅ | `RecursionAndVirtualOverrideDispatch` |
| Mixed-parameter reflection and runtime call | ✅ | `MixedParameterReflectionAndRuntimeCall` |

### 2.3 Static / Global Functions

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Static global function reflection and runtime call | ✅ | `StaticGlobalFunctionReflectionAndRuntimeCall` |
| Static WorldContext generation matrix | ✅ | `StaticWorldContextGenerationMatrix` |
| Static global complex-parameter matrix | ✅ | `StaticGlobalComplexParameterMatrix` |
| Static global advanced-metadata and namespace matrix | ✅ | `StaticGlobalAdvancedMetadataAndNamespaceMatrix` |

### 2.4 Network Specifiers

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Network specifier flag matrix | ✅ | `NetworkSpecifierFlagMatrix` |
| Network specifier callable/authority/metadata matrix | ✅ | `NetworkSpecifierCallableAuthorityAndMetadataMatrix` |

### 2.5 BlueprintOverride / BlueprintEvent

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Override BeginPlay/Tick and Super execution | ✅ | `BlueprintOverrideBeginPlayTickAndSuperExecute` |
| Override native Actor event parameter matrix | ✅ | `BlueprintOverrideNativeActorEventParameterMatrix` |
| Override inherited metadata / out parameters and Super / const Pure | ✅ | `BlueprintOverrideInheritanceMetadataMatrix` `BlueprintOverrideOutParameterAndSuperMatrix` `ConstBlueprintPureOverrideMatrix` |
| BlueprintEvent reflection and implementation invocation | ✅ | `BlueprintEventReflectsAndInvokesImplementation` |
| BlueprintEvent Callable/Pure/out-parameter matrix | ✅ | `BlueprintEventCallablePureAndOutParameterMatrix` |
| BlueprintEvent default-argument and ref-parameter matrix | ✅ | `BlueprintEventDefaultArgumentsAndRefParameterMatrix` |
| BlueprintPure out-only and inout runtime matrix | ✅ | `BlueprintPureOutOnlyAndInoutRuntimeMatrix` |

### 2.6 Parameters / Return Values / Type Reflection

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Return-type reflection matrix | ✅ | `ReturnTypeReflectionMatrix` |
| Object/class parameter reflection matrix | ✅ | `ObjectAndClassParameterReflectionMatrix` |
| Enum parameter/return/container matrix | ✅ | `EnumParameterReturnAndContainerMatrix` |
| handle parameter and return reflection matrix | ✅ | `HandleParameterAndReturnReflectionMatrix` |
| Delegate parameter reflection and runtime matrix | ✅ | `DelegateParameterReflectionAndRuntimeMatrix` |
| Primitive parameter order and out-layout matrix | ✅ | `PrimitiveParameterOrderAndOutLayoutMatrix` |
| Default-argument and out-flag layout / type-conversion matrix | ✅ | `DefaultArgumentsAndOutFlagLayout` `DefaultArgumentTypeConversionMatrix` |
| Reference-direction flag and runtime matrix | ✅ | `ReferenceDirectionFlagAndRuntimeMatrix` |
| Return and out-parameter permutation matrix | ✅ | `ReturnAndOutParameterPermutationMatrix` |
| Container parameter and return reflection matrix | ✅ | `ContainerParameterAndReturnReflectionMatrix` |
| Script-struct parameter direction and return matrix | ✅ | `ScriptStructParameterDirectionAndReturnMatrix` |
| optional return reflection matrix | ✅ | `OptionalReturnReflectionMatrix` |
| Unsupported UFUNCTION shape diagnostics (boundary) | 🚫 | `UnsupportedUFunctionShapeDiagnostics` |

## 3. UINTERFACE (UInterfaceTests 12)

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Native interface reference member and dispatch | ✅ | `NativeInterfaceReferenceMemberAndDispatch` |
| Native interface polymorphic references and parameters | ✅ | `NativeInterfacePolymorphicReferencesAndParameters` |
| Single native interface metadata and reflected dispatch | ✅ | `NativeSingleInterfaceMetadataAndReflectedDispatch` |
| Multiple native interface metadata and independent dispatch | ✅ | `NativeMultipleInterfaceMetadataAndIndependentDispatch` |
| Script-level `interface` keyword is rejected | 🚫 | `ScriptInterfaceKeywordRejected` `ScriptInterfaceMethodsRejected` |
| UINTERFACE macro/specifier/Blueprintable/GeneratedBody are rejected in script | 🚫 | `UInterfaceMacroDeclarationRejected` `UInterfaceSpecifierDeclarationRejected` `UInterfaceBlueprintableSpecifierRejected` `GeneratedBodyInsideInterfaceRejected` |
| `TScriptInterface<I>` / arrays of it are rejected | 🚫 | `TScriptInterfaceTypeRejected` `TScriptInterfaceArrayRejected` |

## 4. Combined Macros (MacrosTests 19)

| Scenario | Status | Covering Test Method |
|------|------|------------|
| UDelegate macro and script delegate reflection | ✅ | `UDelegateMacroDeclarationRejected` `ScriptDelegateReflectsUDelegateFunction` |
| Custom metadata key round trip / editor-condition active branch | ✅ | `CustomMetadataKeysRoundTrip` `EditorConditionActiveBranchReflects` |
| Reflection macro combinations / macro expansion ignores comments, strings, and inactive branches | ✅ | `ReflectionMacroCombination` `MacroExpansionIgnoresCommentsStringsAndInactiveBranches` |
| Advanced UEnum declaration / custom metadata / bitflag runtime | ✅ | `UEnumAdvancedDeclaration` `UEnumCustomMetadataRoundTrip` `UEnumBitflagMetadataAndRuntimeOperators` |
| UFunction specifier metadata and const reflection / recursive virtual override and Super | ✅ | `UFunctionSpecifiersMetadataAndConstReflection` `UFunctionRecursiveVirtualOverrideAndSuperCall` |
| Advanced UStruct usage / UParam modifiers | ✅ | `UStructAdvancedUsage` `UParamModifiers` |
| BlueprintEvent metadata and dispatch / default implementation | ✅ | `BlueprintEventMetadataAndDispatch` `BlueprintEventDefaultImplementations` |
| Interface/GeneratedBody/ScriptInterface/WithEditor macros are rejected in script | 🚫 | `UInterfaceMacroDeclarationRejected` `GeneratedBodyInsideInterfaceRejected` `ScriptInterfaceDeclarationBoundariesRejected` `WithEditorMacroNameRejected` `DynamicMacroNamesAreNotScriptAPIs` (control) |

## 5. Meta Specifiers (MetaSpecifierTests 13)

| Scenario | Status | Covering Test Method |
|------|------|------------|
| ClampMin/Max / UIMin/Max / Units | ✅ | `ClampMinMaxMeta` `UIMinMaxMeta` `UnitsMeta` |
| DisplayName / property-presentation meta | ✅ | `DisplayNameMeta` `PropertyPresentationMeta` |
| EditCondition / Inline toggle | ✅ | `EditConditionMeta` `InlineEditConditionToggleMeta` |
| float editor meta round trip | ✅ | `FloatEditorMetaSpecifierRoundTrip` |
| UClass display and BP meta | ✅ | `UClassDisplayAndBlueprintMeta` |
| UFunction basic specifiers and flags / display and parameter meta / WorldContext and Pin meta / recursion | ✅ | `UFunctionBasicSpecifiersAndFlags` `UFunctionDisplayAndParameterMeta` `UFunctionWorldContextAndPinMeta` `UFunctionRecursion` |

---

## Summary

| File | Methods |
|------|------|
| UEnum | 13 |
| UFunction | 44 |
| UInterface | 12 |
| Macros | 19 |
| MetaSpecifier | 13 |
| **Total** | **101** |

**Pending (⬜)**: no hard gaps currently. Script-level interfaces / `TScriptInterface` are explicit fork-unsupported items and are guarded by UInterface/Macros `*Rejected` boundaries (`../coverage-gaps.md §2.3`); if the fork later supports them, migrate those rows to ⬜.
