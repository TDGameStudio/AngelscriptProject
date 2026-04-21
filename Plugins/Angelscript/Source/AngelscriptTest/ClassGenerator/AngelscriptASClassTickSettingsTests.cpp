#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_ClassGenerator_AngelscriptASClassTickSettingsTests_Private
{
	static const FName ASClassTickSettingsModuleName(TEXT("ASClassTickSettings"));
	static const FString ASClassTickSettingsFilename(TEXT("ASClassTickSettings.as"));
	static const FName ASClassTickParentName(TEXT("AScriptTickParent"));
	static const FName ASClassTickChildName(TEXT("AScriptTickChild"));
}

using namespace AngelscriptTest_ClassGenerator_AngelscriptASClassTickSettingsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassTickSettingsEnableChildTickWhenReceiveTickIsImplementedTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.TickSettingsEnableChildTickWhenReceiveTickIsImplemented",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#ue57-blueprint): ReceiveTick BlueprintOverride not found in parent on UE 5.7; check AActor tick event registration

bool FAngelscriptASClassTickSettingsEnableChildTickWhenReceiveTickIsImplementedTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASClassTickSettingsModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class AScriptTickParent : AActor
{
}

UCLASS()
class AScriptTickChild : AScriptTickParent
{
	UFUNCTION(BlueprintOverride)
	void ReceiveTick(float DeltaTime)
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
	AActor* ParentCDO = ParentASClass != nullptr ? ParentASClass->GetDefaultObject<AActor>() : nullptr;
	AActor* ChildCDO = ChildASClass != nullptr ? ChildASClass->GetDefaultObject<AActor>() : nullptr;
	if (!TestNotNull(TEXT("ASClass tick-settings test should resolve the generated parent UASClass"), ParentASClass)
		|| !TestNotNull(TEXT("ASClass tick-settings test should compile the child actor as a UASClass"), ChildASClass)
		|| !TestNotNull(TEXT("ASClass tick-settings test should expose the parent actor CDO"), ParentCDO)
		|| !TestNotNull(TEXT("ASClass tick-settings test should expose the child actor CDO"), ChildCDO))
	{
		return false;
	}

	TestFalse(TEXT("ASClass tick-settings test should keep the parent class out of tick when it declares no tick overrides"), ParentASClass->bCanEverTick);
	TestFalse(TEXT("ASClass tick-settings test should keep the parent CDO tick-disabled"), ParentCDO->PrimaryActorTick.bCanEverTick);

	TestTrue(TEXT("ASClass tick-settings test should enable tick on the child class when ReceiveTick is implemented"), ChildASClass->bCanEverTick);
	TestTrue(TEXT("ASClass tick-settings test should start the child class with tick enabled when ReceiveTick is implemented"), ChildASClass->bStartWithTickEnabled);
	TestTrue(TEXT("ASClass tick-settings test should propagate bCanEverTick onto the child actor CDO"), ChildCDO->PrimaryActorTick.bCanEverTick);
	TestTrue(TEXT("ASClass tick-settings test should propagate bStartWithTickEnabled onto the child actor CDO"), ChildCDO->PrimaryActorTick.bStartWithTickEnabled);
	ASTEST_END_SHARE_FRESH

	return true;
}

#endif
