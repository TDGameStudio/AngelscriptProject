/**
 * @version v1
 * @summary A UPROPERTY bool compiles. The observers cover bIsAlive true, a false write, and copy independence of a local snapshot.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY bool compiles. The observers cover bIsAlive true, a false write, and copy independence of a local snapshot.
 * @topic Baseline
 */
class AUPropBoolActor : AActor
{
	UPROPERTY()
	bool bIsAlive = true;

	/**
	 * Observe the default bIsAlive of true.
	 *
	 * @Kind Observe
	 * @Covers UProperty.BoolPropertyType
	 * @Inputs none
	 * @Return true when bIsAlive is true
	 */
	UFUNCTION()
	bool IsAliveDefault()
	{
		return bIsAlive == true;
	}

	/**
	 * Observe a false write that restores true.
	 *
	 * @Kind Observe
	 * @Covers UProperty.BoolPropertyType
	 * @Inputs bIsAlive written to false then restored
	 * @Return true when the false write lands and the saved default is true
	 * @Boundary false write
	 */
	UFUNCTION()
	bool IsAliveFalseBoundary()
	{
		bool Saved = bIsAlive;
		bIsAlive = false;
		bool bCleared = bIsAlive == false;
		bIsAlive = Saved;
		if (!bCleared)
		{
			return false;
		}
		return Saved == true;
	}

	/**
	 * Observe that mutating a local copy leaves bIsAlive true.
	 *
	 * @Kind Observe
	 * @Covers UProperty.BoolPropertyType
	 * @Inputs a local copy written to false
	 * @Return true when bIsAlive stays true and the copy is false
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool IsAliveCopyIndependence()
	{
		bool Original = bIsAlive;
		bool Copy = Original;
		Copy = false;
		if (bIsAlive != Original)
		{
			return false;
		}
		if (Copy != false)
		{
			return false;
		}
		return Original == true;
	}
}
/** @end */
