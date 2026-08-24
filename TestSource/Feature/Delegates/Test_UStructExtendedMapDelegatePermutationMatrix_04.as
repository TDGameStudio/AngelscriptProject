// Theme: Feature.Delegates. WorldStory block 4: BeginPlay executes bool/float map delegates.
// C++: AngelscriptCoverageUStructTests.cpp::UStructExtendedMapDelegatePermutationMatrix lines 6885-6986.
// Isolation=none: wrap BeginPlay with key/value types, signals, MakeKey/MakeValue, handlers.
// Oracle: BoolStructValueResult 2, BoolStructOutPreserved Score 122, StructFloatReturn 342.5f.
// Extra: empty maps Num 0; false-key miss. FixtureIsolated. Keep BeginPlay.

USTRUCT(BlueprintType)
struct FDelegateExtendedMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FDelegateExtendedMapKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

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

delegate int FBoolStructMapValueSignal(TMap<bool, FDelegateExtendedMapValue> Items);
delegate int FBoolStructMapInSignal(const TMap<bool, FDelegateExtendedMapValue>&in Items);
delegate void FBoolStructMapOutSignal(TMap<bool, FDelegateExtendedMapValue>&out Items);
delegate int FBoolStructMapInoutSignal(TMap<bool, FDelegateExtendedMapValue>&inout Items);
delegate TMap<bool, FDelegateExtendedMapValue> FBoolStructMapReturnSignal();
delegate int FStructBoolMapValueSignal(TMap<FDelegateExtendedMapKey, bool> Items);
delegate int FStructBoolMapInSignal(const TMap<FDelegateExtendedMapKey, bool>&in Items);
delegate void FStructBoolMapOutSignal(TMap<FDelegateExtendedMapKey, bool>&out Items);
delegate int FStructBoolMapInoutSignal(TMap<FDelegateExtendedMapKey, bool>&inout Items);
delegate TMap<FDelegateExtendedMapKey, bool> FStructBoolMapReturnSignal();
delegate int FStructFloatMapValueSignal(TMap<FDelegateExtendedMapKey, float> Items);
delegate int FStructFloatMapInSignal(const TMap<FDelegateExtendedMapKey, float>&in Items);
delegate void FStructFloatMapOutSignal(TMap<FDelegateExtendedMapKey, float>&out Items);
delegate int FStructFloatMapInoutSignal(TMap<FDelegateExtendedMapKey, float>&inout Items);
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

	FDelegateExtendedMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateExtendedMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FDelegateExtendedMapValue MakeValue(int Score, FString Label)
	{
		FDelegateExtendedMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UFUNCTION()
	int HandleBoolStructValue(TMap<bool, FDelegateExtendedMapValue> Items)
	{
		FDelegateExtendedMapValue Found;
		BoolStructValuePreserved = Items.Find(false, Found) && Found.Score == 102 && Found.Label == "BoolValueFalse";
		return Items.Num();
	}

	UFUNCTION()
	int HandleBoolStructIn(const TMap<bool, FDelegateExtendedMapValue>&in Items)
	{
		FDelegateExtendedMapValue Found;
		BoolStructInPreserved = Items.Find(true, Found) && Found.Score == 111 && Found.Label == "BoolInTrue";
		return Items.Num() + 10;
	}

	UFUNCTION()
	void HandleBoolStructOut(TMap<bool, FDelegateExtendedMapValue>&out Items)
	{
		Items.Add(true, MakeValue(121, "BoolOutTrue"));
		Items.Add(false, MakeValue(122, "BoolOutFalse"));
	}

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

	UFUNCTION()
	TMap<bool, FDelegateExtendedMapValue> HandleBoolStructReturn()
	{
		TMap<bool, FDelegateExtendedMapValue> Items;
		Items.Add(true, MakeValue(141, "BoolReturnTrue"));
		Items.Add(false, MakeValue(142, "BoolReturnFalse"));
		return Items;
	}

	UFUNCTION()
	int HandleStructBoolValue(TMap<FDelegateExtendedMapKey, bool> Items)
	{
		bool Found = true;
		StructBoolValuePreserved = Items.Find(MakeKey(201, n"StructBoolValueB"), Found) && !Found;
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructBoolIn(const TMap<FDelegateExtendedMapKey, bool>&in Items)
	{
		bool Found = false;
		StructBoolInPreserved = Items.Find(MakeKey(211, n"StructBoolInB"), Found) && Found;
		return Items.Num() + 20;
	}

	UFUNCTION()
	void HandleStructBoolOut(TMap<FDelegateExtendedMapKey, bool>&out Items)
	{
		Items.Add(MakeKey(220, n"StructBoolOutA"), true);
		Items.Add(MakeKey(221, n"StructBoolOutB"), false);
	}

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

	UFUNCTION()
	TMap<FDelegateExtendedMapKey, bool> HandleStructBoolReturn()
	{
		TMap<FDelegateExtendedMapKey, bool> Items;
		Items.Add(MakeKey(240, n"StructBoolReturnA"), true);
		Items.Add(MakeKey(241, n"StructBoolReturnB"), false);
		return Items;
	}

	UFUNCTION()
	int HandleStructFloatValue(TMap<FDelegateExtendedMapKey, float> Items)
	{
		float Found = 0.0f;
		StructFloatValuePreserved = Items.Find(MakeKey(301, n"StructFloatValueB"), Found) && Found == 302.5f;
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructFloatIn(const TMap<FDelegateExtendedMapKey, float>&in Items)
	{
		float Found = 0.0f;
		StructFloatInPreserved = Items.Find(MakeKey(311, n"StructFloatInB"), Found) && Found == 312.5f;
		return Items.Num() + 30;
	}

	UFUNCTION()
	void HandleStructFloatOut(TMap<FDelegateExtendedMapKey, float>&out Items)
	{
		Items.Add(MakeKey(320, n"StructFloatOutA"), 321.5f);
		Items.Add(MakeKey(321, n"StructFloatOutB"), 322.5f);
	}

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

	UFUNCTION()
	TMap<FDelegateExtendedMapKey, float> HandleStructFloatReturn()
	{
		TMap<FDelegateExtendedMapKey, float> Items;
		Items.Add(MakeKey(340, n"StructFloatReturnA"), 341.5f);
		Items.Add(MakeKey(341, n"StructFloatReturnB"), 342.5f);
		return Items;
	}

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
}

int Observe_BoolStructValueResult_DefaultZero(ACoverageStructExtendedMapDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructExtendedMapDelegatePermutationMatrix_04 setup: required Actor is null");
	}
	return Actor.BoolStructValueResult;
}

int Observe_EmptyBoolMap_DefaultNum()
{
	TMap<bool, FDelegateExtendedMapValue> Items;
	return Items.Num();
}

bool Observe_Value_CopyIndependence()
{
	FDelegateExtendedMapValue Original;
	Original.Score = 102;
	Original.Label = "BoolValueFalse";
	FDelegateExtendedMapValue Copy = Original;
	Copy.Score = 0;
	return Original.Score == 102 && Copy.Score == 0;
}
