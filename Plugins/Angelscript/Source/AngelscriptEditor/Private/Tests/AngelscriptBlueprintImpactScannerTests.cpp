#include "BlueprintImpact/AngelscriptBlueprintImpactScanner.h"
#include "BlueprintImpact/AngelscriptBlueprintImpactScanCommandlet.h"

#include "Core/AngelscriptEngine.h"
#include "Core/AngelscriptRuntimeModule.h"
#include "Core/AngelscriptRuntimeModule.h"

#include "AssetRegistry/AssetRegistryModule.h"
#include "HAL/FileManager.h"
#include "K2Node_CallFunction.h"
#include "K2Node_CustomEvent.h"
#include "Kismet/KismetMathLibrary.h"
#include "Kismet2/BlueprintEditorUtils.h"
#include "Kismet2/KismetEditorUtilities.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/PackageName.h"
#include "Misc/ScopeExit.h"
#include "UObject/SavePackage.h"
#include "UObject/GarbageCollection.h"
#include "UObject/Package.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactNormalizePathsTest,
	"Angelscript.Editor.BlueprintImpact.NormalizePaths",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactMatchChangedScriptsToModuleSectionsTest,
	"Angelscript.Editor.BlueprintImpact.MatchChangedScriptsToModuleSections",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactBuildSymbolsTest,
	"Angelscript.Editor.BlueprintImpact.BuildImpactSymbols",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactAnalyzeParentClassTest,
	"Angelscript.Editor.BlueprintImpact.AnalyzeParentClass",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactCommandletInvalidFileTest,
	"Angelscript.Editor.BlueprintImpact.CommandletInvalidFile",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactCommandletEngineNotReadyTest,
	"Angelscript.Editor.BlueprintImpact.CommandletEngineNotReadyReturnsExitCode2",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactAnalyzeVariableTypeTest,
	"Angelscript.Editor.BlueprintImpact.AnalyzeVariableType",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactAnalyzePinTypeTest,
	"Angelscript.Editor.BlueprintImpact.AnalyzePinType",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactAnalyzeNodeDependencyTest,
	"Angelscript.Editor.BlueprintImpact.AnalyzeNodeDependency",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactAnalyzeReferencedAssetTest,
	"Angelscript.Editor.BlueprintImpact.AnalyzeReferencedAsset",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactAnalyzeDelegateSignatureTest,
	"Angelscript.Editor.BlueprintImpact.AnalyzeDelegateSignature",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactFindBlueprintAssetsDiskBackedTest,
	"Angelscript.Editor.BlueprintImpact.FindBlueprintAssetsDiskBacked",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptEditor_Private_Tests_AngelscriptBlueprintImpactScannerTests_Private
{
	TSharedRef<FAngelscriptModuleDesc> MakeTestModule(const FString& ModuleName, TArray<FAngelscriptModuleDesc::FCodeSection> CodeSections)
	{
		TSharedRef<FAngelscriptModuleDesc> Module = MakeShared<FAngelscriptModuleDesc>();
		Module->ModuleName = ModuleName;
		Module->Code = MoveTemp(CodeSections);
		return Module;
	}

	FAngelscriptModuleDesc::FCodeSection MakeCodeSection(const FString& RelativeFilename, const FString& AbsoluteFilename = TEXT("J:/Dummy/Script.as"))
	{
		FAngelscriptModuleDesc::FCodeSection Section;
		Section.RelativeFilename = RelativeFilename;
		Section.AbsoluteFilename = AbsoluteFilename;
		Section.Code = TEXT("// Test");
		Section.CodeHash = 0;
		return Section;
	}

	TSharedRef<FAngelscriptClassDesc> MakeClassDesc(const FString& ClassName, UClass* GeneratedClass)
	{
		TSharedRef<FAngelscriptClassDesc> ClassDesc = MakeShared<FAngelscriptClassDesc>();
		ClassDesc->ClassName = ClassName;
		ClassDesc->Class = GeneratedClass;
		return ClassDesc;
	}

	TSharedRef<FAngelscriptClassDesc> MakeStructDesc(const FString& StructName, UScriptStruct* GeneratedStruct)
	{
		TSharedRef<FAngelscriptClassDesc> StructDesc = MakeShared<FAngelscriptClassDesc>();
		StructDesc->ClassName = StructName;
		StructDesc->bIsStruct = true;
		StructDesc->Struct = GeneratedStruct;
		return StructDesc;
	}

	TSharedRef<FAngelscriptEnumDesc> MakeEnumDesc(const FString& EnumName, UEnum* GeneratedEnum)
	{
		TSharedRef<FAngelscriptEnumDesc> EnumDesc = MakeShared<FAngelscriptEnumDesc>();
		EnumDesc->EnumName = EnumName;
		EnumDesc->Enum = GeneratedEnum;
		return EnumDesc;
	}

	UBlueprint* CreateTransientBlueprintChild(FAutomationTestBase& Test, UClass* ParentClass, FStringView Suffix)
	{
		const FString PackagePath = FString::Printf(
			TEXT("/Temp/AngelscriptBlueprintImpact_%.*s_%s"),
			Suffix.Len(),
			Suffix.GetData(),
			*FGuid::NewGuid().ToString(EGuidFormats::Digits));

		UPackage* BlueprintPackage = CreatePackage(*PackagePath);
		if (!Test.TestNotNull(TEXT("Blueprint impact test should create a transient package"), BlueprintPackage))
		{
			return nullptr;
		}

		BlueprintPackage->SetFlags(RF_Transient);
		const FName BlueprintName(*FPackageName::GetLongPackageAssetName(PackagePath));
		UBlueprint* Blueprint = FKismetEditorUtilities::CreateBlueprint(
			ParentClass,
			BlueprintPackage,
			BlueprintName,
			BPTYPE_Normal,
			UBlueprint::StaticClass(),
			UBlueprintGeneratedClass::StaticClass(),
			TEXT("AngelscriptBlueprintImpactScannerTests"));
		if (Blueprint != nullptr)
		{
			FKismetEditorUtilities::CompileBlueprint(Blueprint);
		}
		return Blueprint;
	}

	void CleanupBlueprint(UBlueprint*& Blueprint)
	{
		if (Blueprint == nullptr)
		{
			return;
		}

		if (UClass* BlueprintClass = Blueprint->GeneratedClass)
		{
			BlueprintClass->MarkAsGarbage();
		}

		if (UPackage* BlueprintPackage = Blueprint->GetOutermost())
		{
			BlueprintPackage->MarkAsGarbage();
		}

		Blueprint->MarkAsGarbage();
		CollectGarbage(RF_NoFlags, true);
		Blueprint = nullptr;
	}

	UK2Node_CallFunction* AddCallFunctionNode(UBlueprint& Blueprint, UFunction* Function)
	{
		if (Function == nullptr)
		{
			return nullptr;
		}

		UEdGraph* EventGraph = FBlueprintEditorUtils::FindEventGraph(&Blueprint);
		if (EventGraph == nullptr)
		{
			return nullptr;
		}

		UK2Node_CallFunction* CallFunctionNode = NewObject<UK2Node_CallFunction>(EventGraph);
		EventGraph->AddNode(CallFunctionNode, false, false);
		CallFunctionNode->CreateNewGuid();
		CallFunctionNode->PostPlacedNewNode();
		CallFunctionNode->SetFromFunction(Function);
		CallFunctionNode->AllocateDefaultPins();
		// UE 5.7: FBlueprintEditorUtils::GetAllNodesOfClass only surfaces nodes that
		// are part of the blueprint's compiled graph tree. Running ReconstructNode()
		// here resolves the FunctionReference (so UK2Node::HasExternalDependencies
		// reports the callee's Outer UClass) and a subsequent CompileBlueprint pass
		// registers the node through the ubergraph traversal path, matching what
		// real UI-driven node placement does.
		CallFunctionNode->ReconstructNode();
		FKismetEditorUtilities::CompileBlueprint(&Blueprint);
		return CallFunctionNode;
	}

	bool SaveBlueprintToDisk(FAutomationTestBase& Test, UBlueprint& Blueprint, const FString& PackagePath, FString& OutPackageFilename)
	{
		UPackage* Package = Blueprint.GetOutermost();
		if (!Test.TestNotNull(TEXT("Blueprint impact test should have a package before save"), Package))
		{
			return false;
		}

		Package->SetDirtyFlag(true);
		OutPackageFilename = FPackageName::LongPackageNameToFilename(PackagePath, FPackageName::GetAssetPackageExtension());
		FSavePackageArgs SaveArgs;
		SaveArgs.TopLevelFlags = RF_Public | RF_Standalone;
		SaveArgs.SaveFlags = SAVE_NoError;
		return Test.TestTrue(TEXT("Blueprint impact test should save the package to disk"), UPackage::SavePackage(Package, &Blueprint, *OutPackageFilename, SaveArgs));
	}

	UBlueprint* CreateDiskBackedBlueprintChild(FAutomationTestBase& Test, UClass* ParentClass, FStringView Suffix, FString& OutPackagePath, FString& OutPackageFilename)
	{
		const FString AssetName = FString::Printf(TEXT("BP_EditorImpact_%.*s_%s"), Suffix.Len(), Suffix.GetData(), *FGuid::NewGuid().ToString(EGuidFormats::Digits));
		OutPackagePath = FString::Printf(TEXT("/Game/Automation/%s"), *AssetName);
		UPackage* Package = CreatePackage(*OutPackagePath);
		if (!Test.TestNotNull(TEXT("Blueprint impact test should create a disk-backed package"), Package))
		{
			return nullptr;
		}

		UBlueprint* Blueprint = FKismetEditorUtilities::CreateBlueprint(
			ParentClass,
			Package,
			FName(*AssetName),
			BPTYPE_Normal,
			UBlueprint::StaticClass(),
			UBlueprintGeneratedClass::StaticClass(),
			TEXT("AngelscriptBlueprintImpactScannerTests"));
		if (Blueprint == nullptr)
		{
			return nullptr;
		}

		FKismetEditorUtilities::CompileBlueprint(Blueprint);
		FAssetRegistryModule& AssetRegistryModule = FModuleManager::LoadModuleChecked<FAssetRegistryModule>(TEXT("AssetRegistry"));
		AssetRegistryModule.AssetCreated(Blueprint);
		if (!SaveBlueprintToDisk(Test, *Blueprint, OutPackagePath, OutPackageFilename))
		{
			return nullptr;
		}

		return Blueprint;
	}
}

