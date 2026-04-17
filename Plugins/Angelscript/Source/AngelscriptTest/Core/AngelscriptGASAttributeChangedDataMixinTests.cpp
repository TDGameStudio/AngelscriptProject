#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestUtilities.h"

#include "Components/ActorTestSpawner.h"
#include "GameplayEffect.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Core_AngelscriptGASAttributeChangedDataMixinTests_Private
{
	const FName HealthAttributeName = GET_MEMBER_NAME_CHECKED(UAngelscriptGASTestAttributeSet, Health);
	const float InitialHealthValue = 10.f;
	const float HealthDeltaMagnitude = 15.f;
	const float UpdatedHealthValue = InitialHealthValue + HealthDeltaMagnitude;

	bool InitializeAttributeChangedDataFixture(
		FAutomationTestBase& Test,
		FActorTestSpawner& Spawner,
		AAngelscriptGASTestActor*& OutActor,
		UAngelscriptAbilitySystemComponent*& OutAbilitySystemComponent,
		FGameplayAttribute& OutHealthAttribute)
	{
		OutActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
		if (!Test.TestNotNull(TEXT("AttributeChangedData mixin test should spawn a test actor"), OutActor))
		{
			return false;
		}

		OutAbilitySystemComponent = OutActor->AbilitySystemComponent;
		if (!Test.TestNotNull(TEXT("AttributeChangedData mixin test should expose an ability-system component"), OutAbilitySystemComponent))
		{
			return false;
		}

		OutAbilitySystemComponent->InitAbilityActorInfo(OutActor, OutActor);

		UAngelscriptAttributeSet* AttributeSet =
			OutAbilitySystemComponent->RegisterAttributeSet(UAngelscriptGASTestAttributeSet::StaticClass());
		if (!Test.TestNotNull(TEXT("AttributeChangedData mixin test should register a test attribute set"), AttributeSet))
		{
			return false;
		}

		if (!Test.TestTrue(
				TEXT("AttributeChangedData mixin test should resolve the Health gameplay attribute"),
				UAngelscriptAttributeSet::TryGetGameplayAttribute(
					UAngelscriptGASTestAttributeSet::StaticClass(),
					HealthAttributeName,
					OutHealthAttribute)))
		{
			return false;
		}

		return Test.TestTrue(
			TEXT("AttributeChangedData mixin test should seed the Health attribute"),
			OutAbilitySystemComponent->TrySetAttributeBaseValue(
				UAngelscriptGASTestAttributeSet::StaticClass(),
				HealthAttributeName,
				InitialHealthValue));
	}

	UGameplayEffect* CreateInstantHealthModifierEffect(
		UObject* Outer,
		const FGameplayAttribute& HealthAttribute)
	{
		UGameplayEffect* Effect = NewObject<UGameplayEffect>(Outer, TEXT("AttributeChangedDataMixinInstantEffect"));
		check(Effect != nullptr);

		Effect->DurationPolicy = EGameplayEffectDurationType::Instant;

		FGameplayModifierInfo& Modifier = Effect->Modifiers.AddDefaulted_GetRef();
		Modifier.Attribute = HealthAttribute;
		Modifier.ModifierOp = EGameplayModOp::Additive;
		Modifier.ModifierMagnitude = FGameplayEffectModifierMagnitude(FScalableFloat(HealthDeltaMagnitude));

		return Effect;
	}
}

