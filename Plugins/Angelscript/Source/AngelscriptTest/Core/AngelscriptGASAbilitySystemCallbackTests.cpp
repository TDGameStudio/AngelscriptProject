#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptGASAbilitySystemCallbackTests_Private
{
	const FName HealthAttributeName = GET_MEMBER_NAME_CHECKED(UAngelscriptGASTestAttributeSet, Health);
	const float InitialHealthValue = 10.f;
	const float UpdatedHealthValue = 25.f;

	bool InitializeAttributeCallbackFixture(
		FAutomationTestBase& Test,
		FActorTestSpawner& Spawner,
		const TCHAR* Context,
		AAngelscriptGASTestActor*& OutActor,
		UAngelscriptAbilitySystemComponent*& OutAbilitySystemComponent)
	{
		OutActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should spawn a test actor"), Context),
				OutActor))
		{
			return false;
		}

		OutAbilitySystemComponent = OutActor->AbilitySystemComponent;
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should expose an ability-system component"), Context),
				OutAbilitySystemComponent))
		{
			return false;
		}

		OutAbilitySystemComponent->InitAbilityActorInfo(OutActor, OutActor);

		UAngelscriptAttributeSet* AttributeSet =
			OutAbilitySystemComponent->RegisterAttributeSet(UAngelscriptGASTestAttributeSet::StaticClass());
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should register a test attribute set"), Context),
				AttributeSet))
		{
			return false;
		}

		return Test.TestTrue(
			*FString::Printf(TEXT("%s should seed the Health attribute to the expected baseline"), Context),
			OutAbilitySystemComponent->TrySetAttributeBaseValue(
				UAngelscriptGASTestAttributeSet::StaticClass(),
				HealthAttributeName,
				InitialHealthValue));
	}
}

using namespace AngelscriptTest_Core_AngelscriptGASAbilitySystemCallbackTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASAbilitySystemAttributeCallbackTest,
	"Angelscript.TestModule.Engine.GAS.AbilitySystem.AttributeCallbacksDeduplicateAndReportValues",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASAbilitySystemAttributeCallbackTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* DirectActor = nullptr;
	UAngelscriptAbilitySystemComponent* DirectAbilitySystemComponent = nullptr;
	if (!InitializeAttributeCallbackFixture(
			*this,
			Spawner,
			TEXT("Direct attribute callback fixture"),
			DirectActor,
			DirectAbilitySystemComponent))
	{
		return false;
	}

	UAngelscriptGASTestAttributeChangedListener* DirectListener =
		NewObject<UAngelscriptGASTestAttributeChangedListener>(DirectActor, TEXT("AttributeChangedListener"));
	if (!TestNotNull(TEXT("Direct attribute callback scenario should create a listener"), DirectListener))
	{
		return false;
	}

	float FirstReportedCurrentValue = 0.f;
	DirectAbilitySystemComponent->GetAndRegisterAttributeChangedCallback(
		UAngelscriptGASTestAttributeSet::StaticClass(),
		HealthAttributeName,
		DirectListener,
		GET_FUNCTION_NAME_CHECKED(UAngelscriptGASTestAttributeChangedListener, RecordAttributeChanged),
		FirstReportedCurrentValue);
	TestEqual(
		TEXT("First GetAndRegisterAttributeChangedCallback call should report the seeded Health value"),
		FirstReportedCurrentValue,
		InitialHealthValue);

	float SecondReportedCurrentValue = -1.f;
	DirectAbilitySystemComponent->GetAndRegisterAttributeChangedCallback(
		UAngelscriptGASTestAttributeSet::StaticClass(),
		HealthAttributeName,
		DirectListener,
		GET_FUNCTION_NAME_CHECKED(UAngelscriptGASTestAttributeChangedListener, RecordAttributeChanged),
		SecondReportedCurrentValue);
	TestEqual(
		TEXT("Repeated GetAndRegisterAttributeChangedCallback calls should keep returning the current Health value"),
		SecondReportedCurrentValue,
		InitialHealthValue);
	TestEqual(
		TEXT("Registering the same direct listener twice should not invoke the callback eagerly"),
		DirectListener->CallbackCount,
		0);

	if (!TestTrue(
			TEXT("Updating Health after direct callback registration should succeed"),
			DirectAbilitySystemComponent->TrySetAttributeBaseValue(
				UAngelscriptGASTestAttributeSet::StaticClass(),
				HealthAttributeName,
				UpdatedHealthValue)))
	{
		return false;
	}

	TestEqual(TEXT("Direct callback should only fire once after duplicate registration"), DirectListener->CallbackCount, 1);
	TestEqual(TEXT("Direct callback should report the Health attribute name"), DirectListener->LastAttributeName, HealthAttributeName);
	TestEqual(TEXT("Direct callback should report the previous Health value"), DirectListener->LastOldValue, InitialHealthValue);
	TestEqual(TEXT("Direct callback should report the updated Health value"), DirectListener->LastNewValue, UpdatedHealthValue);

	AAngelscriptGASTestActor* DeprecatedActor = nullptr;
	UAngelscriptAbilitySystemComponent* DeprecatedAbilitySystemComponent = nullptr;
	if (!InitializeAttributeCallbackFixture(
			*this,
			Spawner,
			TEXT("Deprecated attribute callback fixture"),
			DeprecatedActor,
			DeprecatedAbilitySystemComponent))
	{
		return false;
	}

	UAngelscriptGASTestModifiedAttributeListener* DeprecatedListener =
		NewObject<UAngelscriptGASTestModifiedAttributeListener>(DeprecatedActor, TEXT("ModifiedAttributeListener"));
	if (!TestNotNull(TEXT("Deprecated attribute callback scenario should create an OnAttributeChanged listener"), DeprecatedListener))
	{
		return false;
	}

	DeprecatedAbilitySystemComponent->OnAttributeChanged.AddDynamic(
		DeprecatedListener,
		&UAngelscriptGASTestModifiedAttributeListener::RecordModifiedAttribute);

	float FirstDeprecatedCurrentValue = 0.f;
