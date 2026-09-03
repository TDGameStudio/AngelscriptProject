/**
 * BeginPlay float-struct and object-struct executes. FloatStructValueResult 2.
 * FloatOutB Score 622. ObjectOutB Key.Value 722. Empty maps Num 0. 0.0f miss.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MapKeyValueFloatObjectStructBeginPlay
 * @Harness UClass
 * @Tag Feature.Delegates.MapKeyValueFloatObjectStructBeginPlay
 * @Provenance Theme: Feature.Delegates. Positive block 11: BeginPlay float-struct and object-struct executes.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 8137-8220.
 * @Provenance Isolation=none: wrap the BeginPlay statements with float/object signals, MakeValue,
 * @Provenance MakeKeyObject, and handlers. Oracle: FloatStructValueResult 2; FloatOutB Score 622;
 * @Provenance ObjectOutB Key.Value 722. Extra: empty maps Num 0; 0.0f miss. DefaultSafe.
 */

UCLASS()
class UCoverageStructDelegateMapKeyObject : UObject
{
	UPROPERTY()
	int Value = 0;
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
 * Float-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FFloatStructMapValueSignal(TMap<float, FDelegateKeyValueMapValue> Items);

/**
 * Float-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FFloatStructMapInSignal(const TMap<float, FDelegateKeyValueMapValue>&in Items);

/**
 * Float-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FFloatStructMapOutSignal(TMap<float, FDelegateKeyValueMapValue>&out Items);

/**
 * Float-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FFloatStructMapInoutSignal(TMap<float, FDelegateKeyValueMapValue>&inout Items);

/**
 * Float-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of values
 */
delegate TMap<float, FDelegateKeyValueMapValue> FFloatStructMapReturnSignal();

/**
 * Object-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FObjectStructMapValueSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items);

/**
 * Object-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FObjectStructMapInSignal(const TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&in Items);

/**
 * Object-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FObjectStructMapOutSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&out Items);

/**
 * Object-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FObjectStructMapInoutSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&inout Items);

/**
 * Object-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of values
 */
delegate TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> FObjectStructMapReturnSignal();

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	FFloatStructMapValueSignal FloatStructValueSignal;

	UPROPERTY()
	FFloatStructMapInSignal FloatStructInSignal;

	UPROPERTY()
	FFloatStructMapOutSignal FloatStructOutSignal;

	UPROPERTY()
	FFloatStructMapInoutSignal FloatStructInoutSignal;

	UPROPERTY()
	FFloatStructMapReturnSignal FloatStructReturnSignal;

	UPROPERTY()
	FObjectStructMapValueSignal ObjectStructValueSignal;

	UPROPERTY()
	FObjectStructMapInSignal ObjectStructInSignal;

	UPROPERTY()
	FObjectStructMapOutSignal ObjectStructOutSignal;

	UPROPERTY()
	FObjectStructMapInoutSignal ObjectStructInoutSignal;

	UPROPERTY()
	FObjectStructMapReturnSignal ObjectStructReturnSignal;

	UPROPERTY()
	int FloatStructValueResult = 0;

	UPROPERTY()
	int FloatStructInResult = 0;

	UPROPERTY()
	int FloatStructInoutResult = 0;

	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructOutResult;

	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructInoutResultItems;

	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructReturnResult;

	UPROPERTY()
	bool FloatStructValuePreserved = false;

	UPROPERTY()
	bool FloatStructInPreserved = false;

	UPROPERTY()
	bool FloatStructOutPreserved = false;

	UPROPERTY()
	bool FloatStructInoutPreserved = false;

	UPROPERTY()
	bool FloatStructReturnPreserved = false;

	UPROPERTY()
	int ObjectStructValueResult = 0;

	UPROPERTY()
	int ObjectStructInResult = 0;

	UPROPERTY()
	int ObjectStructInoutResult = 0;

	UPROPERTY()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructOutResult;

	UPROPERTY()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructInoutResultItems;

	UPROPERTY()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructReturnResult;

	UPROPERTY()
	bool ObjectStructValuePreserved = false;

	UPROPERTY()
	bool ObjectStructInPreserved = false;

	UPROPERTY()
	bool ObjectStructOutPreserved = false;

	UPROPERTY()
	bool ObjectStructInoutPreserved = false;

	UPROPERTY()
	bool ObjectStructReturnPreserved = false;

