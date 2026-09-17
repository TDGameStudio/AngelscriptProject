/**
 * @version v1
 * @summary BeginPlay executes bool/float map delegates. BoolStructValueResult 2, BoolStructOutPreserved Score 122, StructFloatReturn 342.5f. Empty maps Num 0. False-key miss.
 * @topic Feature
 */
/**
 * @version root
 * @summary BeginPlay executes bool/float map delegates. BoolStructValueResult 2, BoolStructOutPreserved Score 122, StructFloatReturn 342.5f. Empty maps Num 0. False-key miss.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FDelegateExtendedMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers Delegates.ExtendedMapBoolFloatBeginPlay
	 * @Inputs another FDelegateExtendedMapKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FDelegateExtendedMapKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 887 plus Tag.GetHash().
	 *
	 * @Covers Delegates.ExtendedMapBoolFloatBeginPlay
	 * @Inputs none
	 * @Return uint32(ID * 887) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 887) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FDelegateExtendedMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

/**
 * Bool-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FBoolStructMapValueSignal(TMap<bool, FDelegateExtendedMapValue> Items);

/**
 * Bool-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FBoolStructMapInSignal(const TMap<bool, FDelegateExtendedMapValue>&in Items);

/**
 * Bool-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FBoolStructMapOutSignal(TMap<bool, FDelegateExtendedMapValue>&out Items);

/**
 * Bool-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FBoolStructMapInoutSignal(TMap<bool, FDelegateExtendedMapValue>&inout Items);

/**
 * Bool-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of values
 */
delegate TMap<bool, FDelegateExtendedMapValue> FBoolStructMapReturnSignal();

/**
 * Struct-to-bool map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructBoolMapValueSignal(TMap<FDelegateExtendedMapKey, bool> Items);

/**
 * Struct-to-bool map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructBoolMapInSignal(const TMap<FDelegateExtendedMapKey, bool>&in Items);

/**
 * Struct-to-bool map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructBoolMapOutSignal(TMap<FDelegateExtendedMapKey, bool>&out Items);

/**
 * Struct-to-bool map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructBoolMapInoutSignal(TMap<FDelegateExtendedMapKey, bool>&inout Items);

/**
 * Struct-to-bool map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of bools
 */
delegate TMap<FDelegateExtendedMapKey, bool> FStructBoolMapReturnSignal();

/**
 * Struct-to-float map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructFloatMapValueSignal(TMap<FDelegateExtendedMapKey, float> Items);

/**
 * Struct-to-float map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructFloatMapInSignal(const TMap<FDelegateExtendedMapKey, float>&in Items);

/**
 * Struct-to-float map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructFloatMapOutSignal(TMap<FDelegateExtendedMapKey, float>&out Items);

/**
 * Struct-to-float map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructFloatMapInoutSignal(TMap<FDelegateExtendedMapKey, float>&inout Items);

/**
 * Struct-to-float map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of floats
 */
delegate TMap<FDelegateExtendedMapKey, float> FStructFloatMapReturnSignal();

UCLASS()
class ACoverageStructExtendedMapDelegateActor : AActor
{
	UPROPERTY()
	FBoolStructMapValueSignal BoolStructValueSignal;

	UPROPERTY()
	FBoolStructMapInSignal BoolStructInSignal;

	UPROPERTY()
	FBoolStructMapOutSignal BoolStructOutSignal;

	UPROPERTY()
	FBoolStructMapInoutSignal BoolStructInoutSignal;

	UPROPERTY()
	FBoolStructMapReturnSignal BoolStructReturnSignal;

	UPROPERTY()
	FStructBoolMapValueSignal StructBoolValueSignal;

	UPROPERTY()
	FStructBoolMapInSignal StructBoolInSignal;

	UPROPERTY()
	FStructBoolMapOutSignal StructBoolOutSignal;

	UPROPERTY()
	FStructBoolMapInoutSignal StructBoolInoutSignal;

	UPROPERTY()
	FStructBoolMapReturnSignal StructBoolReturnSignal;

	UPROPERTY()
	FStructFloatMapValueSignal StructFloatValueSignal;

	UPROPERTY()
	FStructFloatMapInSignal StructFloatInSignal;

	UPROPERTY()
	FStructFloatMapOutSignal StructFloatOutSignal;

