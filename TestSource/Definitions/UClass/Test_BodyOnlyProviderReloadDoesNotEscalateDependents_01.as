// Theme: Definitions.UClass. Reload version pair 01 (initial). Positive body-only soft reload.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::BodyOnlyProviderReloadDoesNotEscalateDependents InitialSource.
// Oracle: GetValue returns 1; live Consumer.Provider is null.
// Retained after reload: SoftProvider/SoftConsumer types, GetValue, Provider property. Replaced in 02: GetValue body 1 -> 2.
// Extra: unset provider handle is null; two live providers both return 1.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationSoftProvider : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}

UCLASS()
class UClassGeneratorPropagationSoftConsumer : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationSoftProvider Provider;
}

int Observe_SoftInitial_GetValueDefault(UClassGeneratorPropagationSoftProvider Provider)
{
	return Provider.GetValue();
}

bool Observe_SoftInitial_ConsumerProviderNull(UClassGeneratorPropagationSoftConsumer Consumer)
{
	return Consumer.Provider == nullptr;
}

bool Observe_SoftInitial_NullDefault()
{
	UClassGeneratorPropagationSoftProvider Provider = nullptr;
	return Provider == nullptr;
}

int Observe_SoftInitial_GetValueOnTwo(UClassGeneratorPropagationSoftProvider First, UClassGeneratorPropagationSoftProvider Second)
{
	return First.GetValue() + Second.GetValue();
}