using namespace AngelscriptEditor_Private_Tests_AngelscriptBlueprintImpactScannerTests_Private;

bool FAngelscriptBlueprintImpactNormalizePathsTest::RunTest(const FString& Parameters)
{
	const TArray<FString> ChangedScripts = {
		TEXT("Scripts\\Gameplay\\Enemy.as"),
		TEXT("./Scripts/Gameplay/Enemy.as"),
		TEXT("/Scripts/Gameplay/Boss.as"),
		TEXT("scripts/gameplay/enemy.as")
	};

	const TArray<FString> NormalizedPaths = AngelscriptEditor::BlueprintImpact::NormalizeChangedScriptPaths(ChangedScripts);

	TestEqual(TEXT("BlueprintImpact.NormalizePaths should collapse duplicate script paths after normalization"), NormalizedPaths.Num(), 2);
	TestEqual(TEXT("BlueprintImpact.NormalizePaths should normalize separators and trim leading relative markers"), NormalizedPaths[0], FString(TEXT("scripts/gameplay/boss.as")));
	return TestEqual(TEXT("BlueprintImpact.NormalizePaths should normalize paths case-insensitively"), NormalizedPaths[1], FString(TEXT("scripts/gameplay/enemy.as")));
}

bool FAngelscriptBlueprintImpactMatchChangedScriptsToModuleSectionsTest::RunTest(const FString& Parameters)
{
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = {
		MakeTestModule(TEXT("Gameplay.Enemy"), {
			MakeCodeSection(TEXT("Scripts/Gameplay/Enemy.as")),
			MakeCodeSection(TEXT("Scripts/Gameplay/EnemyAbilities.as"))
		}),
		MakeTestModule(TEXT("Gameplay.Npc"), {
			MakeCodeSection(TEXT("Scripts/Gameplay/Npc.as"))
		})
	};

	const TArray<FString> ChangedScripts = {
		TEXT("scripts\\gameplay\\enemy.as")
	};

	const TArray<TSharedRef<FAngelscriptModuleDesc>> MatchingModules = AngelscriptEditor::BlueprintImpact::FindModulesForChangedScripts(Modules, ChangedScripts);

	if (!TestEqual(TEXT("BlueprintImpact.MatchChangedScriptsToModuleSections should only return modules containing at least one changed script section"), MatchingModules.Num(), 1))
	{
		return false;
	}

	return TestEqual(TEXT("BlueprintImpact.MatchChangedScriptsToModuleSections should return the module whose code sections include the changed script"), MatchingModules[0]->ModuleName, FString(TEXT("Gameplay.Enemy")));
}

