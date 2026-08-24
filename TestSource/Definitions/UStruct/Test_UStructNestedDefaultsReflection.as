// Theme: Definitions.UStruct. WorldStory nested USTRUCT defaults on an actor CDO.
// C++: AngelscriptCoverageUStructTests.cpp::UStructNestedDefaultsReflection
// CompileScriptModule + CDO: Defaults.Weight==29, Leaf.Count==17, Leaf.Label=="LeafDefault".
// Extra: independent empty leaf mutation; copy independence of branch vs mutated copy.
// FixtureIsolated. Keep UPROPERTY name Defaults.

USTRUCT(BlueprintType)
struct FNestedDefaultLeaf
{
	UPROPERTY(EditAnywhere)
	int Count = 17;

	UPROPERTY(BlueprintReadOnly)
	FString Label = "LeafDefault";
}

USTRUCT(BlueprintType)
struct FNestedDefaultBranch
{
	UPROPERTY(EditAnywhere)
	int Weight = 29;

	UPROPERTY(EditAnywhere)
	FNestedDefaultLeaf Leaf;
}

UCLASS()
class ACoverageStructNestedDefaultsActor : AActor
{
	UPROPERTY(EditAnywhere)
	FNestedDefaultBranch Defaults;
}

bool Observe_NestedDefaults_CDOShape(ACoverageStructNestedDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructNestedDefaultsReflection setup: required Actor is null");
	}
	return Actor.Defaults.Weight == 29
		&& Actor.Defaults.Leaf.Count == 17
		&& Actor.Defaults.Leaf.Label == "LeafDefault";
}

bool Observe_NestedDefaults_EmptyIndependentLeaf()
{
	FNestedDefaultLeaf Leaf;
	FNestedDefaultLeaf Mutated = Leaf;
	Mutated.Count = 0;
	Mutated.Label = "";
	return Leaf.Count == 17 && Leaf.Label == "LeafDefault"
		&& Mutated.Count == 0 && Mutated.Label == "";
}

bool Observe_NestedDefaults_CopyIndependence()
{
	FNestedDefaultBranch Original;
	FNestedDefaultBranch Copy = Original;
	Copy.Weight = 0;
	Copy.Leaf.Count = 0;
	Copy.Leaf.Label = "";
	return Original.Weight == 29 && Original.Leaf.Count == 17
		&& Original.Leaf.Label == "LeafDefault"
		&& Copy.Weight == 0 && Copy.Leaf.Count == 0 && Copy.Leaf.Label == "";
}
