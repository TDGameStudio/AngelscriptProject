/**
 * @version v1
 * @summary Remove deletes an existing member and reports whether it existed. int is canonical; other shapes repeat the four entries.
 * @topic Containers
 */
/**
 * @version root
 * @summary Remove deletes an existing member and reports whether it existed. int is canonical; other shapes repeat the four entries.
 * @topic Baseline
 */
UCLASS()
class UTSetRemoveObject : UObject
{
}

namespace TSetTest
{
	/**
	 * Observe Remove: existing member is dropped; missing Remove returns false.
	 *
	 * @Kind Observe
	 * @Covers TSet.Remove
	 * @Inputs TSet<int> with members; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		if (!Values.Remove(20) || Values.Contains(20) || Values.Num() != 2)
		{
			return false;
		}
		return !Values.Remove(99) && Values.Contains(10) && Values.Contains(30);
	}

	/**
	 * In-only: read a set that already had a member removed.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values.Num() after a successful Remove
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove(const TSet<int>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add members then Remove one.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result.Num() is one less
	 */
	UFUNCTION()
	void FillThenRemove(TSet<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Result.Remove(20);
	}

	/**
	 * Inout: Remove one present member.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs canonical members present
	 * @Return void; Num decreases by 1
	 */
	UFUNCTION()
	void RemoveInPlace(TSet<int>&inout Values)
	{
		Values.Remove(20);
	}


	/**
	 * Observe Remove_FString: existing member is dropped; missing Remove returns false.
	 *
	 * @Kind Observe
	 * @Covers TSet.Remove
	 * @Inputs TSet<FString> with members; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent_FString()
	{
		TSet<FString> Values;
		Values.Add("alpha");
		Values.Add("beta");
		Values.Add("gamma");
		if (!Values.Remove("beta") || Values.Contains("beta") || Values.Num() != 2)
		{
			return false;
		}
		return !Values.Remove("missing") && Values.Contains("alpha") && Values.Contains("gamma");
	}

	/**
	 * In-only: read a set that already had a member removed_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Source set received as const TSet<FString>&in
	 * @Inputs Values.Num() after a successful Remove
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove_FString(const TSet<FString>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add members then Remove one_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Result Destination received as TSet<FString>&out
	 * @Inputs Empty &out TSet<FString>
	 * @Return void; Result.Num() is one less
	 */
	UFUNCTION()
	void FillThenRemove_FString(TSet<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
		Result.Remove("beta");
	}

	/**
	 * Inout: Remove one present member_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Set received as TSet<FString>&inout
	 * @Inputs canonical members present
	 * @Return void; Num decreases by 1
	 */
	UFUNCTION()
	void RemoveInPlace_FString(TSet<FString>&inout Values)
	{
		Values.Remove("beta");
	}


	/**
	 * Observe Remove_FName: existing member is dropped; missing Remove returns false.
	 *
	 * @Kind Observe
	 * @Covers TSet.Remove
	 * @Inputs TSet<FName> with members; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent_FName()
	{
		TSet<FName> Values;
		Values.Add(n"Red");
		Values.Add(n"Green");
		Values.Add(n"Blue");
		if (!Values.Remove(n"Green") || Values.Contains(n"Green") || Values.Num() != 2)
		{
			return false;
		}
		return !Values.Remove(n"Missing") && Values.Contains(n"Red") && Values.Contains(n"Blue");
	}

	/**
	 * In-only: read a set that already had a member removed_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Source set received as const TSet<FName>&in
	 * @Inputs Values.Num() after a successful Remove
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove_FName(const TSet<FName>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add members then Remove one_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Result Destination received as TSet<FName>&out
	 * @Inputs Empty &out TSet<FName>
	 * @Return void; Result.Num() is one less
	 */
	UFUNCTION()
	void FillThenRemove_FName(TSet<FName>&out Result)
	{
		Result.Add(n"Red");
		Result.Add(n"Green");
		Result.Add(n"Blue");
		Result.Remove(n"Green");
	}

	/**
	 * Inout: Remove one present member_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Set received as TSet<FName>&inout
	 * @Inputs canonical members present
	 * @Return void; Num decreases by 1
	 */
	UFUNCTION()
	void RemoveInPlace_FName(TSet<FName>&inout Values)
	{
		Values.Remove(n"Green");
	}


	/**
	 * Observe Remove_bool: existing member is dropped; missing Remove returns false.
	 *
	 * @Kind Observe
	 * @Covers TSet.Remove
	 * @Inputs TSet<bool> with members; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent_bool()
	{
		TSet<bool> Values;
		Values.Add(true);
		Values.Add(false);
		if (!Values.Remove(true) || Values.Contains(true) || Values.Num() != 1)
		{
			return false;
		}
		return !Values.Remove(true) && Values.Contains(false);
	}

	/**
	 * In-only: read a set that already had a member removed_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Source set received as const TSet<bool>&in
	 * @Inputs Values.Num() after a successful Remove
	 * @Return true when Num() == 1
	 */
	UFUNCTION()
	bool ReadAfterRemove_bool(const TSet<bool>&in Values)
	{
		return Values.Num() == 1;
	}

