/**
 * Nested USTRUCT defaults on an actor CDO. C++ reads Defaults.Weight and
 * Leaf.Count/Label. Keep the UPROPERTY name Defaults.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructNestedDefaultsReflection
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructNestedDefaultsReflection
 * @Provenance Theme: Definitions.UStruct. WorldStory nested USTRUCT defaults on an actor CDO.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructNestedDefaultsReflection
 * @Provenance CompileScriptModule + CDO: Defaults.Weight==29, Leaf.Count==17, Leaf.Label=="LeafDefault".
 * @Provenance Extra: independent empty leaf mutation; copy independence of branch vs mutated copy.
 * @Provenance FixtureIsolated. Keep UPROPERTY name Defaults.
 */

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

	/**
	 * Observe nested CDO defaults on this actor.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNestedDefaultsReflection
	 * @Inputs an actor that has not begun play
	 * @Return true when Weight is 29, Leaf.Count is 17, and Leaf.Label is LeafDefault
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool NestedDefaultsCDOShape()
	{
		if (Defaults.Weight != 29)
		{
			return false;
		}
		if (Defaults.Leaf.Count != 17)
		{
			return false;
		}
		return Defaults.Leaf.Label == "LeafDefault";
	}

	/**
	 * Observe that mutating a leaf copy leaves the original intact.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNestedDefaultsReflection
	 * @Inputs a copy whose Count and Label were cleared
	 * @Return true when the original keeps 17/LeafDefault and the copy is empty
	 * @Boundary independent leaf mutation
	 */
	UFUNCTION()
	bool NestedDefaultsEmptyIndependentLeaf()
	{
		FNestedDefaultLeaf Leaf;
		FNestedDefaultLeaf Mutated = Leaf;
		Mutated.Count = 0;
		Mutated.Label = "";
		if (Leaf.Count != 17)
		{
			return false;
		}
		if (Leaf.Label != "LeafDefault")
		{
			return false;
		}
		if (Mutated.Count != 0)
		{
			return false;
		}
		return Mutated.Label == "";
	}

	/**
	 * Observe that copying the branch does not alias nested leaf members.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNestedDefaultsReflection
	 * @Inputs a copy whose Weight and Leaf were cleared
	 * @Return true when the original keeps 29/17/LeafDefault and the copy is empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool NestedDefaultsCopyIndependence()
	{
		FNestedDefaultBranch Original;
		FNestedDefaultBranch Copy = Original;
		Copy.Weight = 0;
		Copy.Leaf.Count = 0;
		Copy.Leaf.Label = "";
		if (Original.Weight != 29)
		{
			return false;
		}
		if (Original.Leaf.Count != 17)
		{
			return false;
		}
		if (Original.Leaf.Label != "LeafDefault")
		{
			return false;
		}
		if (Copy.Weight != 0)
		{
			return false;
		}
		if (Copy.Leaf.Count != 0)
		{
			return false;
		}
		return Copy.Leaf.Label == "";
	}
}
