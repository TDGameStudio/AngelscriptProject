/**
 * @version v1
 * @summary An unknown Meta key currently compiles because C++ wraps the failure in #if 0 (structural-validation-absent). The observers cover the default 0 and a boundary write that restores 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary An unknown Meta key currently compiles because C++ wraps the failure in #if 0 (structural-validation-absent). The observers cover the default 0 and a boundary write that restores 0.
 * @topic Baseline
 */
class AUPropBadMetaActor : AActor
{
	UPROPERTY(Meta = (NonExistentMetaKey = true))
	int X = 0;

	/**
	 * Observe the default X of 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UnknownMetaKey
	 * @Inputs none
	 * @Return true when X is 0
	 */
	UFUNCTION()
	bool BadMetaDefault()
	{
		return X == 0;
	}

	/**
	 * Observe that the empty default is 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UnknownMetaKey
	 * @Inputs none
	 * @Return true when X is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool BadMetaEmptyDefault()
	{
		return X == 0;
	}

	/**
	 * Observe a boundary write of 1 that restores the default 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UnknownMetaKey
	 * @Inputs X written to 1 then restored
	 * @Return true when the write lands and the saved default is 0
	 * @Boundary write then restore
	 */
	UFUNCTION()
	bool BadMetaBoundaryWrite()
	{
		int Saved = X;
		X = 1;
		bool bWrote = X == 1;
		X = Saved;
		if (!bWrote)
		{
			return false;
		}
		return Saved == 0;
	}
}
/** @end */
