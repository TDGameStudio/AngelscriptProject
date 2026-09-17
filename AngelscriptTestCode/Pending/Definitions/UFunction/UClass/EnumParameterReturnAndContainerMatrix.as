/**
 * @version v1
 * @summary UENUM parameter, return, and container matrix. EvaluateEnumMatrix(Ready=4, {Armed=10, Fired=28}) is 42 and LastScore 42. ReturnState(true) is Fired. ReturnStateArray is Ready+Fired. ReturnStateMap is Armed 14 Fired 28.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UENUM parameter, return, and container matrix. EvaluateEnumMatrix(Ready=4, {Armed=10, Fired=28}) is 42 and LastScore 42. ReturnState(true) is Fired. ReturnStateArray is Ready+Fired. ReturnStateMap is Armed 14 Fired 28.
 * @topic Baseline
 */
UENUM(BlueprintType)
enum ECoverageUFunctionState
{
	UFunctionStateIdle = 0,
	UFunctionStateReady = 4,
	UFunctionStateArmed = 10,
	UFunctionStateFired = 28
}

UCLASS()
class ACoverageUFunctionEnumActor : AActor
{
	UPROPERTY()
	ECoverageUFunctionState LastState = ECoverageUFunctionState::UFunctionStateIdle;

	UPROPERTY()
	int LastScore = 0;

	/**
	 * Score State plus each States value and store LastState/LastScore.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param State Enum stored as LastState
	 * @Param States Enums received as const TArray<ECoverageUFunctionState>&in
	 * @Inputs State and States
	 * @Return LastScore after the write
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Enum")
	int EvaluateEnumMatrix(ECoverageUFunctionState State, const TArray<ECoverageUFunctionState>&in States)
	{
		LastState = State;

		int Score = int(State);
		for (int Index = 0; Index < States.Num(); ++Index)
		{
			Score += int(States[Index]);
		}

		LastScore = Score;
		return Score;
	}

	/**
	 * Return Fired when bUseFired is true, otherwise Ready.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param bUseFired Selects Fired versus Ready
	 * @Inputs bUseFired
	 * @Return Fired or Ready
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Enum")
	ECoverageUFunctionState ReturnState(bool bUseFired)
	{
		return bUseFired ? ECoverageUFunctionState::UFunctionStateFired : ECoverageUFunctionState::UFunctionStateReady;
	}

	/**
	 * Return Ready then Fired.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return a two-element state array
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Enum")
	TArray<ECoverageUFunctionState> ReturnStateArray()
	{
		TArray<ECoverageUFunctionState> States;
		States.Add(ECoverageUFunctionState::UFunctionStateReady);
		States.Add(ECoverageUFunctionState::UFunctionStateFired);
		return States;
	}

	/**
	 * Return Armed 14 and Fired 28.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return a two-entry state map
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Enum")
	TMap<ECoverageUFunctionState, int> ReturnStateMap()
	{
		TMap<ECoverageUFunctionState, int> Scores;
		Scores.Add(ECoverageUFunctionState::UFunctionStateArmed, 14);
		Scores.Add(ECoverageUFunctionState::UFunctionStateFired, 28);
		return Scores;
	}

	/**
	 * Return Ready and Fired.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return a two-element state set
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Enum")
	TSet<ECoverageUFunctionState> ReturnStateSet()
	{
		TSet<ECoverageUFunctionState> States;
		States.Add(ECoverageUFunctionState::UFunctionStateReady);
		States.Add(ECoverageUFunctionState::UFunctionStateFired);
		return States;
	}

	/**
	 * Observe EvaluateEnumMatrix(Ready, {Armed, Fired}).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs EvaluateEnumMatrix Ready plus Armed and Fired
	 * @Return 42
	 */
	UFUNCTION()
	int EnumMatrixReadyArmedFired()
	{
		TArray<ECoverageUFunctionState> States;
		States.Add(ECoverageUFunctionState::UFunctionStateArmed);
		States.Add(ECoverageUFunctionState::UFunctionStateFired);
		return EvaluateEnumMatrix(ECoverageUFunctionState::UFunctionStateReady, States);
	}

	/**
	 * Observe EvaluateEnumMatrix(Idle, empty).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs EvaluateEnumMatrix Idle plus an empty array
	 * @Return 0
	 * @Boundary Idle and empty array
	 */
	UFUNCTION()
	int EnumMatrixIdleEmptyArray()
	{
		TArray<ECoverageUFunctionState> States;
		return EvaluateEnumMatrix(ECoverageUFunctionState::UFunctionStateIdle, States);
	}

	/**
	 * Observe ReturnState(true) and ReturnState(false).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnState(true) and ReturnState(false)
	 * @Return true when true is Fired and false is Ready
	 */
	UFUNCTION()
	bool EnumMatrixReturnStateTrueFalse()
	{
		if (ReturnState(true) != ECoverageUFunctionState::UFunctionStateFired)
		{
			return false;
		}
		return ReturnState(false) == ECoverageUFunctionState::UFunctionStateReady;
	}

	/**
	 * Observe ReturnStateArray, ReturnStateMap, and ReturnStateSet.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnStateArray, ReturnStateMap, and ReturnStateSet
	 * @Return true when the returned containers match the oracle
	 */
	UFUNCTION()
	bool EnumMatrixReturnContainers()
	{
		TArray<ECoverageUFunctionState> States = ReturnStateArray();
		TMap<ECoverageUFunctionState, int> Scores = ReturnStateMap();
		TSet<ECoverageUFunctionState> Unique = ReturnStateSet();
		int Armed = 0;
		int Fired = 0;
		Scores.Find(ECoverageUFunctionState::UFunctionStateArmed, Armed);
		Scores.Find(ECoverageUFunctionState::UFunctionStateFired, Fired);
		if (States.Num() != 2)
		{
			return false;
		}
		if (States[0] != ECoverageUFunctionState::UFunctionStateReady)
		{
			return false;
		}
		if (States[1] != ECoverageUFunctionState::UFunctionStateFired)
		{
			return false;
		}
		if (Armed != 14)
		{
			return false;
		}
		if (Fired != 28)
		{
			return false;
		}
		if (!Unique.Contains(ECoverageUFunctionState::UFunctionStateReady))
		{
			return false;
		}
		return Unique.Contains(ECoverageUFunctionState::UFunctionStateFired);
	}

	/**
	 * Observe the default LastScore.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs LastScore on a freshly constructed actor
	 * @Return 0
	 * @Boundary default LastScore
	 */
	UFUNCTION()
	int EnumMatrixDefaultScore()
	{
		return LastScore;
	}
}
/** @end */
