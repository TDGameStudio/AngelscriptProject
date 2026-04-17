#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestUtilities.h"

#include "Components/ActorTestSpawner.h"
#include "GameplayEffect.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Core_AngelscriptGASAbilitySystemQueryTests_Private
{
	float GetMaxValue(const TArray<float>& Values)
	{
		float MaxValue = -1.f;
		for (const float Value : Values)
		{
			MaxValue = FMath::Max(MaxValue, Value);
		}

		return MaxValue;
	}
}

using namespace AngelscriptTest_Core_AngelscriptGASAbilitySystemQueryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASAbilitySystemQueryTest,
	"Angelscript.TestModule.Engine.GAS.AbilitySystem.SpecSourceObjectAndCooldownQueriesReflectLiveState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASAbilitySystemQueryTest::RunTest(const FString& Parameters)
{
	FAngelscriptTestFixture Fixture(*this, ETestEngineMode::IsolatedFull);
	if (!TestTrue(TEXT("GAS query test should acquire an isolated full engine"), Fixture.IsValid()))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS query test actor should spawn"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS query test actor should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	UObject* SourceObjectA = NewObject<UAngelscriptGASTestSourceObject>(TestActor, TEXT("AbilitySourceObjectA"));
	UObject* SourceObjectB = NewObject<UAngelscriptGASTestSourceObject>(TestActor, TEXT("AbilitySourceObjectB"));
	if (!TestNotNull(TEXT("GAS query test should create the initial source object"), SourceObjectA)
		|| !TestNotNull(TEXT("GAS query test should create the replacement source object"), SourceObjectB))
	{
		return false;
	}

	const FGameplayAbilitySpecHandle AbilityHandle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestCooldownAbility::StaticClass(), 1, 0, SourceObjectA);
	if (!TestTrue(TEXT("GAS query test should grant a valid ability handle"), AbilityHandle.IsValid()))
	{
		return false;
	}

	FActiveGameplayEffectHandle ShortCooldownHandle;
	FActiveGameplayEffectHandle LongCooldownHandle;
	ON_SCOPE_EXIT
	{
		if (AbilitySystemComponent != nullptr)
		{
			if (ShortCooldownHandle.IsValid())
			{
				AbilitySystemComponent->RemoveActiveGameplayEffect(ShortCooldownHandle);
			}

			if (LongCooldownHandle.IsValid())
			{
				AbilitySystemComponent->RemoveActiveGameplayEffect(LongCooldownHandle);
			}

			AbilitySystemComponent->CancelAbilityByHandle(AbilityHandle);
			AbilitySystemComponent->ClearAbility(AbilityHandle);
		}
	};

	TestTrue(
		TEXT("GetAbilitySpecSourceObject should return the source object recorded at grant time"),
		AbilitySystemComponent->GetAbilitySpecSourceObject(AbilityHandle) == SourceObjectA);
	TestTrue(
		TEXT("CanActivateAbilityByClass should succeed for the granted cooldown-test ability"),
		AbilitySystemComponent->CanActivateAbilityByClass(UAngelscriptGASTestCooldownAbility::StaticClass()));
	TestTrue(
		TEXT("CanActivateAbilitySpec should succeed for the granted cooldown-test ability handle"),
		AbilitySystemComponent->CanActivateAbilitySpec(AbilityHandle));

	AbilitySystemComponent->SetAbilitySpecSourceObject(AbilityHandle, SourceObjectB);
	TestTrue(
		TEXT("SetAbilitySpecSourceObject should make the replacement source object observable through the getter"),
		AbilitySystemComponent->GetAbilitySpecSourceObject(AbilityHandle) == SourceObjectB);

	TestEqual(
		TEXT("GetCooldownTimeRemaining should return zero before any matching cooldown effect is active"),
		AbilitySystemComponent->GetCooldownTimeRemaining(UAngelscriptGASTestCooldownAbility::StaticClass()),
		0.f);
	AddExpectedErrorPlain(TEXT("Ensure condition failed: HasAbility(InAbilityClass)"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedErrorPlain(TEXT("LogOutputDevice:"), EAutomationExpectedErrorFlags::Contains, 0);
	TestEqual(
		TEXT("GetCooldownTimeRemaining should return -1 for an ability class that has not been granted"),
		AbilitySystemComponent->GetCooldownTimeRemaining(UAngelscriptGASTestAbility::StaticClass()),
		-1.f);

	const FGameplayTagContainer* CooldownTags = GetDefault<UAngelscriptGASTestCooldownAbility>()->GetCooldownTags();
	if (!TestNotNull(TEXT("GAS query test ability should expose a cooldown tag container"), CooldownTags)
		|| !TestTrue(TEXT("GAS query test ability should resolve at least one valid cooldown tag"), CooldownTags->Num() > 0))
	{
		return false;
	}

	UAngelscriptGASTestCooldownEffect* CooldownEffect = GetMutableDefault<UAngelscriptGASTestCooldownEffect>();
	if (!TestNotNull(TEXT("GAS query test should resolve the mutable cooldown gameplay-effect CDO"), CooldownEffect))
	{
		return false;
	}

	CooldownEffect->ConfigureGrantedTags(*CooldownTags);

	const FGameplayEffectContextHandle EffectContext = AbilitySystemComponent->MakeEffectContext();
	FGameplayEffectSpec ShortCooldownSpec(CooldownEffect, EffectContext, 1.f);
	ShortCooldownSpec.SetDuration(2.f, false);
	ShortCooldownHandle = AbilitySystemComponent->ApplyGameplayEffectSpecToSelf(ShortCooldownSpec);

	FGameplayEffectSpec LongCooldownSpec(CooldownEffect, EffectContext, 1.f);
	LongCooldownSpec.SetDuration(5.f, false);
	LongCooldownHandle = AbilitySystemComponent->ApplyGameplayEffectSpecToSelf(LongCooldownSpec);

	if (!TestTrue(TEXT("GAS query test should apply the short cooldown effect"), ShortCooldownHandle.IsValid())
		|| !TestTrue(TEXT("GAS query test should apply the long cooldown effect"), LongCooldownHandle.IsValid()))
	{
		return false;
	}

	const FGameplayEffectQuery CooldownQuery = FGameplayEffectQuery::MakeQuery_MatchAnyOwningTags(*CooldownTags);
	const TArray<float> ActiveCooldownDurations = AbilitySystemComponent->GetActiveEffectsTimeRemaining(CooldownQuery);
	if (!TestTrue(TEXT("GAS query test should observe both active cooldown effects"), ActiveCooldownDurations.Num() >= 2))
	{
		return false;
	}

	const float ExpectedMaxDuration = GetMaxValue(ActiveCooldownDurations);
	const float CooldownTimeRemaining =
		AbilitySystemComponent->GetCooldownTimeRemaining(UAngelscriptGASTestCooldownAbility::StaticClass());

	TestTrue(
		TEXT("GetCooldownTimeRemaining should report a positive cooldown while matching effects are active"),
		CooldownTimeRemaining > 0.f);
	TestTrue(
		TEXT("GetCooldownTimeRemaining should stay very close to the longest active cooldown remaining time"),
		CooldownTimeRemaining <= ExpectedMaxDuration + KINDA_SMALL_NUMBER
			&& CooldownTimeRemaining >= ExpectedMaxDuration - 0.25f);

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASAbilitySystemInvalidHandleGuardsTest,
	"Angelscript.TestModule.Engine.GAS.AbilitySystem.InvalidSpecHandleGuardsDoNotCrashOrMutateState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASCheckedAttributeGetterMissingSetTest,
	"Angelscript.TestModule.Engine.GAS.AbilitySystem.CheckedAttributeGettersReportMissingSetDeterministically",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASAbilitySystemInvalidHandleGuardsTest::RunTest(const FString& Parameters)
{
	FAngelscriptTestFixture Fixture(*this, ETestEngineMode::IsolatedFull);
	if (!TestTrue(TEXT("GAS invalid-handle guard test should acquire an isolated full engine"), Fixture.IsValid()))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS invalid-handle guard test actor should spawn"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS invalid-handle guard test actor should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	UObject* SourceObjectA = NewObject<UAngelscriptGASTestSourceObject>(TestActor, TEXT("AbilitySourceObjectA"));
	UObject* RogueSourceObject = NewObject<UAngelscriptGASTestSourceObject>(TestActor, TEXT("AbilitySourceObjectRogue"));
	if (!TestNotNull(TEXT("GAS invalid-handle guard test should create the granted source object"), SourceObjectA)
		|| !TestNotNull(TEXT("GAS invalid-handle guard test should create the rogue source object"), RogueSourceObject))
	{
		return false;
	}

	const FGameplayAbilitySpecHandle ValidHandle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestCooldownAbility::StaticClass(), 1, 0, SourceObjectA);
	if (!TestTrue(TEXT("GAS invalid-handle guard test should grant a valid ability handle"), ValidHandle.IsValid()))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		if (AbilitySystemComponent != nullptr && ValidHandle.IsValid())
		{
			AbilitySystemComponent->CancelAbilityByHandle(ValidHandle);
			AbilitySystemComponent->ClearAbility(ValidHandle);
		}
	};

	const FGameplayAbilitySpecHandle InvalidHandle;

	TestTrue(
		TEXT("The control valid handle should expose the original source object before invalid-handle probes"),
		AbilitySystemComponent->GetAbilitySpecSourceObject(ValidHandle) == SourceObjectA);
	TestTrue(
		TEXT("The control valid handle should remain activatable before invalid-handle probes"),
		AbilitySystemComponent->CanActivateAbilitySpec(ValidHandle));

	TestFalse(
		TEXT("CanActivateAbilitySpec should fail closed for a default-constructed invalid handle"),
		AbilitySystemComponent->CanActivateAbilitySpec(InvalidHandle));
	TestNull(
		TEXT("GetAbilitySpecSourceObject should return nullptr for a default-constructed invalid handle"),
		AbilitySystemComponent->GetAbilitySpecSourceObject(InvalidHandle));

	AbilitySystemComponent->SetAbilitySpecSourceObject(InvalidHandle, RogueSourceObject);
	AbilitySystemComponent->CancelAbilityByHandle(InvalidHandle);

	TestTrue(
		TEXT("The valid granted ability should still be present after invalid-handle mutation probes"),
		AbilitySystemComponent->HasAbility(UAngelscriptGASTestCooldownAbility::StaticClass()));
	TestTrue(
		TEXT("The valid handle source object should remain unchanged after invalid-handle mutation probes"),
		AbilitySystemComponent->GetAbilitySpecSourceObject(ValidHandle) == SourceObjectA);
	TestTrue(
		TEXT("The valid handle should remain activatable after invalid-handle mutation probes"),
		AbilitySystemComponent->CanActivateAbilitySpec(ValidHandle));

	return true;
}

