/**
 * @version v1
 * @summary Const &in, &out, and &inout reference directions. ReadConstRefs(30, "Input", (7,8,9)) is 42 LastLabel Input. FillOutRefs writes 42 / "OutLabel" / (4,5,6). MutateInoutRefs(10, "InLabel", (1,2,3)) returns 37, writes 15 /.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Const &in, &out, and &inout reference directions. ReadConstRefs(30, "Input", (7,8,9)) is 42 LastLabel Input. FillOutRefs writes 42 / "OutLabel" / (4,5,6). MutateInoutRefs(10, "InLabel", (1,2,3)) returns 37, writes 15 /.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionReferenceDirectionActor : AActor
{
	UPROPERTY()
	int LastReadScore = 0;

	UPROPERTY()
	bool bInoutSawOriginal = false;

	UPROPERTY()
	FString LastLabel;

	UPROPERTY()
	FVector LastVector = FVector::ZeroVector;

	/**
	 * Read const &in count, label, and location into Last*.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Count Integer received as const int&in
	 * @Param Label String received as const FString&in
	 * @Param Location Vector received as const FVector&in
	 * @Inputs Count, Label, Location
	 * @Return LastReadScore
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|References")
	int ReadConstRefs(const int&in Count, const FString&in Label, const FVector&in Location)
	{
		LastReadScore = Count + Label.Len() + int(Location.X);
		LastLabel = Label;
		LastVector = Location;
		return LastReadScore;
	}

	/**
	 * Fill &out count, label, and location.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Count Integer received as int&out
	 * @Param Label String received as FString&out
	 * @Param Location Vector received as FVector&out
	 * @Inputs empty out destinations
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|References")
	void FillOutRefs(int&out Count, FString&out Label, FVector&out Location)
	{
		Count = 42;
		Label = "OutLabel";
		Location = FVector(4.0, 5.0, 6.0);
	}

	/**
	 * Mutate &inout count, label, and location.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Count Integer received as int&inout
	 * @Param Label String received as FString&inout
	 * @Param Location Vector received as FVector&inout
	 * @Inputs Count, Label, Location
	 * @Return Count + Label.Len() + int(Location.Z)
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|References")
	int MutateInoutRefs(int&inout Count, FString&inout Label, FVector&inout Location)
	{
		bInoutSawOriginal = Count == 10 && Label == "InLabel" && Location.X == 1.0;
		Count += 5;
		Label += "|Mutated";
		Location += FVector(2.0, 3.0, 4.0);
		return Count + Label.Len() + int(Location.Z);
	}

	/**
	 * Observe ReadConstRefs of 30, Input, (7,8,9).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs 30, Input, (7,8,9)
	 * @Return 42
	 */
	UFUNCTION()
	int ReadConstNominal()
	{
		return ReadConstRefs(30, "Input", FVector(7.0, 8.0, 9.0));
	}

	/**
	 * Observe FillOutRefs destinations.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs empty out destinations
	 * @Return true when 42 / OutLabel / (4,5,6)
	 */
	UFUNCTION()
	bool FillOutNominal()
	{
		int Count = 0;
		FString Label;
		FVector Location = FVector::ZeroVector;
		FillOutRefs(Count, Label, Location);
		if (Count != 42)
		{
			return false;
		}
		if (Label != "OutLabel")
		{
			return false;
		}
		if (Location.X != 4.0)
		{
			return false;
		}
		if (Location.Y != 5.0)
		{
			return false;
		}
		return Location.Z == 6.0;
	}

	/**
	 * Observe MutateInoutRefs of 10, InLabel, (1,2,3).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs 10, InLabel, (1,2,3)
	 * @Return 37 when mutated to 15 / InLabel|Mutated / (3,5,7) and bInoutSawOriginal
	 */
	UFUNCTION()
	int MutateInoutNominal()
	{
		int Count = 10;
		FString Label = "InLabel";
		FVector Location = FVector(1.0, 2.0, 3.0);
		int Result = MutateInoutRefs(Count, Label, Location);
		if (!bInoutSawOriginal)
		{
			return -1;
		}
		if (Count != 15)
		{
			return -1;
		}
		if (Label != "InLabel|Mutated")
		{
			return -1;
		}
		if (Location.X != 3.0)
		{
			return -2;
		}
		if (Location.Y != 5.0)
		{
			return -2;
		}
		if (Location.Z != 7.0)
		{
			return -2;
		}
		return Result;
	}

	/**
	 * Observe ReadConstRefs of empty inputs.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs 0, empty string, ZeroVector
	 * @Return 0
	 * @Boundary empty const refs
	 */
	UFUNCTION()
	int ReadEmptyZero()
	{
		return ReadConstRefs(0, "", FVector::ZeroVector);
	}

	/**
	 * Observe the default LastReadScore.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default LastReadScore
	 */
	UFUNCTION()
	int DefaultScore()
	{
		return LastReadScore;
	}

	/**
	 * Observe the default bInoutSawOriginal.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return true when bInoutSawOriginal is false
	 * @Boundary default inout flag
	 */
	UFUNCTION()
	bool DefaultInoutFlag()
	{
		return !bInoutSawOriginal;
	}
}
/** @end */
