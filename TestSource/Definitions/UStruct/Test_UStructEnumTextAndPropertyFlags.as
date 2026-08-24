// Theme: Definitions.UStruct. WorldStory: enum/FText members plus SaveGame and Transient flags.
// C++: AngelscriptCoverageUStructTests.cpp::UStructEnumTextAndPropertyFlags spawn + BeginPlay.
// Oracle: State Finished (2), Description "Struct text value", SavedScore 42, RuntimeScratch 88.
// Extra: CDO Idle / SavedScore 7 / RuntimeScratch 9. FixtureIsolated.

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data.State = EStructMemberState::Finished;
		Data.Description = FText::FromString("Struct text value");
		Data.SavedScore = 42;
		Data.RuntimeScratch = 88;
	}
}

bool Observe_EnumTextFlags_DefaultEmpty(ACoverageStructMemberReflectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructEnumTextAndPropertyFlags setup: required Actor is null");
	}
	return Actor.Data.State == EStructMemberState::Idle
		&& Actor.Data.SavedScore == 7
		&& Actor.Data.RuntimeScratch == 9;
}

bool Observe_EnumTextFlags_NominalBeginPlay(ACoverageStructMemberReflectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructEnumTextAndPropertyFlags setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.Data.State == EStructMemberState::Finished
		&& Actor.Data.Description.ToString() == "Struct text value"
		&& Actor.Data.SavedScore == 42
		&& Actor.Data.RuntimeScratch == 88;
}

bool Observe_EnumTextFlags_CopyIndependence(ACoverageStructMemberReflectionActor First, ACoverageStructMemberReflectionActor Second)
{
	if (First is null)
	{
		throw("Test_UStructEnumTextAndPropertyFlags setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_UStructEnumTextAndPropertyFlags setup: required Second is null");
	}
	First.BeginPlay();
	return First.Data.SavedScore == 42 && Second.Data.SavedScore == 7 && Second.Data.State == EStructMemberState::Idle;
}