	/**
	 * Out-only: Add members then Remove one_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Result Destination received as TSet<bool>&out
	 * @Inputs Empty &out TSet<bool>
	 * @Return void; Result.Num() is one less
	 */
	UFUNCTION()
	void FillThenRemove_bool(TSet<bool>&out Result)
	{
		Result.Add(true);
		Result.Add(false);
		Result.Remove(true);
	}

	/**
	 * Inout: Remove one present member_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Set received as TSet<bool>&inout
	 * @Inputs canonical members present
	 * @Return void; Num decreases by 1
	 */
	UFUNCTION()
	void RemoveInPlace_bool(TSet<bool>&inout Values)
	{
		Values.Remove(true);
	}


	/**
	 * Observe Remove_FVector: existing member is dropped; missing Remove returns false.
	 *
	 * @Kind Observe
	 * @Covers TSet.Remove
	 * @Inputs TSet<FVector> with members; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent_FVector()
	{
		TSet<FVector> Values;
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
		if (!Values.Remove(FVector(0.0f, 1.0f, 0.0f)) || Values.Contains(FVector(0.0f, 1.0f, 0.0f)) || Values.Num() != 2)
		{
			return false;
		}
		return !Values.Remove(FVector(9.0f, 9.0f, 9.0f)) && Values.Contains(FVector(1.0f, 0.0f, 0.0f)) && Values.Contains(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * In-only: read a set that already had a member removed_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Source set received as const TSet<FVector>&in
	 * @Inputs Values.Num() after a successful Remove
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove_FVector(const TSet<FVector>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add members then Remove one_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Result Destination received as TSet<FVector>&out
	 * @Inputs Empty &out TSet<FVector>
	 * @Return void; Result.Num() is one less
	 */
	UFUNCTION()
	void FillThenRemove_FVector(TSet<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
		Result.Remove(FVector(0.0f, 1.0f, 0.0f));
	}

	/**
	 * Inout: Remove one present member_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Set received as TSet<FVector>&inout
	 * @Inputs canonical members present
	 * @Return void; Num decreases by 1
	 */
	UFUNCTION()
	void RemoveInPlace_FVector(TSet<FVector>&inout Values)
	{
		Values.Remove(FVector(0.0f, 1.0f, 0.0f));
	}


	/**
	 * Observe Remove_UObject: existing member is dropped; missing Remove returns false.
	 *
	 * @Kind Observe
	 * @Covers TSet.Remove
	 * @Inputs TSet<UObject> with members; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent_UObject()
	{
		TSet<UObject> Values;
		UObject First = NewObject(GetTransientPackage(), UTSetRemoveObject::StaticClass(), n"TSetRemove_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTSetRemoveObject::StaticClass(), n"TSetRemove_Second", true);
		Values.Add(First);
		Values.Add(Second);
		if (!Values.Remove(First) || Values.Contains(First) || Values.Num() != 1)
		{
			return false;
		}
		return !Values.Remove(First) && Values.Contains(Second);
	}

	/**
	 * In-only: read a set that already had a member removed_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Source set received as const TSet<UObject>&in
	 * @Inputs Values.Num() after a successful Remove
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove_UObject(const TSet<UObject>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add members then Remove one_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Result Destination received as TSet<UObject>&out
	 * @Inputs Empty &out TSet<UObject>
	 * @Return void; Result.Num() is one less
	 */
	UFUNCTION()
	void FillThenRemove_UObject(TSet<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTSetRemoveObject::StaticClass(), n"UTSetRemoveObject_Fill_0", true));
		Result.Add(NewObject(GetTransientPackage(), UTSetRemoveObject::StaticClass(), n"UTSetRemoveObject_Fill_1", true));
		Result.Add(NewObject(GetTransientPackage(), UTSetRemoveObject::StaticClass(), n"UTSetRemoveObject_Fill_2", true));
		UObject Drop = nullptr;
		for (UObject Item : Result)
		{
			Drop = Item;
			break;
		}
		Result.Remove(Drop);
	}

	/**
	 * Inout: Remove one present member_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Set received as TSet<UObject>&inout
	 * @Inputs canonical members present
	 * @Return void; Num decreases by 1
	 */
	UFUNCTION()
	void RemoveInPlace_UObject(TSet<UObject>&inout Values)
	{
		UObject Drop = nullptr;
		for (UObject Item : Values)
		{
			Drop = Item;
			break;
		}
		Values.Remove(Drop);
	}


}
/** @end */
