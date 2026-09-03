/**
 * Member methods Score, Describe, Add, Rename, WithBonus, and CopyFrom on a
 * USTRUCT. C++ reads InitialScore, InitialDescription, Data, MutatedScore, and
 * BonusData after BeginPlay.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructMemberMethodInvocationMatrix
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructMemberMethodInvocationMatrix
 * @Provenance Theme: Definitions.UStruct. WorldStory: member methods Score/Describe/Add/Rename/WithBonus/CopyFrom.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMemberMethodInvocationMatrix spawn + BeginPlay.
 * @Provenance Oracle: InitialScore 44, InitialDescription Base:4, Data.Count 7 Label Renamed, MutatedScore 77,
 * @Provenance BonusData 12/Renamed_Bonus. Extra: empty Score 0 Describe ":0". FixtureIsolated.
 */

USTRUCT(BlueprintType)
struct FStructMethodPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;

	/**
	 * Score as Count * 10 plus Label length.
	 *
	 * @Covers UStruct.UStructMemberMethodInvocationMatrix
	 * @Inputs none
	 * @Return Count * 10 + Label.Len()
	 */
	int Score() const
	{
		return Count * 10 + Label.Len();
	}

	/**
	 * Describe as Label:Count.
	 *
	 * @Covers UStruct.UStructMemberMethodInvocationMatrix
	 * @Inputs none
	 * @Return Label + ":" + Count
	 */
	FString Describe() const
	{
		return Label + ":" + Count;
	}

	/**
	 * Add a delta to Count.
	 *
	 * @Covers UStruct.UStructMemberMethodInvocationMatrix
	 * @Inputs a delta
	 * @Return Count increased by Delta
	 * @Param Delta the amount to add
	 */
	void Add(int Delta)
	{
		Count += Delta;
	}

	/**
	 * Replace Label.
	 *
	 * @Covers UStruct.UStructMemberMethodInvocationMatrix
	 * @Inputs a new label
	 * @Return Label set to NewLabel
	 * @Param NewLabel the replacement label
	 */
	void Rename(const FString&in NewLabel)
	{
		Label = NewLabel;
	}

	/**
	 * Return a copy with Count increased and Label suffixed with _Bonus.
	 *
	 * @Covers UStruct.UStructMemberMethodInvocationMatrix
	 * @Inputs a bonus
	 * @Return a new payload
	 * @Param Bonus the amount added to Count
	 */
	FStructMethodPayload WithBonus(int Bonus) const
	{
		FStructMethodPayload Result;
		Result.Count = Count + Bonus;
		Result.Label = Label + "_Bonus";
		return Result;
	}

	/**
	 * Copy Count and Label from another payload.
	 *
	 * @Covers UStruct.UStructMemberMethodInvocationMatrix
	 * @Inputs another FStructMethodPayload
	 * @Return this matching Other
	 * @Param Other the source payload
	 */
	void CopyFrom(const FStructMethodPayload&in Other)
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

	/**
	 * WorldStory: BeginPlay scores, mutates, bonuses, and copies the payload.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructMemberMethodInvocationMatrix
	 * @Inputs none
	 * @Return InitialScore 44, Data 7/Renamed, MutatedScore 77, BonusData 12/Renamed_Bonus
	 */
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

	/**
	 * Observe empty method results before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructMemberMethodInvocationMatrix
	 * @Inputs an actor that has not begun play
	 * @Return true when Score is 0, Describe is :0, and actor fields are still default
	 * @Boundary empty payload
	 */
	UFUNCTION()
	bool MemberMethodDefaultEmpty()
	{
		FStructMethodPayload Empty;
		if (Empty.Score() != 0)
		{
			return false;
		}
		if (Empty.Describe() != ":0")
		{
			return false;
		}
		if (InitialScore != 0)
		{
			return false;
		}
		return Data.Count == 0;
	}

	/**
	 * Observe method oracles after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructMemberMethodInvocationMatrix
	 * @Inputs BeginPlay on this actor
	 * @Return true when score, rename, bonus, and copy match
	 */
	UFUNCTION()
	bool MemberMethodNominalBeginPlay()
	{
		BeginPlay();
		if (InitialScore != 44)
		{
			return false;
		}
		if (InitialDescription != "Base:4")
		{
			return false;
		}
		if (Data.Count != 7)
		{
			return false;
		}
		if (Data.Label != "Renamed")
		{
			return false;
		}
		if (MutatedScore != 77)
		{
			return false;
		}
		if (MutatedDescription != "Renamed:7")
		{
			return false;
		}
		if (BonusData.Count != 12)
		{
			return false;
		}
		if (BonusData.Label != "Renamed_Bonus")
		{
			return false;
		}
		if (CopiedData.Count != 12)
		{
			return false;
		}
		return CopiedData.Label == "Renamed_Bonus";
	}

	/**
	 * Observe that WithBonus copies independently of later Add.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructMemberMethodInvocationMatrix
	 * @Inputs WithBonus(5) then Add(1) on the source
	 * @Return true when the bonus stays 9/Base_Bonus and the source is 5
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool MemberMethodCopyIndependence()
	{
		FStructMethodPayload Source;
		Source.Count = 4;
		Source.Label = "Base";
		FStructMethodPayload Bonus = Source.WithBonus(5);
		Source.Add(1);
		if (Bonus.Count != 9)
		{
			return false;
		}
		if (Bonus.Label != "Base_Bonus")
		{
			return false;
		}
		return Source.Count == 5;
	}
}