bool FAngelscriptBlueprintImpactBuildSymbolsTest::RunTest(const FString& Parameters)
{
	TSharedRef<FAngelscriptModuleDesc> Module = MakeShared<FAngelscriptModuleDesc>();
	Module->Classes.Add(MakeClassDesc(TEXT("BlueprintImpactActor"), AActor::StaticClass()));
	Module->Classes.Add(MakeStructDesc(TEXT("BlueprintImpactStruct"), TBaseStructure<FVector>::Get()));
	Module->Enums.Add(MakeEnumDesc(TEXT("BlueprintImpactEnum"), StaticEnum<EAutoReceiveInput::Type>()));

	const AngelscriptEditor::BlueprintImpact::FBlueprintImpactSymbols Symbols = AngelscriptEditor::BlueprintImpact::BuildImpactSymbols({ Module });

	if (!TestTrue(TEXT("BlueprintImpact.BuildImpactSymbols should collect generated classes"), Symbols.Classes.Contains(AActor::StaticClass())))
	{
		return false;
	}

	if (!TestTrue(TEXT("BlueprintImpact.BuildImpactSymbols should collect generated structs"), Symbols.Structs.Contains(TBaseStructure<FVector>::Get())))
	{
		return false;
	}

	return TestTrue(TEXT("BlueprintImpact.BuildImpactSymbols should collect generated enums"), Symbols.Enums.Contains(StaticEnum<EAutoReceiveInput::Type>()));
}

