/**
 * @version v1
 * @summary An abstract BlueprintType generated class keeps Score and GetScore. The class is Abstract so NewObject of this type is unavailable; an unset handle is null.
 * @topic Definitions
 */
/**
 * @version root
 * @summary An abstract BlueprintType generated class keeps Score and GetScore. The class is Abstract so NewObject of this type is unavailable; an unset handle is null.
 * @topic Baseline
 */
UCLASS(Abstract, BlueprintType)
class UCompilerConsistencyCarrier : UObject
{
	UPROPERTY()
	int Score;

	/**
	 * Observe GetScore: it returns Score.
	 *
	 * @Kind Observe
	 * @Covers UClass.GeneratedClass
	 * @Inputs Score
	 * @Return Score
	 */
	UFUNCTION()
	int GetScore()
	{
		return Score;
	}

	/**
	 * Observe that an unset abstract handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.GeneratedClass
	 * @Inputs an unset UCompilerConsistencyCarrier handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int DefaultHandleIsNull()
	{
		UCompilerConsistencyCarrier Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
