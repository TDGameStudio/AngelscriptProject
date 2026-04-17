#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#define protected public
#define private public
#include "../../AngelscriptRuntime/Core/AngelscriptAbilityTaskLibrary.h"
#undef private
#undef protected

#include "Abilities/GameplayAbilityTargetActor_Radius.h"
#include "Abilities/GameplayAbilityTargetTypes.h"
#include "Components/ActorTestSpawner.h"
#include "Curves/CurveFloat.h"
#include "Curves/CurveVector.h"
#include "GameFramework/Character.h"
#include "GameplayTagsManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "TimerManager.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptAbilityTaskLibraryTests_Private
{
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

	bool GetAnyGameplayTag(FAutomationTestBase& Test, FGameplayTag& OutTag)
	{
		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);
		if (!Test.TestTrue(TEXT("AbilityTaskLibrary wrapper test requires at least one registered gameplay tag"), AllTags.Num() > 0))
		{
			return false;
		}

		OutTag = AllTags.First();
		return true;
	}

	bool GetAnyUnrelatedGameplayTags(
		FAutomationTestBase& Test,
		FGameplayTag& OutPrimaryTag,
		FGameplayTag& OutSecondaryTag)
	{
		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);

		TArray<FGameplayTag> TagArray;
		AllTags.GetGameplayTagArray(TagArray);

		for (const FGameplayTag& CandidatePrimaryTag : TagArray)
		{
			if (!CandidatePrimaryTag.IsValid())
			{
				continue;
			}

			for (const FGameplayTag& CandidateSecondaryTag : TagArray)
			{
				if (!CandidateSecondaryTag.IsValid() || CandidateSecondaryTag == CandidatePrimaryTag)
				{
					continue;
				}

				if (CandidatePrimaryTag.MatchesTag(CandidateSecondaryTag)
					|| CandidateSecondaryTag.MatchesTag(CandidatePrimaryTag))
				{
					continue;
				}

				OutPrimaryTag = CandidatePrimaryTag;
				OutSecondaryTag = CandidateSecondaryTag;
				return true;
			}
		}

		Test.AddError(TEXT("AbilityTaskLibrary wrapper test requires two unrelated gameplay tags"));
		return false;
	}

	template<typename TObjectType>
	TObjectType* ReadObjectProperty(
		FAutomationTestBase& Test,
		const UObject& Object,
		const TCHAR* PropertyName)
	{
		const FObjectPropertyBase* Property = FindFProperty<FObjectPropertyBase>(Object.GetClass(), PropertyName);
		if (!Test.TestNotNull(*FString::Printf(TEXT("Expected reflected property '%s' on %s"), PropertyName, *Object.GetClass()->GetName()), Property))
		{
			return nullptr;
		}

		return Cast<TObjectType>(Property->GetObjectPropertyValue_InContainer(&Object));
	}

	FGameplayAbilityTargetDataHandle MakeActorArrayTargetData(const TArray<AActor*>& Actors)
	{
		FGameplayAbilityTargetData_ActorArray* TargetData = new FGameplayAbilityTargetData_ActorArray();
		for (AActor* Actor : Actors)
		{
			TargetData->TargetActorArray.Add(Actor);
		}

		FGameplayAbilityTargetDataHandle Handle;
		Handle.Add(TargetData);
		return Handle;
	}

	FGameplayTargetDataFilterHandle MakeTargetDataFilterHandle(
		AActor* SelfActor,
		TSubclassOf<AActor> RequiredActorClass,
		const ETargetDataFilterSelf::Type SelfFilter,
		const bool bReverseFilter)
	{
		FGameplayTargetDataFilterHandle Handle;
		Handle.Filter = MakeShared<FGameplayTargetDataFilter>();
		Handle.Filter->SelfActor = SelfActor;
		Handle.Filter->RequiredActorClass = RequiredActorClass;
		Handle.Filter->SelfFilter = SelfFilter;
		Handle.Filter->bReverseFilter = bReverseFilter;
		return Handle;
	}

	template<typename TTaskType>
	bool ExpectTaskOwnershipWithoutInstanceName(
		FAutomationTestBase& Test,
		const FString& Label,
		TTaskType* Task,
		UGameplayAbility* ExpectedAbility,
		UAbilitySystemComponent* ExpectedASC,
		const FGameplayAbilitySpecHandle& ExpectedHandle)
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
			Task->AbilitySystemComponent.Get() == ExpectedASC);
		Test.TestTrue(
			*FString::Printf(TEXT("%s should preserve the granted ability spec handle"), *Label),
			Task->GetAbilitySpecHandle() == ExpectedHandle);
		return true;
	}

	bool ExpectFilterHandle(
		FAutomationTestBase& Test,
		const FString& Label,
		const FGameplayTargetDataFilterHandle& Actual,
		const FGameplayTargetDataFilterHandle& Expected)
	{
		const bool bHasActualFilter = Actual.Filter.IsValid();
		const bool bHasExpectedFilter = Expected.Filter.IsValid();
		Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve filter validity"), *Label),
			bHasActualFilter,
			bHasExpectedFilter);
		if (!bHasActualFilter || !bHasExpectedFilter)
		{
			return bHasActualFilter == bHasExpectedFilter;
		}

		Test.TestTrue(
			*FString::Printf(TEXT("%s should preserve the filter shared pointer"), *Label),
			Actual.Filter == Expected.Filter);
		Test.TestTrue(
			*FString::Printf(TEXT("%s should preserve the filter self actor"), *Label),
			Actual.Filter->SelfActor == Expected.Filter->SelfActor);
		Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the filter required actor class"), *Label),
			Actual.Filter->RequiredActorClass,
			Expected.Filter->RequiredActorClass);
		Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the filter self mode"), *Label),
			Actual.Filter->SelfFilter.GetValue(),
			Expected.Filter->SelfFilter.GetValue());
		Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the filter reverse flag"), *Label),
			Actual.Filter->bReverseFilter,
			Expected.Filter->bReverseFilter);
		return true;
	}

	template<typename TTaskType>
	bool ExpectTaskOwnership(
		FAutomationTestBase& Test,
		const FString& Label,
		TTaskType* Task,
		UGameplayAbility* ExpectedAbility,
		UAbilitySystemComponent* ExpectedASC,
		const FGameplayAbilitySpecHandle& ExpectedHandle,
		const FName ExpectedInstanceName)
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
			Task->AbilitySystemComponent.Get() == ExpectedASC);
		Test.TestTrue(
			*FString::Printf(TEXT("%s should preserve the granted ability spec handle"), *Label),
			Task->GetAbilitySpecHandle() == ExpectedHandle);
		Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the provided instance name"), *Label),
			Task->GetInstanceName(),
			ExpectedInstanceName);
		return true;
	}
}

