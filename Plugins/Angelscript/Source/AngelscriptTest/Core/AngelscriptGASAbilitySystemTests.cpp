#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptGASAbilitySystemTests_Private
{
	int32 CountAttributeSetsOfClass(const UAngelscriptAbilitySystemComponent& AbilitySystemComponent, const UClass* AttributeSetClass)
	{
		int32 MatchCount = 0;
		for (const UAttributeSet* AttributeSet : AbilitySystemComponent.GetSpawnedAttributes())
		{
			if (AttributeSet != nullptr && AttributeSet->IsA(AttributeSetClass))
			{
				++MatchCount;
			}
		}

		return MatchCount;
	}

	FGameplayAbilitySpec* FindAbilitySpec(UAngelscriptAbilitySystemComponent& AbilitySystemComponent, const FGameplayAbilitySpecHandle& Handle)
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
}

using namespace AngelscriptTest_Core_AngelscriptGASAbilitySystemTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASRegisterAttributeSetReplayTest,
	"Angelscript.TestModule.Engine.GAS.AbilitySystem.RegisterAttributeSetReplaysExistingSets",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASGiveAbilitySpecAndDelegateTest,
	"Angelscript.TestModule.Engine.GAS.AbilitySystem.GiveAbilityPopulatesSpecAndBroadcastsDelegates",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASRemoveAbilityOnEndLifecycleTest,
	"Angelscript.TestModule.Engine.GAS.AbilitySystem.RemoveAbilityOnEndBroadcastsRemovalAndPrunesSpec",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASRegisterAttributeSetReplayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS RegisterAttributeSet test actor should spawn"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS RegisterAttributeSet test actor should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	UAngelscriptAttributeSet* FirstRegisteredSet =
		AbilitySystemComponent->RegisterAttributeSet(UAngelscriptGASTestAttributeSet::StaticClass());
	if (!TestNotNull(TEXT("First RegisterAttributeSet call should create an attribute set"), FirstRegisteredSet))
	{
		return false;
	}

	TestTrue(
		TEXT("RegisterAttributeSet should create the requested attribute-set subclass"),
		FirstRegisteredSet->IsA(UAngelscriptGASTestAttributeSet::StaticClass()));
	TestTrue(
		TEXT("RegisterAttributeSet should outer the created set to the owning actor"),
		FirstRegisteredSet->GetOuter() == TestActor);

	UAngelscriptGASTestAttributeSetListener* Listener =
		NewObject<UAngelscriptGASTestAttributeSetListener>(TestActor, TEXT("AttributeSetReplayListener"));
	if (!TestNotNull(TEXT("Attribute-set replay test should create a listener object"), Listener))
	{
		return false;
	}

	AbilitySystemComponent->OnAttributeSetRegistered(
		Listener,
		GET_FUNCTION_NAME_CHECKED(UAngelscriptGASTestAttributeSetListener, RecordAttributeSet));

	TestEqual(
		TEXT("OnAttributeSetRegistered should immediately replay already-registered attribute sets"),
		Listener->ReplayCount,
		1);
	TestTrue(
		TEXT("OnAttributeSetRegistered immediate replay should pass the existing attribute-set instance"),
		Listener->LastRegisteredAttributeSet == FirstRegisteredSet);

	UAngelscriptAttributeSet* SecondRegisteredSet =
		AbilitySystemComponent->RegisterAttributeSet(UAngelscriptGASTestAttributeSet::StaticClass());
	TestTrue(
		TEXT("RegisterAttributeSet should deduplicate repeated registrations of the same class"),
		SecondRegisteredSet == FirstRegisteredSet);
	TestEqual(
		TEXT("Repeated RegisterAttributeSet calls should not replay or broadcast a duplicate registration"),
		Listener->ReplayCount,
		1);
	TestEqual(
		TEXT("Ability-system component should keep only one spawned attribute set for the requested class"),
		CountAttributeSetsOfClass(*AbilitySystemComponent, UAngelscriptGASTestAttributeSet::StaticClass()),
		1);

	ASTEST_END_SHARE_CLEAN
	return true;
}