bool FAngelscriptBlueprintImpactAnalyzeParentClassTest::RunTest(const FString& Parameters)
{
	UBlueprint* Blueprint = CreateTransientBlueprintChild(*this, AActor::StaticClass(), TEXT("ParentMatch"));
	ON_SCOPE_EXIT
	{
		CleanupBlueprint(Blueprint);
	};

	if (!TestNotNull(TEXT("BlueprintImpact.AnalyzeParentClass should create a transient blueprint"), Blueprint))
	{
		return false;
	}

	AngelscriptEditor::BlueprintImpact::FBlueprintImpactSymbols Symbols;
	Symbols.Classes.Add(AActor::StaticClass());

	TArray<AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason> Reasons;
	if (!TestTrue(TEXT("BlueprintImpact.AnalyzeParentClass should report a matching blueprint when its parent class is in the impact set"), AngelscriptEditor::BlueprintImpact::AnalyzeLoadedBlueprint(*Blueprint, Symbols, Reasons)))
	{
		return false;
	}

	return TestTrue(TEXT("BlueprintImpact.AnalyzeParentClass should record the parent class reason"), Reasons.Contains(AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason::ScriptParentClass));
}

bool FAngelscriptBlueprintImpactCommandletInvalidFileTest::RunTest(const FString& Parameters)
{
	UAngelscriptBlueprintImpactScanCommandlet* Commandlet = NewObject<UAngelscriptBlueprintImpactScanCommandlet>();
	if (!TestNotNull(TEXT("BlueprintImpact.CommandletInvalidFile should create the commandlet object"), Commandlet))
	{
		return false;
	}

	// The commandlet checks bDidInitialCompileSucceed before parsing arguments and returns
	// EngineNotReady (exit code 2) if the flag is false. Automation context may leave the
	// flag off in some clean test-engine configurations, so force-set it here to isolate
	// the InvalidArguments (exit code 1) path we actually want to cover.
	// Use TryGetCurrentEngine() instead of Get() to avoid asserting when earlier tests in
	// the same run popped the global context stack without restoring it.
	FAngelscriptRuntimeModule::InitializeAngelscript();
	FAngelscriptRuntimeModule::InitializeAngelscript();
	FAngelscriptEngine* EnginePtr = FAngelscriptEngine::TryGetCurrentEngine();
	if (!TestNotNull(TEXT("BlueprintImpact.CommandletInvalidFile should have a scoped Angelscript engine available"), EnginePtr))
	{
		return false;
	}
	FAngelscriptEngine& Engine = *EnginePtr;
	const bool bOriginalDidInitialCompileSucceed = Engine.bDidInitialCompileSucceed;
	ON_SCOPE_EXIT
	{
		Engine.bDidInitialCompileSucceed = bOriginalDidInitialCompileSucceed;
	};
	Engine.bDidInitialCompileSucceed = true;

	AddExpectedError(TEXT("Blueprint impact commandlet failed to read ChangedScriptFile"), EAutomationExpectedErrorFlags::Contains, 1);

	return TestEqual(
		TEXT("BlueprintImpact.CommandletInvalidFile should return the invalid-arguments exit code for a missing ChangedScriptFile"),
		Commandlet->Main(TEXT("ChangedScriptFile=J:/Missing/DoesNotExist.txt")),
		1);
}