PRAGMA_DISABLE_DEPRECATION_WARNINGS
	DeprecatedAbilitySystemComponent->GetAndRegisterCallbackForAttribute(
		UAngelscriptGASTestAttributeSet::StaticClass(),
		HealthAttributeName,
		FirstDeprecatedCurrentValue);
	TestEqual(
		TEXT("Deprecated GetAndRegisterCallbackForAttribute should report the seeded Health value"),
		FirstDeprecatedCurrentValue,
		InitialHealthValue);

	float SecondDeprecatedCurrentValue = -1.f;
	DeprecatedAbilitySystemComponent->GetAndRegisterCallbackForAttribute(
		UAngelscriptGASTestAttributeSet::StaticClass(),
		HealthAttributeName,
		SecondDeprecatedCurrentValue);
PRAGMA_ENABLE_DEPRECATION_WARNINGS
	TestEqual(
		TEXT("Repeated deprecated registrations should keep reporting the current Health value"),
		SecondDeprecatedCurrentValue,
		InitialHealthValue);
	TestEqual(
		TEXT("Deprecated callback registration should not broadcast before any value change"),
		DeprecatedListener->BroadcastCount,
		0);

	if (!TestTrue(
			TEXT("Updating Health after deprecated callback registration should succeed"),
			DeprecatedAbilitySystemComponent->TrySetAttributeBaseValue(
				UAngelscriptGASTestAttributeSet::StaticClass(),
				HealthAttributeName,
				UpdatedHealthValue)))
	{
		return false;
	}

	TestEqual(TEXT("Deprecated trampoline should broadcast once after duplicate registration"), DeprecatedListener->BroadcastCount, 1);
	TestEqual(TEXT("Deprecated trampoline should report the Health attribute name"), DeprecatedListener->LastAttributeName, HealthAttributeName);
	TestEqual(TEXT("Deprecated trampoline should report the previous Health value"), DeprecatedListener->LastOldValue, InitialHealthValue);
	TestEqual(TEXT("Deprecated trampoline should report the updated Health value"), DeprecatedListener->LastNewValue, UpdatedHealthValue);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
