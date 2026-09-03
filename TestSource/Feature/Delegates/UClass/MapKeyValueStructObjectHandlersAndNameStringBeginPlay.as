/**
 * Struct-object handlers plus name/string BeginPlay. HandleStructObjectValue
 * Found.Value 502. NameStructValueResult 2. NameOutB Score 122. Empty maps
 * Num 0. Null object miss.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MapKeyValueStructObjectHandlersAndNameStringBeginPlay
 * @Harness UClass
 * @Tag Feature.Delegates.MapKeyValueStructObjectHandlersAndNameStringBeginPlay
 * @Provenance Theme: Feature.Delegates. WorldStory block 10: struct-object handlers plus name/string BeginPlay.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 8009-8136.
 * @Provenance Isolation=none: wrap HandleStructObject* and the BeginPlay fragment with key/value/object
 * @Provenance types, signals, MakeKey/MakeValue/MakeObject, and name/string handlers.
 * @Provenance Oracle: HandleStructObjectValue Found.Value 502; NameStructValueResult 2; NameOutB Score 122.
 * @Provenance Extra: empty maps Num 0; null object miss. FixtureIsolated. Keep BeginPlay.
 */

UCLASS()
class UCoverageStructDelegateMapValueObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers Delegates.MapKeyValueStructObjectHandlersAndNameStringBeginPlay
	 * @Inputs another FDelegateKeyValueMapKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FDelegateKeyValueMapKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 929 plus Tag.GetHash().
	 *
	 * @Covers Delegates.MapKeyValueStructObjectHandlersAndNameStringBeginPlay
	 * @Inputs none
	 * @Return uint32(ID * 929) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 929) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

/**
 * Name-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FNameStructMapValueSignal(TMap<FName, FDelegateKeyValueMapValue> Items);

/**
 * Name-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FNameStructMapInSignal(const TMap<FName, FDelegateKeyValueMapValue>&in Items);

/**
 * Name-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FNameStructMapOutSignal(TMap<FName, FDelegateKeyValueMapValue>&out Items);

/**
 * Name-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FNameStructMapInoutSignal(TMap<FName, FDelegateKeyValueMapValue>&inout Items);

/**
 * Name-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of values
 */
delegate TMap<FName, FDelegateKeyValueMapValue> FNameStructMapReturnSignal();

/**
 * String-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStringStructMapValueSignal(TMap<FString, FDelegateKeyValueMapValue> Items);

/**
 * String-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStringStructMapInSignal(const TMap<FString, FDelegateKeyValueMapValue>&in Items);

/**
 * String-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStringStructMapOutSignal(TMap<FString, FDelegateKeyValueMapValue>&out Items);

/**
 * String-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStringStructMapInoutSignal(TMap<FString, FDelegateKeyValueMapValue>&inout Items);

/**
 * String-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of values
 */
