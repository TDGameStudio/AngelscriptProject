/**
 * Name-struct and string-struct handlers. HandleNameStructValue preserves
 * Score 102. Inout mutates 131 to 231. Empty TMap Num 0. Missing name Find
 * false.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MapKeyValueNameStructAndStringStructHandlers
 * @Harness UClass
 * @Tag Feature.Delegates.MapKeyValueNameStructAndStringStructHandlers
 * @Provenance Theme: Feature.Delegates. Positive block 7: name-struct and string-struct handlers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7635-7752.
 * @Provenance Isolation=none: wrap HandleNameStruct* / HandleStringStruct* with value type and flags.
 * @Provenance Oracle: HandleNameStructValue preserves Score 102; inout mutates 131->231.
 * @Provenance Extra: empty TMap Num 0; missing name Find false. DefaultSafe.
 */

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	bool NameStructValuePreserved = false;

	UPROPERTY()
	bool NameStructInPreserved = false;

	UPROPERTY()
	bool NameStructInoutPreserved = false;

	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructInoutResultItems;

	UPROPERTY()
	bool StringStructValuePreserved = false;

	UPROPERTY()
	bool StringStructInPreserved = false;

	UPROPERTY()
	bool StringStructInoutPreserved = false;

	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructInoutResultItems;

	/**
	 * Build a map value from a score and label.
	 *
	 * @Covers Delegates.MapKeyValueNameStructAndStringStructHandlers
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FDelegateKeyValueMapValue MakeValue(int Score, FString Label)
	{
		FDelegateKeyValueMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * Count a name-to-struct map by value and record Find NameValueB Score 102.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleNameStructValue(TMap<FName, FDelegateKeyValueMapValue> Items)
	{
		FDelegateKeyValueMapValue Found;
		NameStructValuePreserved =
			Items.Find(n"NameValueB", Found)
			&& Found.Score == 102
			&& Found.Label == "NameValueB";
		return Items.Num();
	}

	/**
	 * Count a const name-to-struct map as &in and record Find NameInB Score 112.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FName, FDelegateKeyValueMapValue>&in
	 * @Inputs Items
	 * @Return Items.Num() + 10
	 */
	UFUNCTION()
	int HandleNameStructIn(const TMap<FName, FDelegateKeyValueMapValue>&in Items)
	{
		FDelegateKeyValueMapValue Found;
		NameStructInPreserved =
			Items.Find(n"NameInB", Found)
			&& Found.Score == 112
			&& Found.Label == "NameInB";
		return Items.Num() + 10;
	}

	/**
	 * Fill an &out name-to-struct map with two names.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FName, FDelegateKeyValueMapValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleNameStructOut(TMap<FName, FDelegateKeyValueMapValue>&out Items)
	{
		Items.Add(n"NameOutA", MakeValue(121, "NameOutA"));
		Items.Add(n"NameOutB", MakeValue(122, "NameOutB"));
	}

	/**
	 * Mutate an &inout name-to-struct map, rewriting NameInoutA to Score 231.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FName, FDelegateKeyValueMapValue>&inout
	 * @Inputs Items
	 * @Return Items.Num() + Mutated.Score
	 */
	UFUNCTION()
	int HandleNameStructInout(TMap<FName, FDelegateKeyValueMapValue>&inout Items)
	{
		FDelegateKeyValueMapValue Found;
		if (Items.Find(n"NameInoutA", Found))
		{
			Found.Score += 100;
			Found.Label = "NameInoutMutated";
			Items.Add(n"NameInoutA", Found);
		}
		Items.Add(n"NameInoutB", MakeValue(132, "NameInoutAdded"));
		NameStructInoutResultItems = Items;
		FDelegateKeyValueMapValue Mutated;
		NameStructInoutPreserved =
			Items.Find(n"NameInoutA", Mutated)
			&& Mutated.Score == 231
			&& Mutated.Label == "NameInoutMutated";
		return Items.Num() + Mutated.Score;
	}

	/**
	 * Return a name-to-struct map of two names.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return NameReturnA/B
	 */
	UFUNCTION()
	TMap<FName, FDelegateKeyValueMapValue> HandleNameStructReturn()
	{
		TMap<FName, FDelegateKeyValueMapValue> Items;
		Items.Add(n"NameReturnA", MakeValue(141, "NameReturnA"));
		Items.Add(n"NameReturnB", MakeValue(142, "NameReturnB"));
		return Items;
	}

	/**
	 * Count a string-to-struct map by value and record Find StringValueB Score 202.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStringStructValue(TMap<FString, FDelegateKeyValueMapValue> Items)
	{
		FDelegateKeyValueMapValue Found;
		StringStructValuePreserved =
			Items.Find("StringValueB", Found)
			&& Found.Score == 202
			&& Found.Label == "StringValueB";
		return Items.Num();
	}

	/**
	 * Count a const string-to-struct map as &in and record Find StringInB Score 212.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FString, FDelegateKeyValueMapValue>&in
	 * @Inputs Items
	 * @Return Items.Num() + 20
	 */
	UFUNCTION()
	int HandleStringStructIn(const TMap<FString, FDelegateKeyValueMapValue>&in Items)
	{
		FDelegateKeyValueMapValue Found;
		StringStructInPreserved =
			Items.Find("StringInB", Found)
			&& Found.Score == 212
			&& Found.Label == "StringInB";
		return Items.Num() + 20;
	}

	/**
	 * Fill an &out string-to-struct map with two strings.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FString, FDelegateKeyValueMapValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleStringStructOut(TMap<FString, FDelegateKeyValueMapValue>&out Items)
	{
		Items.Add("StringOutA", MakeValue(221, "StringOutA"));
		Items.Add("StringOutB", MakeValue(222, "StringOutB"));
	}

	/**
	 * Mutate an &inout string-to-struct map, rewriting StringInoutA to Score 331.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FString, FDelegateKeyValueMapValue>&inout
	 * @Inputs Items
	 * @Return Items.Num() + Mutated.Score
	 */
	UFUNCTION()
	int HandleStringStructInout(TMap<FString, FDelegateKeyValueMapValue>&inout Items)
	{
		FDelegateKeyValueMapValue Found;
		if (Items.Find("StringInoutA", Found))
		{
			Found.Score += 100;
			Found.Label = "StringInoutMutated";
			Items.Add("StringInoutA", Found);
		}
		Items.Add("StringInoutB", MakeValue(232, "StringInoutAdded"));
		StringStructInoutResultItems = Items;
		FDelegateKeyValueMapValue Mutated;
		StringStructInoutPreserved =
			Items.Find("StringInoutA", Mutated)
			&& Mutated.Score == 331
			&& Mutated.Label == "StringInoutMutated";
		return Items.Num() + Mutated.Score;
	}

	/**
	 * Return a string-to-struct map of two strings.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return StringReturnA/B
	 */
	UFUNCTION()
	TMap<FString, FDelegateKeyValueMapValue> HandleStringStructReturn()
	{
		TMap<FString, FDelegateKeyValueMapValue> Items;
		Items.Add("StringReturnA", MakeValue(241, "StringReturnA"));
		Items.Add("StringReturnB", MakeValue(242, "StringReturnB"));
		return Items;
	}

	/**
	 * Observe empty name-to-struct map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyNameMapDefaultNum()
	{
		TMap<FName, FDelegateKeyValueMapValue> Items;
		return Items.Num();
	}

	/**
	 * Observe MakeValue of Score 0 empty Label.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Score 0 empty Label
	 * @Return 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	int MakeValueZeroBoundary()
	{
		FDelegateKeyValueMapValue Value = MakeValue(0, "");
		return Value.Score;
	}

	/**
	 * Observe Find of a missing name.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs empty map
	 * @Return true when Find misses and Score stays 0
	 * @Boundary missing name
	 */
	UFUNCTION()
	bool MissingNameFindBoundary()
	{
		TMap<FName, FDelegateKeyValueMapValue> Items;
		FDelegateKeyValueMapValue Found;
		if (Items.Find(n"NameValueB", Found))
		{
			return false;
		}
		return Found.Score == 0;
	}
}
