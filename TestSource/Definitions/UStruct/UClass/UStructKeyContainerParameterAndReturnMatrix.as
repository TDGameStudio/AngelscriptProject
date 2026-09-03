/**
 * TMap/TSet of hashable struct keys as parameters and returns.
 * CountStructKeyMapValue Contains key 11. ReturnStructValueMap score 441.
 * Set out two keys. Empty map/set counts 0.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructKeyContainerParameterAndReturnMatrix
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructKeyContainerParameterAndReturnMatrix
 * @Provenance Theme: Definitions.UStruct. WorldStory: TMap/TSet of hashable struct keys as parameters and returns.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructKeyContainerParameterAndReturnMatrix.
 * @Provenance Oracle: CountStructKeyMapValue Contains key 11; ReturnStructValueMap score 441; set out two keys.
 * @Provenance Extra: empty map/set counts 0. FixtureIsolated.
 */

USTRUCT(BlueprintType)
struct FStructContainerKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Inputs another FStructContainerKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FStructContainerKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 313 plus Tag.GetHash().
	 *
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Inputs none
	 * @Return uint32(ID * 313) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 313) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FStructContainerValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructKeyContainerMatrixActor : AActor
{
	UPROPERTY()
	int StructKeyMapValueCount = 0;

	UPROPERTY()
	int StructKeyMapInCount = 0;

	UPROPERTY()
	TMap<FStructContainerKey, int> StructKeyMapInout;

	UPROPERTY()
	TMap<FStructContainerKey, int> StructKeyMapOut;

	UPROPERTY()
	TMap<FStructContainerKey, int> StructKeyMapReturn;

	UPROPERTY()
	bool StructKeyMapValueContains = false;

	UPROPERTY()
	bool StructKeyMapInContains = false;

	UPROPERTY()
	bool StructKeyMapInoutMutated = false;

	UPROPERTY()
	bool StructValueMapReturnContains = false;

	UPROPERTY()
	int StructValueMapReturnScore = 0;

	UPROPERTY()
	int StructSetValueCount = 0;

	UPROPERTY()
	int StructSetInCount = 0;

	UPROPERTY()
	TSet<FStructContainerKey> StructSetInout;

	UPROPERTY()
	TSet<FStructContainerKey> StructSetOut;

	UPROPERTY()
	TSet<FStructContainerKey> StructSetReturn;

	UPROPERTY()
	bool StructSetValueContains = false;

	UPROPERTY()
	bool StructSetInContains = false;

	UPROPERTY()
	bool StructSetInoutMutated = false;

	/**
	 * Build a container key from an id and tag.
	 *
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FStructContainerKey MakeKey(int ID, FName Tag)
	{
		FStructContainerKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Build a container value from a score and label.
	 *
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FStructContainerValue MakeValue(int Score, FString Label)
	{
		FStructContainerValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * Count a struct-key map by value and record Contains key 11.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return StructKeyMapValueCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructKeyMapValue(TMap<FStructContainerKey, int> Items)
	{
		StructKeyMapValueCount = Items.Num();
		StructKeyMapValueContains = Items.Contains(MakeKey(11, n"MapValueB"));
		return StructKeyMapValueCount;
	}

	/**
	 * Count a const struct-key map as &in and record Contains key 13.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Param Items Map received as const TMap<FStructContainerKey, int>&in
	 * @Inputs Items
	 * @Return StructKeyMapInCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructKeyMapIn(const TMap<FStructContainerKey, int>&in Items)
	{
		StructKeyMapInCount = Items.Num();
		StructKeyMapInContains = Items.Contains(MakeKey(13, n"MapInB"));
		return StructKeyMapInCount;
	}

	/**
	 * Fill an &out struct-key map with two keys.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Param Items Map received as TMap<FStructContainerKey, int>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructKeyMapOut(TMap<FStructContainerKey, int>&out Items)
	{
		Items.Add(MakeKey(14, n"MapOutA"), 114);
		Items.Add(MakeKey(15, n"MapOutB"), 115);
		StructKeyMapOut = Items;
	}

	/**
	 * Mutate an &inout struct-key map, rewriting key 20 to 220.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Param Items Map received as TMap<FStructContainerKey, int>&inout
	 * @Inputs Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStructKeyMapInout(TMap<FStructContainerKey, int>&inout Items)
	{
		FStructContainerKey Existing = MakeKey(20, n"MapInoutA");
		Items.Remove(Existing);
		Items.Add(Existing, 220);
		Items.Add(MakeKey(21, n"MapInoutB"), 221);
		StructKeyMapInout = Items;
		int MutatedValue = 0;
		StructKeyMapInoutMutated = Items.Find(Existing, MutatedValue) && MutatedValue == 220;
	}

	/**
	 * Return a struct-key map of two keys.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Inputs none
	 * @Return keys 30/31
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FStructContainerKey, int> ReturnStructKeyMap()
	{
		TMap<FStructContainerKey, int> Items;
		Items.Add(MakeKey(30, n"MapReturnA"), 330);
		Items.Add(MakeKey(31, n"MapReturnB"), 331);
		return Items;
	}

	/**
	 * Return a map of int to struct value and record score 441.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Inputs none
	 * @Return keys 40/41 with Score 441 on 41
	 */
	UFUNCTION(BlueprintCallable)
	TMap<int, FStructContainerValue> ReturnStructValueMap()
	{
		TMap<int, FStructContainerValue> Items;
		Items.Add(40, MakeValue(440, "MapValueReturnA"));
		Items.Add(41, MakeValue(441, "MapValueReturnB"));

		FStructContainerValue Found;
		StructValueMapReturnContains = Items.Find(41, Found);
		StructValueMapReturnScore = Found.Score;
		return Items;
	}

	/**
	 * Count a struct-key set by value and record Contains key 51.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Param Items Set received by value
	 * @Inputs Items
	 * @Return StructSetValueCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructSetValue(TSet<FStructContainerKey> Items)
	{
		StructSetValueCount = Items.Num();
		StructSetValueContains = Items.Contains(MakeKey(51, n"SetValueB"));
		return StructSetValueCount;
	}

	/**
	 * Count a const struct-key set as &in and record Contains key 53.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Param Items Set received as const TSet<FStructContainerKey>&in
	 * @Inputs Items
	 * @Return StructSetInCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructSetIn(const TSet<FStructContainerKey>&in Items)
	{
		StructSetInCount = Items.Num();
		StructSetInContains = Items.Contains(MakeKey(53, n"SetInB"));
		return StructSetInCount;
	}

	/**
	 * Fill an &out struct-key set with two keys.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Param Items Set received as TSet<FStructContainerKey>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructSetOut(TSet<FStructContainerKey>&out Items)
	{
		Items.Add(MakeKey(54, n"SetOutA"));
		Items.Add(MakeKey(55, n"SetOutB"));
		StructSetOut = Items;
	}

	/**
	 * Mutate an &inout struct-key set, removing 60 and adding 61.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Param Items Set received as TSet<FStructContainerKey>&inout
	 * @Inputs Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStructSetInout(TSet<FStructContainerKey>&inout Items)
	{
		Items.Remove(MakeKey(60, n"SetInoutA"));
		Items.Add(MakeKey(61, n"SetInoutB"));
		StructSetInout = Items;
		StructSetInoutMutated = !Items.Contains(MakeKey(60, n"SetInoutA")) && Items.Contains(MakeKey(61, n"SetInoutB"));
	}

	/**
	 * Return a struct-key set of two keys.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Inputs none
	 * @Return keys 70/71
	 */
	UFUNCTION(BlueprintCallable)
	TSet<FStructContainerKey> ReturnStructSet()
	{
		TSet<FStructContainerKey> Items;
		Items.Add(MakeKey(70, n"SetReturnA"));
		Items.Add(MakeKey(71, n"SetReturnB"));
		return Items;
	}

	/**
	 * Observe empty map/set counts and empty out containers.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Inputs empty map and set
	 * @Return true when counts are 0 and out containers are empty
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool KeyContainerDefaultEmpty()
	{
		TMap<FStructContainerKey, int> EmptyMap;
		TSet<FStructContainerKey> EmptySet;
		if (CountStructKeyMapValue(EmptyMap) != 0)
		{
			return false;
		}
		if (StructKeyMapValueContains)
		{
			return false;
		}
		if (CountStructSetValue(EmptySet) != 0)
		{
			return false;
		}
		if (StructKeyMapOut.Num() != 0)
		{
			return false;
		}
		return StructSetOut.Num() == 0;
	}

	/**
	 * Observe nominal struct-key map and set value/in/out/inout/return.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Inputs populated maps and sets
	 * @Return true when Contains key 11, score 441, and inout mutated
	 */
	UFUNCTION()
	bool KeyContainerNominalMapAndSet()
	{
		TMap<FStructContainerKey, int> MapValue;
		MapValue.Add(MakeKey(10, n"MapValueA"), 110);
		MapValue.Add(MakeKey(11, n"MapValueB"), 111);
		TMap<FStructContainerKey, int> MapIn;
		MapIn.Add(MakeKey(12, n"MapInA"), 112);
		MapIn.Add(MakeKey(13, n"MapInB"), 113);
		TMap<FStructContainerKey, int> MapOut;
		FillStructKeyMapOut(MapOut);
		TMap<FStructContainerKey, int> MapInout;
		MapInout.Add(MakeKey(20, n"MapInoutA"), 120);
		MutateStructKeyMapInout(MapInout);
		TMap<int, FStructContainerValue> ValueReturn = ReturnStructValueMap();
		TSet<FStructContainerKey> SetValue;
		SetValue.Add(MakeKey(50, n"SetValueA"));
		SetValue.Add(MakeKey(51, n"SetValueB"));
		TSet<FStructContainerKey> SetInout;
		SetInout.Add(MakeKey(60, n"SetInoutA"));
		MutateStructSetInout(SetInout);
		if (CountStructKeyMapValue(MapValue) != 2)
		{
			return false;
		}
		if (!StructKeyMapValueContains)
		{
			return false;
		}
		if (CountStructKeyMapIn(MapIn) != 2)
		{
			return false;
		}
		if (!StructKeyMapInContains)
		{
			return false;
		}
		if (MapOut.Num() != 2)
		{
			return false;
		}
		if (!StructKeyMapInoutMutated)
		{
			return false;
		}
		if (!StructValueMapReturnContains)
		{
			return false;
		}
		if (StructValueMapReturnScore != 441)
		{
			return false;
		}
		if (CountStructSetValue(SetValue) != 2)
		{
			return false;
		}
		if (!StructSetValueContains)
		{
			return false;
		}
		if (!StructSetInoutMutated)
		{
			return false;
		}
		return ValueReturn.Num() == 2;
	}

	/**
	 * Observe Find of a zero-id empty-tag key.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructKeyContainerParameterAndReturnMatrix
	 * @Inputs key ID 0 Tag empty mapped to 0
	 * @Return true when Find of a matching zero key returns 0
	 * @Boundary zero key
	 */
	UFUNCTION()
	bool KeyContainerZeroKeyBoundary()
	{
		FStructContainerKey Zero = MakeKey(0, n"");
		TMap<FStructContainerKey, int> Items;
		Items.Add(Zero, 0);
		int Found = -1;
		if (!Items.Find(MakeKey(0, n""), Found))
		{
			return false;
		}
		return Found == 0;
	}
}