bool FAngelscriptGASGiveAbilitySpecAndDelegateTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS GiveAbility test actor should spawn"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS GiveAbility test actor should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	UAngelscriptGASTestAbilityGivenListener* Listener =
		NewObject<UAngelscriptGASTestAbilityGivenListener>(TestActor, TEXT("AbilityGivenListener"));
	if (!TestNotNull(TEXT("GAS GiveAbility test should create an ability-given listener"), Listener))
	{
		return false;
	}

	AbilitySystemComponent->OnAbilityGiven.AddDynamic(
		Listener,
		&UAngelscriptGASTestAbilityGivenListener::RecordAbilityGiven);

	UObject* FirstSourceObject = NewObject<UAngelscriptGASTestSourceObject>(TestActor, TEXT("AbilitySourceObjectA"));
	if (!TestNotNull(TEXT("GAS GiveAbility test should create a source object"), FirstSourceObject))
	{
		return false;
	}

	const int32 AbilityLevel = 3;
	const int32 InputID = 7;
	const FGameplayAbilitySpecHandle FirstHandle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestAbility::StaticClass(), AbilityLevel, InputID, FirstSourceObject);
	if (!TestTrue(TEXT("BP_GiveAbility should return a valid handle"), FirstHandle.IsValid()))
	{
		return false;
	}

	TestTrue(
		TEXT("BP_GiveAbility should register the granted ability class"),
		AbilitySystemComponent->HasAbility(UAngelscriptGASTestAbility::StaticClass()));
	TestEqual(
		TEXT("OnAbilityGiven should broadcast exactly once for the first grant"),
		Listener->BroadcastCount,
		1);
	TestTrue(
		TEXT("OnAbilityGiven should report the handle that was returned by BP_GiveAbility"),
		Listener->LastHandle == FirstHandle);
	TestEqual(
		TEXT("OnAbilityGiven should report the configured ability level"),
		Listener->LastLevel,
		AbilityLevel);
	TestEqual(
		TEXT("OnAbilityGiven should report the configured input id"),
		Listener->LastInputID,
		InputID);
	TestTrue(
		TEXT("OnAbilityGiven should report the configured source object"),
		Listener->LastSourceObject == FirstSourceObject);
	TestTrue(
		TEXT("OnAbilityGiven should report the granted ability class"),
		Listener->LastAbilityClass == UAngelscriptGASTestAbility::StaticClass());

	FGameplayAbilitySpec* FirstSpec = FindAbilitySpec(*AbilitySystemComponent, FirstHandle);
	if (!TestNotNull(TEXT("Granted ability handle should resolve to an ability spec"), FirstSpec))
	{
		return false;
	}

	TestEqual(TEXT("Granted ability spec should preserve the requested level"), FirstSpec->Level, AbilityLevel);
	TestEqual(TEXT("Granted ability spec should preserve the requested input id"), FirstSpec->InputID, InputID);
	TestTrue(TEXT("Granted ability spec should preserve the requested source object"), FirstSpec->SourceObject.Get() == FirstSourceObject);

	if (!TestTrue(TEXT("TryActivateAbilitySpec should activate the granted ability"), AbilitySystemComponent->TryActivateAbilitySpec(FirstHandle)))
	{
		return false;
	}

	TestTrue(
		TEXT("Activated ability should report as active"),
		AbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestAbility::StaticClass()));

	UAngelscriptGASTestAbility* FirstAbilityInstance = GetPrimaryTestAbilityInstance(*AbilitySystemComponent, FirstHandle);
	if (!TestNotNull(TEXT("Activated ability should create a primary instance"), FirstAbilityInstance))
	{
		return false;
	}

	TestEqual(TEXT("Activated ability instance should record exactly one activation"), FirstAbilityInstance->ActivationCount, 1);
	TestEqual(TEXT("Activation should not rebroadcast OnAbilityGiven"), Listener->BroadcastCount, 1);

	AbilitySystemComponent->CancelAbilityByHandle(FirstHandle);
	TestFalse(
		TEXT("CancelAbilityByHandle should deactivate the granted ability"),
		AbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestAbility::StaticClass()));
	TestEqual(TEXT("CancelAbilityByHandle should end the active ability instance once"), FirstAbilityInstance->EndCount, 1);

	AAngelscriptGASTestActor* CancelByClassActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS GiveAbility class-cancel scenario should spawn a second test actor"), CancelByClassActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* CancelByClassAbilitySystemComponent = CancelByClassActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS GiveAbility class-cancel scenario should expose an ability-system component"), CancelByClassAbilitySystemComponent))
	{
		return false;
	}

	CancelByClassAbilitySystemComponent->InitAbilityActorInfo(CancelByClassActor, CancelByClassActor);

	UAngelscriptGASTestAbilityGivenListener* CancelByClassListener =
		NewObject<UAngelscriptGASTestAbilityGivenListener>(CancelByClassActor, TEXT("AbilityGivenListener_CancelByClass"));
	if (!TestNotNull(TEXT("GAS GiveAbility class-cancel scenario should create an ability-given listener"), CancelByClassListener))
	{
		return false;
	}

	CancelByClassAbilitySystemComponent->OnAbilityGiven.AddDynamic(
		CancelByClassListener,
		&UAngelscriptGASTestAbilityGivenListener::RecordAbilityGiven);

	UObject* SecondSourceObject =
		NewObject<UAngelscriptGASTestSourceObject>(CancelByClassActor, TEXT("AbilitySourceObjectB"));
	if (!TestNotNull(TEXT("GAS GiveAbility test should create a second source object"), SecondSourceObject))
	{
		return false;
	}

	const FGameplayAbilitySpecHandle SecondHandle =
		CancelByClassAbilitySystemComponent->BP_GiveAbility(
			UAngelscriptGASTestAbility::StaticClass(),
			1,
			InputID,
			SecondSourceObject);
	if (!TestTrue(TEXT("A second BP_GiveAbility call should also return a valid handle"), SecondHandle.IsValid()))
	{
		return false;
	}

	TestTrue(
		TEXT("The class-cancel scenario should also register the granted ability class"),
		CancelByClassAbilitySystemComponent->HasAbility(UAngelscriptGASTestAbility::StaticClass()));
	TestEqual(TEXT("OnAbilityGiven should broadcast exactly once for the class-cancel grant"), CancelByClassListener->BroadcastCount, 1);
	TestTrue(TEXT("The class-cancel grant should report the returned handle"), CancelByClassListener->LastHandle == SecondHandle);
	TestEqual(TEXT("The class-cancel grant should preserve the requested input id"), CancelByClassListener->LastInputID, InputID);
	TestTrue(TEXT("The class-cancel grant should preserve the requested source object"), CancelByClassListener->LastSourceObject == SecondSourceObject);

	FGameplayAbilitySpec* SecondSpec = FindAbilitySpec(*CancelByClassAbilitySystemComponent, SecondHandle);
	if (!TestNotNull(TEXT("The class-cancel grant should resolve to an ability spec"), SecondSpec))
	{
		return false;
	}

	TestEqual(TEXT("The class-cancel grant should preserve level 1"), SecondSpec->Level, 1);
	TestEqual(TEXT("The class-cancel grant should preserve the requested input id"), SecondSpec->InputID, InputID);
	TestTrue(TEXT("The class-cancel grant should preserve the requested source object"), SecondSpec->SourceObject.Get() == SecondSourceObject);

	if (!TestTrue(
		TEXT("TryActivateAbilitySpec should activate the class-cancel grant"),
		CancelByClassAbilitySystemComponent->TryActivateAbilitySpec(SecondHandle)))
	{
		return false;
	}

	UAngelscriptGASTestAbility* SecondAbilityInstance =
		GetPrimaryTestAbilityInstance(*CancelByClassAbilitySystemComponent, SecondHandle);
	if (!TestNotNull(TEXT("The second granted ability should create a primary instance"), SecondAbilityInstance))
	{
		return false;
	}

	TestEqual(TEXT("The second activated ability should record one activation"), SecondAbilityInstance->ActivationCount, 1);
	TestTrue(
		TEXT("The class-cancel scenario ability should report as active after activation"),
		CancelByClassAbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestAbility::StaticClass()));

	CancelByClassAbilitySystemComponent->CancelAbility(UAngelscriptGASTestAbility::StaticClass());
	TestFalse(
		TEXT("CancelAbility by class should deactivate the granted ability"),
		CancelByClassAbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestAbility::StaticClass()));
	TestEqual(TEXT("CancelAbility by class should end the second ability instance once"), SecondAbilityInstance->EndCount, 1);
	TestEqual(TEXT("Cancellation should not rebroadcast OnAbilityGiven"), CancelByClassListener->BroadcastCount, 1);

	ASTEST_END_SHARE_CLEAN
	return true;
}