using namespace AngelscriptTest_Core_AngelscriptGASAttributeChangedDataMixinTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASAttributeChangedDataMixinTest,
	"Angelscript.TestModule.Engine.GAS.AttributeChangedDataMixin.AccessorsExposeWrappedCallbackDataAndNullPaths",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASAttributeChangedDataMixinTest::RunTest(const FString& Parameters)
{
	FAngelscriptTestFixture Fixture(*this, ETestEngineMode::IsolatedFull);
	if (!TestTrue(TEXT("AttributeChangedData mixin test should acquire an isolated full engine"), Fixture.IsValid()))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = nullptr;
	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = nullptr;
	FGameplayAttribute HealthAttribute;
	if (!InitializeAttributeChangedDataFixture(
			*this,
			Spawner,
			TestActor,
			AbilitySystemComponent,
			HealthAttribute))
	{
		return false;
	}

	FAngelscriptAttributeChangedData ControlData;
	ControlData.WrappedData.Attribute = HealthAttribute;
	ControlData.WrappedData.OldValue = InitialHealthValue;
	ControlData.WrappedData.NewValue = UpdatedHealthValue;

	bool bControlEffectSpecValid = true;
	const FGameplayEffectSpec& ControlEffectSpec =
		UAngelscriptAttributeChangedDataMixinLibrary::GetEffectSpec(ControlData, bControlEffectSpecValid);
	bool bControlEvaluatedDataValid = true;
	const FGameplayModifierEvaluatedData& ControlEvaluatedData =
		UAngelscriptAttributeChangedDataMixinLibrary::GetGameplayModifierEvaluatedData(ControlData, bControlEvaluatedDataValid);

	TestTrue(
		TEXT("AttributeChangedData mixin control case should preserve the wrapped gameplay attribute"),
		UAngelscriptAttributeSet::CompareGameplayAttributes(
			UAngelscriptAttributeChangedDataMixinLibrary::GetGameplayAttribute(ControlData),
			HealthAttribute));
	TestEqual(
		TEXT("AttributeChangedData mixin control case should preserve the wrapped old value"),
		UAngelscriptAttributeChangedDataMixinLibrary::GetOldValue(ControlData),
		InitialHealthValue);
	TestEqual(
		TEXT("AttributeChangedData mixin control case should preserve the wrapped new value"),
		UAngelscriptAttributeChangedDataMixinLibrary::GetNewValue(ControlData),
		UpdatedHealthValue);
	TestFalse(
		TEXT("AttributeChangedData mixin control case should report an invalid gameplay-effect spec when GEModData is null"),
		bControlEffectSpecValid);
	TestFalse(
		TEXT("AttributeChangedData mixin control case should report invalid evaluated data when GEModData is null"),
		bControlEvaluatedDataValid);
	TestNull(
		TEXT("AttributeChangedData mixin control case should return nullptr for the target ASC when GEModData is null"),
		UAngelscriptAttributeChangedDataMixinLibrary::GetTargetAbilitySystemComponent(ControlData));
	TestFalse(
		TEXT("AttributeChangedData mixin control case should keep the dummy effect spec definition null"),
		ControlEffectSpec.Def != nullptr);
	TestFalse(
		TEXT("AttributeChangedData mixin control case should keep the dummy evaluated-data attribute invalid"),
		ControlEvaluatedData.Attribute.IsValid());

	UAngelscriptGASTestAttributeChangedListener* Listener =
		NewObject<UAngelscriptGASTestAttributeChangedListener>(TestActor, TEXT("AttributeChangedDataListener"));
	if (!TestNotNull(TEXT("AttributeChangedData mixin test should create an attribute-change listener"), Listener))
	{
		return false;
	}

	float CurrentValueBeforeRegistration = -1.f;
	AbilitySystemComponent->GetAndRegisterAttributeChangedCallback(
		UAngelscriptGASTestAttributeSet::StaticClass(),
		HealthAttributeName,
		Listener,
		GET_FUNCTION_NAME_CHECKED(UAngelscriptGASTestAttributeChangedListener, RecordAttributeChanged),
		CurrentValueBeforeRegistration);
	TestEqual(
		TEXT("AttributeChangedData mixin test should report the seeded Health value before registration"),
		CurrentValueBeforeRegistration,
		InitialHealthValue);

	UGameplayEffect* HealthEffect = CreateInstantHealthModifierEffect(TestActor, HealthAttribute);
	if (!TestNotNull(TEXT("AttributeChangedData mixin test should create an instant Health gameplay effect"), HealthEffect))
	{
		return false;
	}

	const FGameplayEffectContextHandle EffectContext = AbilitySystemComponent->MakeEffectContext();
	FGameplayEffectSpec HealthEffectSpec(HealthEffect, EffectContext, 1.f);
	AbilitySystemComponent->ApplyGameplayEffectSpecToSelf(HealthEffectSpec);

	if (!TestEqual(
			TEXT("AttributeChangedData mixin test should receive exactly one callback after applying the gameplay effect"),
			Listener->CallbackCount,
			1))
	{
		return false;
	}

	TestEqual(
		TEXT("AttributeChangedData mixin test should report the Health attribute name from the listener"),
		Listener->LastAttributeName,
		HealthAttributeName);
	TestEqual(
		TEXT("AttributeChangedData mixin test should report the previous Health value from the listener"),
		Listener->LastOldValue,
		InitialHealthValue);
	TestEqual(
		TEXT("AttributeChangedData mixin test should report the updated Health value from the listener"),
		Listener->LastNewValue,
		UpdatedHealthValue);

	const FAngelscriptAttributeChangedData& CallbackData = Listener->LastAttributeChangeData;
	bool bEffectSpecValid = false;
	const FGameplayEffectSpec& ExposedEffectSpec =
		UAngelscriptAttributeChangedDataMixinLibrary::GetEffectSpec(CallbackData, bEffectSpecValid);
	bool bEvaluatedDataValid = false;
	const FGameplayModifierEvaluatedData& ExposedEvaluatedData =
		UAngelscriptAttributeChangedDataMixinLibrary::GetGameplayModifierEvaluatedData(CallbackData, bEvaluatedDataValid);

	TestTrue(
		TEXT("AttributeChangedData mixin callback case should expose the wrapped gameplay attribute"),
		UAngelscriptAttributeSet::CompareGameplayAttributes(
			UAngelscriptAttributeChangedDataMixinLibrary::GetGameplayAttribute(CallbackData),
			HealthAttribute));
	TestEqual(
		TEXT("AttributeChangedData mixin callback case should expose the wrapped old value"),
		UAngelscriptAttributeChangedDataMixinLibrary::GetOldValue(CallbackData),
		InitialHealthValue);
	TestEqual(
		TEXT("AttributeChangedData mixin callback case should expose the wrapped new value"),
		UAngelscriptAttributeChangedDataMixinLibrary::GetNewValue(CallbackData),
		UpdatedHealthValue);
	TestTrue(
		TEXT("AttributeChangedData mixin callback case should report a valid gameplay-effect spec"),
		bEffectSpecValid);
	TestTrue(
		TEXT("AttributeChangedData mixin callback case should report valid evaluated data"),
		bEvaluatedDataValid);
	TestTrue(
		TEXT("AttributeChangedData mixin callback case should expose the same gameplay-effect definition"),
		ExposedEffectSpec.Def == HealthEffect);
	TestTrue(
		TEXT("AttributeChangedData mixin callback case should expose the target ability-system component"),
		UAngelscriptAttributeChangedDataMixinLibrary::GetTargetAbilitySystemComponent(CallbackData) == AbilitySystemComponent);
	TestTrue(
		TEXT("AttributeChangedData mixin callback case should expose the evaluated Health attribute"),
		UAngelscriptAttributeSet::CompareGameplayAttributes(ExposedEvaluatedData.Attribute, HealthAttribute));
	TestEqual(
		TEXT("AttributeChangedData mixin callback case should expose the additive modifier op"),
		static_cast<uint8>(ExposedEvaluatedData.ModifierOp.GetValue()),
		static_cast<uint8>(EGameplayModOp::Additive));
	TestEqual(
		TEXT("AttributeChangedData mixin callback case should expose the evaluated modifier magnitude"),
		ExposedEvaluatedData.Magnitude,
		HealthDeltaMagnitude);

	return true;
}

#endif
