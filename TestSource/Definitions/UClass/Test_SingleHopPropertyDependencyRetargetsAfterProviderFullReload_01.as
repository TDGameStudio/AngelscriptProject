// Theme: Definitions.UClass. Reload version pair 01 (initial). Positive full-reload planning source.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::SingleHopPropertyDependencyRetargetsAfterProviderFullReload InitialSource.
// Oracle: Provider.Value defaults to 1; Consumer.Provider is null on a live consumer.
// Retained after reload: Provider/Consumer types and the Provider property. Replaced in 02: AddedValue.
// Extra: Value 0 is the empty boundary; mutating one provider does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationProvider : UObject
{
	UPROPERTY()
	int Value = 1;
}

UCLASS()
class UClassGeneratorPropagationConsumer : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationProvider Provider;
}

int Observe_SingleHopInitial_ProviderDefaultValue(UClassGeneratorPropagationProvider Provider)
{
	return Provider.Value;
}

int Observe_SingleHopInitial_ProviderEmptyValueBoundary(UClassGeneratorPropagationProvider Provider)
{
	Provider.Value = 0;
	return Provider.Value;
}

bool Observe_SingleHopInitial_ConsumerProviderNull(UClassGeneratorPropagationConsumer Consumer)
{
	return Consumer.Provider == nullptr;
}

bool Observe_SingleHopInitial_CopyIndependent(UClassGeneratorPropagationProvider First, UClassGeneratorPropagationProvider Second)
{
	First.Value = 9;
	return Second.Value == 1;
}
