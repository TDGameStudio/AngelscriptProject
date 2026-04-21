#include "BlueprintImpact/AngelscriptBlueprintImpactScanner.h"
#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "AssetRegistry/AssetRegistryModule.h"
#include "Engine/Blueprint.h"
#include "HAL/FileManager.h"
#include "Kismet2/KismetEditorUtilities.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/PackageName.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"
#include "UObject/Package.h"
#include "UObject/SavePackage.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace BlueprintImpactScenarioTest
{
	UBlueprint* CreateTransientBlueprintChild(FAutomationTestBase& Test, UClass* ParentClass, FStringView Suffix)
	{
		if (!Test.TestNotNull(TEXT("Blueprint impact scenario should receive a valid parent class"), ParentClass))
		{
			return nullptr;
		}

		const FString PackagePath = FString::Printf(
			TEXT("/Temp/AngelscriptBlueprintImpact_%.*s_%s"),
			Suffix.Len(),
			Suffix.GetData(),
			*FGuid::NewGuid().ToString(EGuidFormats::Digits));
		UPackage* BlueprintPackage = CreatePackage(*PackagePath);
		if (!Test.TestNotNull(TEXT("Blueprint impact scenario should create a transient package"), BlueprintPackage))
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
			TEXT("AngelscriptBlueprintImpactTests"));
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

		// A sibling CleanupBlueprint call earlier in the same ON_SCOPE_EXIT chain may
		// have triggered CollectGarbage and reaped our unreferenced UObjects already.
		// After GC, the C++ pointer can remain non-null while the UObject's InternalIndex
		// is -1, which makes MarkAsGarbage trip the `Index >= 0` assertion in
		// FUObjectArray::IndexToObject. IsValidLowLevel() checks the object against the
		// UObjectArray directly (not just IsValid flags), so it catches post-GC stale
		// pointers that IsValid() still approves.
		if (!Blueprint->IsValidLowLevel())
		{
			Blueprint = nullptr;
			return;
		}

		if (UClass* BlueprintClass = Blueprint->GeneratedClass)
		{
			if (BlueprintClass->IsValidLowLevel())
			{
				BlueprintClass->MarkAsGarbage();
			}
		}

		if (UPackage* BlueprintPackage = Blueprint->GetOutermost())
		{
			if (BlueprintPackage->IsValidLowLevel())
			{
				BlueprintPackage->MarkAsGarbage();
			}
		}

		Blueprint->MarkAsGarbage();
		CollectGarbage(RF_NoFlags, true);
		Blueprint = nullptr;
	}

	bool SaveBlueprintToDisk(FAutomationTestBase& Test, UBlueprint& Blueprint, const FString& PackagePath, FString& OutPackageFilename)
	{
		UPackage* Package = Blueprint.GetOutermost();
		if (!Test.TestNotNull(TEXT("Blueprint impact disk-backed scenario should have a package before save"), Package))
		{
			return false;
		}

		Package->SetDirtyFlag(true);
		OutPackageFilename = FPackageName::LongPackageNameToFilename(PackagePath, FPackageName::GetAssetPackageExtension());
		FSavePackageArgs SaveArgs;
		SaveArgs.TopLevelFlags = RF_Public | RF_Standalone;
		SaveArgs.SaveFlags = SAVE_NoError;
		return Test.TestTrue(
			TEXT("Blueprint impact disk-backed scenario should save the blueprint package to disk"),
			UPackage::SavePackage(Package, &Blueprint, *OutPackageFilename, SaveArgs));
	}

	UBlueprint* CreateDiskBackedBlueprintChild(
		FAutomationTestBase& Test,
		UClass* ParentClass,
		FStringView Suffix,
		FString& OutPackagePath,
		FString& OutPackageFilename)
	{
		if (!Test.TestNotNull(TEXT("Blueprint impact disk-backed scenario should receive a valid parent class"), ParentClass))
		{
			return nullptr;
		}

		const FString AssetName = FString::Printf(TEXT("BP_%.*s_%s"), Suffix.Len(), Suffix.GetData(), *FGuid::NewGuid().ToString(EGuidFormats::Digits));
		OutPackagePath = FString::Printf(TEXT("/Game/Automation/%s"), *AssetName);
		UPackage* BlueprintPackage = CreatePackage(*OutPackagePath);
		if (!Test.TestNotNull(TEXT("Blueprint impact disk-backed scenario should create a package"), BlueprintPackage))
		{
			return nullptr;
		}

		UBlueprint* Blueprint = FKismetEditorUtilities::CreateBlueprint(
			ParentClass,
			BlueprintPackage,
			FName(*AssetName),
			BPTYPE_Normal,
			UBlueprint::StaticClass(),
			UBlueprintGeneratedClass::StaticClass(),
			TEXT("AngelscriptBlueprintImpactTests"));
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

using namespace BlueprintImpactScenarioTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactScriptParentMatchTest,
	"Angelscript.TestModule.BlueprintImpact.ScriptParentMatch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactChangedScriptFilterTest,
	"Angelscript.TestModule.BlueprintImpact.ChangedScriptFilter",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintImpactDiskBackedAssetScanTest,
	"Angelscript.TestModule.BlueprintImpact.DiskBackedAssetScan",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptBlueprintImpactScriptParentMatchTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioBlueprintImpactScriptParentMatch"));
	UBlueprint* Blueprint = nullptr;
	ON_SCOPE_EXIT
	{
		BlueprintImpactScenarioTest::CleanupBlueprint(Blueprint);
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptParentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioBlueprintImpactScriptParentMatch.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioBlueprintImpactScriptParentMatch : AActor
{
	UPROPERTY()
	int Marker = 1;
}
)AS"),
		TEXT("AScenarioBlueprintImpactScriptParentMatch"));
	if (ScriptParentClass == nullptr)
	{
		return false;
	}

	Blueprint = BlueprintImpactScenarioTest::CreateTransientBlueprintChild(*this, ScriptParentClass, TEXT("ParentMatch"));
	if (!TestNotNull(TEXT("Blueprint impact scenario should create a child blueprint"), Blueprint))
	{
		return false;
	}

	const TArray<TSharedRef<FAngelscriptModuleDesc>> MatchingModules = AngelscriptEditor::BlueprintImpact::FindModulesForChangedScripts(
		Engine.GetActiveModules(),
		{ TEXT("ScenarioBlueprintImpactScriptParentMatch.as") });
	if (!TestEqual(TEXT("Blueprint impact scenario should resolve the changed script to exactly one active module"), MatchingModules.Num(), 1))
	{
		return false;
	}

	const AngelscriptEditor::BlueprintImpact::FBlueprintImpactSymbols Symbols = AngelscriptEditor::BlueprintImpact::BuildImpactSymbols(MatchingModules);
	TArray<AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason> Reasons;
	if (!TestTrue(TEXT("Blueprint impact scenario should mark the blueprint child as impacted by the script parent class"), AngelscriptEditor::BlueprintImpact::AnalyzeLoadedBlueprint(*Blueprint, Symbols, Reasons)))
	{
		return false;
	}

	TestTrue(TEXT("Blueprint impact scenario should record the script parent class reason"), Reasons.Contains(AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason::ScriptParentClass));

	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptBlueprintImpactChangedScriptFilterTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleA(TEXT("ScenarioBlueprintImpactFilterA"));
	static const FName ModuleB(TEXT("ScenarioBlueprintImpactFilterB"));
	UBlueprint* BlueprintA = nullptr;
	UBlueprint* BlueprintB = nullptr;
	ON_SCOPE_EXIT
	{
		BlueprintImpactScenarioTest::CleanupBlueprint(BlueprintA);
		BlueprintImpactScenarioTest::CleanupBlueprint(BlueprintB);
		Engine.DiscardModule(*ModuleA.ToString());
		Engine.DiscardModule(*ModuleB.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptParentA = CompileScriptModule(
		*this,
		Engine,
		ModuleA,
		TEXT("ScenarioBlueprintImpactFilterA.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioBlueprintImpactFilterA : AActor
{
	UPROPERTY()
	int Value = 1;
}
)AS"),
		TEXT("AScenarioBlueprintImpactFilterA"));
	if (ScriptParentA == nullptr)
	{
		return false;
	}

	UClass* ScriptParentB = CompileScriptModule(
		*this,
		Engine,
		ModuleB,
		TEXT("ScenarioBlueprintImpactFilterB.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioBlueprintImpactFilterB : AActor
{
	UPROPERTY()
	int Value = 2;
}
)AS"),
		TEXT("AScenarioBlueprintImpactFilterB"));
	if (ScriptParentB == nullptr)
	{
		return false;
	}

	BlueprintA = BlueprintImpactScenarioTest::CreateTransientBlueprintChild(*this, ScriptParentA, TEXT("FilterA"));
	BlueprintB = BlueprintImpactScenarioTest::CreateTransientBlueprintChild(*this, ScriptParentB, TEXT("FilterB"));
	if (!TestNotNull(TEXT("Blueprint impact filter scenario should create blueprint A"), BlueprintA)
		|| !TestNotNull(TEXT("Blueprint impact filter scenario should create blueprint B"), BlueprintB))
	{
		return false;
	}

	const TArray<TSharedRef<FAngelscriptModuleDesc>> MatchingModules = AngelscriptEditor::BlueprintImpact::FindModulesForChangedScripts(
		Engine.GetActiveModules(),
		{ TEXT("ScenarioBlueprintImpactFilterA.as") });
	if (!TestEqual(TEXT("Blueprint impact filter scenario should only keep the module matching the changed script"), MatchingModules.Num(), 1))
	{
		return false;
	}

	const AngelscriptEditor::BlueprintImpact::FBlueprintImpactSymbols Symbols = AngelscriptEditor::BlueprintImpact::BuildImpactSymbols(MatchingModules);

	TArray<AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason> BlueprintAReasons;
	TArray<AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason> BlueprintBReasons;
	const bool bBlueprintAImpacted = AngelscriptEditor::BlueprintImpact::AnalyzeLoadedBlueprint(*BlueprintA, Symbols, BlueprintAReasons);
	const bool bBlueprintBImpacted = AngelscriptEditor::BlueprintImpact::AnalyzeLoadedBlueprint(*BlueprintB, Symbols, BlueprintBReasons);

	if (!TestTrue(TEXT("Blueprint impact filter scenario should still mark the matching script-parent blueprint"), bBlueprintAImpacted))
	{
		return false;
	}

	TestFalse(TEXT("Blueprint impact filter scenario should not mark a blueprint whose script parent is unrelated to the changed script"), bBlueprintBImpacted);

	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptBlueprintImpactDiskBackedAssetScanTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioBlueprintImpactDiskBackedAssetScan"));
	UBlueprint* Blueprint = nullptr;
	FString PackagePath;
	FString PackageFilename;
	ON_SCOPE_EXIT
	{
		if (!PackageFilename.IsEmpty())
		{
			IFileManager::Get().Delete(*PackageFilename, false, true, true);
		}
		BlueprintImpactScenarioTest::CleanupBlueprint(Blueprint);
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptParentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioBlueprintImpactDiskBackedAssetScan.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioBlueprintImpactDiskBackedAssetScan : AActor
{
	UPROPERTY()
	int Marker = 10;
}
)AS"),
		TEXT("AScenarioBlueprintImpactDiskBackedAssetScan"));
	if (ScriptParentClass == nullptr)
	{
		return false;
	}

	Blueprint = BlueprintImpactScenarioTest::CreateDiskBackedBlueprintChild(
		*this,
		ScriptParentClass,
		TEXT("DiskBacked"),
		PackagePath,
		PackageFilename);
	if (!TestNotNull(TEXT("Blueprint impact disk-backed scenario should create a saved blueprint asset"), Blueprint))
	{
		return false;
	}

	FAssetRegistryModule& AssetRegistryModule = FModuleManager::LoadModuleChecked<FAssetRegistryModule>(TEXT("AssetRegistry"));
	AssetRegistryModule.Get().ScanModifiedAssetFiles({ PackageFilename });

	AngelscriptEditor::BlueprintImpact::FBlueprintImpactRequest Request;
	Request.ChangedScripts = { TEXT("ScenarioBlueprintImpactDiskBackedAssetScan.as") };
	const AngelscriptEditor::BlueprintImpact::FBlueprintImpactScanResult ScanResult = AngelscriptEditor::BlueprintImpact::ScanBlueprintAssets(
		Engine,
		AssetRegistryModule.Get(),
		Request);

	if (!TestTrue(TEXT("Blueprint impact disk-backed scenario should discover the saved blueprint asset as a candidate"), ScanResult.CandidateAssets.ContainsByPredicate([&PackagePath](const FAssetData& AssetData)
	{
		return AssetData.PackageName.ToString() == PackagePath;
	})))
	{
		return false;
	}

	return TestTrue(TEXT("Blueprint impact disk-backed scenario should mark the saved blueprint asset as impacted"), ScanResult.Matches.ContainsByPredicate([&PackagePath](const AngelscriptEditor::BlueprintImpact::FBlueprintImpactMatch& Match)
	{
		return Match.AssetData.PackageName.ToString() == PackagePath;
	}));

	ASTEST_END_SHARE_CLEAN
}

#endif
