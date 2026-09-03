/**
 * Empty() clears every member. Idempotent on an already-empty set; Add after Empty
 * starts a new set. Empty is the RoundTrip surface; Reset stays int Observe.
 *
 * @Theme Containers.TSet
 * @Subject TSet.Empty
 * @Harness Function
 * @Tag Containers.TSet.TSetEmptyClear
 * @Namespace TSetTest
 */

UCLASS()
class UTSetEmptyClearObject : UObject
{
}

namespace TSetTest
{
	/**
	 * Observe Empty: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TSet.Empty
	 * @Inputs Default TSet<int>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd()
	{
		TSet<int> Values;
		Values.Empty();
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add(10);
		Values.Empty();
		if (Values.Num() != 0 || Values.Contains(10))
		{
			return false;
		}
		Values.Add(10);
		Values.Add(20);
		Values.Empty();
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * In-only: read an emptied TSet<int> from const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty(const TSet<int>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TSet<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty(TSet<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing TSet<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs Values is non-empty
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace(TSet<int>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Empty_FString: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TSet.Empty
	 * @Inputs Default TSet<FString>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_FString()
	{
		TSet<FString> Values;
		Values.Empty();
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add("alpha");
		Values.Empty();
		if (Values.Num() != 0 || Values.Contains("alpha"))
		{
			return false;
		}
		Values.Add("alpha");
		Values.Add("beta");
		Values.Empty();
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * In-only: read an emptied TSet<FString> from const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Source set received as const TSet<FString>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty_FString(const TSet<FString>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TSet<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Result Destination received as TSet<FString>&out
	 * @Inputs Empty &out TSet<FString>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_FString(TSet<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing TSet<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Set received as TSet<FString>&inout
	 * @Inputs Values is non-empty
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_FString(TSet<FString>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Empty_FName: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TSet.Empty
	 * @Inputs Default TSet<FName>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_FName()
	{
		TSet<FName> Values;
		Values.Empty();
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add(n"Red");
		Values.Empty();
		if (Values.Num() != 0 || Values.Contains(n"Red"))
		{
			return false;
		}
		Values.Add(n"Red");
		Values.Add(n"Green");
		Values.Empty();
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * In-only: read an emptied TSet<FName> from const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Source set received as const TSet<FName>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty_FName(const TSet<FName>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TSet<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Result Destination received as TSet<FName>&out
	 * @Inputs Empty &out TSet<FName>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_FName(TSet<FName>&out Result)
	{
		Result.Add(n"Red");
		Result.Add(n"Green");
		Result.Add(n"Blue");
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing TSet<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Set received as TSet<FName>&inout
	 * @Inputs Values is non-empty
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_FName(TSet<FName>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Empty_bool: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TSet.Empty
	 * @Inputs Default TSet<bool>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_bool()
	{
		TSet<bool> Values;
		Values.Empty();
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add(true);
		Values.Empty();
		if (Values.Num() != 0 || Values.Contains(true))
		{
			return false;
		}
		Values.Add(true);
		Values.Add(false);
		Values.Empty();
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * In-only: read an emptied TSet<bool> from const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Source set received as const TSet<bool>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty_bool(const TSet<bool>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TSet<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Result Destination received as TSet<bool>&out
	 * @Inputs Empty &out TSet<bool>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_bool(TSet<bool>&out Result)
	{
		Result.Add(true);
		Result.Add(false);
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing TSet<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Set received as TSet<bool>&inout
	 * @Inputs Values is non-empty
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_bool(TSet<bool>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Empty_FVector: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TSet.Empty
	 * @Inputs Default TSet<FVector>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_FVector()
	{
		TSet<FVector> Values;
		Values.Empty();
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		Values.Empty();
		if (Values.Num() != 0 || Values.Contains(FVector(1.0f, 0.0f, 0.0f)))
		{
			return false;
		}
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Empty();
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * In-only: read an emptied TSet<FVector> from const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Source set received as const TSet<FVector>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty_FVector(const TSet<FVector>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TSet<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Result Destination received as TSet<FVector>&out
	 * @Inputs Empty &out TSet<FVector>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_FVector(TSet<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing TSet<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Set received as TSet<FVector>&inout
	 * @Inputs Values is non-empty
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_FVector(TSet<FVector>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Empty_UObject: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TSet.Empty
	 * @Inputs Default TSet<UObject>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_UObject()
	{
		TSet<UObject> Values;
		UObject First = NewObject(GetTransientPackage(), UTSetEmptyClearObject::StaticClass(), n"TSetEmpty_First", true);
		Values.Empty();
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add(First);
		Values.Empty();
		if (Values.Num() != 0 || Values.Contains(First))
		{
			return false;
		}
		Values.Add(First);
		return Values.Num() == 1 && Values.Contains(First);
	}

	/**
	 * In-only: read an emptied TSet<UObject> from const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Source set received as const TSet<UObject>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty_UObject(const TSet<UObject>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TSet<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Result Destination received as TSet<UObject>&out
	 * @Inputs Empty &out TSet<UObject>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_UObject(TSet<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTSetEmptyClearObject::StaticClass(), n"UTSetEmptyClearObject_Fill_0", true));
		Result.Add(NewObject(GetTransientPackage(), UTSetEmptyClearObject::StaticClass(), n"UTSetEmptyClearObject_Fill_1", true));
		Result.Add(NewObject(GetTransientPackage(), UTSetEmptyClearObject::StaticClass(), n"UTSetEmptyClearObject_Fill_2", true));
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing TSet<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Param Values Set received as TSet<UObject>&inout
	 * @Inputs Values is non-empty
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_UObject(TSet<UObject>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Reset: clears members while remaining usable for Add.
	 *
	 * @Kind Observe
	 * @Covers TSet.Reset
	 * @Inputs TSet<int> [10, 20]; Reset(); Add(30)
	 * @Return true when Reset leaves Num 0 and Add after Reset works
	 */
	UFUNCTION()
	bool ResetClearsThenAllowsAdd()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Reset();
		if (Values.Num() != 0 || Values.Contains(10))
		{
			return false;
		}
		Values.Add(30);
		return Values.Num() == 1 && Values.Contains(30);
	}

}
