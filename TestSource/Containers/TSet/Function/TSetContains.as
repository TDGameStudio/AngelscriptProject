/**
 * Contains is true for present elements and false for absent ones.
 * Empty Contains is also a first step here; EmptyConstruction owns the empty
 * type matrix. int is canonical; other shapes repeat the four entries.
 *
 * @Theme Containers.TSet
 * @Subject TSet.Contains
 * @Harness Function
 * @Tag Containers.TSet.TSetContains
 * @Namespace TSetTest
 */

UCLASS()
class UTSetContainsObject : UObject
{
}

namespace TSetTest
{
	/**
	 * Empty set contains nothing; after Add, present match and others do not.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<int>; Contains miss; Add present
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent()
	{
		TSet<int> Values;
		if (Values.Contains(10))
		{
			return false;
		}
		Values.Add(10);
		if (!Values.Contains(10) || Values.Contains(99))
		{
			return false;
		}
		Values.Add(20);
		Values.Add(30);
		return Values.Contains(10) && Values.Contains(20) && Values.Contains(30) && !Values.Contains(99);
	}

	/**
	 * In-only: Contains on a const&in TSet<int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs canonical members
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ReadContains(const TSet<int>&in Values)
	{
		return Values.Contains(10) && Values.Contains(20) && Values.Contains(30) && !Values.Contains(99);
	}

	/**
	 * Out-only: fill an empty &out TSet<int> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetForContains(TSet<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
	}

	/**
	 * Inout: Add the last member so Contains becomes true.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendForContains(TSet<int>&inout Values)
	{
		Values.Add(30);
	}


	/**
	 * Empty set contains nothing; after Add, present match and others do not_FString.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<FString>; Contains miss; Add present
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent_FString()
	{
		TSet<FString> Values;
		if (Values.Contains("alpha"))
		{
			return false;
		}
		Values.Add("alpha");
		if (!Values.Contains("alpha") || Values.Contains("missing"))
		{
			return false;
		}
		Values.Add("beta");
		Values.Add("gamma");
		return Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma") && !Values.Contains("missing");
	}

	/**
	 * In-only: Contains on a const&in TSet<FString> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<FString>&in
	 * @Inputs canonical members
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ReadContains_FString(const TSet<FString>&in Values)
	{
		return Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma") && !Values.Contains("missing");
	}

	/**
	 * Out-only: fill an empty &out TSet<FString> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Result Destination received as TSet<FString>&out
	 * @Inputs Empty &out TSet<FString>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetForContains_FString(TSet<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
	}

	/**
	 * Inout: Add the last member so Contains becomes true_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Set received as TSet<FString>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendForContains_FString(TSet<FString>&inout Values)
	{
		Values.Add("gamma");
	}


	/**
	 * Empty set contains nothing; after Add, present match and others do not_FName.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<FName>; Contains miss; Add present
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent_FName()
	{
		TSet<FName> Values;
		if (Values.Contains(n"Red"))
		{
			return false;
		}
		Values.Add(n"Red");
		if (!Values.Contains(n"Red") || Values.Contains(n"Missing"))
		{
			return false;
		}
		Values.Add(n"Green");
		Values.Add(n"Blue");
		return Values.Contains(n"Red") && Values.Contains(n"Green") && Values.Contains(n"Blue") && !Values.Contains(n"Missing");
	}

	/**
	 * In-only: Contains on a const&in TSet<FName> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<FName>&in
	 * @Inputs canonical members
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ReadContains_FName(const TSet<FName>&in Values)
	{
		return Values.Contains(n"Red") && Values.Contains(n"Green") && Values.Contains(n"Blue") && !Values.Contains(n"Missing");
	}

	/**
	 * Out-only: fill an empty &out TSet<FName> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Result Destination received as TSet<FName>&out
	 * @Inputs Empty &out TSet<FName>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetForContains_FName(TSet<FName>&out Result)
	{
		Result.Add(n"Red");
		Result.Add(n"Green");
		Result.Add(n"Blue");
	}

	/**
	 * Inout: Add the last member so Contains becomes true_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Set received as TSet<FName>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendForContains_FName(TSet<FName>&inout Values)
	{
		Values.Add(n"Blue");
	}


	/**
	 * Empty set contains nothing; after Add, present match and others do not_bool.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<bool>; Contains miss; Add present
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent_bool()
	{
		TSet<bool> Values;
		if (Values.Contains(true))
		{
			return false;
		}
		Values.Add(true);
		if (!Values.Contains(true) || Values.Contains(false))
		{
			return false;
		}
		Values.Add(false);
		return Values.Contains(true) && Values.Contains(false);
	}

	/**
	 * In-only: Contains on a const&in TSet<bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<bool>&in
	 * @Inputs canonical members
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ReadContains_bool(const TSet<bool>&in Values)
	{
		return Values.Contains(true) && Values.Contains(false);
	}

	/**
	 * Out-only: fill an empty &out TSet<bool> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Result Destination received as TSet<bool>&out
	 * @Inputs Empty &out TSet<bool>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetForContains_bool(TSet<bool>&out Result)
	{
		Result.Add(true);
		Result.Add(false);
	}

	/**
	 * Inout: Add the last member so Contains becomes true_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Set received as TSet<bool>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendForContains_bool(TSet<bool>&inout Values)
	{
		Values.Add(false);
	}


	/**
	 * Empty set contains nothing; after Add, present match and others do not_FVector.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<FVector>; Contains miss; Add present
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent_FVector()
	{
		TSet<FVector> Values;
		if (Values.Contains(FVector(1.0f, 0.0f, 0.0f)))
		{
			return false;
		}
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		if (!Values.Contains(FVector(1.0f, 0.0f, 0.0f)) || Values.Contains(FVector(9.0f, 9.0f, 9.0f)))
		{
			return false;
		}
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
		return Values.Contains(FVector(1.0f, 0.0f, 0.0f)) && Values.Contains(FVector(0.0f, 1.0f, 0.0f)) && Values.Contains(FVector(0.0f, 0.0f, 1.0f)) && !Values.Contains(FVector(9.0f, 9.0f, 9.0f));
	}

	/**
	 * In-only: Contains on a const&in TSet<FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<FVector>&in
	 * @Inputs canonical members
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ReadContains_FVector(const TSet<FVector>&in Values)
	{
		return Values.Contains(FVector(1.0f, 0.0f, 0.0f)) && Values.Contains(FVector(0.0f, 1.0f, 0.0f)) && Values.Contains(FVector(0.0f, 0.0f, 1.0f)) && !Values.Contains(FVector(9.0f, 9.0f, 9.0f));
	}

	/**
	 * Out-only: fill an empty &out TSet<FVector> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Result Destination received as TSet<FVector>&out
	 * @Inputs Empty &out TSet<FVector>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetForContains_FVector(TSet<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: Add the last member so Contains becomes true_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Set received as TSet<FVector>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendForContains_FVector(TSet<FVector>&inout Values)
	{
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Empty set contains nothing; after Add, present match and others do not_UObject.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<UObject>; Contains miss; Add present
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent_UObject()
	{
		TSet<UObject> Values;
		UObject First = NewObject(GetTransientPackage(), UTSetContainsObject::StaticClass(), n"TSetContains_First", true);
		if (Values.Contains(First) || First == nullptr)
		{
			return false;
		}
		Values.Add(First);
		return Values.Contains(First) && !Values.Contains(nullptr);
	}

	/**
	 * In-only: Contains on a const&in TSet<UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<UObject>&in
	 * @Inputs canonical members
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ReadContains_UObject(const TSet<UObject>&in Values)
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
		return Count == Values.Num() && Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TSet<UObject> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Result Destination received as TSet<UObject>&out
	 * @Inputs Empty &out TSet<UObject>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetForContains_UObject(TSet<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTSetContainsObject::StaticClass(), n"UTSetContainsObject_Fill_0", true));
		Result.Add(NewObject(GetTransientPackage(), UTSetContainsObject::StaticClass(), n"UTSetContainsObject_Fill_1", true));
		Result.Add(NewObject(GetTransientPackage(), UTSetContainsObject::StaticClass(), n"UTSetContainsObject_Fill_2", true));
	}

	/**
	 * Inout: Add the last member so Contains becomes true_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Set received as TSet<UObject>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendForContains_UObject(TSet<UObject>&inout Values)
	{
		Values.Add(NewObject(GetTransientPackage(), UTSetContainsObject::StaticClass(), n"UTSetContainsObject_Append", true));
	}


}