using namespace AngelscriptTest_Core_AngelscriptAbilityTaskLibraryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAbilityTaskLibraryRepresentativeWrappersTest,
	"Angelscript.TestModule.Engine.GASAbilityTaskLibrary.RepresentativeWrappersReturnExpectedTaskTypes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAbilityTaskLibraryRepresentativeWrappersTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FGameplayTag ObservedTag;
	if (!GetAnyGameplayTag(*this, ObservedTag))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* OwnerActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("AbilityTaskLibrary wrapper test owner actor should spawn"), OwnerActor))
	{
		return false;
	}

	AAngelscriptGASTestActor* ExternalActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("AbilityTaskLibrary wrapper test external actor should spawn"), ExternalActor))
	{
		return false;
	}

	AGameplayAbilityTargetActor_Radius* TargetActor = &Spawner.SpawnActor<AGameplayAbilityTargetActor_Radius>();
	if (!TestNotNull(TEXT("AbilityTaskLibrary wrapper test target actor should spawn"), TargetActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* OwnerASC = OwnerActor->AbilitySystemComponent;
	UAngelscriptAbilitySystemComponent* ExternalASC = ExternalActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("AbilityTaskLibrary wrapper test owner ASC should exist"), OwnerASC) ||
		!TestNotNull(TEXT("AbilityTaskLibrary wrapper test external ASC should exist"), ExternalASC))
	{
		return false;
	}

	OwnerASC->InitAbilityActorInfo(OwnerActor, OwnerActor);
	ExternalASC->InitAbilityActorInfo(ExternalActor, ExternalActor);

	const FGameplayAbilitySpecHandle AbilityHandle =
		OwnerASC->BP_GiveAbility(UAngelscriptGASTestAbility::StaticClass(), 1, 0, nullptr);
	if (!TestTrue(TEXT("AbilityTaskLibrary wrapper test should grant a valid ability handle"), AbilityHandle.IsValid()))
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

	if (!TestTrue(TEXT("AbilityTaskLibrary wrapper test should activate the granted ability"), OwnerASC->TryActivateAbilitySpec(AbilityHandle)))
	{
		return false;
	}

	UAngelscriptGASTestAbility* AbilityInstance = GetPrimaryTestAbilityInstance(*OwnerASC, AbilityHandle);
	if (!TestNotNull(TEXT("AbilityTaskLibrary wrapper test should resolve the primary ability instance"), AbilityInstance))
	{
		return false;
	}

	const FGameplayTagQuery Query = FGameplayTagQuery::MakeQuery_MatchTag(ObservedTag);
	if (!TestFalse(TEXT("AbilityTaskLibrary wrapper test query should not be empty"), Query.IsEmpty()))
	{
		return false;
	}

	UAbilityTask_WaitDelay* WaitDelayTask = UAngelscriptAbilityTaskLibrary::WaitDelay(AbilityInstance, 0.5f);
	UAbilityTask_WaitGameplayEvent* WaitGameplayEventTask =
		UAngelscriptAbilityTaskLibrary::WaitGameplayEvent(AbilityInstance, ObservedTag, ExternalActor, true, false);
	UAbilityTask_WaitGameplayTagAdded* WaitGameplayTagAddTask =
		UAngelscriptAbilityTaskLibrary::WaitGameplayTagAdd(AbilityInstance, ObservedTag, ExternalActor, true);
	UAbilityTask_WaitGameplayTagRemoved* WaitGameplayTagRemoveTask =
		UAngelscriptAbilityTaskLibrary::WaitGameplayTagRemove(AbilityInstance, ObservedTag, ExternalActor, false);
	UAbilityTask_WaitGameplayTagQuery* WaitGameplayTagQueryTask =
		UAngelscriptAbilityTaskLibrary::WaitGameplayTagQuery(
			AbilityInstance,
			Query,
			ExternalActor,
			EWaitGameplayTagQueryTriggerCondition::WhenTrue,
			true);
	UAbilityTask_WaitInputPress* WaitInputPressTask = UAngelscriptAbilityTaskLibrary::WaitInputPress(AbilityInstance, true);
	UAbilityTask_WaitInputRelease* WaitInputReleaseTask = UAngelscriptAbilityTaskLibrary::WaitInputRelease(AbilityInstance, false);
	UAbilityTask_WaitTargetData* WaitTargetDataTask =
		UAngelscriptAbilityTaskLibrary::WaitTargetDataUsingActor(
			AbilityInstance,
			TEXT("RepresentativeTargetDataTask"),
			EGameplayTargetingConfirmation::UserConfirmed,
			TargetActor);

	if (!TestNotNull(TEXT("WaitDelay should return a task"), WaitDelayTask) ||
		!TestNotNull(TEXT("WaitGameplayEvent should return a task"), WaitGameplayEventTask) ||
		!TestNotNull(TEXT("WaitGameplayTagAdd should return a task"), WaitGameplayTagAddTask) ||
		!TestNotNull(TEXT("WaitGameplayTagRemove should return a task"), WaitGameplayTagRemoveTask) ||
		!TestNotNull(TEXT("WaitGameplayTagQuery should return a task"), WaitGameplayTagQueryTask) ||
		!TestNotNull(TEXT("WaitInputPress should return a task"), WaitInputPressTask) ||
		!TestNotNull(TEXT("WaitInputRelease should return a task"), WaitInputReleaseTask) ||
		!TestNotNull(TEXT("WaitTargetDataUsingActor should return a task"), WaitTargetDataTask))
	{
		return false;
	}

	TestTrue(TEXT("WaitDelay should return the native wait-delay task class"), WaitDelayTask->GetClass() == UAbilityTask_WaitDelay::StaticClass());
	TestTrue(TEXT("WaitGameplayEvent should return the native gameplay-event task class"), WaitGameplayEventTask->GetClass() == UAbilityTask_WaitGameplayEvent::StaticClass());
	TestTrue(TEXT("WaitGameplayTagAdd should return the native gameplay-tag-added task class"), WaitGameplayTagAddTask->GetClass() == UAbilityTask_WaitGameplayTagAdded::StaticClass());
	TestTrue(TEXT("WaitGameplayTagRemove should return the native gameplay-tag-removed task class"), WaitGameplayTagRemoveTask->GetClass() == UAbilityTask_WaitGameplayTagRemoved::StaticClass());
	TestTrue(TEXT("WaitGameplayTagQuery should return the native gameplay-tag-query task class"), WaitGameplayTagQueryTask->GetClass() == UAbilityTask_WaitGameplayTagQuery::StaticClass());
	TestTrue(TEXT("WaitInputPress should return the native input-press task class"), WaitInputPressTask->GetClass() == UAbilityTask_WaitInputPress::StaticClass());
	TestTrue(TEXT("WaitInputRelease should return the native input-release task class"), WaitInputReleaseTask->GetClass() == UAbilityTask_WaitInputRelease::StaticClass());
	TestTrue(TEXT("WaitTargetDataUsingActor should return the native target-data task class"), WaitTargetDataTask->GetClass() == UAbilityTask_WaitTargetData::StaticClass());

	TestTrue(TEXT("WaitDelay should keep the owning ability"), WaitDelayTask->Ability == AbilityInstance);
	TestTrue(TEXT("WaitGameplayEvent should keep the owning ability"), WaitGameplayEventTask->Ability == AbilityInstance);
	TestTrue(TEXT("WaitGameplayTagAdd should keep the owning ability"), WaitGameplayTagAddTask->Ability == AbilityInstance);
	TestTrue(TEXT("WaitGameplayTagRemove should keep the owning ability"), WaitGameplayTagRemoveTask->Ability == AbilityInstance);
	TestTrue(TEXT("WaitGameplayTagQuery should keep the owning ability"), WaitGameplayTagQueryTask->Ability == AbilityInstance);
	TestTrue(TEXT("WaitInputPress should keep the owning ability"), WaitInputPressTask->Ability == AbilityInstance);
	TestTrue(TEXT("WaitInputRelease should keep the owning ability"), WaitInputReleaseTask->Ability == AbilityInstance);
	TestTrue(TEXT("WaitTargetDataUsingActor should keep the owning ability"), WaitTargetDataTask->Ability == AbilityInstance);

	TestTrue(TEXT("WaitDelay should keep the owner ASC"), WaitDelayTask->AbilitySystemComponent.Get() == OwnerASC);
	TestTrue(TEXT("WaitGameplayEvent should keep the owner ASC"), WaitGameplayEventTask->AbilitySystemComponent.Get() == OwnerASC);
	TestTrue(TEXT("WaitGameplayTagAdd should keep the owner ASC"), WaitGameplayTagAddTask->AbilitySystemComponent.Get() == OwnerASC);
	TestTrue(TEXT("WaitGameplayTagRemove should keep the owner ASC"), WaitGameplayTagRemoveTask->AbilitySystemComponent.Get() == OwnerASC);
	TestTrue(TEXT("WaitGameplayTagQuery should keep the owner ASC"), WaitGameplayTagQueryTask->AbilitySystemComponent.Get() == OwnerASC);
	TestTrue(TEXT("WaitInputPress should keep the owner ASC"), WaitInputPressTask->AbilitySystemComponent.Get() == OwnerASC);
	TestTrue(TEXT("WaitInputRelease should keep the owner ASC"), WaitInputReleaseTask->AbilitySystemComponent.Get() == OwnerASC);
	TestTrue(TEXT("WaitTargetDataUsingActor should keep the owner ASC"), WaitTargetDataTask->AbilitySystemComponent.Get() == OwnerASC);

	TestTrue(TEXT("WaitDelay should preserve the granted ability spec handle"), WaitDelayTask->GetAbilitySpecHandle() == AbilityHandle);
	TestEqual(TEXT("WaitGameplayEvent should preserve the observed event tag"), WaitGameplayEventTask->Tag, ObservedTag);
	TestEqual(TEXT("WaitGameplayTagAdd should preserve the observed gameplay tag"), WaitGameplayTagAddTask->Tag, ObservedTag);
	TestEqual(TEXT("WaitGameplayTagRemove should preserve the observed gameplay tag"), WaitGameplayTagRemoveTask->Tag, ObservedTag);
	TestEqual(TEXT("WaitTargetDataUsingActor should preserve the provided task instance name"), WaitTargetDataTask->GetInstanceName(), FName(TEXT("RepresentativeTargetDataTask")));

	TestTrue(
		TEXT("WaitGameplayEvent should resolve the external target actor to its ASC"),
		ReadObjectProperty<UAbilitySystemComponent>(*this, *WaitGameplayEventTask, TEXT("OptionalExternalTarget")) == ExternalASC);
	TestTrue(
		TEXT("WaitGameplayTagAdd should resolve the external target actor to its ASC"),
		ReadObjectProperty<UAbilitySystemComponent>(*this, *WaitGameplayTagAddTask, TEXT("OptionalExternalTarget")) == ExternalASC);
	TestTrue(
		TEXT("WaitGameplayTagRemove should resolve the external target actor to its ASC"),
		ReadObjectProperty<UAbilitySystemComponent>(*this, *WaitGameplayTagRemoveTask, TEXT("OptionalExternalTarget")) == ExternalASC);
	TestTrue(
		TEXT("WaitGameplayTagQuery should resolve the external target actor to its ASC"),
		ReadObjectProperty<UAbilitySystemComponent>(*this, *WaitGameplayTagQueryTask, TEXT("OptionalExternalTarget")) == ExternalASC);
	TestTrue(
		TEXT("WaitTargetDataUsingActor should preserve the provided target actor"),
		ReadObjectProperty<AGameplayAbilityTargetActor>(*this, *WaitTargetDataTask, TEXT("TargetActor")) == TargetActor);

	ASTEST_END_SHARE_CLEAN
	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAbilityTaskLibraryGameplayEffectWatcherWrappersTest,
	"Angelscript.TestModule.Engine.GASAbilityTaskLibrary.GameplayEffectWatchWrappersRouteOwnerFiltersAndHandles",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAbilityTaskLibraryGameplayEffectWatcherWrappersTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FGameplayTag PrimaryTag;
	FGameplayTag SecondaryTag;
	if (!GetAnyUnrelatedGameplayTags(*this, PrimaryTag, SecondaryTag))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* OwnerActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	AAngelscriptGASTestActor* ExternalActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GameplayEffectWatchWrappers owner actor should spawn"), OwnerActor) ||
		!TestNotNull(TEXT("GameplayEffectWatchWrappers external actor should spawn"), ExternalActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* OwnerASC = OwnerActor->AbilitySystemComponent;
	UAngelscriptAbilitySystemComponent* ExternalASC = ExternalActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GameplayEffectWatchWrappers owner ASC should exist"), OwnerASC) ||
		!TestNotNull(TEXT("GameplayEffectWatchWrappers external ASC should exist"), ExternalASC))
	{
		return false;
	}

	OwnerASC->InitAbilityActorInfo(OwnerActor, OwnerActor);
	ExternalASC->InitAbilityActorInfo(ExternalActor, ExternalActor);

	const FGameplayAbilitySpecHandle AbilityHandle =
		OwnerASC->BP_GiveAbility(UAngelscriptGASTestAbility::StaticClass(), 1, 0, nullptr);
	if (!TestTrue(TEXT("GameplayEffectWatchWrappers should grant a valid ability handle"), AbilityHandle.IsValid()))
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

	if (!TestTrue(TEXT("GameplayEffectWatchWrappers should activate the granted ability"), OwnerASC->TryActivateAbilitySpec(AbilityHandle)))
	{
		return false;
	}

	UAngelscriptGASTestAbility* AbilityInstance = GetPrimaryTestAbilityInstance(*OwnerASC, AbilityHandle);
	if (!TestNotNull(TEXT("GameplayEffectWatchWrappers should resolve the primary ability instance"), AbilityInstance))
	{
		return false;
	}

	const FGameplayTargetDataFilterHandle SelfFilter =
		MakeTargetDataFilterHandle(OwnerActor, AAngelscriptGASTestActor::StaticClass(), ETargetDataFilterSelf::TDFS_NoOthers, false);
	const FGameplayTargetDataFilterHandle TargetFilter =
		MakeTargetDataFilterHandle(ExternalActor, AActor::StaticClass(), ETargetDataFilterSelf::TDFS_NoSelf, true);

	FGameplayTagRequirements SelfSourceRequirements;
	SelfSourceRequirements.RequireTags.AddTag(PrimaryTag);
	FGameplayTagRequirements SelfTargetRequirements;
	SelfTargetRequirements.IgnoreTags.AddTag(SecondaryTag);
	FGameplayTagRequirements TargetSourceRequirements;
	TargetSourceRequirements.IgnoreTags.AddTag(PrimaryTag);
	FGameplayTagRequirements TargetTargetRequirements;
	TargetTargetRequirements.RequireTags.AddTag(SecondaryTag);
	FGameplayTagRequirements ImmunitySourceRequirements;
	ImmunitySourceRequirements.RequireTags.AddTag(PrimaryTag);
	FGameplayTagRequirements ImmunityTargetRequirements;
	ImmunityTargetRequirements.IgnoreTags.AddTag(SecondaryTag);

	const FGameplayTagQuery SelfSourceQuery = FGameplayTagQuery::MakeQuery_MatchTag(PrimaryTag);
	const FGameplayTagQuery SelfTargetQuery = FGameplayTagQuery::MakeQuery_MatchTag(SecondaryTag);
	const FGameplayTagQuery TargetSourceQuery = FGameplayTagQuery::MakeQuery_MatchTag(SecondaryTag);
	const FGameplayTagQuery TargetTargetQuery = FGameplayTagQuery::MakeQuery_MatchTag(PrimaryTag);

	UAngelscriptGASTestCooldownEffect* CooldownEffect = NewObject<UAngelscriptGASTestCooldownEffect>(GetTransientPackage());
	if (!TestNotNull(TEXT("GameplayEffectWatchWrappers should create a cooldown effect"), CooldownEffect))
	{
		return false;
	}

