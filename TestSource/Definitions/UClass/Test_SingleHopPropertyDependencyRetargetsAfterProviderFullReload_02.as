// Theme: Definitions.UClass. Reload version pair 02 (layout change). Positive full-reload source.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::SingleHopPropertyDependencyRetargetsAfterProviderFullReload ReloadSource.
// Oracle: Provider.Value stays 1; AddedValue defaults to 2; Consumer.Provider still null on a live consumer.
// Retained: Provider/Consumer types, Value, Provider property. Replaced: AddedValue = 2.
// Extra: AddedValue 0 is the empty boundary; mutating one provider does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationProvider : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
}

UCLASS()
class UClassGeneratorPropagationConsumer : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationProvider Provider;
}

int Observe_SingleHopReload_ProviderDefaultValue(UClassGeneratorPropagationProvider Provider)
{
	return Provider.Value;
}

int Observe_SingleHopReload_AddedValueDefault(UClassGeneratorPropagationProvider Provider)
{
	return Provider.AddedValue;
}

int Observe_SingleHopReload_AddedValueEmptyBoundary(UClassGeneratorPropagationProvider Provider)
{
	Provider.AddedValue = 0;
	return Provider.AddedValue;
}

bool Observe_SingleHopReload_CopyIndependent(UClassGeneratorPropagationProvider First, UClassGeneratorPropagationProvider Second)
{
	First.AddedValue = 9;
	return Second.AddedValue == 2;
}
