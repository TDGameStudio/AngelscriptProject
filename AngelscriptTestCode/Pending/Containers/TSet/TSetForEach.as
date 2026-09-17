/**
 * @version v1
 * @summary foreach walks elements; membership, not iteration order. foreach is the RoundTrip surface; Iterator stays Observe (int). int is canonical; other shapes repeat the four entries. Do not mutate an element in place (that.
 * @topic Containers
 */
/**
 * @version root
 * @summary foreach walks elements; membership, not iteration order. foreach is the RoundTrip surface; Iterator stays Observe (int). int is canonical; other shapes repeat the four entries. Do not mutate an element in place (that.
 * @topic Baseline
 */
UCLASS()
class UTSetForEachObject : UObject
{
}

namespace TSetTest
{
	/**
	 * Observe foreach: every visited element is Contains-true and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.foreach
	 * @Inputs TSet<int> with members; for (T Item : Values)
	 * @Return true when count equals Num
	 */
	UFUNCTION()
	bool ForEachElementsMatchSet()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		int Count = 0;
		for (int Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * In-only: foreach a const&in TSet<int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs canonical members
	 * @Return true when foreach visits Num matching members
	 */
	UFUNCTION()
	bool ReadForEach(const TSet<int>&in Values)
	{
		int Count = 0;
		for (int Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: copy members through foreach into an empty &out TSet<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result.Num() matches
	 */
	UFUNCTION()
	void FillSetByForEach(TSet<int>&out Result)
	{
		TSet<int> Source;
		Source.Add(10);
		Source.Add(20);
		Source.Add(30);
		for (int Item : Source)
		{
			Result.Add(Item);
		}
	}

	/**
	 * Inout: Add one more member; do not mutate existing elements in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendByForEach(TSet<int>&inout Values)
	{
		Values.Add(30);
	}


	/**
	 * Observe foreach_FString: every visited element is Contains-true and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.foreach
	 * @Inputs TSet<FString> with members; for (T Item : Values)
	 * @Return true when count equals Num
	 */
	UFUNCTION()
	bool ForEachElementsMatchSet_FString()
	{
		TSet<FString> Values;
		Values.Add("alpha");
		Values.Add("beta");
		Values.Add("gamma");
		int Count = 0;
		for (FString Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * In-only: foreach a const&in TSet<FString> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Source set received as const TSet<FString>&in
	 * @Inputs canonical members
	 * @Return true when foreach visits Num matching members
	 */
	UFUNCTION()
	bool ReadForEach_FString(const TSet<FString>&in Values)
	{
		int Count = 0;
		for (FString Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: copy members through foreach into an empty &out TSet<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Result Destination received as TSet<FString>&out
	 * @Inputs Empty &out TSet<FString>
	 * @Return void; Result.Num() matches
	 */
	UFUNCTION()
	void FillSetByForEach_FString(TSet<FString>&out Result)
	{
		TSet<FString> Source;
		Source.Add("alpha");
		Source.Add("beta");
		Source.Add("gamma");
		for (FString Item : Source)
		{
			Result.Add(Item);
		}
	}

	/**
	 * Inout: Add one more member; do not mutate existing elements in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Set received as TSet<FString>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendByForEach_FString(TSet<FString>&inout Values)
	{
		Values.Add("gamma");
	}


	/**
	 * Observe foreach_FName: every visited element is Contains-true and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.foreach
	 * @Inputs TSet<FName> with members; for (T Item : Values)
	 * @Return true when count equals Num
	 */
	UFUNCTION()
	bool ForEachElementsMatchSet_FName()
	{
		TSet<FName> Values;
		Values.Add(n"Red");
		Values.Add(n"Green");
		Values.Add(n"Blue");
		int Count = 0;
		for (FName Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * In-only: foreach a const&in TSet<FName> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Source set received as const TSet<FName>&in
	 * @Inputs canonical members
	 * @Return true when foreach visits Num matching members
	 */
	UFUNCTION()
	bool ReadForEach_FName(const TSet<FName>&in Values)
	{
		int Count = 0;
		for (FName Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: copy members through foreach into an empty &out TSet<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Result Destination received as TSet<FName>&out
	 * @Inputs Empty &out TSet<FName>
	 * @Return void; Result.Num() matches
	 */
	UFUNCTION()
	void FillSetByForEach_FName(TSet<FName>&out Result)
	{
		TSet<FName> Source;
		Source.Add(n"Red");
		Source.Add(n"Green");
		Source.Add(n"Blue");
		for (FName Item : Source)
		{
			Result.Add(Item);
		}
	}

	/**
	 * Inout: Add one more member; do not mutate existing elements in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Set received as TSet<FName>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendByForEach_FName(TSet<FName>&inout Values)
	{
		Values.Add(n"Blue");
	}


	/**
	 * Observe foreach_bool: every visited element is Contains-true and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.foreach
	 * @Inputs TSet<bool> with members; for (T Item : Values)
	 * @Return true when count equals Num
	 */
	UFUNCTION()
	bool ForEachElementsMatchSet_bool()
	{
		TSet<bool> Values;
		Values.Add(true);
		Values.Add(false);
		int Count = 0;
		for (bool Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 2;
	}

	/**
	 * In-only: foreach a const&in TSet<bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Source set received as const TSet<bool>&in
	 * @Inputs canonical members
	 * @Return true when foreach visits Num matching members
	 */
	UFUNCTION()
	bool ReadForEach_bool(const TSet<bool>&in Values)
	{
		int Count = 0;
		for (bool Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 2;
	}

	/**
	 * Out-only: copy members through foreach into an empty &out TSet<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Result Destination received as TSet<bool>&out
	 * @Inputs Empty &out TSet<bool>
	 * @Return void; Result.Num() matches
	 */
	UFUNCTION()
	void FillSetByForEach_bool(TSet<bool>&out Result)
	{
		TSet<bool> Source;
		Source.Add(true);
		Source.Add(false);
		for (bool Item : Source)
		{
			Result.Add(Item);
		}
	}

	/**
	 * Inout: Add one more member; do not mutate existing elements in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Set received as TSet<bool>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendByForEach_bool(TSet<bool>&inout Values)
	{
		Values.Add(false);
	}


	/**
	 * Observe foreach_FVector: every visited element is Contains-true and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.foreach
	 * @Inputs TSet<FVector> with members; for (T Item : Values)
	 * @Return true when count equals Num
	 */
	UFUNCTION()
	bool ForEachElementsMatchSet_FVector()
	{
		TSet<FVector> Values;
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
		int Count = 0;
		for (FVector Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * In-only: foreach a const&in TSet<FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Source set received as const TSet<FVector>&in
	 * @Inputs canonical members
	 * @Return true when foreach visits Num matching members
	 */
	UFUNCTION()
	bool ReadForEach_FVector(const TSet<FVector>&in Values)
	{
		int Count = 0;
		for (FVector Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: copy members through foreach into an empty &out TSet<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Result Destination received as TSet<FVector>&out
	 * @Inputs Empty &out TSet<FVector>
	 * @Return void; Result.Num() matches
	 */
	UFUNCTION()
	void FillSetByForEach_FVector(TSet<FVector>&out Result)
	{
		TSet<FVector> Source;
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Source.Add(FVector(0.0f, 1.0f, 0.0f));
		Source.Add(FVector(0.0f, 0.0f, 1.0f));
		for (FVector Item : Source)
		{
			Result.Add(Item);
		}
	}

	/**
	 * Inout: Add one more member; do not mutate existing elements in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Set received as TSet<FVector>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendByForEach_FVector(TSet<FVector>&inout Values)
	{
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Observe foreach_UObject: every visited element is Contains-true and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.foreach
	 * @Inputs TSet<UObject> with members; for (T Item : Values)
	 * @Return true when count equals Num
	 */
	UFUNCTION()
	bool ForEachElementsMatchSet_UObject()
	{
		TSet<UObject> Values;
		UObject First = NewObject(GetTransientPackage(), UTSetForEachObject::StaticClass(), n"TSetForEach_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTSetForEachObject::StaticClass(), n"TSetForEach_Second", true);
		Values.Add(First);
		Values.Add(Second);
		int Count = 0;
		for (UObject Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 2;
	}

	/**
	 * In-only: foreach a const&in TSet<UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Source set received as const TSet<UObject>&in
	 * @Inputs canonical members
	 * @Return true when foreach visits Num matching members
	 */
	UFUNCTION()
	bool ReadForEach_UObject(const TSet<UObject>&in Values)
	{
		int Count = 0;
		for (UObject Item : Values)
		{
			if (!Values.Contains(Item) || Item == nullptr)
			{
				return false;
			}
			Count++;
		}
		return Count == 3 && Values.Num() == 3;
	}

	/**
	 * Out-only: copy members through foreach into an empty &out TSet<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Result Destination received as TSet<UObject>&out
	 * @Inputs Empty &out TSet<UObject>
	 * @Return void; Result.Num() matches
	 */
	UFUNCTION()
	void FillSetByForEach_UObject(TSet<UObject>&out Result)
	{
		TSet<UObject> Source;
		Source.Add(NewObject(GetTransientPackage(), UTSetForEachObject::StaticClass(), n"TSetForEach_Fill_0", true));
		Source.Add(NewObject(GetTransientPackage(), UTSetForEachObject::StaticClass(), n"TSetForEach_Fill_1", true));
		Source.Add(NewObject(GetTransientPackage(), UTSetForEachObject::StaticClass(), n"TSetForEach_Fill_2", true));
		for (UObject Item : Source)
		{
			Result.Add(Item);
		}
	}

	/**
	 * Inout: Add one more member; do not mutate existing elements in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Set received as TSet<UObject>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendByForEach_UObject(TSet<UObject>&inout Values)
	{
		Values.Add(NewObject(GetTransientPackage(), UTSetForEachObject::StaticClass(), n"TSetForEach_Extra", true));
	}


	/**
	 * Observe Iterator: Proceed walks every member; Contains matches.
	 *
	 * @Kind Observe
	 * @Covers TSet.Iterator
	 * @Inputs [10, 20, 30]; Iterator until !CanProceed
	 * @Return true when count is 3 and sum is 60
	 */
	UFUNCTION()
	bool IteratorProceedsOverEveryMember()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		int Count = 0;
		int Sum = 0;
		TSetIterator<int> It = Values.Iterator();
		while (It.CanProceed)
		{
			Sum += It.Proceed();
			Count++;
		}
		return Count == 3 && Sum == 60;
	}

}
/** @end */
