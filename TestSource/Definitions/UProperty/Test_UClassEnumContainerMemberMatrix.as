// Theme: Definitions.UProperty. WorldStory: TArray/TSet/TMap of a BlueprintType UENUM.
// C++: inner/key/value are FEnumProperty; ArraySecondValue is Fired; ArmedScore 20; bSetContainsArmed true.
// Extra: empty StateArray Num 0; Idle is unused in the set-contains path. FixtureIsolated.

UENUM(BlueprintType)
enum EUClassPropertyContainerState
{
	Idle,
	Armed,
	Fired
}

UCLASS()
class ACoverageUClassEnumContainerMemberActor : AActor
{
	UPROPERTY()
	TArray<EUClassPropertyContainerState> StateArray;

	UPROPERTY()
	TSet<EUClassPropertyContainerState> StateSet;

	UPROPERTY()
	TMap<EUClassPropertyContainerState, int> StateToScore;

	UPROPERTY()
	TMap<int, EUClassPropertyContainerState> ScoreToState;

	UPROPERTY()
	bool bSetContainsArmed = false;

	UPROPERTY()
	int ArmedScore = 0;

	UPROPERTY()
	bool bScoreToStateFired = false;

	UPROPERTY()
	int ArraySecondValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StateArray.Add(EUClassPropertyContainerState::Idle);
		StateArray.Add(EUClassPropertyContainerState::Fired);
		StateArray.Add(EUClassPropertyContainerState::Armed);
		ArraySecondValue = int(StateArray[1]);

		StateSet.Add(EUClassPropertyContainerState::Idle);
		StateSet.Add(EUClassPropertyContainerState::Armed);
		StateSet.Add(EUClassPropertyContainerState::Armed);
		bSetContainsArmed = StateSet.Contains(EUClassPropertyContainerState::Armed);

		StateToScore.Add(EUClassPropertyContainerState::Idle, 10);
		StateToScore.Add(EUClassPropertyContainerState::Armed, 20);
		StateToScore.Find(EUClassPropertyContainerState::Armed, ArmedScore);

		ScoreToState.Add(1, EUClassPropertyContainerState::Idle);
		ScoreToState.Add(2, EUClassPropertyContainerState::Fired);
		bScoreToStateFired = ScoreToState[2] == EUClassPropertyContainerState::Fired;
	}
}

int Observe_EnumContainer_EmptyArrayNum()
{
	TArray<EUClassPropertyContainerState> StateArray;
	return StateArray.Num();
}

bool Observe_EnumContainer_MissingFiredScore()
{
	TMap<EUClassPropertyContainerState, int> StateToScore;
	int ArmedScore = 0;
	return !StateToScore.Find(EUClassPropertyContainerState::Fired, ArmedScore) && ArmedScore == 0;
}
