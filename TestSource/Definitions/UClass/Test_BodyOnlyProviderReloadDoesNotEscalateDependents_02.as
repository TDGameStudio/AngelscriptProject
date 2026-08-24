// Theme: Definitions.UClass. Reload version pair 02 (body-only). Positive soft-reload source.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::BodyOnlyProviderReloadDoesNotEscalateDependents ReloadSource.
// Oracle: GetValue returns 2; live Consumer.Provider is still null.
// Retained: SoftProvider/SoftConsumer types, GetValue name, Provider property. Replaced: GetValue body 1 -> 2.
// Extra: unset provider handle is null; two live providers both return 2.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationSoftProvider : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 2;
	}
}

UCLASS()
class UClassGeneratorPropagationSoftConsumer : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationSoftProvider Provider;
}

int Observe_SoftReload_GetValueDefault(UClassGeneratorPropagationSoftProvider Provider)
{
	return Provider.GetValue();
}

bool Observe_SoftReload_ConsumerProviderNull(UClassGeneratorPropagationSoftConsumer Consumer)
{
	return Consumer.Provider == nullptr;
}

bool Observe_SoftReload_NullDefault()
{
	UClassGeneratorPropagationSoftProvider Provider = nullptr;
	return Provider == nullptr;
}

int Observe_SoftReload_GetValueOnTwo(UClassGeneratorPropagationSoftProvider First, UClassGeneratorPropagationSoftProvider Second)
{
	return First.GetValue() + Second.GetValue();
}
