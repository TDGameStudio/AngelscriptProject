/**
 * FVector4, FIntPoint and FIntVector under reflection: scalar UPROPERTY defaults
 * beside TArrays of each type, filled during BeginPlay.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.Vector4IntPointIntVectorReflection
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.Vector4IntPointIntVectorReflection
 * @Provenance C++: AngelscriptCoverageMathGeometricStructs.cpp::Vector4IntPointIntVectorReflection
 * @Provenance sha256=511484dbe8480ee7441e47d54a02c61108a8315167a47865d7f2d08dc294348f; lines 529-559.
 * @Provenance Oracle after spawn+BeginPlay: Vector4Value.X 1 W 4; IntPointValue.X 5 Y 6; IntVectorValue.X 7;
 * @Provenance arrays receive one element each in BeginPlay.
 * @Provenance Extra: local construct keeps array Num 0 while scalar defaults remain.
 * @Provenance FixtureIsolated. Actor owns the structs.
 */

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

	/**
	 * Adds one element to each array.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all three arrays gain one element
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Vector4Array.Add(FVector4(10, 11, 12, 13));
		IntPointArray.Add(FIntPoint(14, 15));
		IntVectorArray.Add(FIntVector(16, 17, 18));
	}

	/**
	 * Observe that a locally constructed actor leaves the arrays empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three arrays report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool Vector4IntStructDefaultEmptyArrays()
	{
		if (Vector4Array.Num() != 0)
		{
			return false;
		}

		if (IntPointArray.Num() != 0)
		{
			return false;
		}

		return IntVectorArray.Num() == 0;
	}

	/**
	 * Observe the scalar struct defaults.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all sampled components match
	 */
	UFUNCTION()
	bool Vector4IntStructNominalDefaults()
	{
		if (!Math::IsNearlyEqual(Vector4Value.X, 1.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(Vector4Value.W, 4.0))
		{
			return false;
		}

		if (IntPointValue.X != 5)
		{
			return false;
		}

		if (IntPointValue.Y != 6)
		{
			return false;
		}

		return IntVectorValue.X == 7;
	}

	/**
	 * Observe the array contents after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then the three arrays
	 * @Return true when each array holds its element
	 */
	UFUNCTION()
	bool Vector4IntStructAfterBeginPlay()
	{
		BeginPlay();

		if (Vector4Array.Num() != 1)
		{
			return false;
		}

		if (IntPointArray[0].X != 14)
		{
			return false;
		}

		return IntVectorArray[0].X == 16;
	}
}