bool FAngelscriptGASCheckedAttributeGetterMissingSetTest::RunTest(const FString& Parameters)
{
	FAngelscriptTestFixture Fixture(*this, ETestEngineMode::IsolatedFull);
	if (!TestTrue(TEXT("GAS checked-attribute getter test should acquire an isolated full engine"), Fixture.IsValid()))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS checked-attribute getter test actor should spawn"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS checked-attribute getter test actor should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	const FName HealthAttributeName = GET_MEMBER_NAME_CHECKED(UAngelscriptGASTestAttributeSet, Health);
	const int32 InitialSpawnedAttributeCount = AbilitySystemComponent->GetSpawnedAttributes().Num();

	AddExpectedErrorPlain(
		TEXT("Ensure condition failed: TryGetAttributeCurrentValue(AttributeSetClass, AttributeName, OutCurrentValue)"),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedErrorPlain(
		TEXT("Ensure condition failed: TryGetAttributeBaseValue(AttributeSetClass, AttributeName, OutBaseValue)"),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedErrorPlain(TEXT("LogOutputDevice:"), EAutomationExpectedErrorFlags::Contains, 0);

	const float MissingCurrentFirst =
		AbilitySystemComponent->GetAttributeCurrentValueChecked(UAngelscriptGASTestAttributeSet::StaticClass(), HealthAttributeName);
	volatile float CurrentPathStackNoise = 17.25f;
	if (CurrentPathStackNoise < 0.f)
	{
		AddInfo(TEXT("Current-path stack noise branch should never execute."));
	}

	const float MissingCurrentSecond =
		AbilitySystemComponent->GetAttributeCurrentValueChecked(UAngelscriptGASTestAttributeSet::StaticClass(), HealthAttributeName);
	volatile float BasePathStackNoise = 29.5f;
	if (BasePathStackNoise < 0.f)
	{
		AddInfo(TEXT("Base-path stack noise branch should never execute."));
	}

	const float MissingBaseFirst =
		AbilitySystemComponent->GetAttributeBaseValueChecked(UAngelscriptGASTestAttributeSet::StaticClass(), HealthAttributeName);
	volatile float RepeatBasePathStackNoise = 41.75f;
	if (RepeatBasePathStackNoise < 0.f)
	{
		AddInfo(TEXT("Repeat base-path stack noise branch should never execute."));
	}

	const float MissingBaseSecond =
		AbilitySystemComponent->GetAttributeBaseValueChecked(UAngelscriptGASTestAttributeSet::StaticClass(), HealthAttributeName);

	TestEqual(
		TEXT("Checked attribute getters should not create spawned attribute sets on the missing-set path"),
		AbilitySystemComponent->GetSpawnedAttributes().Num(),
		InitialSpawnedAttributeCount);
	TestEqual(
		TEXT("GetAttributeCurrentValueChecked should return the same value across repeated missing-set calls"),
		MissingCurrentFirst,
		MissingCurrentSecond);
	TestEqual(
		TEXT("GetAttributeBaseValueChecked should return the same value across repeated missing-set calls"),
		MissingBaseFirst,
		MissingBaseSecond);
	TestEqual(
		TEXT("GetAttributeCurrentValueChecked should fail closed to 0 when the attribute set is missing"),
		MissingCurrentFirst,
		0.f);
	TestEqual(
		TEXT("GetAttributeBaseValueChecked should fail closed to 0 when the attribute set is missing"),
		MissingBaseFirst,
		0.f);

	UAngelscriptGASTestAttributeSet* AttributeSet =
		Cast<UAngelscriptGASTestAttributeSet>(
			AbilitySystemComponent->RegisterAttributeSet(UAngelscriptGASTestAttributeSet::StaticClass()));
	if (!TestNotNull(TEXT("Checked attribute getter test should register the control attribute set"), AttributeSet))
	{
		return false;
	}

	TestEqual(
		TEXT("RegisterAttributeSet should add exactly one spawned attribute set for the control path"),
		AbilitySystemComponent->GetSpawnedAttributes().Num(),
		InitialSpawnedAttributeCount + 1);
	if (!TestTrue(
			TEXT("Checked attribute getter control path should set the Health base value"),
			AbilitySystemComponent->TrySetAttributeBaseValue(
				UAngelscriptGASTestAttributeSet::StaticClass(),
				HealthAttributeName,
				25.f)))
	{
		return false;
	}

	TestEqual(
		TEXT("GetAttributeCurrentValueChecked should return the registered attribute current value"),
		AbilitySystemComponent->GetAttributeCurrentValueChecked(UAngelscriptGASTestAttributeSet::StaticClass(), HealthAttributeName),
		25.f);
	TestEqual(
		TEXT("GetAttributeBaseValueChecked should return the registered attribute base value"),
		AbilitySystemComponent->GetAttributeBaseValueChecked(UAngelscriptGASTestAttributeSet::StaticClass(), HealthAttributeName),
		25.f);

	return true;
}

#endif
