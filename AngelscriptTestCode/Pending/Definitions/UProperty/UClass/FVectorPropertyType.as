/**
 * @version v1
 * @summary A UPROPERTY FVector compiles. The observers cover the zero default, the empty IsNearlyZero boundary, and copy independence of a local snapshot.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY FVector compiles. The observers cover the zero default, the empty IsNearlyZero boundary, and copy independence of a local snapshot.
 * @topic Baseline
 */
class AUPropVecActor : AActor
{
	UPROPERTY()
	FVector Location;

	/**
	 * Observe the default Location of (0,0,0).
	 *
	 * @Kind Observe
	 * @Covers UProperty.FVectorPropertyType
	 * @Inputs none
	 * @Return true when Location equals the zero vector
	 */
	UFUNCTION()
	bool LocationDefault()
	{
		return Location.Equals(FVector(0.0f, 0.0f, 0.0f));
	}

	/**
	 * Observe that the empty default is nearly zero.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FVectorPropertyType
	 * @Inputs none
	 * @Return true when Location.IsNearlyZero()
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool LocationEmptyDefault()
	{
		return Location.IsNearlyZero();
	}

	/**
	 * Observe that mutating a local copy leaves Location at zero.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FVectorPropertyType
	 * @Inputs a local copy written to (1,2,3)
	 * @Return true when Location equals the original and the copy is (1,2,3)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool LocationCopyIndependence()
	{
		FVector Original = Location;
		FVector Copy = Original;
		Copy = FVector(1.0f, 2.0f, 3.0f);
		if (!Location.Equals(Original))
		{
			return false;
		}
		return Copy.Equals(FVector(1.0f, 2.0f, 3.0f));
	}
}
/** @end */
