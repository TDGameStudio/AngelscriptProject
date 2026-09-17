/**
 * @version v1
 * @summary Call FetchScore, not a synthetic GetScore. C++ CheckGetterAccess oracle Result==7. The observers cover the default Score and the Score!=7 guard.
 * @topic Feature
 */
/**
 * @version root
 * @summary Call FetchScore, not a synthetic GetScore. C++ CheckGetterAccess oracle Result==7. The observers cover the default Score and the Score!=7 guard.
 * @topic Baseline
 */
#if EDITOR
UCLASS()
class AAutoAccessorGetterScriptActor : AAngelscriptPropertyAccessorCarrier
{
	/**
	 * WorldStory: FetchScore is the callable getter; a Score other than 7 returns 10.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.BlueprintGetterRemainsCallableWithoutSyntheticAlias
	 * @Inputs Score on the carrier
	 * @Return FetchScore() when Score==7, otherwise 10
	 */
	UFUNCTION()
	int32 CheckGetterAccess()
	{
		if (Score != 7)
		{
			return 10;
		}

		return FetchScore();
	}

	/**
	 * Observe the getter path when Score is the carrier default.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.BlueprintGetterRemainsCallableWithoutSyntheticAlias
	 * @Inputs Score at its carrier default
	 * @Return CheckGetterAccess()
	 */
	UFUNCTION()
	int GetterAccessNominal()
	{
		return CheckGetterAccess();
	}

	/**
	 * Observe the default Score field without calling FetchScore.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.BlueprintGetterRemainsCallableWithoutSyntheticAlias
	 * @Inputs Score at its carrier default
	 * @Return Score
	 * @Boundary default Score
	 */
	UFUNCTION()
	int GetterAccess_DefaultScore()
	{
		return Score;
	}

	/**
	 * Observe the Score!=7 guard by writing Score to 0.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.BlueprintGetterRemainsCallableWithoutSyntheticAlias
	 * @Inputs Score written to 0
	 * @Return 10 from the Score!=7 guard
	 * @Boundary Score written to 0
	 */
	UFUNCTION()
	int GetterAccess_WrongScoreBoundary()
	{
		Score = 0;
		return CheckGetterAccess();
	}
}
#endif
/** @end */
