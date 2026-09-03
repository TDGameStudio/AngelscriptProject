/**
 * Enum and FText members plus SaveGame and Transient flags. C++ reads State,
 * Description, SavedScore, and RuntimeScratch after BeginPlay.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructEnumTextAndPropertyFlags
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructEnumTextAndPropertyFlags
 * @Provenance Theme: Definitions.UStruct. WorldStory: enum/FText members plus SaveGame and Transient flags.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructEnumTextAndPropertyFlags spawn + BeginPlay.
 * @Provenance Oracle: State Finished (2), Description "Struct text value", SavedScore 42, RuntimeScratch 88.
 * @Provenance Extra: CDO Idle / SavedScore 7 / RuntimeScratch 9. FixtureIsolated.
 */

UENUM(BlueprintType)
enum EStructMemberState
{
	Idle,
	Running,
	Finished
}

USTRUCT(BlueprintType)
struct FStructMemberReflectionData
{
	UPROPERTY(EditAnywhere)
	EStructMemberState State = EStructMemberState::Idle;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FText Description;

	UPROPERTY(SaveGame)
	int SavedScore = 7;

	UPROPERTY(Transient)
	int RuntimeScratch = 9;
}

UCLASS()
class ACoverageStructMemberReflectionActor : AActor
{
	UPROPERTY()
	FStructMemberReflectionData Data;

	/**
	 * WorldStory: BeginPlay writes enum, text, SaveGame, and Transient members.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructEnumTextAndPropertyFlags
	 * @Inputs none
	 * @Return State Finished, Description Struct text value, SavedScore 42, RuntimeScratch 88
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data.State = EStructMemberState::Finished;
		Data.Description = FText::FromString("Struct text value");
		Data.SavedScore = 42;
		Data.RuntimeScratch = 88;
	}

	/**
	 * Observe CDO defaults before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructEnumTextAndPropertyFlags
	 * @Inputs an actor that has not begun play
	 * @Return true when State is Idle, SavedScore is 7, and RuntimeScratch is 9
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool EnumTextFlagsDefaultEmpty()
	{
		if (Data.State != EStructMemberState::Idle)
		{
			return false;
		}
		if (Data.SavedScore != 7)
		{
			return false;
		}
		return Data.RuntimeScratch == 9;
	}

	/**
	 * Observe enum/text/flag values after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructEnumTextAndPropertyFlags
	 * @Inputs BeginPlay on this actor
	 * @Return true when State, Description, SavedScore, and RuntimeScratch match
	 */
	UFUNCTION()
	bool EnumTextFlagsNominalBeginPlay()
	{
		BeginPlay();
		if (Data.State != EStructMemberState::Finished)
		{
			return false;
		}
		if (Data.Description.ToString() != "Struct text value")
		{
			return false;
		}
		if (Data.SavedScore != 42)
		{
			return false;
		}
		return Data.RuntimeScratch == 88;
	}

	/**
	 * Observe that a second actor is independent of this actor's BeginPlay fill.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructEnumTextAndPropertyFlags
	 * @Inputs this actor after BeginPlay and a second unfilled actor
	 * @Return true when this actor holds 42/Finished and the second stays 7/Idle
	 * @Param Second the other actor supplied by the runner
	 * @Boundary two-instance independence
	 */
	UFUNCTION()
	bool EnumTextFlagsCopyIndependence(ACoverageStructMemberReflectionActor Second)
	{
		if (Second == nullptr)
		{
			throw("UStructEnumTextAndPropertyFlags setup: required Second is null");
		}
		BeginPlay();
		if (Data.SavedScore != 42)
		{
			return false;
		}
		if (Second.Data.SavedScore != 7)
		{
			return false;
		}
		return Second.Data.State == EStructMemberState::Idle;
	}
}
