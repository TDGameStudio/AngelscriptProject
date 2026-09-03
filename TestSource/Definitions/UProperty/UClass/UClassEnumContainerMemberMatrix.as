/**
 * TArray/TSet/TMap of a BlueprintType UENUM. C++ verifies named members by
 * path, so those UPROPERTY names are kept. The observers cover empty StateArray
 * Num 0 and a missing Fired score lookup.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UClassEnumContainerMemberMatrix
 * @Harness UClass
 * @Tag Definitions.UProperty.UClassEnumContainerMemberMatrix
 * @Provenance Theme: Definitions.UProperty. WorldStory: TArray/TSet/TMap of a BlueprintType UENUM.
 * @Provenance C++: inner/key/value are FEnumProperty; ArraySecondValue is Fired; ArmedScore 20; bSetContainsArmed true.
 * @Provenance Extra: empty StateArray Num 0; Idle is unused in the set-contains path. FixtureIsolated.
 */

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

	/**
	 * WorldStory: fill enum containers and publish lookup flags.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.UClassEnumContainerMemberMatrix
	 * @Inputs none
	 * @Return ArraySecondValue Fired; ArmedScore 20; bSetContainsArmed true
	 */
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

	/**
	 * Observe that an empty StateArray has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassEnumContainerMemberMatrix
	 * @Inputs a default-constructed TArray of the enum
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int EnumContainerEmptyArrayNum()
	{
		TArray<EUClassPropertyContainerState> StateArray;
		return StateArray.Num();
	}

	/**
	 * Observe that a missing Fired score lookup leaves ArmedScore at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassEnumContainerMemberMatrix
	 * @Inputs an empty StateToScore map
	 * @Return true when Find fails and ArmedScore stays 0
	 * @Boundary missing key
	 */
	UFUNCTION()
	bool EnumContainerMissingFiredScore()
	{
		TMap<EUClassPropertyContainerState, int> StateToScore;
		int ArmedScore = 0;
		if (StateToScore.Find(EUClassPropertyContainerState::Fired, ArmedScore))
		{
			return false;
		}
		return ArmedScore == 0;
	}
}
