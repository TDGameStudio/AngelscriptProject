/**
 * @version v1
 * @summary A multi-variable UPROPERTY currently compiles because C++ wraps the failure in #if 0 (structural-validation-absent). The observers cover X and Y defaulting to 0 and that a Y write is independent of X.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A multi-variable UPROPERTY currently compiles because C++ wraps the failure in #if 0 (structural-validation-absent). The observers cover X and Y defaulting to 0 and that a Y write is independent of X.
 * @topic Baseline
 */
class AUPropMultiDeclActor : AActor
{
	UPROPERTY()
	int X, Y;

	/**
	 * Observe that X and Y default to 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MultiVariableDeclaration
	 * @Inputs none
	 * @Return true when both are 0
	 */
	UFUNCTION()
	bool MultiDeclDefault()
	{
		if (X != 0)
		{
			return false;
		}
		return Y == 0;
	}

	/**
	 * Observe that the empty defaults are 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MultiVariableDeclaration
	 * @Inputs none
	 * @Return true when both are 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool MultiDeclEmptyDefault()
	{
		if (X != 0)
		{
			return false;
		}
		return Y == 0;
	}

	/**
	 * Observe that writing Y leaves X unchanged.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MultiVariableDeclaration
	 * @Inputs Y written to 7 then restored
	 * @Return true when X stays 0 and Y becomes 7
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool MultiDeclCopyIndependence()
	{
		int SavedX = X;
		Y = 7;
		if (X != SavedX)
		{
			Y = 0;
			return false;
		}
		if (Y != 7)
		{
			Y = 0;
			return false;
		}
		Y = 0;
		return SavedX == 0;
	}
}
/** @end */
