/**
 * An abstract BlueprintType generated class keeps Score and GetScore. The
 * class is Abstract so NewObject of this type is unavailable; an unset handle
 * is null.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.GeneratedClassConsistency
 * @Harness UClass
 * @Tag Definitions.UClass.GeneratedClassConsistency
 * @Provenance Theme: Definitions.UClass. Positive: abstract BlueprintType generated class keeps Score and GetScore.
 * @Provenance C++: AngelscriptCompilerEndToEndTests.cpp::GeneratedClassConsistency
 * @Provenance Oracle: GetScore returns Score; default Score is 0 after NewObject of a non-abstract path is unavailable
 * @Provenance (class is Abstract). Extra: default handle is null. DefaultSafe.
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
