#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#include "../../AngelscriptRuntime/Core/AngelscriptAbilityAsyncLibrary.h"

#include "AbilitySystemBlueprintLibrary.h"
#include "Components/ActorTestSpawner.h"
#include "GameplayTagsManager.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptGASAsyncLibraryTests_Private
{
	const FName HealthAttributeName = GET_MEMBER_NAME_CHECKED(UAngelscriptGASTestAttributeSet, Health);
	const float InitialHealthValue = 10.f;
	const float UpdatedHealthValue = 25.f;
	const float SecondUpdatedHealthValue = 40.f;
	const float MatchingEventMagnitude = 7.f;
	const float IgnoredEventMagnitude = 3.f;

	bool GetDistinctGameplayTags(
		FAutomationTestBase& Test,
		FGameplayTag& OutMatchingTag,
		FGameplayTag& OutNonMatchingTag)
	{
		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);

		TArray<FGameplayTag> AvailableTags;
		AllTags.GetGameplayTagArray(AvailableTags);
		if (!Test.TestTrue(TEXT("GAS async tag-query test requires at least two registered gameplay tags"), AvailableTags.Num() >= 2))
		{
			return false;
		}

		for (const FGameplayTag& CandidateMatchingTag : AvailableTags)
		{
			const FGameplayTagQuery Query = FGameplayTagQuery::MakeQuery_MatchTag(CandidateMatchingTag);
			for (const FGameplayTag& CandidateNonMatchingTag : AvailableTags)
			{
				if (CandidateNonMatchingTag == CandidateMatchingTag)
				{
					continue;
				}

				FGameplayTagContainer Container;
				Container.AddTag(CandidateNonMatchingTag);
				if (!Query.Matches(Container))
				{
					OutMatchingTag = CandidateMatchingTag;
					OutNonMatchingTag = CandidateNonMatchingTag;
					return true;
				}
			}
		}

		Test.AddError(TEXT("GAS async tag-query test could not find a non-matching gameplay tag pair"));
		return false;
	}

	bool GetParentAndChildGameplayTags(
		FAutomationTestBase& Test,
		FGameplayTag& OutParentTag,
		FGameplayTag& OutChildTag)
	{
		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);

		TArray<FGameplayTag> AvailableTags;
		AllTags.GetGameplayTagArray(AvailableTags);
		if (!Test.TestTrue(TEXT("GAS async actor-wrapper test requires at least one hierarchical gameplay tag pair"), AvailableTags.Num() > 0))
		{
			return false;
		}

		for (const FGameplayTag& CandidateChildTag : AvailableTags)
		{
			const FGameplayTag CandidateParentTag = CandidateChildTag.RequestDirectParent();
			if (CandidateParentTag.IsValid())
			{
				OutParentTag = CandidateParentTag;
				OutChildTag = CandidateChildTag;
				return true;
			}
		}

		Test.AddError(TEXT("GAS async actor-wrapper test could not find a gameplay tag with a direct parent"));
		return false;
	}

	bool InitializeAsyncActorFixture(
		FAutomationTestBase& Test,
		FActorTestSpawner& Spawner,
		AAngelscriptGASTestActor*& OutActor,
		UAngelscriptAbilitySystemComponent*& OutAbilitySystemComponent,
		FGameplayAttribute& OutHealthAttribute)
	{
		OutActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
		if (!Test.TestNotNull(TEXT("GAS async actor-wrapper test should spawn a test actor"), OutActor))
		{
			return false;
		}

		OutAbilitySystemComponent = OutActor->AbilitySystemComponent;
		if (!Test.TestNotNull(TEXT("GAS async actor-wrapper test should expose an ability-system component"), OutAbilitySystemComponent))
		{
			return false;
		}

		OutAbilitySystemComponent->InitAbilityActorInfo(OutActor, OutActor);

		UAngelscriptAttributeSet* AttributeSet =
			OutAbilitySystemComponent->RegisterAttributeSet(UAngelscriptGASTestAttributeSet::StaticClass());
		if (!Test.TestNotNull(TEXT("GAS async actor-wrapper test should register a test attribute set"), AttributeSet))
		{
			return false;
		}

		if (!Test.TestTrue(
				TEXT("GAS async actor-wrapper test should resolve the Health attribute"),
				UAngelscriptAttributeSet::TryGetGameplayAttribute(
					UAngelscriptGASTestAttributeSet::StaticClass(),
					HealthAttributeName,
					OutHealthAttribute)))
		{
			return false;
		}

		return Test.TestTrue(
			TEXT("GAS async actor-wrapper test should seed the Health attribute"),
			OutAbilitySystemComponent->TrySetAttributeBaseValue(
				UAngelscriptGASTestAttributeSet::StaticClass(),
				HealthAttributeName,
				InitialHealthValue));
	}

	void SendGameplayEventToActor(AActor* TargetActor, const FGameplayTag& EventTag, const float EventMagnitude)
	{
		FGameplayEventData Payload;
		Payload.EventTag = EventTag;
		Payload.EventMagnitude = EventMagnitude;
		Payload.Instigator = TargetActor;
		UAbilitySystemBlueprintLibrary::SendGameplayEventToActor(TargetActor, EventTag, Payload);
	}

	void ActivateAsyncTask(UAbilityAsync* Task)
	{
		check(Task != nullptr);
		Task->Activate();
	}
}

