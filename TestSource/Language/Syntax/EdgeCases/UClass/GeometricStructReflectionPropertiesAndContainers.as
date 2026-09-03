/**
 * Geometric structs under reflection: FBox and FPlane as UPROPERTY defaults, and
 * both inside TArray and TMap containers filled during BeginPlay.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.GeometricStructReflectionPropertiesAndContainers
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.GeometricStructReflectionPropertiesAndContainers
 * @Provenance C++: AngelscriptCoverageMathGeometricStructs.cpp::GeometricStructReflectionPropertiesAndContainers
 * @Provenance sha256=d2f6e118c0e1055c4ffd8cbed7cdb50a01cd30613efa61ca7ac1bc43e15b8c6e; lines 653-685.
 * @Provenance Oracle: BoxValue/PlaneValue reflect as those structs; BoxArray/PlaneArray/BoxMap fill in BeginPlay.
 * @Provenance Extra: local construct keeps container Num 0; BoxValue Min/Max remain the declaration defaults.
 * @Provenance FixtureIsolated. Actor owns the geometric structs.
 */

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

	/**
	 * Fills every geometric container.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the arrays and map receive their oracle values
	 */
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

	/**
	 * Observe that a locally constructed actor leaves every container empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GeometricStructDefaultEmptyContainers()
	{
		if (BoxArray.Num() != 0)
		{
			return false;
		}

		if (PlaneArray.Num() != 0)
		{
			return false;
		}

		return BoxMap.Num() == 0;
	}

	/**
	 * Observe that the box default survived reflection.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the BoxValue default
	 * @Return true when Min and Max equal their declared corners
	 */
	UFUNCTION()
	bool GeometricStructBoxDefault()
	{
		if (!BoxValue.Min.Equals(FVector(-1, -2, -3), 0.001))
		{
			return false;
		}

		return BoxValue.Max.Equals(FVector(4, 5, 6), 0.001);
	}

	/**
	 * Observe the container counts after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then all three containers
	 * @Return true when all three counts are 2
	 */
	UFUNCTION()
	bool GeometricStructAfterBeginPlay()
	{
		BeginPlay();

		if (BoxArray.Num() != 2)
		{
			return false;
		}

		if (PlaneArray.Num() != 2)
		{
			return false;
		}

		return BoxMap.Num() == 2;
	}
}
