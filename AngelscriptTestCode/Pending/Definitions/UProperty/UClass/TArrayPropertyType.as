/**
 * @version v1
 * @summary A UPROPERTY TArray<int> compiles. The observers cover empty Scores Num 0 and that Add(7) then a copied TArray is independent.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY TArray<int> compiles. The observers cover empty Scores Num 0 and that Add(7) then a copied TArray is independent.
 * @topic Baseline
 */
class AUPropArrActor : AActor
{
	UPROPERTY()
	TArray<int> Scores;

	/**
	 * Observe the default Scores Num of 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TArrayPropertyType
	 * @Inputs none
	 * @Return true when Num is 0
	 */
	UFUNCTION()
	bool ScoresDefault()
	{
		return Scores.Num() == 0;
	}

	/**
	 * Observe that the empty default has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TArrayPropertyType
	 * @Inputs none
	 * @Return true when Num is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool ScoresEmptyDefault()
	{
		return Scores.Num() == 0;
	}

	/**
	 * Observe that mutating a copied TArray leaves Scores[0] at 7.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TArrayPropertyType
	 * @Inputs Scores.Add(7) then Copy[0] = 9
	 * @Return true when Scores[0] is 7 and Copy[0] is 9
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ScoresCopyIndependence()
	{
		Scores.Add(7);
		TArray<int> Copy = Scores;
		Copy[0] = 9;
		if (Scores[0] != 7)
		{
			Scores.Empty();
			return false;
		}
		if (Copy[0] != 9)
		{
			Scores.Empty();
			return false;
		}
		Scores.Empty();
		return true;
	}
}
/** @end */