	UPROPERTY()
	FStructFloatMapInoutSignal StructFloatInoutSignal;

	UPROPERTY()
	FStructFloatMapReturnSignal StructFloatReturnSignal;

	UPROPERTY()
	int BoolStructValueResult = 0;

	UPROPERTY()
	int BoolStructInResult = 0;

	UPROPERTY()
	int BoolStructInoutResult = 0;

	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructOutResult;

	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructInoutResultItems;

	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructReturnResult;

	UPROPERTY()
	bool BoolStructValuePreserved = false;

	UPROPERTY()
	bool BoolStructInPreserved = false;

	UPROPERTY()
	bool BoolStructOutPreserved = false;

	UPROPERTY()
	bool BoolStructInoutPreserved = false;

	UPROPERTY()
	bool BoolStructReturnPreserved = false;

	UPROPERTY()
	int StructBoolValueResult = 0;

	UPROPERTY()
	int StructBoolInResult = 0;

	UPROPERTY()
	int StructBoolInoutResult = 0;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolOutResult;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolInoutResultItems;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolReturnResult;

	UPROPERTY()
	bool StructBoolValuePreserved = false;

	UPROPERTY()
	bool StructBoolInPreserved = false;

	UPROPERTY()
	bool StructBoolOutPreserved = false;

	UPROPERTY()
	bool StructBoolInoutPreserved = false;

	UPROPERTY()
	bool StructBoolReturnPreserved = false;

	UPROPERTY()
	int StructFloatValueResult = 0;

	UPROPERTY()
	int StructFloatInResult = 0;

	UPROPERTY()
	int StructFloatInoutResult = 0;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatOutResult;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatInoutResultItems;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatReturnResult;

	UPROPERTY()
	bool StructFloatValuePreserved = false;

	UPROPERTY()
	bool StructFloatInPreserved = false;

	UPROPERTY()
	bool StructFloatOutPreserved = false;

	UPROPERTY()
	bool StructFloatInoutPreserved = false;

	UPROPERTY()
	bool StructFloatReturnPreserved = false;

	/**
	 * Build an extended map key from an id and tag.
	 *
	 * @Covers Delegates.ExtendedMapBoolFloatBeginPlay
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FDelegateExtendedMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateExtendedMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Build an extended map value from a score and label.
	 *
	 * @Covers Delegates.ExtendedMapBoolFloatBeginPlay
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FDelegateExtendedMapValue MakeValue(int Score, FString Label)
	{
		FDelegateExtendedMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * Count a bool-to-struct map by value and record Find(false) Score 102.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleBoolStructValue(TMap<bool, FDelegateExtendedMapValue> Items)
	{
		FDelegateExtendedMapValue Found;
		BoolStructValuePreserved = Items.Find(false, Found) && Found.Score == 102 && Found.Label == "BoolValueFalse";
		return Items.Num();
	}

	/**
	 * Count a const bool-to-struct map as &in and record Find(true) Score 111.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<bool, FDelegateExtendedMapValue>&in
	 * @Inputs Items
	 * @Return Items.Num() + 10
	 */
	UFUNCTION()
	int HandleBoolStructIn(const TMap<bool, FDelegateExtendedMapValue>&in Items)
	{
		FDelegateExtendedMapValue Found;
		BoolStructInPreserved = Items.Find(true, Found) && Found.Score == 111 && Found.Label == "BoolInTrue";
		return Items.Num() + 10;
	}

	/**
	 * Fill an &out bool-to-struct map with true/false values.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<bool, FDelegateExtendedMapValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleBoolStructOut(TMap<bool, FDelegateExtendedMapValue>&out Items)
	{
		Items.Add(true, MakeValue(121, "BoolOutTrue"));
		Items.Add(false, MakeValue(122, "BoolOutFalse"));
	}

	/**
	 * Mutate an &inout bool-to-struct map, rewriting true to Score 231.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<bool, FDelegateExtendedMapValue>&inout
	 * @Inputs Items
	 * @Return Items.Num() + Mutated.Score
	 */
	UFUNCTION()
	int HandleBoolStructInout(TMap<bool, FDelegateExtendedMapValue>&inout Items)
	{
		FDelegateExtendedMapValue Found;
		if (Items.Find(true, Found))
		{
			Found.Score += 100;
			Found.Label = "BoolInoutMutated";
			Items.Add(true, Found);
		}
		Items.Add(false, MakeValue(132, "BoolInoutAdded"));
		BoolStructInoutResultItems = Items;
		FDelegateExtendedMapValue Mutated;
		BoolStructInoutPreserved = Items.Find(true, Mutated) && Mutated.Score == 231 && Mutated.Label == "BoolInoutMutated";
		return Items.Num() + Mutated.Score;
	}

