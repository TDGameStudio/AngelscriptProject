// Theme: Language.Syntax.EdgeCases. WorldStory: FVector4/FIntPoint/FIntVector reflection.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::Vector4IntPointIntVectorReflection
// sha256=511484dbe8480ee7441e47d54a02c61108a8315167a47865d7f2d08dc294348f; lines 529-559.
// Oracle after spawn+BeginPlay: Vector4Value.X 1 W 4; IntPointValue.X 5 Y 6; IntVectorValue.X 7;
// arrays receive one element each in BeginPlay.
// Extra: local construct keeps array Num 0 while scalar defaults remain.
// FixtureIsolated. Actor owns the structs.

UCLASS()
class ACoverageMathVector4IntStructActor : AActor
{
	UPROPERTY()
	FVector4 Vector4Value = FVector4(1, 2, 3, 4);

	UPROPERTY()
	FIntPoint IntPointValue = FIntPoint(5, 6);

	UPROPERTY()
	FIntVector IntVectorValue = FIntVector(7, 8, 9);

	UPROPERTY()
	TArray<FVector4> Vector4Array;

	UPROPERTY()
	TArray<FIntPoint> IntPointArray;

	UPROPERTY()
	TArray<FIntVector> IntVectorArray;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Vector4Array.Add(FVector4(10, 11, 12, 13));
		IntPointArray.Add(FIntPoint(14, 15));
		IntVectorArray.Add(FIntVector(16, 17, 18));
	}
}

bool Observe_Vector4IntStruct_DefaultEmptyArrays(ACoverageMathVector4IntStructActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Vector4IntPointIntVectorReflection setup: required Actor is null");
	}
	return Actor.Vector4Array.Num() == 0 && Actor.IntPointArray.Num() == 0 && Actor.IntVectorArray.Num() == 0;
}

bool Observe_Vector4IntStruct_NominalDefaults(ACoverageMathVector4IntStructActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Vector4IntPointIntVectorReflection setup: required Actor is null");
	}
	return Actor.Vector4Value.X == 1.0 && Actor.Vector4Value.W == 4.0
		&& Actor.IntPointValue.X == 5 && Actor.IntPointValue.Y == 6
		&& Actor.IntVectorValue.X == 7;
}

bool Observe_Vector4IntStruct_AfterBeginPlay(ACoverageMathVector4IntStructActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Vector4IntPointIntVectorReflection setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.Vector4Array.Num() == 1 && Actor.IntPointArray[0].X == 14 && Actor.IntVectorArray[0].X == 16;
}
