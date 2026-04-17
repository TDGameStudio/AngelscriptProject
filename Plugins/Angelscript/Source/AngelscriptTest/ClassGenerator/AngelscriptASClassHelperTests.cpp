#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Components/ActorTestSpawner.h"
#include "Engine/Blueprint.h"
#include "Kismet2/KismetEditorUtilities.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/PackageName.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"
#include "UObject/Package.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ASClassHelperTest
{
	UBlueprint* CreateTransientBlueprintChild(
		FAutomationTestBase& Test,
		UClass* ParentClass,
		FStringView Suffix,
		const TCHAR* CallingContext = TEXT("AngelscriptASClassHelperTests"))
	{
		if (!Test.TestNotNull(TEXT("ASClass helper scenario should receive a valid script parent class"), ParentClass))
		{
			return nullptr;
		}

		const FString PackagePath = FString::Printf(
			TEXT("/Temp/AngelscriptASClassHelper_%.*s_%s"),
			Suffix.Len(),
			Suffix.GetData(),
			*FGuid::NewGuid().ToString(EGuidFormats::Digits));
		UPackage* BlueprintPackage = CreatePackage(*PackagePath);
		if (!Test.TestNotNull(TEXT("ASClass helper scenario should create a transient blueprint package"), BlueprintPackage))
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
			CallingContext);
		if (!Test.TestNotNull(TEXT("ASClass helper scenario should create a transient blueprint asset"), Blueprint))
		{
			return nullptr;
		}

		return Blueprint;
	}

	bool CompileAndValidateBlueprint(FAutomationTestBase& Test, UBlueprint& Blueprint)
	{
		FKismetEditorUtilities::CompileBlueprint(&Blueprint);
		return Test.TestNotNull(TEXT("ASClass helper scenario should compile the transient blueprint"), Blueprint.GeneratedClass.Get());
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

	struct FScopedTransientBlueprint
	{
		UBlueprint* BlueprintAsset = nullptr;

		~FScopedTransientBlueprint()
		{
			CleanupBlueprint(BlueprintAsset);
		}

		UClass* GetGeneratedClass() const
		{
			return BlueprintAsset != nullptr ? BlueprintAsset->GeneratedClass.Get() : nullptr;
		}
	};
}

using namespace ASClassHelperTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioASClassHierarchyHelpersResolveScriptAndNativeAncestorsTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.HierarchyHelpersResolveScriptAndNativeAncestors",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioASClassHierarchyHelpersResolveScriptAndNativeAncestorsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioASClassHierarchyHelpers"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptParentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioASClassHierarchyHelpers.as"),
		TEXT(R"AS(
UCLASS()
class AScriptHierarchyHelperParent : AActor
{
	UPROPERTY()
	int Marker = 17;
}
)AS"),
		TEXT("AScriptHierarchyHelperParent"));
	if (ScriptParentClass == nullptr)
	{
		return false;
	}

	UASClass* ScriptASClass = Cast<UASClass>(ScriptParentClass);
	if (!TestNotNull(TEXT("ASClass helper scenario should compile the script parent as a UASClass"), ScriptASClass))
	{
		return false;
	}

	ASClassHelperTest::FScopedTransientBlueprint Blueprint;
	Blueprint.BlueprintAsset = ASClassHelperTest::CreateTransientBlueprintChild(*this, ScriptParentClass, TEXT("HierarchyHelpers"));
	if (Blueprint.BlueprintAsset == nullptr)
	{
		return false;
	}

	if (!ASClassHelperTest::CompileAndValidateBlueprint(*this, *Blueprint.BlueprintAsset))
	{
		return false;
	}

	UClass* BlueprintChildClass = Blueprint.GetGeneratedClass();
	if (!TestNotNull(TEXT("ASClass helper scenario should produce a generated Blueprint child class"), BlueprintChildClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* BlueprintChildActor = SpawnScriptActor(*this, Spawner, BlueprintChildClass);
	if (!TestNotNull(TEXT("ASClass helper scenario should spawn the Blueprint child actor"), BlueprintChildActor))
	{
		return false;
	}

	UASClass* ScriptAncestorFromScriptClass = UASClass::GetFirstASClass(ScriptParentClass);
	UASClass* ScriptAncestorFromBlueprintClass = UASClass::GetFirstASClass(BlueprintChildClass);
	UASClass* ScriptAncestorFromBlueprintActor = UASClass::GetFirstASClass(BlueprintChildActor);
	UClass* ScriptOrNativeFromBlueprintClass = UASClass::GetFirstASOrNativeClass(BlueprintChildClass);
	UClass* ScriptOrNativeFromNativeActor = UASClass::GetFirstASOrNativeClass(AActor::StaticClass());

	TestTrue(TEXT("ASClass helper scenario should resolve the script parent from the script class itself"), ScriptAncestorFromScriptClass == ScriptParentClass);
	TestTrue(TEXT("ASClass helper scenario should resolve the script parent from the Blueprint child class"), ScriptAncestorFromBlueprintClass == ScriptParentClass);
	TestTrue(TEXT("ASClass helper scenario should resolve the script parent from the Blueprint child actor instance"), ScriptAncestorFromBlueprintActor == ScriptParentClass);
	TestTrue(TEXT("ASClass helper scenario should prefer the script ancestor over the generated Blueprint class"), ScriptOrNativeFromBlueprintClass == ScriptParentClass);
	TestTrue(TEXT("ASClass helper scenario should return AActor for native AActor fallback"), ScriptOrNativeFromNativeActor == AActor::StaticClass());
	ASTEST_END_SHARE_FRESH

	return true;
}

#endif
