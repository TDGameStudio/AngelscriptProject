// Theme: Definitions.UClass. Reload version pair 02 (leaf layout change). Positive multi-hop chain.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::MultiHopPropertyDependencyRetargetsEntireChain ReloadSource.
// Oracle: Leaf.Value stays 1; AddedValue defaults to 2; Middle.Leaf and Root.Middle still null on live owners.
// Retained: Leaf/Middle/Root types and property names. Replaced: Leaf.AddedValue = 2.
// Extra: AddedValue 0 is the empty boundary; mutating one leaf does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationLeaf : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
}

UCLASS()
class UClassGeneratorPropagationMiddle : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationLeaf Leaf;
}

UCLASS()
class UClassGeneratorPropagationRoot : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationMiddle Middle;
}

int Observe_MultiHopReload_LeafDefaultValue(UClassGeneratorPropagationLeaf Leaf)
{
	return Leaf.Value;
}

int Observe_MultiHopReload_AddedValueDefault(UClassGeneratorPropagationLeaf Leaf)
{
	return Leaf.AddedValue;
}

int Observe_MultiHopReload_AddedValueEmptyBoundary(UClassGeneratorPropagationLeaf Leaf)
{
	Leaf.AddedValue = 0;
	return Leaf.AddedValue;
}

bool Observe_MultiHopReload_CopyIndependent(UClassGeneratorPropagationLeaf First, UClassGeneratorPropagationLeaf Second)
{
	First.AddedValue = 9;
	return Second.AddedValue == 2;
}