bool FAngelscriptGASRemoveAbilityOnEndLifecycleTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS remove-on-end scenario should spawn a test actor"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS remove-on-end scenario should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	UAngelscriptGASTestAbilityGivenListener* RemovedListener =
		NewObject<UAngelscriptGASTestAbilityGivenListener>(TestActor, TEXT("AbilityRemovedListener"));
	if (!TestNotNull(TEXT("GAS remove-on-end scenario should create an ability-removed listener"), RemovedListener))
	{
		return false;
	}

	AbilitySystemComponent->OnAbilityRemoved.AddDynamic(
		RemovedListener,
		&UAngelscriptGASTestAbilityGivenListener::RecordAbilityGiven);

	UObject* SourceObject = NewObject<UAngelscriptGASTestSourceObject>(TestActor, TEXT("RemoveOnEndSourceObject"));
	if (!TestNotNull(TEXT("GAS remove-on-end scenario should create a source object"), SourceObject))
	{
		return false;
	}

	const int32 AbilityLevel = 5;
	const int32 InputID = 11;
	const FGameplayAbilitySpecHandle Handle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestAbility::StaticClass(), AbilityLevel, InputID, SourceObject);
	if (!TestTrue(TEXT("BP_GiveAbility should return a valid handle for remove-on-end"), Handle.IsValid()))
	{
		return false;
	}

	TestTrue(
		TEXT("Remove-on-end grant should register the requested ability class"),
		AbilitySystemComponent->HasAbility(UAngelscriptGASTestAbility::StaticClass()));
	TestTrue(
		TEXT("GetAbilitySpecSourceObject should expose the granted source object before removal"),
		AbilitySystemComponent->GetAbilitySpecSourceObject(Handle) == SourceObject);
	TestTrue(
		TEXT("CanActivateAbilitySpec should accept the granted handle before activation"),
		AbilitySystemComponent->CanActivateAbilitySpec(Handle));
	TestEqual(TEXT("OnAbilityRemoved should not broadcast before ability end"), RemovedListener->BroadcastCount, 0);

	if (!TestTrue(TEXT("TryActivateAbilitySpec should activate the remove-on-end grant"), AbilitySystemComponent->TryActivateAbilitySpec(Handle)))
	{
		return false;
	}

	UAngelscriptGASTestAbility* AbilityInstance = GetPrimaryTestAbilityInstance(*AbilitySystemComponent, Handle);
	if (!TestNotNull(TEXT("Remove-on-end activation should create a primary ability instance"), AbilityInstance))
	{
		return false;
	}

	TestEqual(TEXT("Remove-on-end activation should increment the activation count once"), AbilityInstance->ActivationCount, 1);
	TestTrue(
		TEXT("Granted ability should report active after activation"),
		AbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestAbility::StaticClass()));

	AbilitySystemComponent->BP_SetRemoveAbilityOnEnd(Handle);

	AbilitySystemComponent->CancelAbilityByHandle(Handle);

	TestEqual(TEXT("OnAbilityRemoved should broadcast exactly once for remove-on-end"), RemovedListener->BroadcastCount, 1);
	TestTrue(TEXT("OnAbilityRemoved should report the removed handle"), RemovedListener->LastHandle == Handle);
	TestEqual(TEXT("OnAbilityRemoved should preserve the granted level"), RemovedListener->LastLevel, AbilityLevel);
	TestEqual(TEXT("OnAbilityRemoved should preserve the granted input id"), RemovedListener->LastInputID, InputID);
	TestTrue(TEXT("OnAbilityRemoved should preserve the granted source object"), RemovedListener->LastSourceObject == SourceObject);
	TestTrue(
		TEXT("OnAbilityRemoved should preserve the removed ability class"),
		RemovedListener->LastAbilityClass == UAngelscriptGASTestAbility::StaticClass());

	TestFalse(
		TEXT("Remove-on-end should prune the granted ability after it ends"),
		AbilitySystemComponent->HasAbility(UAngelscriptGASTestAbility::StaticClass()));
	TestFalse(
		TEXT("Removed ability should no longer report active"),
		AbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestAbility::StaticClass()));
	AddExpectedError(TEXT("CanActivateAbilitySpec called with invalid Handle"), EAutomationExpectedErrorFlags::Contains, 1);
	TestFalse(
		TEXT("CanActivateAbilitySpec should reject the removed handle"),
		AbilitySystemComponent->CanActivateAbilitySpec(Handle));
	AddExpectedError(TEXT("GetAbilitySpecSourceObject called with invalid Handle"), EAutomationExpectedErrorFlags::Contains, 1);
	TestTrue(
		TEXT("GetAbilitySpecSourceObject should return nullptr after the spec is removed"),
		AbilitySystemComponent->GetAbilitySpecSourceObject(Handle) == nullptr);
	TestTrue(
		TEXT("Removed handle should no longer resolve to an ability spec"),
		FindAbilitySpec(*AbilitySystemComponent, Handle) == nullptr);

	AbilitySystemComponent->CancelAbilityByHandle(Handle);
	AbilitySystemComponent->CancelAbility(UAngelscriptGASTestAbility::StaticClass());

	TestEqual(
		TEXT("Repeated cancellation or query control paths should not rebroadcast OnAbilityRemoved"),
		RemovedListener->BroadcastCount,
		1);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
