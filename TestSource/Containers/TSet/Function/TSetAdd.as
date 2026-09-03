/**
 * TSet.Add inserts a value when no equal element is present. Duplicate Add
 * keeps Num. Presence is observed through Contains, then through UFUNCTION
 * in, out, and inout. int is canonical; other shapes repeat the four entries
 * with a type suffix. float elements are omitted (hash/equality footgun).
 *
 * @Theme Containers.TSet
 * @Subject TSet.Add
 * @Harness Function
 * @Tag Containers.TSet.TSetAdd
 * @Namespace TSetTest
 */

UCLASS()
class UTSetAddObject : UObject
{
}

namespace TSetTest
{
	/**
	 * Observe Add: new values grow Num; duplicate Add keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs Default-constructed TSet<int>; Add two distinct; Add first again
	 * @Return true when Num grows for a new value and duplicate keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndDuplicateKeepsNum()
	{
		TSet<int> Values;
		Values.Add(10);
		if (Values.Num() != 1 || !Values.Contains(10))
		{
			return false;
		}
		Values.Add(20);
		if (Values.Num() != 2 || !Values.Contains(20))
		{
			return false;
		}
		Values.Add(10);
		return Values.Num() == 2 && Values.Contains(10) && Values.Contains(20);
	}

	/**
	 * In-only: read Add membership from a const&in TSet<int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num and Contains match
	 */
	UFUNCTION()
	bool ReadAddedMembers(const TSet<int>&in Values)
	{
		return Values.Num() == 3 && Values.Contains(10) && Values.Contains(20) && Values.Contains(30);
	}

	/**
	 * Out-only: fill an empty &out TSet<int> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAdd(TSet<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
	}

	/**
	 * Inout: Add the last canonical member onto an existing TSet<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs Values already has the prefix members
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendWithAdd(TSet<int>&inout Values)
	{
		Values.Add(30);
	}


	/**
	 * Observe Add_FString: new values grow Num; duplicate Add keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs Default-constructed TSet<FString>; Add two distinct; Add first again
	 * @Return true when Num grows for a new value and duplicate keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndDuplicateKeepsNum_FString()
	{
		TSet<FString> Values;
		Values.Add("alpha");
		if (Values.Num() != 1 || !Values.Contains("alpha"))
		{
			return false;
		}
		Values.Add("beta");
		if (Values.Num() != 2 || !Values.Contains("beta"))
		{
			return false;
		}
		Values.Add("alpha");
		return Values.Num() == 2 && Values.Contains("alpha") && Values.Contains("beta");
	}

	/**
	 * In-only: read Add membership from a const&in TSet<FString> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Source set received as const TSet<FString>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num and Contains match
	 */
	UFUNCTION()
	bool ReadAddedMembers_FString(const TSet<FString>&in Values)
	{
		return Values.Num() == 3 && Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma");
	}

	/**
	 * Out-only: fill an empty &out TSet<FString> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<FString>&out
	 * @Inputs Empty &out TSet<FString>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAdd_FString(TSet<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
	}

	/**
	 * Inout: Add the last canonical member onto an existing TSet<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Set received as TSet<FString>&inout
	 * @Inputs Values already has the prefix members
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendWithAdd_FString(TSet<FString>&inout Values)
	{
		Values.Add("gamma");
	}


	/**
	 * Observe Add_FName: new values grow Num; duplicate Add keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs Default-constructed TSet<FName>; Add two distinct; Add first again
	 * @Return true when Num grows for a new value and duplicate keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndDuplicateKeepsNum_FName()
	{
		TSet<FName> Values;
		Values.Add(n"Red");
		if (Values.Num() != 1 || !Values.Contains(n"Red"))
		{
			return false;
		}
		Values.Add(n"Green");
		if (Values.Num() != 2 || !Values.Contains(n"Green"))
		{
			return false;
		}
		Values.Add(n"Red");
		return Values.Num() == 2 && Values.Contains(n"Red") && Values.Contains(n"Green");
	}

	/**
	 * In-only: read Add membership from a const&in TSet<FName> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Source set received as const TSet<FName>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num and Contains match
	 */
	UFUNCTION()
	bool ReadAddedMembers_FName(const TSet<FName>&in Values)
	{
		return Values.Num() == 3 && Values.Contains(n"Red") && Values.Contains(n"Green") && Values.Contains(n"Blue");
	}

