#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#define protected public
#define private public
#include "../../AngelscriptRuntime/Core/AngelscriptAbilityTaskLibrary.h"
#undef private
#undef protected

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptAbilityTaskLibraryAttributeTests_Private
{
	const FName HealthAttributeName = GET_MEMBER_NAME_CHECKED(UAngelscriptGASTestAttributeSet, Health);
	const FName MaxHealthAttributeName = GET_MEMBER_NAME_CHECKED(UAngelscriptGASTestAttributeSet, MaxHealth);

	constexpr float InitialHealthValue = 40.f;
	constexpr float MidHealthValue = 45.f;
	constexpr float ComparisonMatchHealthValue = 60.f;
	constexpr float InitialMaxHealthValue = 80.f;
	constexpr float ThresholdMatchMaxHealthValue = 120.f;
	constexpr float PostTriggerHealthValue = 70.f;
	constexpr float PostTriggerMaxHealthValue = 90.f;

	FGameplayAbilitySpec* FindAbilitySpec(
		UAngelscriptAbilitySystemComponent& AbilitySystemComponent,
		const FGameplayAbilitySpecHandle& Handle)
	{
		return AbilitySystemComponent.FindAbilitySpecFromHandle(Handle);
	}

	UAngelscriptGASTestAbility* GetPrimaryTestAbilityInstance(
		UAngelscriptAbilitySystemComponent& AbilitySystemComponent,
		const FGameplayAbilitySpecHandle& Handle)
	{
		FGameplayAbilitySpec* AbilitySpec = FindAbilitySpec(AbilitySystemComponent, Handle);
		if (AbilitySpec == nullptr)
		{
			return nullptr;
		}

		return Cast<UAngelscriptGASTestAbility>(AbilitySpec->GetPrimaryInstance());
	}

	bool ResolveGameplayAttribute(
		FAutomationTestBase& Test,
		const FName AttributeName,
		FGameplayAttribute& OutAttribute)
	{
		return Test.TestTrue(
			*FString::Printf(TEXT("AbilityTaskLibrary attribute wrapper test should resolve gameplay attribute '%s'"), *AttributeName.ToString()),
			UAngelscriptAttributeSet::TryGetGameplayAttribute(
				UAngelscriptGASTestAttributeSet::StaticClass(),
				AttributeName,
				OutAttribute));
	}

	bool SetAttributeBaseValue(
		FAutomationTestBase& Test,
		UAngelscriptAbilitySystemComponent& AbilitySystemComponent,
		const FName AttributeName,
		const float NewValue)
	{
		return Test.TestTrue(
			*FString::Printf(TEXT("AbilityTaskLibrary attribute wrapper test should set '%s' to %.2f"), *AttributeName.ToString(), NewValue),
			AbilitySystemComponent.TrySetAttributeBaseValue(
				UAngelscriptGASTestAttributeSet::StaticClass(),
				AttributeName,
				NewValue));
	}

	template<typename TaskType>
	bool ExpectTaskOwnershipAndExternalOwner(
		FAutomationTestBase& Test,
		const FString& Label,
		TaskType* Task,
		UGameplayAbility* ExpectedAbility,
		UAbilitySystemComponent* ExpectedOwnerASC,
		UAbilitySystemComponent* ExpectedExternalASC)
	{
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should return a task"), *Label), Task))
		{
			return false;
		}

		Test.TestTrue(
			*FString::Printf(TEXT("%s should keep the owning ability"), *Label),
			Task->Ability == ExpectedAbility);
		Test.TestTrue(
			*FString::Printf(TEXT("%s should keep the owner ASC"), *Label),
			Task->AbilitySystemComponent.Get() == ExpectedOwnerASC);
		Test.TestTrue(
			*FString::Printf(TEXT("%s should store the external owner ASC"), *Label),
			Task->ExternalOwner == ExpectedExternalASC);
		return true;
	}
}

