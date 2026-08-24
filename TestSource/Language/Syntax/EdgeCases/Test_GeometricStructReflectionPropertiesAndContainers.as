// Theme: Language.Syntax.EdgeCases. WorldStory: FBox/FPlane UPROPERTY plus containers.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::GeometricStructReflectionPropertiesAndContainers
// sha256=d2f6e118c0e1055c4ffd8cbed7cdb50a01cd30613efa61ca7ac1bc43e15b8c6e; lines 653-685.
// Oracle: BoxValue/PlaneValue reflect as those structs; BoxArray/PlaneArray/BoxMap fill in BeginPlay.
// Extra: local construct keeps container Num 0; BoxValue Min/Max remain the declaration defaults.
// FixtureIsolated. Actor owns the geometric structs.

UCLASS()
class ACoverageMathGeometricStructActor : AActor
{
	UPROPERTY()
	FBox BoxValue = FBox(FVector(-1, -2, -3), FVector(4, 5, 6));

	UPROPERTY()
	FPlane PlaneValue = FPlane(FVector(0, 0, 10), FVector(0, 0, 1));

	UPROPERTY()
	TArray<FBox> BoxArray;

	UPROPERTY()
	TArray<FPlane> PlaneArray;

	UPROPERTY()
	TMap<int, FBox> BoxMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BoxArray.Add(FBox(FVector(1, 2, 3), FVector(4, 5, 6)));
		BoxArray.Add(FBox(FVector(-10, -20, -30), FVector(-1, -2, -3)));

		PlaneArray.Add(FPlane(FVector(0, 0, 8), FVector(0, 0, 1)));
		PlaneArray.Add(FPlane(FVector(2, 0, 0), FVector(1, 0, 0)));

		BoxMap.Add(7, FBox(FVector(10, 20, 30), FVector(40, 50, 60)));
		BoxMap.Add(8, FBox(FVector(-4, -5, -6), FVector(-1, -2, -3)));
	}
}

bool Observe_GeometricStruct_DefaultEmptyContainers(ACoverageMathGeometricStructActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GeometricStructReflectionPropertiesAndContainers setup: required Actor is null");
	}
	return Actor.BoxArray.Num() == 0 && Actor.PlaneArray.Num() == 0 && Actor.BoxMap.Num() == 0;
}

bool Observe_GeometricStruct_BoxDefault(ACoverageMathGeometricStructActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GeometricStructReflectionPropertiesAndContainers setup: required Actor is null");
	}
	return Actor.BoxValue.Min.Equals(FVector(-1, -2, -3), 0.001) && Actor.BoxValue.Max.Equals(FVector(4, 5, 6), 0.001);
}

bool Observe_GeometricStruct_AfterBeginPlay(ACoverageMathGeometricStructActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GeometricStructReflectionPropertiesAndContainers setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.BoxArray.Num() == 2 && Actor.PlaneArray.Num() == 2 && Actor.BoxMap.Num() == 2;
}
