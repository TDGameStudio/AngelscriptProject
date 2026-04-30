#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Components/ActorTestSpawner.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;

namespace AngelscriptTest_ClassGenerator_AngelscriptASClassTickSettingsTests_Private
{
	static const FName ASClassTickSettingsModuleName(TEXT("ASClassTickSettings"));
	static const FString ASClassTickSettingsFilename(TEXT("ASClassTickSettings.as"));
	static const FName ASClassTickParentName(TEXT("AScriptTickParent"));
	static const FName ASClassTickChildName(TEXT("AScriptTickChild"));
}


IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassTickSettingsEnableChildTickWhenReceiveTickIsImplementedTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.TickSettingsEnableChildTickWhenReceiveTickIsImplemented",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASClassTickSettingsEnableChildTickWhenReceiveTickIsImplementedTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptTest_ClassGenerator_AngelscriptASClassTickSettingsTests_Private;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASClassTickSettingsModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	// UE 5.7: AActor::ReceiveTick is no longer a BlueprintImplementableEvent.
	// Use Tick (the AngelScript-idiomatic name) instead.
	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class AScriptTickParent : AActor
{
}

UCLASS()
class AScriptTickChild : AScriptTickParent
{
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
	}
}
)AS");

	UClass* ChildClass = CompileScriptModule(
		*this,
		Engine,
		ASClassTickSettingsModuleName,
		ASClassTickSettingsFilename,
		ScriptSource,
		ASClassTickChildName);
	if (ChildClass == nullptr)
	{
		return false;
	}

	UASClass* ParentASClass = Cast<UASClass>(FindGeneratedClass(&Engine, ASClassTickParentName));
	UASClass* ChildASClass = Cast<UASClass>(ChildClass);
	if (!TestNotNull(TEXT("ASClass tick-settings test should resolve the generated parent UASClass"), ParentASClass)
		|| !TestNotNull(TEXT("ASClass tick-settings test should compile the child actor as a UASClass"), ChildASClass))
	{
		return false;
	}

	TestFalse(TEXT("ASClass tick-settings test should keep the parent class out of tick when it declares no tick overrides"), ParentASClass->bCanEverTick);

	TestTrue(TEXT("ASClass tick-settings test should enable tick on the child class when Tick is implemented"), ChildASClass->bCanEverTick);
	TestTrue(TEXT("ASClass tick-settings test should start the child class with tick enabled when Tick is implemented"), ChildASClass->bStartWithTickEnabled);

	// UE 5.7: CDO tick propagation for bCanEverTick is unreliable because
	// AActor's C++ constructor resets PrimaryActorTick.bCanEverTick after
	// StaticActorConstructor sets it. The UASClass-level flags are authoritative
	// and StaticActorConstructor applies them correctly at spawn-time.
	// Verify via a spawned actor instead of the CDO.
	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* SpawnedChild = SpawnScriptActor(*this, Spawner, ChildClass);
	if (!TestNotNull(TEXT("ASClass tick-settings test should spawn a child actor instance"), SpawnedChild))
	{
		return false;
	}

	TestTrue(TEXT("ASClass tick-settings test should propagate bCanEverTick onto a spawned child actor"), SpawnedChild->PrimaryActorTick.bCanEverTick);
	TestTrue(TEXT("ASClass tick-settings test should propagate bStartWithTickEnabled onto a spawned child actor"), SpawnedChild->PrimaryActorTick.bStartWithTickEnabled);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
