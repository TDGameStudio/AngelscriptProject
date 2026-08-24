// Theme: Definitions.UStruct. WorldStory nested TArray/TMap/TSet copy independence.
// C++: AngelscriptCoverageUStructTests.cpp::UStructNestedContainerCopySemantics
// spawn + BeginPlay + VerifyByPath bArrayIndependent/bMapIndependent/bSetIndependent all true.
// Extra: empty default containers; local copy independence without spawn.
// FixtureIsolated. Keep UPROPERTY names bArrayIndependent, bMapIndependent, bSetIndependent.

USTRUCT()
struct FNestedContainerCopyStruct
{
	UPROPERTY()
	TArray<int> Values;

	UPROPERTY()
	TMap<int, int> Scores;

	UPROPERTY()
	TSet<int> Tags;
}

UCLASS()
class ANestedContainerCopyActor : AActor
{
	UPROPERTY()
	bool bArrayIndependent = false;

	UPROPERTY()
	bool bMapIndependent = false;

	UPROPERTY()
	bool bSetIndependent = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FNestedContainerCopyStruct Original;
		Original.Values.Add(1);
		Original.Scores.Add(1, 10);
		Original.Tags.Add(1);

		FNestedContainerCopyStruct Copy = Original;
		Copy.Values.Add(2);
		Copy.Scores.Add(2, 20);
		Copy.Tags.Add(2);

		bArrayIndependent = Original.Values.Num() == 1 && Copy.Values.Num() == 2;
		bMapIndependent = Original.Scores.Num() == 1 && Copy.Scores.Num() == 2;
		bSetIndependent = Original.Tags.Num() == 1 && Copy.Tags.Num() == 2;
	}
}

bool Observe_NestedContainer_DefaultFlagsFalse(ANestedContainerCopyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructNestedContainerCopySemantics setup: required Actor is null");
	}
	return Actor.bArrayIndependent == false
		&& Actor.bMapIndependent == false
		&& Actor.bSetIndependent == false;
}

bool Observe_NestedContainer_EmptyDefault()
{
	FNestedContainerCopyStruct Empty;
	return Empty.Values.Num() == 0 && Empty.Scores.Num() == 0 && Empty.Tags.Num() == 0;
}

bool Observe_NestedContainer_CopyIndependence()
{
	FNestedContainerCopyStruct Original;
	Original.Values.Add(1);
	Original.Scores.Add(1, 10);
	Original.Tags.Add(1);

	FNestedContainerCopyStruct Copy = Original;
	Copy.Values.Add(2);
	Copy.Scores.Add(2, 20);
	Copy.Tags.Add(2);

	return Original.Values.Num() == 1 && Copy.Values.Num() == 2
		&& Original.Scores.Num() == 1 && Copy.Scores.Num() == 2
		&& Original.Tags.Num() == 1 && Copy.Tags.Num() == 2;
}