	/**
	 * Out-only: fill an empty &out TSet<FName> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<FName>&out
	 * @Inputs Empty &out TSet<FName>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAdd_FName(TSet<FName>&out Result)
	{
		Result.Add(n"Red");
		Result.Add(n"Green");
		Result.Add(n"Blue");
	}

	/**
	 * Inout: Add the last canonical member onto an existing TSet<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Set received as TSet<FName>&inout
	 * @Inputs Values already has the prefix members
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendWithAdd_FName(TSet<FName>&inout Values)
	{
		Values.Add(n"Blue");
	}


	/**
	 * Observe Add_bool: new values grow Num; duplicate Add keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs Default-constructed TSet<bool>; Add two distinct; Add first again
	 * @Return true when Num grows for a new value and duplicate keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndDuplicateKeepsNum_bool()
	{
		TSet<bool> Values;
		Values.Add(true);
		if (Values.Num() != 1 || !Values.Contains(true))
		{
			return false;
		}
		Values.Add(false);
		Values.Add(true);
		return Values.Num() == 2 && Values.Contains(true) && Values.Contains(false);
	}

	/**
	 * In-only: read Add membership from a const&in TSet<bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Source set received as const TSet<bool>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num and Contains match
	 */
	UFUNCTION()
	bool ReadAddedMembers_bool(const TSet<bool>&in Values)
	{
		return Values.Num() == 2 && Values.Contains(true) && Values.Contains(false);
	}

	/**
	 * Out-only: fill an empty &out TSet<bool> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<bool>&out
	 * @Inputs Empty &out TSet<bool>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAdd_bool(TSet<bool>&out Result)
	{
		Result.Add(true);
		Result.Add(false);
	}

	/**
	 * Inout: Add the last canonical member onto an existing TSet<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Set received as TSet<bool>&inout
	 * @Inputs Values already has the prefix members
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendWithAdd_bool(TSet<bool>&inout Values)
	{
		Values.Add(false);
	}


	/**
	 * Observe Add_FVector: new values grow Num; duplicate Add keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs Default-constructed TSet<FVector>; Add two distinct; Add first again
	 * @Return true when Num grows for a new value and duplicate keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndDuplicateKeepsNum_FVector()
	{
		TSet<FVector> Values;
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		if (Values.Num() != 1 || !Values.Contains(FVector(1.0f, 0.0f, 0.0f)))
		{
			return false;
		}
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		if (Values.Num() != 2 || !Values.Contains(FVector(0.0f, 1.0f, 0.0f)))
		{
			return false;
		}
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		return Values.Num() == 2 && Values.Contains(FVector(1.0f, 0.0f, 0.0f)) && Values.Contains(FVector(0.0f, 1.0f, 0.0f));
	}

	/**
	 * In-only: read Add membership from a const&in TSet<FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Source set received as const TSet<FVector>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num and Contains match
	 */
	UFUNCTION()
	bool ReadAddedMembers_FVector(const TSet<FVector>&in Values)
	{
		return Values.Num() == 3 && Values.Contains(FVector(1.0f, 0.0f, 0.0f)) && Values.Contains(FVector(0.0f, 1.0f, 0.0f)) && Values.Contains(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Out-only: fill an empty &out TSet<FVector> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<FVector>&out
	 * @Inputs Empty &out TSet<FVector>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAdd_FVector(TSet<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: Add the last canonical member onto an existing TSet<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Set received as TSet<FVector>&inout
	 * @Inputs Values already has the prefix members
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendWithAdd_FVector(TSet<FVector>&inout Values)
	{
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Observe Add_UObject: new values grow Num; duplicate Add keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs Default-constructed TSet<UObject>; Add two distinct; Add first again
	 * @Return true when Num grows for a new value and duplicate keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndDuplicateKeepsNum_UObject()
	{
		TSet<UObject> Values;
		UObject First = NewObject(GetTransientPackage(), UTSetAddObject::StaticClass(), n"TSetAdd_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTSetAddObject::StaticClass(), n"TSetAdd_Second", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}
		Values.Add(First);
		if (Values.Num() != 1 || !Values.Contains(First))
		{
			return false;
		}
		Values.Add(Second);
		Values.Add(First);
		return Values.Num() == 2 && Values.Contains(First) && Values.Contains(Second);
	}

	/**
	 * In-only: read Add membership from a const&in TSet<UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Source set received as const TSet<UObject>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num and Contains match
	 */
	UFUNCTION()
	bool ReadAddedMembers_UObject(const TSet<UObject>&in Values)
	{
		int Count = 0;
		for (UObject Item : Values)
		{
			if (Item == nullptr)
			{
				return false;
			}
			Count++;
		}
		return Values.Num() == 3 && Count == 3;
	}

	/**
	 * Out-only: fill an empty &out TSet<UObject> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<UObject>&out
	 * @Inputs Empty &out TSet<UObject>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAdd_UObject(TSet<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTSetAddObject::StaticClass(), n"UTSetAddObject_Fill_0", true));
		Result.Add(NewObject(GetTransientPackage(), UTSetAddObject::StaticClass(), n"UTSetAddObject_Fill_1", true));
		Result.Add(NewObject(GetTransientPackage(), UTSetAddObject::StaticClass(), n"UTSetAddObject_Fill_2", true));
	}

	/**
	 * Inout: Add the last canonical member onto an existing TSet<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Set received as TSet<UObject>&inout
	 * @Inputs Values already has the prefix members
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendWithAdd_UObject(TSet<UObject>&inout Values)
	{
		Values.Add(NewObject(GetTransientPackage(), UTSetAddObject::StaticClass(), n"UTSetAddObject_Append", true));
	}


}
