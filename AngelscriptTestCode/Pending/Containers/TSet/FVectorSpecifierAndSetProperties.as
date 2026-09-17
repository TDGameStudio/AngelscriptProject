/**
 * @version v1
 * @summary Not TSet API. Kept here until moved.
 * @topic Containers
 */
/**
 * @version root
 * @summary Not TSet API. Kept here until moved.
 * @topic Baseline
 */
// CompileScriptModule + spawn + BeginPlay. Oracle: EditablePoint (10,-20,30), VectorSet Num=3
// containing Forward/Right/Up.
// Extra: local construct leaves VectorSet empty; copy independence of the set.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageFVectorSpecifierAndSetActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Coverage|Vector", meta = (MakeEditWidget, ClampMin = "-100.0", ClampMax = "100.0"))
	FVector EditablePoint = FVector(10, -20, 30);

	UPROPERTY()
	TSet<FVector> VectorSet;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		VectorSet.Add(FVector::ForwardVector);
		VectorSet.Add(FVector::RightVector);
		VectorSet.Add(FVector::UpVector);
	}
}

bool Observe_VectorSet_DefaultEmpty(ACoverageFVectorSpecifierAndSetActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorSpecifierAndSetProperties setup: required Actor is null");
	}
	return Actor.VectorSet.Num() == 0;
}

bool Observe_EditablePoint_Default(ACoverageFVectorSpecifierAndSetActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorSpecifierAndSetProperties setup: required Actor is null");
	}
	return Actor.EditablePoint.X == 10.0
		&& Actor.EditablePoint.Y == -20.0
		&& Actor.EditablePoint.Z == 30.0;
}

bool Observe_VectorSet_CopyIndependence(ACoverageFVectorSpecifierAndSetActor First, ACoverageFVectorSpecifierAndSetActor Second)
{
	if (First is null)
	{
		throw("Test_FVectorSpecifierAndSetProperties setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FVectorSpecifierAndSetProperties setup: required Second is null");
	}
	First.VectorSet.Add(FVector::ForwardVector);
	return First.VectorSet.Num() == 1
		&& First.VectorSet.Contains(FVector::ForwardVector)
		&& Second.VectorSet.Num() == 0;
}
/** @end */