using namespace AngelscriptTest_Core_AngelscriptGASAsyncLibraryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASWaitGameplayTagQueryCreatesTaskTest,
	"Angelscript.TestModule.Engine.GAS.Async.WaitGameplayTagQueryCreatesTask",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASWaitGameplayTagQueryCreatesTaskTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FGameplayTag MatchingTag;
	FGameplayTag NonMatchingTag;
	if (!GetDistinctGameplayTags(*this, MatchingTag, NonMatchingTag))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS async tag-query test actor should spawn"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS async tag-query test actor should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	const FGameplayTagQuery Query = FGameplayTagQuery::MakeQuery_MatchTag(MatchingTag);
	TestFalse(TEXT("GAS async tag-query query should not be empty"), Query.IsEmpty());

	UAbilityAsync_WaitGameplayTagQuery* Task = UAngelscriptAbilityAsyncLibrary::WaitGameplayTagQueryOnActor(
		TestActor,
		Query,
		EWaitGameplayTagQueryTriggerCondition::WhenTrue,
		true);
	if (!TestNotNull(TEXT("WaitGameplayTagQueryOnActor should create an async task instead of returning nullptr"), Task))
	{
		return false;
	}

	TestTrue(
		TEXT("WaitGameplayTagQueryOnActor should bind the async task to the target actor's ASC"),
		Task->GetAbilitySystemComponent() == AbilitySystemComponent);

	UAngelscriptGASTestAsyncListener* Listener = NewObject<UAngelscriptGASTestAsyncListener>(TestActor, TEXT("GameplayTagQueryListener"));
	if (!TestNotNull(TEXT("GAS async tag-query test should create a listener object"), Listener))
	{
		return false;
	}

	Task->Triggered.AddDynamic(Listener, &UAngelscriptGASTestAsyncListener::HandleTriggered);
	Task->Activate();

	TestEqual(
		TEXT("WaitGameplayTagQueryOnActor should not fire immediately before the matching tag exists"),
		Listener->TriggerCount,
		0);

	AbilitySystemComponent->AddLooseGameplayTag(NonMatchingTag);
	TestEqual(
		TEXT("WaitGameplayTagQueryOnActor should ignore non-matching tag updates"),
		Listener->TriggerCount,
		0);

	AbilitySystemComponent->AddLooseGameplayTag(MatchingTag);
	TestEqual(
		TEXT("WaitGameplayTagQueryOnActor should trigger once after the matching tag is added"),
		Listener->TriggerCount,
		1);

	TestTrue(
		TEXT("One-shot WaitGameplayTagQueryOnActor should clear its ASC binding after firing"),
		Task->GetAbilitySystemComponent() == nullptr);

	AbilitySystemComponent->RemoveLooseGameplayTag(MatchingTag);
	AbilitySystemComponent->AddLooseGameplayTag(MatchingTag);
	TestEqual(
		TEXT("One-shot WaitGameplayTagQueryOnActor should not trigger again after ending"),
		Listener->TriggerCount,
		1);

	ASTEST_END_SHARE_CLEAN
	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASActorWrappersCreateWorkingTasksTest,
	"Angelscript.TestModule.Engine.GAS.Async.ActorWrappersCreateWorkingTasks",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASActorWrappersCreateWorkingTasksTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FGameplayTag ExactEventTag;
	FGameplayTag ChildEventTag;
	if (!GetParentAndChildGameplayTags(*this, ExactEventTag, ChildEventTag))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = nullptr;
	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = nullptr;
	FGameplayAttribute HealthAttribute;
	if (!InitializeAsyncActorFixture(
			*this,
			Spawner,
			TestActor,
			AbilitySystemComponent,
			HealthAttribute))
	{
		return false;
	}

	UAbilityAsync_WaitAttributeChanged* AttributeTask =
		UAngelscriptAbilityAsyncLibrary::WaitForAttributeChanged(TestActor, HealthAttribute, true);
	UAbilityAsync_WaitGameplayEvent* EventTask =
		UAngelscriptAbilityAsyncLibrary::WaitGameplayEventToActor(TestActor, ExactEventTag, true, true);
	UAbilityAsync_WaitGameplayTagAdded* AddedTask =
		UAngelscriptAbilityAsyncLibrary::WaitGameplayTagAddToActor(TestActor, ChildEventTag, true);

	if (!TestNotNull(TEXT("WaitForAttributeChanged should create an async task"), AttributeTask) ||
		!TestNotNull(TEXT("WaitGameplayEventToActor should create an async task"), EventTask) ||
		!TestNotNull(TEXT("WaitGameplayTagAddToActor should create an async task"), AddedTask))
	{
		return false;
	}

	TestTrue(TEXT("WaitForAttributeChanged should return the native attribute-changed task class"), AttributeTask->GetClass() == UAbilityAsync_WaitAttributeChanged::StaticClass());
	TestTrue(TEXT("WaitGameplayEventToActor should return the native gameplay-event task class"), EventTask->GetClass() == UAbilityAsync_WaitGameplayEvent::StaticClass());
	TestTrue(TEXT("WaitGameplayTagAddToActor should return the native gameplay-tag-added task class"), AddedTask->GetClass() == UAbilityAsync_WaitGameplayTagAdded::StaticClass());

	TestTrue(TEXT("WaitForAttributeChanged should bind the attribute task to the target actor ASC"), AttributeTask->GetAbilitySystemComponent() == AbilitySystemComponent);
	TestTrue(TEXT("WaitGameplayEventToActor should bind the event task to the target actor ASC"), EventTask->GetAbilitySystemComponent() == AbilitySystemComponent);
	TestTrue(TEXT("WaitGameplayTagAddToActor should bind the add-tag task to the target actor ASC"), AddedTask->GetAbilitySystemComponent() == AbilitySystemComponent);

	UAngelscriptGASTestAsyncAttributeListener* AttributeListener =
		NewObject<UAngelscriptGASTestAsyncAttributeListener>(TestActor, TEXT("AsyncAttributeListener"));
	UAngelscriptGASTestGameplayEventListener* EventListener =
		NewObject<UAngelscriptGASTestGameplayEventListener>(TestActor, TEXT("GameplayEventListener"));
	UAngelscriptGASTestAsyncListener* AddedListener =
		NewObject<UAngelscriptGASTestAsyncListener>(TestActor, TEXT("GameplayTagAddedListener"));
	if (!TestNotNull(TEXT("WaitForAttributeChanged should create an attribute listener"), AttributeListener) ||
		!TestNotNull(TEXT("WaitGameplayEventToActor should create an event listener"), EventListener) ||
		!TestNotNull(TEXT("WaitGameplayTagAddToActor should create an add-tag listener"), AddedListener))
	{
		return false;
	}

	AttributeTask->Changed.AddDynamic(AttributeListener, &UAngelscriptGASTestAsyncAttributeListener::RecordAttributeChanged);
	EventTask->EventReceived.AddDynamic(EventListener, &UAngelscriptGASTestGameplayEventListener::RecordGameplayEvent);
	AddedTask->Added.AddDynamic(AddedListener, &UAngelscriptGASTestAsyncListener::HandleTriggered);

	ActivateAsyncTask(AttributeTask);
	ActivateAsyncTask(EventTask);
	ActivateAsyncTask(AddedTask);

	TestEqual(TEXT("Async attribute listener should not fire before Health changes"), AttributeListener->CallbackCount, 0);
	TestEqual(TEXT("Async event listener should not fire before any gameplay event is sent"), EventListener->TriggerCount, 0);
	TestEqual(TEXT("Async tag-added listener should not fire before the tag is added"), AddedListener->TriggerCount, 0);

	SendGameplayEventToActor(TestActor, ChildEventTag, IgnoredEventMagnitude);
	TestEqual(TEXT("WaitGameplayEventToActor should ignore child tags when bMatchExact is true"), EventListener->TriggerCount, 0);

	SendGameplayEventToActor(TestActor, ExactEventTag, MatchingEventMagnitude);
	TestEqual(TEXT("WaitGameplayEventToActor should fire once for the exact observed tag"), EventListener->TriggerCount, 1);
	TestEqual(TEXT("WaitGameplayEventToActor should preserve the matching gameplay-event tag"), EventListener->LastEventTag, ExactEventTag);
	TestEqual(TEXT("WaitGameplayEventToActor should preserve the gameplay-event magnitude"), EventListener->LastEventMagnitude, MatchingEventMagnitude);
	TestTrue(TEXT("One-shot gameplay-event tasks should clear their ASC binding after the first trigger"), EventTask->GetAbilitySystemComponent() == nullptr);

	SendGameplayEventToActor(TestActor, ExactEventTag, MatchingEventMagnitude + 1.f);
	TestEqual(TEXT("One-shot gameplay-event tasks should not re-broadcast after the first trigger"), EventListener->TriggerCount, 1);

	if (!TestTrue(
			TEXT("WaitForAttributeChanged should observe Health base-value updates"),
			AbilitySystemComponent->TrySetAttributeBaseValue(
				UAngelscriptGASTestAttributeSet::StaticClass(),
				HealthAttributeName,
				UpdatedHealthValue)))
	{
		return false;
	}

	TestEqual(TEXT("WaitForAttributeChanged should fire once when Health changes"), AttributeListener->CallbackCount, 1);
	TestEqual(TEXT("WaitForAttributeChanged should report the Health attribute name"), AttributeListener->LastAttributeName, HealthAttributeName);
	TestEqual(TEXT("WaitForAttributeChanged should report the previous Health value"), AttributeListener->LastOldValue, InitialHealthValue);
	TestEqual(TEXT("WaitForAttributeChanged should report the updated Health value"), AttributeListener->LastNewValue, UpdatedHealthValue);
	TestTrue(TEXT("One-shot attribute-changed tasks should clear their ASC binding after the first trigger"), AttributeTask->GetAbilitySystemComponent() == nullptr);

	if (!TestTrue(
			TEXT("A second Health update should still succeed after the attribute task has ended"),
			AbilitySystemComponent->TrySetAttributeBaseValue(
				UAngelscriptGASTestAttributeSet::StaticClass(),
				HealthAttributeName,
				SecondUpdatedHealthValue)))
	{
		return false;
	}

	TestEqual(TEXT("One-shot attribute-changed tasks should not re-broadcast after ending"), AttributeListener->CallbackCount, 1);

	AbilitySystemComponent->AddLooseGameplayTag(ChildEventTag);
	TestEqual(TEXT("WaitGameplayTagAddToActor should fire once when the observed tag is added"), AddedListener->TriggerCount, 1);
	TestTrue(TEXT("One-shot gameplay-tag-added tasks should clear their ASC binding after the first trigger"), AddedTask->GetAbilitySystemComponent() == nullptr);

	UAbilityAsync_WaitGameplayTagRemoved* RemovedTask =
		UAngelscriptAbilityAsyncLibrary::WaitGameplayTagRemoveFromActor(TestActor, ChildEventTag, true);
	if (!TestNotNull(TEXT("WaitGameplayTagRemoveFromActor should create an async task"), RemovedTask))
	{
		return false;
	}

	TestTrue(TEXT("WaitGameplayTagRemoveFromActor should return the native gameplay-tag-removed task class"), RemovedTask->GetClass() == UAbilityAsync_WaitGameplayTagRemoved::StaticClass());
	TestTrue(TEXT("WaitGameplayTagRemoveFromActor should bind the remove-tag task to the target actor ASC"), RemovedTask->GetAbilitySystemComponent() == AbilitySystemComponent);

	UAngelscriptGASTestAsyncListener* RemovedListener =
		NewObject<UAngelscriptGASTestAsyncListener>(TestActor, TEXT("GameplayTagRemovedListener"));
	if (!TestNotNull(TEXT("WaitGameplayTagRemoveFromActor should create a remove-tag listener"), RemovedListener))
	{
		return false;
	}

	RemovedTask->Removed.AddDynamic(RemovedListener, &UAngelscriptGASTestAsyncListener::HandleTriggered);
	ActivateAsyncTask(RemovedTask);
	TestEqual(TEXT("WaitGameplayTagRemoveFromActor should not fire immediately while the observed tag is still present"), RemovedListener->TriggerCount, 0);

	AbilitySystemComponent->RemoveLooseGameplayTag(ChildEventTag);
	TestEqual(TEXT("WaitGameplayTagRemoveFromActor should fire once when the observed tag is removed"), RemovedListener->TriggerCount, 1);
	TestTrue(TEXT("One-shot gameplay-tag-removed tasks should clear their ASC binding after the first trigger"), RemovedTask->GetAbilitySystemComponent() == nullptr);

	AbilitySystemComponent->AddLooseGameplayTag(ChildEventTag);
	TestEqual(TEXT("One-shot gameplay-tag-added tasks should not re-broadcast after ending"), AddedListener->TriggerCount, 1);
	AbilitySystemComponent->RemoveLooseGameplayTag(ChildEventTag);
	TestEqual(TEXT("One-shot gameplay-tag-removed tasks should not re-broadcast after ending"), RemovedListener->TriggerCount, 1);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