using namespace AngelscriptTest_Core_AngelscriptAbilityTaskLibraryAttributeTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAbilityTaskLibraryAttributeWrappersTest,
	"Angelscript.TestModule.Engine.GASAbilityTaskLibrary.AttributeWrappersHonorThresholdsAndExternalOwner",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAbilityTaskLibraryAttributeWrappersTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* OwnerActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	AAngelscriptGASTestActor* ExternalActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("AttributeWrappers owner actor should spawn"), OwnerActor) ||
		!TestNotNull(TEXT("AttributeWrappers external actor should spawn"), ExternalActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* OwnerASC = OwnerActor->AbilitySystemComponent;
	UAngelscriptAbilitySystemComponent* ExternalASC = ExternalActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("AttributeWrappers owner ASC should exist"), OwnerASC) ||
		!TestNotNull(TEXT("AttributeWrappers external ASC should exist"), ExternalASC))
	{
		return false;
	}

	OwnerASC->InitAbilityActorInfo(OwnerActor, OwnerActor);
	ExternalASC->InitAbilityActorInfo(ExternalActor, ExternalActor);

	UAngelscriptAttributeSet* AttributeSet =
		ExternalASC->RegisterAttributeSet(UAngelscriptGASTestAttributeSet::StaticClass());
	if (!TestNotNull(TEXT("AttributeWrappers should register a test attribute set on the external ASC"), AttributeSet))
	{
		return false;
	}

	FGameplayAttribute HealthAttribute;
	FGameplayAttribute MaxHealthAttribute;
	if (!ResolveGameplayAttribute(*this, HealthAttributeName, HealthAttribute) ||
		!ResolveGameplayAttribute(*this, MaxHealthAttributeName, MaxHealthAttribute))
	{
		return false;
	}

	if (!SetAttributeBaseValue(*this, *ExternalASC, HealthAttributeName, InitialHealthValue) ||
		!SetAttributeBaseValue(*this, *ExternalASC, MaxHealthAttributeName, InitialMaxHealthValue))
	{
		return false;
	}

	const FGameplayAbilitySpecHandle AbilityHandle =
		OwnerASC->BP_GiveAbility(UAngelscriptGASTestAbility::StaticClass(), 1, 0, nullptr);
	if (!TestTrue(TEXT("AttributeWrappers should grant a valid ability handle"), AbilityHandle.IsValid()))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		if (OwnerASC != nullptr && AbilityHandle.IsValid())
		{
			OwnerASC->CancelAbilityByHandle(AbilityHandle);
		}
	};

	if (!TestTrue(TEXT("AttributeWrappers should activate the granted ability"), OwnerASC->TryActivateAbilitySpec(AbilityHandle)))
	{
		return false;
	}

	UAngelscriptGASTestAbility* AbilityInstance = GetPrimaryTestAbilityInstance(*OwnerASC, AbilityHandle);
	if (!TestNotNull(TEXT("AttributeWrappers should resolve the primary ability instance"), AbilityInstance))
	{
		return false;
	}

	UAbilityTask_WaitAttributeChange* PlainTask =
		UAngelscriptAbilityTaskLibrary::WaitForAttributeChange(
			AbilityInstance,
			HealthAttribute,
			FGameplayTag(),
			FGameplayTag(),
			true,
			ExternalActor);
	UAbilityTask_WaitAttributeChange* ComparisonTask =
		UAngelscriptAbilityTaskLibrary::WaitForAttributeChangeWithComparison(
			AbilityInstance,
			HealthAttribute,
			FGameplayTag(),
			FGameplayTag(),
			EWaitAttributeChangeComparison::GreaterThan,
			50.f,
			true,
			ExternalActor);
	UAbilityTask_WaitAttributeChangeThreshold* ThresholdTask =
		UAngelscriptAbilityTaskLibrary::WaitForAttributeChangeThreshold(
			AbilityInstance,
			MaxHealthAttribute,
			EWaitAttributeChangeComparison::GreaterThanOrEqualTo,
			100.f,
			true,
			ExternalActor);

	if (!ExpectTaskOwnershipAndExternalOwner(*this, TEXT("WaitForAttributeChange"), PlainTask, AbilityInstance, OwnerASC, ExternalASC) ||
		!ExpectTaskOwnershipAndExternalOwner(*this, TEXT("WaitForAttributeChangeWithComparison"), ComparisonTask, AbilityInstance, OwnerASC, ExternalASC) ||
		!ExpectTaskOwnershipAndExternalOwner(*this, TEXT("WaitForAttributeChangeThreshold"), ThresholdTask, AbilityInstance, OwnerASC, ExternalASC))
	{
		return false;
	}

	TestEqual(TEXT("WaitForAttributeChange should preserve the observed attribute"), PlainTask->Attribute, HealthAttribute);
	TestEqual(TEXT("WaitForAttributeChange should use the native task type"), PlainTask->GetClass(), UAbilityTask_WaitAttributeChange::StaticClass());
	TestEqual(TEXT("WaitForAttributeChange should keep comparison type at None"), PlainTask->ComparisonType.GetValue(), static_cast<int32>(EWaitAttributeChangeComparison::None));
	TestTrue(TEXT("WaitForAttributeChange should preserve trigger-once true"), PlainTask->bTriggerOnce);

	TestEqual(TEXT("WaitForAttributeChangeWithComparison should preserve the observed attribute"), ComparisonTask->Attribute, HealthAttribute);
	TestEqual(TEXT("WaitForAttributeChangeWithComparison should use the native task type"), ComparisonTask->GetClass(), UAbilityTask_WaitAttributeChange::StaticClass());
	TestEqual(TEXT("WaitForAttributeChangeWithComparison should preserve comparison type"), ComparisonTask->ComparisonType.GetValue(), static_cast<int32>(EWaitAttributeChangeComparison::GreaterThan));
	TestEqual(TEXT("WaitForAttributeChangeWithComparison should preserve comparison value"), ComparisonTask->ComparisonValue, 50.f);
	TestTrue(TEXT("WaitForAttributeChangeWithComparison should preserve trigger-once true"), ComparisonTask->bTriggerOnce);

	TestEqual(TEXT("WaitForAttributeChangeThreshold should preserve the observed attribute"), ThresholdTask->Attribute, MaxHealthAttribute);
	TestEqual(TEXT("WaitForAttributeChangeThreshold should use the native task type"), ThresholdTask->GetClass(), UAbilityTask_WaitAttributeChangeThreshold::StaticClass());
	TestEqual(TEXT("WaitForAttributeChangeThreshold should preserve comparison type"), ThresholdTask->ComparisonType.GetValue(), static_cast<int32>(EWaitAttributeChangeComparison::GreaterThanOrEqualTo));
	TestEqual(TEXT("WaitForAttributeChangeThreshold should preserve comparison value"), ThresholdTask->ComparisonValue, 100.f);
	TestTrue(TEXT("WaitForAttributeChangeThreshold should preserve trigger-once true"), ThresholdTask->bTriggerOnce);

	UAngelscriptGASTestAsyncListener* PlainListener =
		NewObject<UAngelscriptGASTestAsyncListener>(OwnerActor, TEXT("AttributePlainListener"));
	UAngelscriptGASTestAsyncListener* ComparisonListener =
		NewObject<UAngelscriptGASTestAsyncListener>(OwnerActor, TEXT("AttributeComparisonListener"));
	UAngelscriptGASTestAttributeThresholdListener* ThresholdListener =
		NewObject<UAngelscriptGASTestAttributeThresholdListener>(OwnerActor, TEXT("AttributeThresholdListener"));
	if (!TestNotNull(TEXT("WaitForAttributeChange should create a plain listener"), PlainListener) ||
		!TestNotNull(TEXT("WaitForAttributeChangeWithComparison should create a comparison listener"), ComparisonListener) ||
		!TestNotNull(TEXT("WaitForAttributeChangeThreshold should create a threshold listener"), ThresholdListener))
	{
		return false;
	}

	PlainTask->OnChange.AddDynamic(PlainListener, &UAngelscriptGASTestAsyncListener::HandleTriggered);
	ComparisonTask->OnChange.AddDynamic(ComparisonListener, &UAngelscriptGASTestAsyncListener::HandleTriggered);
	ThresholdTask->OnChange.AddDynamic(ThresholdListener, &UAngelscriptGASTestAttributeThresholdListener::RecordThresholdChange);

	PlainTask->ReadyForActivation();
	ComparisonTask->ReadyForActivation();
	ThresholdTask->ReadyForActivation();

	TestEqual(TEXT("WaitForAttributeChange should stay idle before Health changes"), PlainListener->TriggerCount, 0);
	TestEqual(TEXT("WaitForAttributeChangeWithComparison should stay idle before Health exceeds the threshold"), ComparisonListener->TriggerCount, 0);
	TestEqual(TEXT("WaitForAttributeChangeThreshold should broadcast the initial false threshold state"), ThresholdListener->CallbackCount, 1);
	TestFalse(TEXT("WaitForAttributeChangeThreshold should report the initial threshold match as false"), ThresholdListener->bLastMatchesComparison);
	TestEqual(TEXT("WaitForAttributeChangeThreshold should report the initial MaxHealth value"), ThresholdListener->LastValue, InitialMaxHealthValue);

	if (!SetAttributeBaseValue(*this, *ExternalASC, HealthAttributeName, MidHealthValue))
	{
		return false;
	}

	TestEqual(TEXT("WaitForAttributeChange should fire once on the first Health update"), PlainListener->TriggerCount, 1);
	TestEqual(TEXT("WaitForAttributeChangeWithComparison should ignore Health values that stay below the threshold"), ComparisonListener->TriggerCount, 0);
	TestEqual(TEXT("WaitForAttributeChangeThreshold should not react to Health-only updates"), ThresholdListener->CallbackCount, 1);

	if (!SetAttributeBaseValue(*this, *ExternalASC, HealthAttributeName, ComparisonMatchHealthValue))
	{
		return false;
	}

	TestEqual(TEXT("WaitForAttributeChange should not fire again after its one-shot broadcast"), PlainListener->TriggerCount, 1);
	TestEqual(TEXT("WaitForAttributeChangeWithComparison should fire once when Health exceeds 50"), ComparisonListener->TriggerCount, 1);

	if (!SetAttributeBaseValue(*this, *ExternalASC, MaxHealthAttributeName, ThresholdMatchMaxHealthValue))
	{
		return false;
	}

	TestEqual(TEXT("WaitForAttributeChangeThreshold should fire again when MaxHealth reaches the threshold"), ThresholdListener->CallbackCount, 2);
	TestTrue(TEXT("WaitForAttributeChangeThreshold should report the threshold transition as matched"), ThresholdListener->bLastMatchesComparison);
	TestEqual(TEXT("WaitForAttributeChangeThreshold should report the updated MaxHealth value"), ThresholdListener->LastValue, ThresholdMatchMaxHealthValue);

	UAbilityTask_WaitAttributeChangeRatioThreshold* RatioTask =
		UAngelscriptAbilityTaskLibrary::WaitForAttributeChangeRatioThreshold(
			AbilityInstance,
			HealthAttribute,
			MaxHealthAttribute,
			EWaitAttributeChangeComparison::LessThanOrEqualTo,
			0.5f,
			true,
			ExternalActor);
	if (!ExpectTaskOwnershipAndExternalOwner(*this, TEXT("WaitForAttributeChangeRatioThreshold"), RatioTask, AbilityInstance, OwnerASC, ExternalASC))
	{
		return false;
	}

	TestEqual(TEXT("WaitForAttributeChangeRatioThreshold should preserve the numerator attribute"), RatioTask->AttributeNumerator, HealthAttribute);
	TestEqual(TEXT("WaitForAttributeChangeRatioThreshold should preserve the denominator attribute"), RatioTask->AttributeDenominator, MaxHealthAttribute);
	TestEqual(TEXT("WaitForAttributeChangeRatioThreshold should use the native task type"), RatioTask->GetClass(), UAbilityTask_WaitAttributeChangeRatioThreshold::StaticClass());
	TestEqual(TEXT("WaitForAttributeChangeRatioThreshold should preserve comparison type"), RatioTask->ComparisonType.GetValue(), static_cast<int32>(EWaitAttributeChangeComparison::LessThanOrEqualTo));
	TestEqual(TEXT("WaitForAttributeChangeRatioThreshold should preserve comparison value"), RatioTask->ComparisonValue, 0.5f);
	TestTrue(TEXT("WaitForAttributeChangeRatioThreshold should preserve trigger-once true"), RatioTask->bTriggerOnce);

	UAngelscriptGASTestAttributeRatioListener* RatioListener =
		NewObject<UAngelscriptGASTestAttributeRatioListener>(OwnerActor, TEXT("AttributeRatioListener"));
	if (!TestNotNull(TEXT("WaitForAttributeChangeRatioThreshold should create a ratio listener"), RatioListener))
	{
		return false;
	}

	RatioTask->OnChange.AddDynamic(RatioListener, &UAngelscriptGASTestAttributeRatioListener::RecordRatioChange);
	RatioTask->ReadyForActivation();

	TestEqual(TEXT("WaitForAttributeChangeRatioThreshold should broadcast once with the current external-owner ratio"), RatioListener->CallbackCount, 1);
	TestTrue(TEXT("WaitForAttributeChangeRatioThreshold should report the current ratio as matching"), RatioListener->bLastMatchesComparison);
	TestEqual(TEXT("WaitForAttributeChangeRatioThreshold should report the current Health/MaxHealth ratio"), RatioListener->LastRatio, 0.5f);

	if (!SetAttributeBaseValue(*this, *ExternalASC, HealthAttributeName, PostTriggerHealthValue) ||
		!SetAttributeBaseValue(*this, *ExternalASC, MaxHealthAttributeName, PostTriggerMaxHealthValue))
	{
		return false;
	}

	TestEqual(TEXT("WaitForAttributeChange should stay at one callback after ending"), PlainListener->TriggerCount, 1);
	TestEqual(TEXT("WaitForAttributeChangeWithComparison should stay at one callback after ending"), ComparisonListener->TriggerCount, 1);
	TestEqual(TEXT("WaitForAttributeChangeThreshold should stay at two callbacks after ending"), ThresholdListener->CallbackCount, 2);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
