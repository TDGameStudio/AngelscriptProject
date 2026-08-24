// Theme: Definitions.UStruct. WorldStory: member methods Score/Describe/Add/Rename/WithBonus/CopyFrom.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMemberMethodInvocationMatrix spawn + BeginPlay.
// Oracle: InitialScore 44, InitialDescription Base:4, Data.Count 7 Label Renamed, MutatedScore 77,
// BonusData 12/Renamed_Bonus. Extra: empty Score 0 Describe ":0". FixtureIsolated.

USTRUCT(BlueprintType)
struct FStructMethodPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;

	int Score() const
	{
		return Count * 10 + Label.Len();
	}

	FString Describe() const
	{
		return Label + ":" + Count;
	}

	void Add(int Delta)
	{
		Count += Delta;
	}

	void Rename(const FString&in NewLabel)
	{
		Label = NewLabel;
	}

	FStructMethodPayload WithBonus(int Bonus) const
	{
		FStructMethodPayload Result;
		Result.Count = Count + Bonus;
		Result.Label = Label + "_Bonus";
		return Result;
	}

	void CopyFrom(const FStructMethodPayload& Other)
	{
		Count = Other.Count;
		Label = Other.Label;
	}
}

UCLASS()
class ACoverageStructMethodActor : AActor
{
	UPROPERTY()
	FStructMethodPayload Data;

	UPROPERTY()
	FStructMethodPayload BonusData;

	UPROPERTY()
	FStructMethodPayload CopiedData;

	UPROPERTY()
	int InitialScore = 0;

	UPROPERTY()
	int MutatedScore = 0;

	UPROPERTY()
	FString InitialDescription;

	UPROPERTY()
	FString MutatedDescription;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data.Count = 4;
		Data.Label = "Base";

		InitialScore = Data.Score();
		InitialDescription = Data.Describe();

		Data.Add(3);
		Data.Rename("Renamed");

		MutatedScore = Data.Score();
		MutatedDescription = Data.Describe();

		BonusData = Data.WithBonus(5);
		CopiedData.CopyFrom(BonusData);
	}
}

bool Observe_MemberMethod_DefaultEmpty(ACoverageStructMethodActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMemberMethodInvocationMatrix setup: required Actor is null");
	}
	FStructMethodPayload Empty;
	return Empty.Score() == 0 && Empty.Describe() == ":0" && Actor.InitialScore == 0 && Actor.Data.Count == 0;
}

bool Observe_MemberMethod_NominalBeginPlay(ACoverageStructMethodActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMemberMethodInvocationMatrix setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.InitialScore == 44
		&& Actor.InitialDescription == "Base:4"
		&& Actor.Data.Count == 7
		&& Actor.Data.Label == "Renamed"
		&& Actor.MutatedScore == 77
		&& Actor.MutatedDescription == "Renamed:7"
		&& Actor.BonusData.Count == 12
		&& Actor.BonusData.Label == "Renamed_Bonus"
		&& Actor.CopiedData.Count == 12
		&& Actor.CopiedData.Label == "Renamed_Bonus";
}

bool Observe_MemberMethod_CopyIndependence()
{
	FStructMethodPayload Source;
	Source.Count = 4;
	Source.Label = "Base";
	FStructMethodPayload Bonus = Source.WithBonus(5);
	Source.Add(1);
	return Bonus.Count == 9 && Bonus.Label == "Base_Bonus" && Source.Count == 5;
}