delegate TMap<FString, FDelegateKeyValueMapValue> FStringStructMapReturnSignal();

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	FNameStructMapValueSignal NameStructValueSignal;

	UPROPERTY()
	FNameStructMapInSignal NameStructInSignal;

	UPROPERTY()
	FNameStructMapOutSignal NameStructOutSignal;

	UPROPERTY()
	FNameStructMapInoutSignal NameStructInoutSignal;

	UPROPERTY()
	FNameStructMapReturnSignal NameStructReturnSignal;

	UPROPERTY()
	FStringStructMapValueSignal StringStructValueSignal;

	UPROPERTY()
	FStringStructMapInSignal StringStructInSignal;

	UPROPERTY()
	FStringStructMapOutSignal StringStructOutSignal;

	UPROPERTY()
	FStringStructMapInoutSignal StringStructInoutSignal;

	UPROPERTY()
	FStringStructMapReturnSignal StringStructReturnSignal;

	UPROPERTY()
	bool StructObjectValuePreserved = false;

	UPROPERTY()
	bool StructObjectInPreserved = false;

	UPROPERTY()
	bool StructObjectInoutPreserved = false;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> StructObjectInoutResultItems;

	UPROPERTY()
	int NameStructValueResult = 0;

	UPROPERTY()
	int NameStructInResult = 0;

	UPROPERTY()
	int NameStructInoutResult = 0;

	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructOutResult;

	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructInoutResultItems;

	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructReturnResult;

	UPROPERTY()
	bool NameStructValuePreserved = false;

	UPROPERTY()
	bool NameStructInPreserved = false;

	UPROPERTY()
	bool NameStructOutPreserved = false;

	UPROPERTY()
	bool NameStructInoutPreserved = false;

	UPROPERTY()
	bool NameStructReturnPreserved = false;

	UPROPERTY()
	int StringStructValueResult = 0;

	UPROPERTY()
	int StringStructInResult = 0;

	UPROPERTY()
	int StringStructInoutResult = 0;

	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructOutResult;

	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructInoutResultItems;

	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructReturnResult;

	UPROPERTY()
	bool StringStructValuePreserved = false;

	UPROPERTY()
	bool StringStructInPreserved = false;

	UPROPERTY()
	bool StringStructOutPreserved = false;

	UPROPERTY()
	bool StringStructInoutPreserved = false;

	UPROPERTY()
	bool StringStructReturnPreserved = false;

	/**
	 * Build a map key from an id and tag.
	 *
	 * @Covers Delegates.MapKeyValueStructObjectHandlersAndNameStringBeginPlay
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FDelegateKeyValueMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateKeyValueMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Build a map value from a score and label.
	 *
	 * @Covers Delegates.MapKeyValueStructObjectHandlersAndNameStringBeginPlay
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
	 * Build a UObject map value with Value.
	 *
	 * @Covers Delegates.MapKeyValueStructObjectHandlersAndNameStringBeginPlay
	 * @Inputs Value
	 * @Return a new UCoverageStructDelegateMapValueObject
	 * @Param Value the object Value
	 */
	UCoverageStructDelegateMapValueObject MakeObject(int Value)
	{
		UCoverageStructDelegateMapValueObject Object = Cast<UCoverageStructDelegateMapValueObject>(NewObject(this, UCoverageStructDelegateMapValueObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	/**
	 * Count a struct-to-object map by value and record Find key 501 Value 502.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStructObjectValue(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> Items)
	{
		UCoverageStructDelegateMapValueObject Found = nullptr;
		StructObjectValuePreserved =
			Items.Find(MakeKey(501, n"StructObjectValueB"), Found)
			&& Found != nullptr
			&& Found.Value == 502;
		return Items.Num();
	}

	/**
	 * Count a const struct-to-object map as &in and record Find key 511 Value 512.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&in
	 * @Inputs Items
	 * @Return Items.Num() + 70
	 */
	UFUNCTION()
	int HandleStructObjectIn(const TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&in Items)
	{
		UCoverageStructDelegateMapValueObject Found = nullptr;
		StructObjectInPreserved =
			Items.Find(MakeKey(511, n"StructObjectInB"), Found)
			&& Found != nullptr
			&& Found.Value == 512;
		return Items.Num() + 70;
	}

	/**
	 * Fill an &out struct-to-object map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleStructObjectOut(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&out Items)
	{
		Items.Add(MakeKey(520, n"StructObjectOutA"), MakeObject(521));
		Items.Add(MakeKey(521, n"StructObjectOutB"), MakeObject(522));
	}

	/**
	 * Mutate an &inout struct-to-object map, rewriting key 530 to Value 631.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&inout
	 * @Inputs Items
	 * @Return Items.Num() + 80
	 */
	UFUNCTION()
	int HandleStructObjectInout(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&inout Items)
	{
		FDelegateKeyValueMapKey Existing = MakeKey(530, n"StructObjectInoutA");
		UCoverageStructDelegateMapValueObject Found = nullptr;
		if (Items.Find(Existing, Found) && Found != nullptr)
		{
			Items.Add(Existing, MakeObject(Found.Value + 100));
		}
		Items.Add(MakeKey(531, n"StructObjectInoutB"), MakeObject(532));
		StructObjectInoutResultItems = Items;
		UCoverageStructDelegateMapValueObject Mutated = nullptr;
		StructObjectInoutPreserved =
			Items.Find(Existing, Mutated)
			&& Mutated != nullptr
			&& Mutated.Value == 631;
		return Items.Num() + 80;
	}

	/**
	 * Return a struct-to-object map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 540/541
	 */
	UFUNCTION()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> HandleStructObjectReturn()
	{
		TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> Items;
		Items.Add(MakeKey(540, n"StructObjectReturnA"), MakeObject(541));
		Items.Add(MakeKey(541, n"StructObjectReturnB"), MakeObject(542));
		return Items;
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
		NameStructValuePreserved = Items.Find(n"NameValueB", Found) && Found.Score == 102 && Found.Label == "NameValueB";
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
		NameStructInPreserved = Items.Find(n"NameInB", Found) && Found.Score == 112 && Found.Label == "NameInB";
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
		NameStructInoutPreserved = Items.Find(n"NameInoutA", Mutated) && Mutated.Score == 231 && Mutated.Label == "NameInoutMutated";
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
		StringStructValuePreserved = Items.Find("StringValueB", Found) && Found.Score == 202 && Found.Label == "StringValueB";
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
		StringStructInPreserved = Items.Find("StringInB", Found) && Found.Score == 212 && Found.Label == "StringInB";
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
		StringStructInoutPreserved = Items.Find("StringInoutA", Mutated) && Mutated.Score == 331 && Mutated.Label == "StringInoutMutated";
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
	 * WorldStory: BeginPlay binds and executes name-struct and string-struct delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return NameStructValueResult 2, NameOutB Score 122
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		NameStructValueSignal.BindUFunction(this, n"HandleNameStructValue");
		NameStructInSignal.BindUFunction(this, n"HandleNameStructIn");
		NameStructOutSignal.BindUFunction(this, n"HandleNameStructOut");
		NameStructInoutSignal.BindUFunction(this, n"HandleNameStructInout");
		NameStructReturnSignal.BindUFunction(this, n"HandleNameStructReturn");

		TMap<FName, FDelegateKeyValueMapValue> NameStructValueItems;
		NameStructValueItems.Add(n"NameValueA", MakeValue(101, "NameValueA"));
		NameStructValueItems.Add(n"NameValueB", MakeValue(102, "NameValueB"));
		NameStructValueResult = NameStructValueSignal.Execute(NameStructValueItems);

		TMap<FName, FDelegateKeyValueMapValue> NameStructInItems;
		NameStructInItems.Add(n"NameInA", MakeValue(111, "NameInA"));
		NameStructInItems.Add(n"NameInB", MakeValue(112, "NameInB"));
		NameStructInResult = NameStructInSignal.Execute(NameStructInItems);

		NameStructOutSignal.Execute(NameStructOutResult);
		FDelegateKeyValueMapValue NameStructOutFound;
		NameStructOutPreserved =
			NameStructOutResult.Find(n"NameOutB", NameStructOutFound)
			&& NameStructOutFound.Score == 122
			&& NameStructOutFound.Label == "NameOutB";

		NameStructInoutResultItems.Add(n"NameInoutA", MakeValue(131, "NameInoutA"));
		NameStructInoutResult = NameStructInoutSignal.Execute(NameStructInoutResultItems);

		NameStructReturnResult = NameStructReturnSignal.Execute();
		FDelegateKeyValueMapValue NameStructReturnFound;
		NameStructReturnPreserved =
			NameStructReturnResult.Find(n"NameReturnB", NameStructReturnFound)
			&& NameStructReturnFound.Score == 142
			&& NameStructReturnFound.Label == "NameReturnB";

		StringStructValueSignal.BindUFunction(this, n"HandleStringStructValue");
		StringStructInSignal.BindUFunction(this, n"HandleStringStructIn");
		StringStructOutSignal.BindUFunction(this, n"HandleStringStructOut");
		StringStructInoutSignal.BindUFunction(this, n"HandleStringStructInout");
		StringStructReturnSignal.BindUFunction(this, n"HandleStringStructReturn");

		TMap<FString, FDelegateKeyValueMapValue> StringStructValueItems;
		StringStructValueItems.Add("StringValueA", MakeValue(201, "StringValueA"));
		StringStructValueItems.Add("StringValueB", MakeValue(202, "StringValueB"));
		StringStructValueResult = StringStructValueSignal.Execute(StringStructValueItems);

		TMap<FString, FDelegateKeyValueMapValue> StringStructInItems;
		StringStructInItems.Add("StringInA", MakeValue(211, "StringInA"));
		StringStructInItems.Add("StringInB", MakeValue(212, "StringInB"));
		StringStructInResult = StringStructInSignal.Execute(StringStructInItems);

		StringStructOutSignal.Execute(StringStructOutResult);
		FDelegateKeyValueMapValue StringStructOutFound;
		StringStructOutPreserved =
			StringStructOutResult.Find("StringOutB", StringStructOutFound)
			&& StringStructOutFound.Score == 222
			&& StringStructOutFound.Label == "StringOutB";

		StringStructInoutResultItems.Add("StringInoutA", MakeValue(231, "StringInoutA"));
		StringStructInoutResult = StringStructInoutSignal.Execute(StringStructInoutResultItems);

		StringStructReturnResult = StringStructReturnSignal.Execute();
		FDelegateKeyValueMapValue StringStructReturnFound;
		StringStructReturnPreserved =
			StringStructReturnResult.Find("StringReturnB", StringStructReturnFound)
			&& StringStructReturnFound.Score == 242
			&& StringStructReturnFound.Label == "StringReturnB";
	}

	/**
	 * Observe the default NameStructValueResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default NameStructValueResult
	 */
	UFUNCTION()
	int NameStructValueResultDefaultZero()
	{
		return NameStructValueResult;
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
	 * Observe a null value object.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs nullptr
	 * @Return true when the object is null
	 * @Boundary null object
	 */
	UFUNCTION()
	bool ValueObjectNullBoundary()
	{
		UCoverageStructDelegateMapValueObject Object = nullptr;
		return Object == nullptr;
	}
}
