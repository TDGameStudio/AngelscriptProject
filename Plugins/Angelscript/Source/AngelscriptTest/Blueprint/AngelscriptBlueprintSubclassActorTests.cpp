#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Engine/Blueprint.h"
#include "Engine/World.h"
#include "GameFramework/WorldSettings.h"
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

namespace BlueprintSubclassActorTest
{
	constexpr float ScenarioTickDeltaTime = 0.016f;
	constexpr int32 ScenarioTickCount = 3;

	UBlueprint* CreateTransientBlueprintChild(FAutomationTestBase& Test, UClass* ParentClass, FStringView Suffix)
	{
		if (!Test.TestNotNull(TEXT("Blueprint parent class should be valid"), ParentClass))
		{
			return nullptr;
		}

		const FString PackagePath = FString::Printf(
			TEXT("/Temp/Angelscript_%.*s_%s"),
			Suffix.Len(),
			Suffix.GetData(),
			*FGuid::NewGuid().ToString(EGuidFormats::Digits));
		UPackage* BlueprintPackage = CreatePackage(*PackagePath);
		if (!Test.TestNotNull(TEXT("Blueprint package should be created"), BlueprintPackage))
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
			TEXT("AngelscriptBlueprintSubclassActorTests"));
		if (!Test.TestNotNull(TEXT("Blueprint asset should be created"), Blueprint))
		{
			return nullptr;
		}

		FKismetEditorUtilities::CompileBlueprint(Blueprint);
		if (!Test.TestNotNull(TEXT("Blueprint should compile to a generated class"), Blueprint->GeneratedClass.Get()))
		{
			return nullptr;
		}

		return Blueprint;
	}

	void BeginPlayWorld(FAngelscriptEngine& Engine, UWorld& World)
	{
		if (!World.HasBegunPlay())
		{
			AWorldSettings* WorldSettings = World.GetWorldSettings();
			if (WorldSettings != nullptr)
			{
				FAngelscriptEngineScope WorldScope(Engine, WorldSettings);
				WorldSettings->NotifyBeginPlay();
			}
		}
	}

}

using namespace BlueprintSubclassActorTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioBlueprintSubclassBeginPlayTest,
	"Angelscript.TestModule.Actor.BlueprintSubclassBeginPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioBlueprintSubclassBeginPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioActorBlueprintSubclassBeginPlay"));
	UBlueprint* Blueprint = nullptr;
	ON_SCOPE_EXIT
	{
		if (Blueprint != nullptr)
		{
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
		}

		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioActorBlueprintSubclassBeginPlay.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorBlueprintSubclassBeginPlay : AActor
{
	UPROPERTY()
	int BeginPlayCalled = 0;

	UPROPERTY()
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCalled += 1;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount += 1;
	}
}
)AS"),
		TEXT("AScenarioActorBlueprintSubclassBeginPlay"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	Blueprint = BlueprintSubclassActorTest::CreateTransientBlueprintChild(*this, ScriptClass, TEXT("BeginPlayChild"));
	if (Blueprint == nullptr)
	{
		return false;
	}

	UClass* BlueprintClass = Blueprint->GeneratedClass;
	if (!TestNotNull(TEXT("Blueprint child class should exist after compilation"), BlueprintClass))
	{
		return false;
	}

	TestTrue(TEXT("Blueprint child should inherit from the script actor class"), BlueprintClass->IsChildOf(ScriptClass));

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, BlueprintClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BlueprintSubclassActorTest::BeginPlayWorld(Engine, Spawner.GetWorld());

	int32 BeginPlayCalled = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("BeginPlayCalled"), BeginPlayCalled))
	{
		return false;
	}

	TestEqual(
		TEXT("World-level BeginPlay should dispatch inherited script BeginPlay to blueprint subclass actors"),
		BeginPlayCalled,
		1);

	TickWorld(Engine, Spawner.GetWorld(), BlueprintSubclassActorTest::ScenarioTickDeltaTime, BlueprintSubclassActorTest::ScenarioTickCount);

	int32 TickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("TickCount"), TickCount))
	{
		return false;
	}

	TestTrue(
		TEXT("World-level Tick should dispatch inherited script Tick to blueprint subclass actors at least once per world tick"),
		TickCount >= BlueprintSubclassActorTest::ScenarioTickCount);

	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