bool FAngelscriptBlueprintImpactCommandletEngineNotReadyTest::RunTest(const FString& Parameters)
{
	UAngelscriptBlueprintImpactScanCommandlet* Commandlet = NewObject<UAngelscriptBlueprintImpactScanCommandlet>();
	if (!TestNotNull(TEXT("BlueprintImpact.CommandletEngineNotReady should create the commandlet object"), Commandlet))
	{
		return false;
	}

	// Same rationale as CommandletInvalidFile above — tolerate a missing engine context.
	FAngelscriptRuntimeModule::InitializeAngelscript();
	FAngelscriptEngine* EnginePtr = FAngelscriptEngine::TryGetCurrentEngine();
	if (!TestNotNull(TEXT("BlueprintImpact.CommandletEngineNotReady should have a scoped Angelscript engine available"), EnginePtr))
	{
		return false;
	}
	FAngelscriptEngine& Engine = *EnginePtr;
	const bool bOriginalDidInitialCompileSucceed = Engine.bDidInitialCompileSucceed;
	ON_SCOPE_EXIT
	{
		Engine.bDidInitialCompileSucceed = bOriginalDidInitialCompileSucceed;
	};

	Engine.bDidInitialCompileSucceed = false;
	AddExpectedError(TEXT("Blueprint impact commandlet requires a successfully initialized Angelscript engine."), EAutomationExpectedErrorFlags::Contains, 1);

	return TestEqual(
		TEXT("BlueprintImpact.CommandletEngineNotReady should return the engine-not-ready exit code before parsing ChangedScriptFile"),
		Commandlet->Main(TEXT("ChangedScriptFile=J:/Missing/DoesNotExist.txt")),
		2);
}

bool FAngelscriptBlueprintImpactAnalyzeVariableTypeTest::RunTest(const FString& Parameters)
{
	UBlueprint* Blueprint = CreateTransientBlueprintChild(*this, UObject::StaticClass(), TEXT("VariableType"));
	ON_SCOPE_EXIT { CleanupBlueprint(Blueprint); };
	if (!TestNotNull(TEXT("BlueprintImpact.AnalyzeVariableType should create a blueprint"), Blueprint))
	{
		return false;
	}

	FBPVariableDescription Variable;
	Variable.VarName = TEXT("ImpactVector");
	Variable.VarType.PinCategory = UEdGraphSchema_K2::PC_Struct;
	Variable.VarType.PinSubCategoryObject = TBaseStructure<FVector>::Get();
	Blueprint->NewVariables.Add(Variable);

	AngelscriptEditor::BlueprintImpact::FBlueprintImpactSymbols Symbols;
	Symbols.Structs.Add(TBaseStructure<FVector>::Get());

	TArray<AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason> Reasons;
	if (!TestTrue(TEXT("BlueprintImpact.AnalyzeVariableType should detect impacted struct variables"), AngelscriptEditor::BlueprintImpact::AnalyzeLoadedBlueprint(*Blueprint, Symbols, Reasons)))
	{
		return false;
	}

	return TestTrue(TEXT("BlueprintImpact.AnalyzeVariableType should record the variable-type reason"), Reasons.Contains(AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason::VariableType));
}