	/**
	 * Build a map value from a score and label.
	 *
	 * @Covers Delegates.MapKeyValueFloatObjectStructBeginPlay
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
	 * Build a UObject map key with Value.
	 *
	 * @Covers Delegates.MapKeyValueFloatObjectStructBeginPlay
	 * @Inputs Value
	 * @Return a new UCoverageStructDelegateMapKeyObject
	 * @Param Value the object Value
	 */
	UCoverageStructDelegateMapKeyObject MakeKeyObject(int Value)
	{
		UCoverageStructDelegateMapKeyObject Object = Cast<UCoverageStructDelegateMapKeyObject>(NewObject(this, UCoverageStructDelegateMapKeyObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	/**
	 * Count a float-to-struct map by value and record Find 602.5 Score 602.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleFloatStructValue(TMap<float, FDelegateKeyValueMapValue> Items)
	{
		FDelegateKeyValueMapValue Found;
		FloatStructValuePreserved = Items.Find(602.5f, Found) && Found.Score == 602 && Found.Label == "FloatValueB";
		return Items.Num();
	}

	/**
	 * Count a const float-to-struct map as &in and record Find 612.5 Score 612.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<float, FDelegateKeyValueMapValue>&in
	 * @Inputs Items
	 * @Return Items.Num() + 30
	 */
	UFUNCTION()
	int HandleFloatStructIn(const TMap<float, FDelegateKeyValueMapValue>&in Items)
	{
		FDelegateKeyValueMapValue Found;
		FloatStructInPreserved = Items.Find(612.5f, Found) && Found.Score == 612 && Found.Label == "FloatInB";
		return Items.Num() + 30;
	}

	/**
	 * Fill an &out float-to-struct map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<float, FDelegateKeyValueMapValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleFloatStructOut(TMap<float, FDelegateKeyValueMapValue>&out Items)
	{
		Items.Add(621.5f, MakeValue(621, "FloatOutA"));
		Items.Add(622.5f, MakeValue(622, "FloatOutB"));
	}

	/**
	 * Mutate an &inout float-to-struct map, rewriting 631.5 to Score 731.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<float, FDelegateKeyValueMapValue>&inout
	 * @Inputs Items
	 * @Return Items.Num() + Mutated.Score
	 */
	UFUNCTION()
	int HandleFloatStructInout(TMap<float, FDelegateKeyValueMapValue>&inout Items)
	{
		FDelegateKeyValueMapValue Found;
		if (Items.Find(631.5f, Found))
		{
			Found.Score += 100;
			Found.Label = "FloatInoutMutated";
			Items.Add(631.5f, Found);
		}
		Items.Add(632.5f, MakeValue(632, "FloatInoutAdded"));
		FloatStructInoutResultItems = Items;
		FDelegateKeyValueMapValue Mutated;
		FloatStructInoutPreserved = Items.Find(631.5f, Mutated) && Mutated.Score == 731 && Mutated.Label == "FloatInoutMutated";
		return Items.Num() + Mutated.Score;
	}

	/**
	 * Return a float-to-struct map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return 641.5/642.5
	 */
	UFUNCTION()
	TMap<float, FDelegateKeyValueMapValue> HandleFloatStructReturn()
	{
		TMap<float, FDelegateKeyValueMapValue> Items;
		Items.Add(641.5f, MakeValue(641, "FloatReturnA"));
		Items.Add(642.5f, MakeValue(642, "FloatReturnB"));
		return Items;
	}

	/**
	 * Count an object-to-struct map by value and record key Value 702 Score 702.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleObjectStructValue(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items)
	{
		ObjectStructValuePreserved = false;
		for (auto Element : Items)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr && Key.Value == 702 && Value.Score == 702 && Value.Label == "ObjectValueB")
			{
				ObjectStructValuePreserved = true;
			}
		}
		return Items.Num();
	}

	/**
	 * Count a const object-to-struct map as &in and record key Value 712 Score 712.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&in
	 * @Inputs Items
	 * @Return Items.Num() + 90
	 */
	UFUNCTION()
	int HandleObjectStructIn(const TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&in Items)
	{
		ObjectStructInPreserved = false;
		for (auto Element : Items)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr && Key.Value == 712 && Value.Score == 712 && Value.Label == "ObjectInB")
			{
				ObjectStructInPreserved = true;
			}
		}
		return Items.Num() + 90;
	}

	/**
	 * Fill an &out object-to-struct map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleObjectStructOut(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&out Items)
	{
		Items.Add(MakeKeyObject(721), MakeValue(721, "ObjectOutA"));
		Items.Add(MakeKeyObject(722), MakeValue(722, "ObjectOutB"));
	}

	/**
	 * Mutate an &inout object-to-struct map, rewriting key 731 to Score 831.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&inout
	 * @Inputs Items
	 * @Return Items.Num() + 100
	 */
	UFUNCTION()
	int HandleObjectStructInout(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&inout Items)
	{
		for (auto Element : Items)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr && Key.Value == 731)
			{
				Value.Score += 100;
				Value.Label = "ObjectInoutMutated";
				Element.SetValue(Value);
			}
		}
		Items.Add(MakeKeyObject(732), MakeValue(732, "ObjectInoutAdded"));
		ObjectStructInoutResultItems = Items;
		ObjectStructInoutPreserved = false;
		for (auto Element : ObjectStructInoutResultItems)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr && Key.Value == 731 && Value.Score == 831 && Value.Label == "ObjectInoutMutated")
			{
				ObjectStructInoutPreserved = true;
			}
		}
		return Items.Num() + 100;
	}

	/**
	 * Return an object-to-struct map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 741/742
	 */
	UFUNCTION()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> HandleObjectStructReturn()
	{
		TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items;
		Items.Add(MakeKeyObject(741), MakeValue(741, "ObjectReturnA"));
		Items.Add(MakeKeyObject(742), MakeValue(742, "ObjectReturnB"));
		return Items;
	}

	/**
	 * WorldStory: BeginPlay binds and executes float-struct and object-struct delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return FloatStructValueResult 2, FloatOutB Score 622, ObjectOutB Key.Value 722
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FloatStructValueSignal.BindUFunction(this, n"HandleFloatStructValue");
		FloatStructInSignal.BindUFunction(this, n"HandleFloatStructIn");
		FloatStructOutSignal.BindUFunction(this, n"HandleFloatStructOut");
		FloatStructInoutSignal.BindUFunction(this, n"HandleFloatStructInout");
		FloatStructReturnSignal.BindUFunction(this, n"HandleFloatStructReturn");

		TMap<float, FDelegateKeyValueMapValue> FloatStructValueItems;
		FloatStructValueItems.Add(601.5f, MakeValue(601, "FloatValueA"));
		FloatStructValueItems.Add(602.5f, MakeValue(602, "FloatValueB"));
		FloatStructValueResult = FloatStructValueSignal.Execute(FloatStructValueItems);

		TMap<float, FDelegateKeyValueMapValue> FloatStructInItems;
		FloatStructInItems.Add(611.5f, MakeValue(611, "FloatInA"));
		FloatStructInItems.Add(612.5f, MakeValue(612, "FloatInB"));
		FloatStructInResult = FloatStructInSignal.Execute(FloatStructInItems);

		FloatStructOutSignal.Execute(FloatStructOutResult);
		FDelegateKeyValueMapValue FloatStructOutFound;
		FloatStructOutPreserved =
			FloatStructOutResult.Find(622.5f, FloatStructOutFound)
			&& FloatStructOutFound.Score == 622
			&& FloatStructOutFound.Label == "FloatOutB";

		FloatStructInoutResultItems.Add(631.5f, MakeValue(631, "FloatInoutA"));
		FloatStructInoutResult = FloatStructInoutSignal.Execute(FloatStructInoutResultItems);

		FloatStructReturnResult = FloatStructReturnSignal.Execute();
		FDelegateKeyValueMapValue FloatStructReturnFound;
		FloatStructReturnPreserved =
			FloatStructReturnResult.Find(642.5f, FloatStructReturnFound)
			&& FloatStructReturnFound.Score == 642
			&& FloatStructReturnFound.Label == "FloatReturnB";

		ObjectStructValueSignal.BindUFunction(this, n"HandleObjectStructValue");
		ObjectStructInSignal.BindUFunction(this, n"HandleObjectStructIn");
		ObjectStructOutSignal.BindUFunction(this, n"HandleObjectStructOut");
		ObjectStructInoutSignal.BindUFunction(this, n"HandleObjectStructInout");
		ObjectStructReturnSignal.BindUFunction(this, n"HandleObjectStructReturn");

		TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructValueItems;
		ObjectStructValueItems.Add(MakeKeyObject(701), MakeValue(701, "ObjectValueA"));
		ObjectStructValueItems.Add(MakeKeyObject(702), MakeValue(702, "ObjectValueB"));
		ObjectStructValueResult = ObjectStructValueSignal.Execute(ObjectStructValueItems);

		TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructInItems;
		ObjectStructInItems.Add(MakeKeyObject(711), MakeValue(711, "ObjectInA"));
		ObjectStructInItems.Add(MakeKeyObject(712), MakeValue(712, "ObjectInB"));
		ObjectStructInResult = ObjectStructInSignal.Execute(ObjectStructInItems);

		ObjectStructOutSignal.Execute(ObjectStructOutResult);
		ObjectStructOutPreserved = false;
		for (auto Element : ObjectStructOutResult)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr
				&& Key.Value == 722
				&& Value.Score == 722
				&& Value.Label == "ObjectOutB")
			{
				ObjectStructOutPreserved = true;
			}
		}

		ObjectStructInoutResultItems.Add(MakeKeyObject(731), MakeValue(731, "ObjectInoutA"));
		ObjectStructInoutResult = ObjectStructInoutSignal.Execute(ObjectStructInoutResultItems);

		ObjectStructReturnResult = ObjectStructReturnSignal.Execute();
		ObjectStructReturnPreserved = false;
		for (auto Element : ObjectStructReturnResult)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr
				&& Key.Value == 742
				&& Value.Score == 742
				&& Value.Label == "ObjectReturnB")
			{
				ObjectStructReturnPreserved = true;
			}
		}
	}

	/**
	 * Observe the default FloatStructValueResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default FloatStructValueResult
	 */
	UFUNCTION()
	int FloatStructValueResultDefaultZero()
	{
		return FloatStructValueResult;
	}

	/**
	 * Observe empty float-to-struct map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyFloatMapDefaultNum()
	{
		TMap<float, FDelegateKeyValueMapValue> Items;
		return Items.Num();
	}

	/**
	 * Observe a null object key.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs nullptr
	 * @Return true when the key is null
	 * @Boundary null key
	 */
	UFUNCTION()
	bool KeyObjectNullBoundary()
	{
		UCoverageStructDelegateMapKeyObject Key = nullptr;
		return Key == nullptr;
	}
}