#pragma warning(push)
#pragma warning(disable: 4996)
	CooldownEffect->StackingType = EGameplayEffectStackingType::AggregateByTarget;
#pragma warning(pop)
	CooldownEffect->StackLimitCount = 2;

	const FGameplayEffectContextHandle EffectContext = OwnerASC->MakeEffectContext();
	FGameplayEffectSpec AppliedSpec(CooldownEffect, EffectContext, 1.f);
	AppliedSpec.SetDuration(30.f, true);
	AppliedSpec.SetStackCount(2);

	const FActiveGameplayEffectHandle AppliedHandle = OwnerASC->ApplyGameplayEffectSpecToSelf(AppliedSpec);
	if (!TestTrue(TEXT("GameplayEffectWatchWrappers should create an active gameplay-effect handle"), AppliedHandle.IsValid()))
	{
		return false;
	}

	UAbilityTask_WaitGameplayEffectApplied_Self* SelfRequirementsTask =
		UAngelscriptAbilityTaskLibrary::WaitGameplayEffectAppliedToSelf(
			AbilityInstance,
			SelfFilter,
			SelfSourceRequirements,
			SelfTargetRequirements,
			false,
			ExternalActor,
			true);
	UAbilityTask_WaitGameplayEffectApplied_Self* SelfQueryTask =
		UAngelscriptAbilityTaskLibrary::WaitGameplayEffectAppliedToSelfQuery(
			AbilityInstance,
			SelfFilter,
			SelfSourceQuery,
			SelfTargetQuery,
			true,
			ExternalActor,
			false);
	UAbilityTask_WaitGameplayEffectApplied_Target* TargetRequirementsTask =
		UAngelscriptAbilityTaskLibrary::WaitGameplayEffectAppliedToTarget(
			AbilityInstance,
			TargetFilter,
			TargetSourceRequirements,
			TargetTargetRequirements,
			true,
			ExternalActor,
			false);
	UAbilityTask_WaitGameplayEffectApplied_Target* TargetQueryTask =
		UAngelscriptAbilityTaskLibrary::WaitGameplayEffectAppliedToTargetQuery(
			AbilityInstance,
			TargetFilter,
			TargetSourceQuery,
			TargetTargetQuery,
			false,
			ExternalActor,
			true);
	UAbilityTask_WaitGameplayEffectBlockedImmunity* BlockedTask =
		UAngelscriptAbilityTaskLibrary::WaitGameplayEffectBlockedByImmunity(
			AbilityInstance,
			ImmunitySourceRequirements,
			ImmunityTargetRequirements,
			ExternalActor,
			true);
	UAbilityTask_WaitGameplayEffectRemoved* RemovedTask =
		UAngelscriptAbilityTaskLibrary::WaitForGameplayEffectRemoved(AbilityInstance, AppliedHandle);
	UAbilityTask_WaitGameplayEffectStackChange* StackTask =
		UAngelscriptAbilityTaskLibrary::WaitForGameplayEffectStackChange(AbilityInstance, AppliedHandle);

	if (!ExpectTaskOwnershipWithoutInstanceName(*this, TEXT("WaitGameplayEffectAppliedToSelf"), SelfRequirementsTask, AbilityInstance, OwnerASC, AbilityHandle) ||
		!ExpectTaskOwnershipWithoutInstanceName(*this, TEXT("WaitGameplayEffectAppliedToSelfQuery"), SelfQueryTask, AbilityInstance, OwnerASC, AbilityHandle) ||
		!ExpectTaskOwnershipWithoutInstanceName(*this, TEXT("WaitGameplayEffectAppliedToTarget"), TargetRequirementsTask, AbilityInstance, OwnerASC, AbilityHandle) ||
		!ExpectTaskOwnershipWithoutInstanceName(*this, TEXT("WaitGameplayEffectAppliedToTargetQuery"), TargetQueryTask, AbilityInstance, OwnerASC, AbilityHandle) ||
		!ExpectTaskOwnershipWithoutInstanceName(*this, TEXT("WaitGameplayEffectBlockedByImmunity"), BlockedTask, AbilityInstance, OwnerASC, AbilityHandle) ||
		!ExpectTaskOwnershipWithoutInstanceName(*this, TEXT("WaitForGameplayEffectRemoved"), RemovedTask, AbilityInstance, OwnerASC, AbilityHandle) ||
		!ExpectTaskOwnershipWithoutInstanceName(*this, TEXT("WaitForGameplayEffectStackChange"), StackTask, AbilityInstance, OwnerASC, AbilityHandle))
	{
		return false;
	}

	TestTrue(TEXT("WaitGameplayEffectAppliedToSelf should return the native self watcher task class"), SelfRequirementsTask->GetClass() == UAbilityTask_WaitGameplayEffectApplied_Self::StaticClass());
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelfQuery should return the native self watcher task class"), SelfQueryTask->GetClass() == UAbilityTask_WaitGameplayEffectApplied_Self::StaticClass());
	TestTrue(TEXT("WaitGameplayEffectAppliedToTarget should return the native target watcher task class"), TargetRequirementsTask->GetClass() == UAbilityTask_WaitGameplayEffectApplied_Target::StaticClass());
	TestTrue(TEXT("WaitGameplayEffectAppliedToTargetQuery should return the native target watcher task class"), TargetQueryTask->GetClass() == UAbilityTask_WaitGameplayEffectApplied_Target::StaticClass());
	TestTrue(TEXT("WaitGameplayEffectBlockedByImmunity should return the native immunity watcher task class"), BlockedTask->GetClass() == UAbilityTask_WaitGameplayEffectBlockedImmunity::StaticClass());
	TestTrue(TEXT("WaitForGameplayEffectRemoved should return the native removed watcher task class"), RemovedTask->GetClass() == UAbilityTask_WaitGameplayEffectRemoved::StaticClass());
	TestTrue(TEXT("WaitForGameplayEffectStackChange should return the native stack watcher task class"), StackTask->GetClass() == UAbilityTask_WaitGameplayEffectStackChange::StaticClass());

	ExpectFilterHandle(*this, TEXT("WaitGameplayEffectAppliedToSelf"), SelfRequirementsTask->Filter, SelfFilter);
	ExpectFilterHandle(*this, TEXT("WaitGameplayEffectAppliedToSelfQuery"), SelfQueryTask->Filter, SelfFilter);
	ExpectFilterHandle(*this, TEXT("WaitGameplayEffectAppliedToTarget"), TargetRequirementsTask->Filter, TargetFilter);
	ExpectFilterHandle(*this, TEXT("WaitGameplayEffectAppliedToTargetQuery"), TargetQueryTask->Filter, TargetFilter);

	TestEqual(TEXT("WaitGameplayEffectAppliedToSelf should preserve source tag requirements"), SelfRequirementsTask->SourceTagRequirements, SelfSourceRequirements);
	TestEqual(TEXT("WaitGameplayEffectAppliedToSelf should preserve target tag requirements"), SelfRequirementsTask->TargetTagRequirements, SelfTargetRequirements);
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelf should leave source tag query empty"), SelfRequirementsTask->SourceTagQuery.IsEmpty());
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelf should leave target tag query empty"), SelfRequirementsTask->TargetTagQuery.IsEmpty());
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelf should leave asset tag requirements empty"), SelfRequirementsTask->AssetTagRequirements.IsEmpty());
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelf should leave granted tag requirements empty"), SelfRequirementsTask->GrantedTagRequirements.IsEmpty());
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelf should use the external owner ASC"), SelfRequirementsTask->UseExternalOwner && SelfRequirementsTask->ExternalOwner == ExternalASC);
	TestFalse(TEXT("WaitGameplayEffectAppliedToSelf should preserve trigger-once false"), SelfRequirementsTask->TriggerOnce);
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelf should preserve periodic-listen true"), SelfRequirementsTask->ListenForPeriodicEffects);

	TestEqual(TEXT("WaitGameplayEffectAppliedToSelfQuery should preserve source tag query"), SelfQueryTask->SourceTagQuery, SelfSourceQuery);
	TestEqual(TEXT("WaitGameplayEffectAppliedToSelfQuery should preserve target tag query"), SelfQueryTask->TargetTagQuery, SelfTargetQuery);
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelfQuery should leave source tag requirements empty"), SelfQueryTask->SourceTagRequirements.IsEmpty());
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelfQuery should leave target tag requirements empty"), SelfQueryTask->TargetTagRequirements.IsEmpty());
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelfQuery should use the external owner ASC"), SelfQueryTask->UseExternalOwner && SelfQueryTask->ExternalOwner == ExternalASC);
	TestTrue(TEXT("WaitGameplayEffectAppliedToSelfQuery should preserve trigger-once true"), SelfQueryTask->TriggerOnce);
	TestFalse(TEXT("WaitGameplayEffectAppliedToSelfQuery should preserve periodic-listen false"), SelfQueryTask->ListenForPeriodicEffects);

	TestEqual(TEXT("WaitGameplayEffectAppliedToTarget should preserve source tag requirements"), TargetRequirementsTask->SourceTagRequirements, TargetSourceRequirements);
	TestEqual(TEXT("WaitGameplayEffectAppliedToTarget should preserve target tag requirements"), TargetRequirementsTask->TargetTagRequirements, TargetTargetRequirements);
	TestTrue(TEXT("WaitGameplayEffectAppliedToTarget should leave source tag query empty"), TargetRequirementsTask->SourceTagQuery.IsEmpty());
	TestTrue(TEXT("WaitGameplayEffectAppliedToTarget should leave target tag query empty"), TargetRequirementsTask->TargetTagQuery.IsEmpty());
	TestTrue(TEXT("WaitGameplayEffectAppliedToTarget should use the external owner ASC"), TargetRequirementsTask->UseExternalOwner && TargetRequirementsTask->ExternalOwner == ExternalASC);
	TestTrue(TEXT("WaitGameplayEffectAppliedToTarget should preserve trigger-once true"), TargetRequirementsTask->TriggerOnce);
	TestFalse(TEXT("WaitGameplayEffectAppliedToTarget should preserve periodic-listen false"), TargetRequirementsTask->ListenForPeriodicEffects);

	TestEqual(TEXT("WaitGameplayEffectAppliedToTargetQuery should preserve source tag query"), TargetQueryTask->SourceTagQuery, TargetSourceQuery);
	TestEqual(TEXT("WaitGameplayEffectAppliedToTargetQuery should preserve target tag query"), TargetQueryTask->TargetTagQuery, TargetTargetQuery);
	TestTrue(TEXT("WaitGameplayEffectAppliedToTargetQuery should leave source tag requirements empty"), TargetQueryTask->SourceTagRequirements.IsEmpty());
	TestTrue(TEXT("WaitGameplayEffectAppliedToTargetQuery should leave target tag requirements empty"), TargetQueryTask->TargetTagRequirements.IsEmpty());
	TestTrue(TEXT("WaitGameplayEffectAppliedToTargetQuery should use the external owner ASC"), TargetQueryTask->UseExternalOwner && TargetQueryTask->ExternalOwner == ExternalASC);
	TestFalse(TEXT("WaitGameplayEffectAppliedToTargetQuery should preserve trigger-once false"), TargetQueryTask->TriggerOnce);
	TestTrue(TEXT("WaitGameplayEffectAppliedToTargetQuery should preserve periodic-listen true"), TargetQueryTask->ListenForPeriodicEffects);

	TestEqual(TEXT("WaitGameplayEffectBlockedByImmunity should preserve source tag requirements"), BlockedTask->SourceTagRequirements, ImmunitySourceRequirements);
	TestEqual(TEXT("WaitGameplayEffectBlockedByImmunity should preserve target tag requirements"), BlockedTask->TargetTagRequirements, ImmunityTargetRequirements);
	TestTrue(TEXT("WaitGameplayEffectBlockedByImmunity should use the external owner ASC"), BlockedTask->UseExternalOwner && BlockedTask->ExternalOwner == ExternalASC);
	TestTrue(TEXT("WaitGameplayEffectBlockedByImmunity should preserve trigger-once true"), BlockedTask->TriggerOnce);
	TestEqual(TEXT("WaitForGameplayEffectRemoved should preserve the active effect handle"), RemovedTask->Handle, AppliedHandle);
	TestEqual(TEXT("WaitForGameplayEffectStackChange should preserve the active effect handle"), StackTask->Handle, AppliedHandle);
	if (!TestEqual(TEXT("GameplayEffectWatchWrappers should create a two-stack effect for stack-change verification"), OwnerASC->GetCurrentStackCount(AppliedHandle), 2))
	{
		return false;
	}

	UAngelscriptGASTestGameplayEffectRemovedListener* RemovedListener =
		NewObject<UAngelscriptGASTestGameplayEffectRemovedListener>(OwnerActor, TEXT("GameplayEffectRemovedListener"));
	UAngelscriptGASTestGameplayEffectStackChangeListener* StackListener =
		NewObject<UAngelscriptGASTestGameplayEffectStackChangeListener>(OwnerActor, TEXT("GameplayEffectStackChangeListener"));
	if (!TestNotNull(TEXT("WaitForGameplayEffectRemoved should create a removal listener"), RemovedListener) ||
		!TestNotNull(TEXT("WaitForGameplayEffectStackChange should create a stack listener"), StackListener))
	{
		return false;
	}

	RemovedTask->OnRemoved.AddDynamic(RemovedListener, &UAngelscriptGASTestGameplayEffectRemovedListener::RecordRemoved);
	StackTask->OnChange.AddDynamic(StackListener, &UAngelscriptGASTestGameplayEffectStackChangeListener::RecordStackChange);
	RemovedTask->Activate();
	StackTask->Activate();

	OwnerASC->RemoveActiveGameplayEffect(AppliedHandle, 1);
	TestEqual(TEXT("WaitForGameplayEffectStackChange should fire once when one stack is removed"), StackListener->CallbackCount, 1);
	TestEqual(TEXT("WaitForGameplayEffectStackChange should report the original handle"), StackListener->LastHandle, AppliedHandle);
	TestEqual(TEXT("WaitForGameplayEffectStackChange should report the previous stack count"), StackListener->LastOldCount, 2);
	TestEqual(TEXT("WaitForGameplayEffectStackChange should report the new stack count"), StackListener->LastNewCount, 1);
	TestEqual(TEXT("WaitForGameplayEffectRemoved should stay idle when only stack count changes"), RemovedListener->CallbackCount, 0);

	OwnerASC->RemoveActiveGameplayEffect(AppliedHandle);
	TestEqual(TEXT("WaitForGameplayEffectRemoved should fire once when the effect is fully removed"), RemovedListener->CallbackCount, 1);
	TestTrue(TEXT("WaitForGameplayEffectRemoved should report a premature removal for manual removal"), RemovedListener->bLastPrematureRemoval);
	TestEqual(TEXT("WaitForGameplayEffectRemoved should report the remaining stack count from the final removal"), RemovedListener->LastStackCount, 1);
	TestEqual(TEXT("WaitForGameplayEffectStackChange should not fire again during final removal"), StackListener->CallbackCount, 1);

	ASTEST_END_SHARE_CLEAN
	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAbilityTaskLibraryRootMotionAndTargetingWrapperArgumentsTest,
	"Angelscript.TestModule.Engine.GASAbilityTaskLibrary.RootMotionAndTargetingWrappersPreserveRepresentativeArguments",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAbilityTaskLibraryRootMotionAndTargetingWrapperArgumentsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* OwnerActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	ACharacter* AvatarActor = &Spawner.SpawnActor<ACharacter>();
	AAngelscriptGASTestActor* DirectTargetActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	AAngelscriptGASTestActor* IndexedTargetActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	AAngelscriptGASTestActor* IgnoredTargetActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	AGameplayAbilityTargetActor_Radius* VisualizeTargetActor = &Spawner.SpawnActor<AGameplayAbilityTargetActor_Radius>();
	if (!TestNotNull(TEXT("RootMotionAndTargetingWrappers owner actor should spawn"), OwnerActor) ||
		!TestNotNull(TEXT("RootMotionAndTargetingWrappers avatar actor should spawn"), AvatarActor) ||
		!TestNotNull(TEXT("RootMotionAndTargetingWrappers direct target actor should spawn"), DirectTargetActor) ||
		!TestNotNull(TEXT("RootMotionAndTargetingWrappers indexed target actor should spawn"), IndexedTargetActor) ||
		!TestNotNull(TEXT("RootMotionAndTargetingWrappers ignored target actor should spawn"), IgnoredTargetActor) ||
		!TestNotNull(TEXT("RootMotionAndTargetingWrappers visualize target actor should spawn"), VisualizeTargetActor))
	{
		return false;
	}

	AvatarActor->SetActorLocation(FVector(10.f, 20.f, 30.f));
	DirectTargetActor->SetActorLocation(FVector(100.f, 10.f, 0.f));
	IndexedTargetActor->SetActorLocation(FVector(250.f, -30.f, 5.f));
	VisualizeTargetActor->SetActorLocation(FVector(-50.f, 70.f, 15.f));

	UAngelscriptAbilitySystemComponent* OwnerASC = OwnerActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("RootMotionAndTargetingWrappers owner ASC should exist"), OwnerASC))
	{
		return false;
	}

	OwnerASC->InitAbilityActorInfo(OwnerActor, AvatarActor);

	const FGameplayAbilitySpecHandle AbilityHandle =
		OwnerASC->BP_GiveAbility(UAngelscriptGASTestAbility::StaticClass(), 1, 0, nullptr);
	if (!TestTrue(TEXT("RootMotionAndTargetingWrappers should grant a valid ability handle"), AbilityHandle.IsValid()))
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

	if (!TestTrue(TEXT("RootMotionAndTargetingWrappers should activate the granted ability"), OwnerASC->TryActivateAbilitySpec(AbilityHandle)))
	{
		return false;
	}

	UAngelscriptGASTestAbility* AbilityInstance = GetPrimaryTestAbilityInstance(*OwnerASC, AbilityHandle);
	if (!TestNotNull(TEXT("RootMotionAndTargetingWrappers should resolve the primary ability instance"), AbilityInstance))
	{
		return false;
	}

	UCurveFloat* HorizontalCurve = NewObject<UCurveFloat>(GetTransientPackage());
	UCurveFloat* VerticalCurve = NewObject<UCurveFloat>(GetTransientPackage());
	UCurveFloat* TimeMappingCurve = NewObject<UCurveFloat>(GetTransientPackage());
	UCurveFloat* InterpolationCurve = NewObject<UCurveFloat>(GetTransientPackage());
	UCurveVector* PathOffsetCurve = NewObject<UCurveVector>(GetTransientPackage());
	UCurveVector* VectorInterpolationCurve = NewObject<UCurveVector>(GetTransientPackage());

	const FName DirectTaskName(TEXT("MoveToActorDirectTask"));
	const FName TargetDataTaskName(TEXT("MoveToTargetDataActorTask"));
	const FName MoveToForceTaskName(TEXT("MoveToForceTask"));
	const FName MoveToLocationTaskName(TEXT("MoveToLocationTask"));
	const FName VisualizeTaskName(TEXT("VisualizeTargetingTask"));
	const FName WaitTargetDataTaskName(TEXT("WaitTargetDataTask"));

	const FVector DirectOffset(12.f, -6.f, 3.f);
	const FVector IndexedOffset(-4.f, 8.f, 16.f);
	const FVector MoveToForceLocation(400.f, -25.f, 60.f);
	const FVector MoveToLocationTarget(-120.f, 75.f, 10.f);
	const FVector FinishSetVelocity(15.f, -5.f, 20.f);
	const FVector FinishClampVelocity(30.f, 10.f, 0.f);
	const float DirectDuration = 1.75f;
	const float IndexedDuration = 2.25f;
	const float MoveToForceDuration = 3.5f;
	const float MoveToLocationDuration = 0.85f;
	const float VisualizeDuration = 4.25f;

	const TArray<AActor*> TargetDataActors = {IgnoredTargetActor, IndexedTargetActor};
	const FGameplayAbilityTargetDataHandle TargetDataHandle = MakeActorArrayTargetData(TargetDataActors);

	UAbilityTask_ApplyRootMotionMoveToActorForce* MoveToActorTask =
		UAngelscriptAbilityTaskLibrary::ApplyRootMotionMoveToActorForce(
			AbilityInstance,
			DirectTaskName,
			DirectTargetActor,
			DirectOffset,
			ERootMotionMoveToActorTargetOffsetType::AlignToTargetForward,
			DirectDuration,
			HorizontalCurve,
			VerticalCurve,
			true,
			EMovementMode::MOVE_Flying,
			true,
			PathOffsetCurve,
			TimeMappingCurve,
			ERootMotionFinishVelocityMode::SetVelocity,
			FinishSetVelocity,
			65.f,
			true);

	UAbilityTask_ApplyRootMotionMoveToActorForce* MoveToTargetDataTask =
		UAngelscriptAbilityTaskLibrary::ApplyRootMotionMoveToTargetDataActorForce(
			AbilityInstance,
			TargetDataTaskName,
			TargetDataHandle,
			0,
			1,
			IndexedOffset,
			ERootMotionMoveToActorTargetOffsetType::AlignToWorldSpace,
			IndexedDuration,
			HorizontalCurve,
			VerticalCurve,
			false,
			EMovementMode::MOVE_Custom,
			false,
			PathOffsetCurve,
			TimeMappingCurve,
			ERootMotionFinishVelocityMode::ClampVelocity,
			FinishClampVelocity,
			90.f,
			false);

	UAbilityTask_ApplyRootMotionMoveToForce* MoveToForceTask =
		UAngelscriptAbilityTaskLibrary::ApplyRootMotionMoveToForce(
			AbilityInstance,
			MoveToForceTaskName,
			MoveToForceLocation,
			MoveToForceDuration,
			true,
			EMovementMode::MOVE_Swimming,
			true,
			PathOffsetCurve,
			ERootMotionFinishVelocityMode::ClampVelocity,
			FinishClampVelocity,
			72.f);

	UAbilityTask_MoveToLocation* MoveToLocationTask =
		UAngelscriptAbilityTaskLibrary::MoveToLocation(
			AbilityInstance,
			MoveToLocationTaskName,
			MoveToLocationTarget,
			MoveToLocationDuration,
			InterpolationCurve,
			VectorInterpolationCurve);

	UAbilityTask_VisualizeTargeting* VisualizeTargetingTask =
		UAngelscriptAbilityTaskLibrary::VisualizeTargetingUsingActor(
			AbilityInstance,
			VisualizeTargetActor,
			VisualizeTaskName,
			VisualizeDuration);

	UAbilityTask_WaitTargetData* WaitTargetDataTask =
		UAngelscriptAbilityTaskLibrary::WaitTargetData(
			AbilityInstance,
			WaitTargetDataTaskName,
			EGameplayTargetingConfirmation::UserConfirmed,
			AGameplayAbilityTargetActor_Radius::StaticClass());

	if (!ExpectTaskOwnership(*this, TEXT("ApplyRootMotionMoveToActorForce"), MoveToActorTask, AbilityInstance, OwnerASC, AbilityHandle, DirectTaskName) ||
		!ExpectTaskOwnership(*this, TEXT("ApplyRootMotionMoveToTargetDataActorForce"), MoveToTargetDataTask, AbilityInstance, OwnerASC, AbilityHandle, TargetDataTaskName) ||
		!ExpectTaskOwnership(*this, TEXT("ApplyRootMotionMoveToForce"), MoveToForceTask, AbilityInstance, OwnerASC, AbilityHandle, MoveToForceTaskName) ||
		!ExpectTaskOwnership(*this, TEXT("MoveToLocation"), MoveToLocationTask, AbilityInstance, OwnerASC, AbilityHandle, MoveToLocationTaskName) ||
		!ExpectTaskOwnership(*this, TEXT("VisualizeTargetingUsingActor"), VisualizeTargetingTask, AbilityInstance, OwnerASC, AbilityHandle, VisualizeTaskName) ||
		!ExpectTaskOwnership(*this, TEXT("WaitTargetData"), WaitTargetDataTask, AbilityInstance, OwnerASC, AbilityHandle, WaitTargetDataTaskName))
	{
		return false;
	}

	TestTrue(TEXT("ApplyRootMotionMoveToActorForce should return the native move-to-actor task class"), MoveToActorTask->GetClass() == UAbilityTask_ApplyRootMotionMoveToActorForce::StaticClass());
	TestTrue(TEXT("ApplyRootMotionMoveToTargetDataActorForce should return the native move-to-actor task class"), MoveToTargetDataTask->GetClass() == UAbilityTask_ApplyRootMotionMoveToActorForce::StaticClass());
	TestTrue(TEXT("ApplyRootMotionMoveToForce should return the native move-to-force task class"), MoveToForceTask->GetClass() == UAbilityTask_ApplyRootMotionMoveToForce::StaticClass());
	TestTrue(TEXT("MoveToLocation should return the native move-to-location task class"), MoveToLocationTask->GetClass() == UAbilityTask_MoveToLocation::StaticClass());
	TestTrue(TEXT("VisualizeTargetingUsingActor should return the native visualize-targeting task class"), VisualizeTargetingTask->GetClass() == UAbilityTask_VisualizeTargeting::StaticClass());
	TestTrue(TEXT("WaitTargetData should return the native wait-target-data task class"), WaitTargetDataTask->GetClass() == UAbilityTask_WaitTargetData::StaticClass());

	TestEqual(TEXT("ApplyRootMotionMoveToActorForce should preserve the direct target actor"), MoveToActorTask->TargetActor.Get(), static_cast<AActor*>(DirectTargetActor));
	TestEqual(TEXT("ApplyRootMotionMoveToActorForce should preserve the target offset"), MoveToActorTask->TargetLocationOffset, DirectOffset);
	TestEqual(TEXT("ApplyRootMotionMoveToActorForce should preserve the offset alignment"), MoveToActorTask->OffsetAlignment, ERootMotionMoveToActorTargetOffsetType::AlignToTargetForward);
	TestEqual(TEXT("ApplyRootMotionMoveToActorForce should preserve duration"), MoveToActorTask->Duration, DirectDuration);
	TestTrue(TEXT("ApplyRootMotionMoveToActorForce should preserve horizontal lerp curve"), MoveToActorTask->TargetLerpSpeedHorizontalCurve == HorizontalCurve);
	TestTrue(TEXT("ApplyRootMotionMoveToActorForce should preserve vertical lerp curve"), MoveToActorTask->TargetLerpSpeedVerticalCurve == VerticalCurve);
	TestTrue(TEXT("ApplyRootMotionMoveToActorForce should preserve time mapping curve"), MoveToActorTask->TimeMappingCurve == TimeMappingCurve);
	TestTrue(TEXT("ApplyRootMotionMoveToActorForce should preserve path offset curve"), MoveToActorTask->PathOffsetCurve == PathOffsetCurve);
	TestTrue(TEXT("ApplyRootMotionMoveToActorForce should preserve movement-mode override"), MoveToActorTask->bSetNewMovementMode);
	TestEqual(TEXT("ApplyRootMotionMoveToActorForce should preserve movement mode"), MoveToActorTask->NewMovementMode, EMovementMode::MOVE_Flying);
	TestTrue(TEXT("ApplyRootMotionMoveToActorForce should preserve restrict-speed flag"), MoveToActorTask->bRestrictSpeedToExpected);
	TestTrue(TEXT("ApplyRootMotionMoveToActorForce should preserve disable-destination-interrupt flag"), MoveToActorTask->bDisableDestinationReachedInterrupt);
	TestEqual(TEXT("ApplyRootMotionMoveToActorForce should preserve finish velocity mode"), MoveToActorTask->FinishVelocityMode, ERootMotionFinishVelocityMode::SetVelocity);
	TestEqual(TEXT("ApplyRootMotionMoveToActorForce should preserve finish set velocity"), MoveToActorTask->FinishSetVelocity, FinishSetVelocity);
	TestEqual(TEXT("ApplyRootMotionMoveToActorForce should preserve finish clamp velocity"), MoveToActorTask->FinishClampVelocity, 65.f);
	TestEqual(TEXT("ApplyRootMotionMoveToActorForce should capture avatar start location"), MoveToActorTask->StartLocation, AvatarActor->GetActorLocation());

	TestEqual(TEXT("ApplyRootMotionMoveToTargetDataActorForce should resolve the indexed target actor"), MoveToTargetDataTask->TargetActor.Get(), static_cast<AActor*>(IndexedTargetActor));
	TestEqual(TEXT("ApplyRootMotionMoveToTargetDataActorForce should preserve the target offset"), MoveToTargetDataTask->TargetLocationOffset, IndexedOffset);
	TestEqual(TEXT("ApplyRootMotionMoveToTargetDataActorForce should preserve offset alignment"), MoveToTargetDataTask->OffsetAlignment, ERootMotionMoveToActorTargetOffsetType::AlignToWorldSpace);
	TestEqual(TEXT("ApplyRootMotionMoveToTargetDataActorForce should preserve duration"), MoveToTargetDataTask->Duration, IndexedDuration);
	TestFalse(TEXT("ApplyRootMotionMoveToTargetDataActorForce should preserve unset movement-mode override"), MoveToTargetDataTask->bSetNewMovementMode);
	TestEqual(TEXT("ApplyRootMotionMoveToTargetDataActorForce should preserve movement mode"), MoveToTargetDataTask->NewMovementMode, EMovementMode::MOVE_Custom);
	TestFalse(TEXT("ApplyRootMotionMoveToTargetDataActorForce should preserve restrict-speed flag"), MoveToTargetDataTask->bRestrictSpeedToExpected);
	TestEqual(TEXT("ApplyRootMotionMoveToTargetDataActorForce should preserve finish velocity mode"), MoveToTargetDataTask->FinishVelocityMode, ERootMotionFinishVelocityMode::ClampVelocity);
	TestEqual(TEXT("ApplyRootMotionMoveToTargetDataActorForce should preserve finish set velocity"), MoveToTargetDataTask->FinishSetVelocity, FinishClampVelocity);
	TestEqual(TEXT("ApplyRootMotionMoveToTargetDataActorForce should preserve finish clamp velocity"), MoveToTargetDataTask->FinishClampVelocity, 90.f);

	TestEqual(TEXT("ApplyRootMotionMoveToForce should preserve target location"), MoveToForceTask->TargetLocation, MoveToForceLocation);
	TestEqual(TEXT("ApplyRootMotionMoveToForce should preserve duration"), MoveToForceTask->Duration, MoveToForceDuration);
	TestTrue(TEXT("ApplyRootMotionMoveToForce should preserve movement-mode override"), MoveToForceTask->bSetNewMovementMode);
	TestEqual(TEXT("ApplyRootMotionMoveToForce should preserve movement mode"), MoveToForceTask->NewMovementMode, EMovementMode::MOVE_Swimming);
	TestTrue(TEXT("ApplyRootMotionMoveToForce should preserve restrict-speed flag"), MoveToForceTask->bRestrictSpeedToExpected);
	TestTrue(TEXT("ApplyRootMotionMoveToForce should preserve path offset curve"), MoveToForceTask->PathOffsetCurve == PathOffsetCurve);
	TestEqual(TEXT("ApplyRootMotionMoveToForce should preserve finish velocity mode"), MoveToForceTask->FinishVelocityMode, ERootMotionFinishVelocityMode::ClampVelocity);
	TestEqual(TEXT("ApplyRootMotionMoveToForce should preserve finish set velocity"), MoveToForceTask->FinishSetVelocity, FinishClampVelocity);
	TestEqual(TEXT("ApplyRootMotionMoveToForce should preserve finish clamp velocity"), MoveToForceTask->FinishClampVelocity, 72.f);

	TestEqual(TEXT("MoveToLocation should preserve target location"), MoveToLocationTask->TargetLocation, MoveToLocationTarget);
	TestEqual(TEXT("MoveToLocation should preserve duration"), MoveToLocationTask->DurationOfMovement, MoveToLocationDuration);
	TestTrue(TEXT("MoveToLocation should preserve float interpolation curve"), MoveToLocationTask->LerpCurve == InterpolationCurve);
	TestTrue(TEXT("MoveToLocation should preserve vector interpolation curve"), MoveToLocationTask->LerpCurveVector == VectorInterpolationCurve);
	TestEqual(TEXT("MoveToLocation should capture avatar start location"), MoveToLocationTask->StartLocation, AvatarActor->GetActorLocation());

	TestTrue(TEXT("VisualizeTargetingUsingActor should preserve the provided target actor"), VisualizeTargetingTask->TargetActor.Get() == VisualizeTargetActor);
	TestTrue(TEXT("VisualizeTargetingUsingActor should not eagerly set target class when using actor overload"), VisualizeTargetingTask->TargetClass == nullptr);
	UWorld* VisualizeWorld = VisualizeTargetingTask->GetWorld();
	if (!TestNotNull(TEXT("VisualizeTargetingUsingActor should resolve a world for timer verification"), VisualizeWorld))
	{
		return false;
	}
	TestTrue(TEXT("VisualizeTargetingUsingActor should schedule its duration timer"), VisualizeWorld->GetTimerManager().IsTimerActive(VisualizeTargetingTask->TimerHandle_OnTimeElapsed));
	TestTrue(
		TEXT("VisualizeTargetingUsingActor should preserve positive duration in the timer manager"),
		VisualizeWorld->GetTimerManager().GetTimerRemaining(VisualizeTargetingTask->TimerHandle_OnTimeElapsed) > 0.f);

	TestTrue(TEXT("WaitTargetData should preserve target class"), WaitTargetDataTask->TargetClass == AGameplayAbilityTargetActor_Radius::StaticClass());
	TestTrue(TEXT("WaitTargetData should leave target actor unset for class overload"), WaitTargetDataTask->TargetActor == nullptr);
	TestEqual(TEXT("WaitTargetData should preserve confirmation type"), WaitTargetDataTask->ConfirmationType, EGameplayTargetingConfirmation::UserConfirmed);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