	/**
	 * Return a bool-to-struct map of true/false values.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return true/false entries
	 */
	UFUNCTION()
	TMap<bool, FDelegateExtendedMapValue> HandleBoolStructReturn()
	{
		TMap<bool, FDelegateExtendedMapValue> Items;
		Items.Add(true, MakeValue(141, "BoolReturnTrue"));
		Items.Add(false, MakeValue(142, "BoolReturnFalse"));
		return Items;
	}

	/**
	 * Count a struct-to-bool map by value and record Find key 201 as false.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStructBoolValue(TMap<FDelegateExtendedMapKey, bool> Items)
	{
		bool Found = true;
		StructBoolValuePreserved = Items.Find(MakeKey(201, n"StructBoolValueB"), Found) && !Found;
		return Items.Num();
	}

	/**
	 * Count a const struct-to-bool map as &in and record Find key 211 as true.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FDelegateExtendedMapKey, bool>&in
	 * @Inputs Items
	 * @Return Items.Num() + 20
	 */
	UFUNCTION()
	int HandleStructBoolIn(const TMap<FDelegateExtendedMapKey, bool>&in Items)
	{
		bool Found = false;
		StructBoolInPreserved = Items.Find(MakeKey(211, n"StructBoolInB"), Found) && Found;
		return Items.Num() + 20;
	}

