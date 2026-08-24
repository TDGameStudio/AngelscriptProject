// Theme: Definitions.UFunction. WorldStory: UENUM parameter, return, and container matrix.
// C++: AngelscriptCoverageUFunctionTests.cpp::EnumParameterReturnAndContainerMatrix
// Oracle: EvaluateEnumMatrix(Ready=4, {Armed=10, Fired=28}) == 42 LastScore 42;
// ReturnState(true) Fired; ReturnStateArray Ready+Fired; ReturnStateMap Armed 14 Fired 28;
// ReturnStateSet contains Ready and Fired.
// Extra: empty array with Idle scores 0; ReturnState(false) is Ready.
// FixtureIsolated. Runner owns World teardown.

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

	UFUNCTION(BlueprintCallable, Category="Coverage|Enum")
	ECoverageUFunctionState ReturnState(bool bUseFired)
	{
		return bUseFired ? ECoverageUFunctionState::UFunctionStateFired : ECoverageUFunctionState::UFunctionStateReady;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Enum")
	TArray<ECoverageUFunctionState> ReturnStateArray()
	{
		TArray<ECoverageUFunctionState> States;
		States.Add(ECoverageUFunctionState::UFunctionStateReady);
		States.Add(ECoverageUFunctionState::UFunctionStateFired);
		return States;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Enum")
	TMap<ECoverageUFunctionState, int> ReturnStateMap()
	{
		TMap<ECoverageUFunctionState, int> Scores;
		Scores.Add(ECoverageUFunctionState::UFunctionStateArmed, 14);
		Scores.Add(ECoverageUFunctionState::UFunctionStateFired, 28);
		return Scores;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Enum")
	TSet<ECoverageUFunctionState> ReturnStateSet()
	{
		TSet<ECoverageUFunctionState> States;
		States.Add(ECoverageUFunctionState::UFunctionStateReady);
		States.Add(ECoverageUFunctionState::UFunctionStateFired);
		return States;
	}
}

int Observe_EnumMatrix_ReadyArmedFired(ACoverageUFunctionEnumActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EnumParameterReturnAndContainerMatrix setup: required Actor is null");
	}
	TArray<ECoverageUFunctionState> States;
	States.Add(ECoverageUFunctionState::UFunctionStateArmed);
	States.Add(ECoverageUFunctionState::UFunctionStateFired);
	return Actor.EvaluateEnumMatrix(ECoverageUFunctionState::UFunctionStateReady, States);
}

int Observe_EnumMatrix_IdleEmptyArray(ACoverageUFunctionEnumActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EnumParameterReturnAndContainerMatrix setup: required Actor is null");
	}
	TArray<ECoverageUFunctionState> States;
	return Actor.EvaluateEnumMatrix(ECoverageUFunctionState::UFunctionStateIdle, States);
}

bool Observe_EnumMatrix_ReturnStateTrueFalse(ACoverageUFunctionEnumActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EnumParameterReturnAndContainerMatrix setup: required Actor is null");
	}
	return Actor.ReturnState(true) == ECoverageUFunctionState::UFunctionStateFired
		&& Actor.ReturnState(false) == ECoverageUFunctionState::UFunctionStateReady;
}

bool Observe_EnumMatrix_ReturnContainers(ACoverageUFunctionEnumActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EnumParameterReturnAndContainerMatrix setup: required Actor is null");
	}
	TArray<ECoverageUFunctionState> States = Actor.ReturnStateArray();
	TMap<ECoverageUFunctionState, int> Scores = Actor.ReturnStateMap();
	TSet<ECoverageUFunctionState> Unique = Actor.ReturnStateSet();
	int Armed = 0;
	int Fired = 0;
	Scores.Find(ECoverageUFunctionState::UFunctionStateArmed, Armed);
	Scores.Find(ECoverageUFunctionState::UFunctionStateFired, Fired);
	return States.Num() == 2
		&& States[0] == ECoverageUFunctionState::UFunctionStateReady
		&& States[1] == ECoverageUFunctionState::UFunctionStateFired
		&& Armed == 14
		&& Fired == 28
		&& Unique.Contains(ECoverageUFunctionState::UFunctionStateReady)
		&& Unique.Contains(ECoverageUFunctionState::UFunctionStateFired);
}

int Observe_EnumMatrix_DefaultScore(ACoverageUFunctionEnumActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EnumParameterReturnAndContainerMatrix setup: required Actor is null");
	}
	return Actor.LastScore;
}