bool FAngelscriptBlueprintImpactAnalyzePinTypeTest::RunTest(const FString& Parameters)
{
	UBlueprint* Blueprint = CreateTransientBlueprintChild(*this, UObject::StaticClass(), TEXT("PinType"));
	ON_SCOPE_EXIT { CleanupBlueprint(Blueprint); };
	if (!TestNotNull(TEXT("BlueprintImpact.AnalyzePinType should create a blueprint"), Blueprint))
	{
		return false;
	}

	UK2Node_CallFunction* CallFunctionNode = AddCallFunctionNode(*Blueprint, UKismetMathLibrary::StaticClass()->FindFunctionByName(TEXT("MakeVector")));
	if (!TestNotNull(TEXT("BlueprintImpact.AnalyzePinType should add a function node with struct pins"), CallFunctionNode))
	{
		return false;
	}

	AngelscriptEditor::BlueprintImpact::FBlueprintImpactSymbols Symbols;
	Symbols.Structs.Add(TBaseStructure<FVector>::Get());

	TArray<AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason> Reasons;
	if (!TestTrue(TEXT("BlueprintImpact.AnalyzePinType should detect nodes whose pins use impacted structs"), AngelscriptEditor::BlueprintImpact::AnalyzeLoadedBlueprint(*Blueprint, Symbols, Reasons)))
	{
		return false;
	}

	return TestTrue(TEXT("BlueprintImpact.AnalyzePinType should record the pin-type reason"), Reasons.Contains(AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason::PinType));
}

bool FAngelscriptBlueprintImpactAnalyzeNodeDependencyTest::RunTest(const FString& Parameters)
{
	UBlueprint* Blueprint = CreateTransientBlueprintChild(*this, UObject::StaticClass(), TEXT("NodeDependency"));
	ON_SCOPE_EXIT { CleanupBlueprint(Blueprint); };
	if (!TestNotNull(TEXT("BlueprintImpact.AnalyzeNodeDependency should create a blueprint"), Blueprint))
	{
		return false;
	}

	UK2Node_CallFunction* CallFunctionNode = AddCallFunctionNode(*Blueprint, UActorComponent::StaticClass()->FindFunctionByName(TEXT("K2_DestroyComponent")));
	if (!TestNotNull(TEXT("BlueprintImpact.AnalyzeNodeDependency should add a function node with external dependencies"), CallFunctionNode))
	{
		return false;
	}

	AngelscriptEditor::BlueprintImpact::FBlueprintImpactSymbols Symbols;
	Symbols.Classes.Add(UActorComponent::StaticClass());

	TArray<AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason> Reasons;
	if (!TestTrue(TEXT("BlueprintImpact.AnalyzeNodeDependency should detect nodes with impacted external dependencies"), AngelscriptEditor::BlueprintImpact::AnalyzeLoadedBlueprint(*Blueprint, Symbols, Reasons)))
	{
		return false;
	}

	return TestTrue(TEXT("BlueprintImpact.AnalyzeNodeDependency should record the node-dependency reason"), Reasons.Contains(AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason::NodeDependency));
}

bool FAngelscriptBlueprintImpactAnalyzeReferencedAssetTest::RunTest(const FString& Parameters)
{
	UBlueprint* Blueprint = CreateTransientBlueprintChild(*this, AActor::StaticClass(), TEXT("ReferencedAsset"));
	ON_SCOPE_EXIT { CleanupBlueprint(Blueprint); };
	if (!TestNotNull(TEXT("BlueprintImpact.AnalyzeReferencedAsset should create a blueprint"), Blueprint))
	{
		return false;
	}

	AngelscriptEditor::BlueprintImpact::FBlueprintImpactSymbols Symbols;
	Symbols.ReplacementObjects.Add(AActor::StaticClass(), UObject::StaticClass());

	TArray<AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason> Reasons;
	if (!TestTrue(TEXT("BlueprintImpact.AnalyzeReferencedAsset should detect blueprint references through replacement-object scanning"), AngelscriptEditor::BlueprintImpact::AnalyzeLoadedBlueprint(*Blueprint, Symbols, Reasons)))
	{
		return false;
	}

	return TestTrue(TEXT("BlueprintImpact.AnalyzeReferencedAsset should record the referenced-asset reason"), Reasons.Contains(AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason::ReferencedAsset));
}