	/**
	 * Fill an &out struct-to-bool map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateExtendedMapKey, bool>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleStructBoolOut(TMap<FDelegateExtendedMapKey, bool>&out Items)
	{
		Items.Add(MakeKey(220, n"StructBoolOutA"), true);
		Items.Add(MakeKey(221, n"StructBoolOutB"), false);
	}

	/**
	 * Mutate an &inout struct-to-bool map, flipping key 230.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateExtendedMapKey, bool>&inout
	 * @Inputs Items
	 * @Return Items.Num() + (Mutated ? 40 : 50)
	 */
	UFUNCTION()
	int HandleStructBoolInout(TMap<FDelegateExtendedMapKey, bool>&inout Items)
	{
		FDelegateExtendedMapKey Existing = MakeKey(230, n"StructBoolInoutA");
		bool Found = false;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, !Found);
		}
		Items.Add(MakeKey(231, n"StructBoolInoutB"), true);
		StructBoolInoutResultItems = Items;
		bool Mutated = false;
		StructBoolInoutPreserved = Items.Find(Existing, Mutated) && !Mutated;
		return Items.Num() + (Mutated ? 40 : 50);
	}

	/**
	 * Return a struct-to-bool map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 240/241
	 */
	UFUNCTION()
	TMap<FDelegateExtendedMapKey, bool> HandleStructBoolReturn()
	{
		TMap<FDelegateExtendedMapKey, bool> Items;
		Items.Add(MakeKey(240, n"StructBoolReturnA"), true);
		Items.Add(MakeKey(241, n"StructBoolReturnB"), false);
		return Items;
	}

	/**
	 * Count a struct-to-float map by value and record Find 302.5f.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStructFloatValue(TMap<FDelegateExtendedMapKey, float> Items)
	{
		float Found = 0.0f;
		StructFloatValuePreserved = Items.Find(MakeKey(301, n"StructFloatValueB"), Found) && Found == 302.5f;
		return Items.Num();
	}

	/**
	 * Count a const struct-to-float map as &in and record Find 312.5f.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FDelegateExtendedMapKey, float>&in
	 * @Inputs Items
	 * @Return Items.Num() + 30
	 */
	UFUNCTION()
	int HandleStructFloatIn(const TMap<FDelegateExtendedMapKey, float>&in Items)
	{
		float Found = 0.0f;
		StructFloatInPreserved = Items.Find(MakeKey(311, n"StructFloatInB"), Found) && Found == 312.5f;
		return Items.Num() + 30;
	}

	/**
	 * Fill an &out struct-to-float map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateExtendedMapKey, float>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleStructFloatOut(TMap<FDelegateExtendedMapKey, float>&out Items)
	{
		Items.Add(MakeKey(320, n"StructFloatOutA"), 321.5f);
		Items.Add(MakeKey(321, n"StructFloatOutB"), 322.5f);
	}

	/**
	 * Mutate an &inout struct-to-float map, adding 100 to key 330.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateExtendedMapKey, float>&inout
	 * @Inputs Items
	 * @Return Items.Num() + int(Mutated)
	 */
	UFUNCTION()
	int HandleStructFloatInout(TMap<FDelegateExtendedMapKey, float>&inout Items)
	{
		FDelegateExtendedMapKey Existing = MakeKey(330, n"StructFloatInoutA");
		float Found = 0.0f;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, Found + 100.0f);
		}
		Items.Add(MakeKey(331, n"StructFloatInoutB"), 332.5f);
		StructFloatInoutResultItems = Items;
		float Mutated = 0.0f;
		StructFloatInoutPreserved = Items.Find(Existing, Mutated) && Mutated == 431.5f;
		return Items.Num() + int(Mutated);
	}

	/**
	 * Return a struct-to-float map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 340/341
	 */
	UFUNCTION()
	TMap<FDelegateExtendedMapKey, float> HandleStructFloatReturn()
	{
		TMap<FDelegateExtendedMapKey, float> Items;
		Items.Add(MakeKey(340, n"StructFloatReturnA"), 341.5f);
		Items.Add(MakeKey(341, n"StructFloatReturnB"), 342.5f);
		return Items;
	}

	/**
	 * WorldStory: BeginPlay binds and executes bool/float map delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return BoolStructValueResult 2, BoolStructOutPreserved Score 122, StructFloatReturn 342.5f
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BoolStructValueSignal.BindUFunction(this, n"HandleBoolStructValue");
		BoolStructInSignal.BindUFunction(this, n"HandleBoolStructIn");
		BoolStructOutSignal.BindUFunction(this, n"HandleBoolStructOut");
		BoolStructInoutSignal.BindUFunction(this, n"HandleBoolStructInout");
		BoolStructReturnSignal.BindUFunction(this, n"HandleBoolStructReturn");

		TMap<bool, FDelegateExtendedMapValue> BoolStructValueItems;
		BoolStructValueItems.Add(true, MakeValue(101, "BoolValueTrue"));
		BoolStructValueItems.Add(false, MakeValue(102, "BoolValueFalse"));
		BoolStructValueResult = BoolStructValueSignal.Execute(BoolStructValueItems);

		TMap<bool, FDelegateExtendedMapValue> BoolStructInItems;
		BoolStructInItems.Add(true, MakeValue(111, "BoolInTrue"));
		BoolStructInItems.Add(false, MakeValue(112, "BoolInFalse"));
		BoolStructInResult = BoolStructInSignal.Execute(BoolStructInItems);

		BoolStructOutSignal.Execute(BoolStructOutResult);
		FDelegateExtendedMapValue BoolStructOutFound;
		BoolStructOutPreserved =
			BoolStructOutResult.Find(false, BoolStructOutFound)
			&& BoolStructOutFound.Score == 122
			&& BoolStructOutFound.Label == "BoolOutFalse";

		BoolStructInoutResultItems.Add(true, MakeValue(131, "BoolInoutOriginal"));
		BoolStructInoutResult = BoolStructInoutSignal.Execute(BoolStructInoutResultItems);

		BoolStructReturnResult = BoolStructReturnSignal.Execute();
		FDelegateExtendedMapValue BoolStructReturnFound;
		BoolStructReturnPreserved =
			BoolStructReturnResult.Find(false, BoolStructReturnFound)
			&& BoolStructReturnFound.Score == 142
			&& BoolStructReturnFound.Label == "BoolReturnFalse";

		StructBoolValueSignal.BindUFunction(this, n"HandleStructBoolValue");
		StructBoolInSignal.BindUFunction(this, n"HandleStructBoolIn");
		StructBoolOutSignal.BindUFunction(this, n"HandleStructBoolOut");
		StructBoolInoutSignal.BindUFunction(this, n"HandleStructBoolInout");
		StructBoolReturnSignal.BindUFunction(this, n"HandleStructBoolReturn");

		TMap<FDelegateExtendedMapKey, bool> StructBoolValueItems;
		StructBoolValueItems.Add(MakeKey(200, n"StructBoolValueA"), true);
		StructBoolValueItems.Add(MakeKey(201, n"StructBoolValueB"), false);
		StructBoolValueResult = StructBoolValueSignal.Execute(StructBoolValueItems);

		TMap<FDelegateExtendedMapKey, bool> StructBoolInItems;
		StructBoolInItems.Add(MakeKey(210, n"StructBoolInA"), false);
		StructBoolInItems.Add(MakeKey(211, n"StructBoolInB"), true);
		StructBoolInResult = StructBoolInSignal.Execute(StructBoolInItems);

		StructBoolOutSignal.Execute(StructBoolOutResult);
		bool StructBoolOutFound = true;
		StructBoolOutPreserved =
			StructBoolOutResult.Find(MakeKey(221, n"StructBoolOutB"), StructBoolOutFound)
			&& !StructBoolOutFound;

		StructBoolInoutResultItems.Add(MakeKey(230, n"StructBoolInoutA"), true);
		StructBoolInoutResult = StructBoolInoutSignal.Execute(StructBoolInoutResultItems);

		StructBoolReturnResult = StructBoolReturnSignal.Execute();
		bool StructBoolReturnFound = true;
		StructBoolReturnPreserved =
			StructBoolReturnResult.Find(MakeKey(241, n"StructBoolReturnB"), StructBoolReturnFound)
			&& !StructBoolReturnFound;

		StructFloatValueSignal.BindUFunction(this, n"HandleStructFloatValue");
		StructFloatInSignal.BindUFunction(this, n"HandleStructFloatIn");
		StructFloatOutSignal.BindUFunction(this, n"HandleStructFloatOut");
		StructFloatInoutSignal.BindUFunction(this, n"HandleStructFloatInout");
		StructFloatReturnSignal.BindUFunction(this, n"HandleStructFloatReturn");

		TMap<FDelegateExtendedMapKey, float> StructFloatValueItems;
		StructFloatValueItems.Add(MakeKey(300, n"StructFloatValueA"), 301.5f);
		StructFloatValueItems.Add(MakeKey(301, n"StructFloatValueB"), 302.5f);
		StructFloatValueResult = StructFloatValueSignal.Execute(StructFloatValueItems);

		TMap<FDelegateExtendedMapKey, float> StructFloatInItems;
		StructFloatInItems.Add(MakeKey(310, n"StructFloatInA"), 311.5f);
		StructFloatInItems.Add(MakeKey(311, n"StructFloatInB"), 312.5f);
		StructFloatInResult = StructFloatInSignal.Execute(StructFloatInItems);

		StructFloatOutSignal.Execute(StructFloatOutResult);
		float StructFloatOutFound = 0.0f;
		StructFloatOutPreserved =
			StructFloatOutResult.Find(MakeKey(321, n"StructFloatOutB"), StructFloatOutFound)
			&& StructFloatOutFound == 322.5f;

		StructFloatInoutResultItems.Add(MakeKey(330, n"StructFloatInoutA"), 331.5f);
		StructFloatInoutResult = StructFloatInoutSignal.Execute(StructFloatInoutResultItems);

		StructFloatReturnResult = StructFloatReturnSignal.Execute();
		float StructFloatReturnFound = 0.0f;
		StructFloatReturnPreserved =
			StructFloatReturnResult.Find(MakeKey(341, n"StructFloatReturnB"), StructFloatReturnFound)
			&& StructFloatReturnFound == 342.5f;
	}

	/**
	 * Observe the default BoolStructValueResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default BoolStructValueResult
	 */
	UFUNCTION()
	int BoolStructValueResultDefaultZero()
	{
		return BoolStructValueResult;
	}

	/**
	 * Observe empty bool-to-struct map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyBoolMapDefaultNum()
	{
		TMap<bool, FDelegateExtendedMapValue> Items;
		return Items.Num();
	}

	/**
	 * Observe that mutating a value copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Original Score 102 and a zeroed copy
	 * @Return true when Original.Score stays 102
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ValueCopyIndependence()
	{
		FDelegateExtendedMapValue Original;
		Original.Score = 102;
		Original.Label = "BoolValueFalse";
		FDelegateExtendedMapValue Copy = Original;
		Copy.Score = 0;
		if (Original.Score != 102)
		{
			return false;
		}
		return Copy.Score == 0;
	}
}
/** @end */
