// Theme: Definitions.UClass. Reload version pair 01 (initial). Positive multi-hop chain.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::MultiHopPropertyDependencyRetargetsEntireChain InitialSource.
// Oracle: Leaf.Value defaults to 1; Middle.Leaf and Root.Middle are null on live owners.
// Retained after reload: Leaf/Middle/Root types and property names. Replaced in 02: Leaf.AddedValue.
// Extra: Value 0 is the empty boundary; mutating one leaf does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationLeaf : UObject
{
	UPROPERTY()
	int Value = 1;
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

int Observe_MultiHopInitial_LeafDefaultValue(UClassGeneratorPropagationLeaf Leaf)
{
	return Leaf.Value;
}

int Observe_MultiHopInitial_LeafEmptyValueBoundary(UClassGeneratorPropagationLeaf Leaf)
{
	Leaf.Value = 0;
	return Leaf.Value;
}

bool Observe_MultiHopInitial_MiddleLeafNull(UClassGeneratorPropagationMiddle Middle)
{
	return Middle.Leaf == nullptr;
}

bool Observe_MultiHopInitial_CopyIndependent(UClassGeneratorPropagationLeaf First, UClassGeneratorPropagationLeaf Second)
{
	First.Value = 9;
	return Second.Value == 1;
}