bool FAngelscriptBlueprintImpactAnalyzeDelegateSignatureTest::RunTest(const FString& Parameters)
{
	UBlueprint* Blueprint = CreateTransientBlueprintChild(*this, UObject::StaticClass(), TEXT("DelegateSignature"));
	ON_SCOPE_EXIT { CleanupBlueprint(Blueprint); };
	if (!TestNotNull(TEXT("BlueprintImpact.AnalyzeDelegateSignature should create a blueprint"), Blueprint))
	{
		return false;
	}

	UEdGraph* EventGraph = FBlueprintEditorUtils::FindEventGraph(Blueprint);
	if (!TestNotNull(TEXT("BlueprintImpact.AnalyzeDelegateSignature should find the event graph"), EventGraph))
	{
		return false;
	}

	UK2Node_CustomEvent* CustomEventNode = NewObject<UK2Node_CustomEvent>(EventGraph);
	EventGraph->AddNode(CustomEventNode, false, false);
	CustomEventNode->CustomFunctionName = TEXT("BlueprintImpactDelegateSignatureEvent");
	CustomEventNode->CreateNewGuid();
	CustomEventNode->PostPlacedNewNode();
	CustomEventNode->AllocateDefaultPins();

	// UE 5.7: UK2Node_CustomEvent's EventReference is resolved during node
	// reconstruction plus a blueprint compile pass — only then does
	// FindEventSignatureFunction() return a non-null UDelegateFunction (the
	// skeleton-class signature the scanner matches on). Mirror the UI-driven
	// flow here so the scanner's Cast<UDelegateFunction> branch actually runs.
	CustomEventNode->ReconstructNode();
	FKismetEditorUtilities::CompileBlueprint(Blueprint);

	UDelegateFunction* SignatureFunction = Cast<UDelegateFunction>(CustomEventNode->FindEventSignatureFunction());
	if (!TestNotNull(TEXT("BlueprintImpact.AnalyzeDelegateSignature should expose a delegate signature function after reconstruct+compile"), SignatureFunction))
	{
		return false;
	}

	AngelscriptEditor::BlueprintImpact::FBlueprintImpactSymbols Symbols;
	Symbols.Delegates.Add(SignatureFunction);

	TArray<AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason> Reasons;
	if (!TestTrue(TEXT("BlueprintImpact.AnalyzeDelegateSignature should detect impacted event signature delegates"), AngelscriptEditor::BlueprintImpact::AnalyzeLoadedBlueprint(*Blueprint, Symbols, Reasons)))
	{
		return false;
	}

	return TestTrue(TEXT("BlueprintImpact.AnalyzeDelegateSignature should record the delegate-signature reason"), Reasons.Contains(AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason::DelegateSignature));
}

bool FAngelscriptBlueprintImpactFindBlueprintAssetsDiskBackedTest::RunTest(const FString& Parameters)
{
	FString PackagePath;
	FString PackageFilename;
	UBlueprint* Blueprint = CreateDiskBackedBlueprintChild(*this, AActor::StaticClass(), TEXT("DiskBackedEditor"), PackagePath, PackageFilename);
	ON_SCOPE_EXIT
	{
		if (!PackageFilename.IsEmpty())
		{
			IFileManager::Get().Delete(*PackageFilename, false, true, true);
		}
		CleanupBlueprint(Blueprint);
	};
	if (!TestNotNull(TEXT("BlueprintImpact.FindBlueprintAssetsDiskBacked should create a saved blueprint asset"), Blueprint))
	{
		return false;
	}

	FAssetRegistryModule& AssetRegistryModule = FModuleManager::LoadModuleChecked<FAssetRegistryModule>(TEXT("AssetRegistry"));
	AssetRegistryModule.Get().ScanModifiedAssetFiles({ PackageFilename });

	const TArray<FAssetData> Assets = AngelscriptEditor::BlueprintImpact::FindBlueprintAssets(AssetRegistryModule.Get(), true);
	return TestTrue(TEXT("BlueprintImpact.FindBlueprintAssetsDiskBacked should return the saved blueprint package when disk-only filtering is enabled"), Assets.ContainsByPredicate([&PackagePath](const FAssetData& AssetData)
	{
		return AssetData.PackageName.ToString() == PackagePath;
	}));
}

#endif
