#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptGASAttributeSetRuntimeTests_Private
{
	const FName HealthAttributeName = GET_MEMBER_NAME_CHECKED(UAngelscriptGASTestReplicatedAttributeSet, Health);
	const FName ManaAttributeName = GET_MEMBER_NAME_CHECKED(UAngelscriptGASTestReplicatedAttributeSet, Mana);
	const float DelegatedHealthValue = 30.f;
	const float ReplicatedHealthValue = 55.f;
}

using namespace AngelscriptTest_Core_AngelscriptGASAttributeSetRuntimeTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASAttributeSetRuntimeConsistencyTest,
	"Angelscript.TestModule.Engine.GAS.AttributeSet.OwnerDelegationAndReplicationStayConsistent",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASAttributeSetRuntimeConsistencyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS AttributeSet runtime test should spawn a test actor"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS AttributeSet runtime test should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	UAngelscriptGASTestReplicatedAttributeSet* AttributeSet =
		Cast<UAngelscriptGASTestReplicatedAttributeSet>(
			AbilitySystemComponent->RegisterAttributeSet(UAngelscriptGASTestReplicatedAttributeSet::StaticClass()));
	if (!TestNotNull(TEXT("GAS AttributeSet runtime test should register a replicated attribute set"), AttributeSet))
	{
		return false;
	}

	TestTrue(
		TEXT("BP_GetOwningActor should resolve the owning actor through the registered ability-system component"),
		AttributeSet->BP_GetOwningActor() == TestActor);
	TestTrue(
		TEXT("BP_GetOwningAbilitySystemComponent should resolve the owning ability-system component"),
		AttributeSet->BP_GetOwningAbilitySystemComponent() == AbilitySystemComponent);

	FGameplayAttribute HealthAttribute;
	FGameplayAttribute HealthAttributeCopy;
	FGameplayAttribute ManaAttribute;
	if (!TestTrue(
			TEXT("TryGetGameplayAttribute should resolve the Health attribute on the replicated test set"),
			UAngelscriptAttributeSet::TryGetGameplayAttribute(
				UAngelscriptGASTestReplicatedAttributeSet::StaticClass(),
				HealthAttributeName,
				HealthAttribute))
		|| !TestTrue(
			TEXT("GetGameplayAttribute should resolve the same Health attribute for compare helper coverage"),
			UAngelscriptAttributeSet::TryGetGameplayAttribute(
				UAngelscriptGASTestReplicatedAttributeSet::StaticClass(),
				HealthAttributeName,
				HealthAttributeCopy))
		|| !TestTrue(
			TEXT("TryGetGameplayAttribute should resolve the Mana attribute for compare helper coverage"),
			UAngelscriptAttributeSet::TryGetGameplayAttribute(
				UAngelscriptGASTestReplicatedAttributeSet::StaticClass(),
				ManaAttributeName,
				ManaAttribute)))
	{
		return false;
	}

	TestTrue(
		TEXT("CompareGameplayAttributes should report the same gameplay attribute as equal"),
		UAngelscriptAttributeSet::CompareGameplayAttributes(HealthAttribute, HealthAttributeCopy));
	TestFalse(
		TEXT("CompareGameplayAttributes should report different gameplay attributes as not equal"),
		UAngelscriptAttributeSet::CompareGameplayAttributes(HealthAttribute, ManaAttribute));

	if (!TestTrue(
			TEXT("TrySetAttributeBaseValue should delegate through the owning ability-system component"),
			AttributeSet->TrySetAttributeBaseValue(HealthAttributeName, DelegatedHealthValue)))
	{
		return false;
	}

	float DelegatedBaseValue = 0.f;
	float DelegatedCurrentValue = 0.f;
	if (!TestTrue(
			TEXT("TryGetAttributeBaseValue should delegate through the owning ability-system component"),
			AttributeSet->TryGetAttributeBaseValue(HealthAttributeName, DelegatedBaseValue))
		|| !TestTrue(
			TEXT("TryGetAttributeCurrentValue should delegate through the owning ability-system component"),
			AttributeSet->TryGetAttributeCurrentValue(HealthAttributeName, DelegatedCurrentValue)))
	{
		return false;
	}

	TestEqual(
		TEXT("TryGetAttributeBaseValue should observe the delegated Health base value"),
		DelegatedBaseValue,
		DelegatedHealthValue);
	TestEqual(
		TEXT("TryGetAttributeCurrentValue should observe the delegated Health current value"),
		DelegatedCurrentValue,
		DelegatedHealthValue);

	FAngelscriptGameplayAttributeData OldHealth = AttributeSet->Health;
	AttributeSet->Health = FAngelscriptGameplayAttributeData(ReplicatedHealthValue);
	AttributeSet->Health.AttributeName = HealthAttributeName;
	AttributeSet->OnRep_Attribute(OldHealth);

	float ReplicatedBaseValue = 0.f;
	float ReplicatedCurrentValue = 0.f;
	if (!TestTrue(
			TEXT("ASC base-value lookup should still succeed after replication backfill"),
			AbilitySystemComponent->TryGetAttributeBaseValue(
				UAngelscriptGASTestReplicatedAttributeSet::StaticClass(),
				HealthAttributeName,
				ReplicatedBaseValue))
		|| !TestTrue(
			TEXT("ASC current-value lookup should still succeed after replication backfill"),
			AbilitySystemComponent->TryGetAttributeCurrentValue(
				UAngelscriptGASTestReplicatedAttributeSet::StaticClass(),
				HealthAttributeName,
				ReplicatedCurrentValue)))
	{
		return false;
	}

	TestEqual(
		TEXT("OnRep_Attribute should push the replicated Health base value back into the owning ability-system component"),
		ReplicatedBaseValue,
		ReplicatedHealthValue);
	TestEqual(
		TEXT("OnRep_Attribute should keep the replicated Health current value aligned with the owning ability-system component"),
		ReplicatedCurrentValue,
		ReplicatedHealthValue);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
