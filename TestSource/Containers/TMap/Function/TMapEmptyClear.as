/**
 * Empty() clears every pair. Idempotent on an already-empty map; Add after Empty
 * starts a new map. Empty is the RoundTrip surface; Reset stays int Observe.
 * int/int is canonical; other shapes repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TMap
 * @Subject TMap.Empty
 * @Harness Function
 * @Tag Containers.TMap.TMapEmptyClear
 * @Namespace TMapTest
 */

UCLASS()
class UTMapEmptyClearObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Observe Empty: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TMap.Empty
	 * @Inputs Default TMap<int, int>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd()
	{
		TMap<int, int> Map;
		Map.Empty();
		if (Map.Num() != 0)
		{
			return false;
		}

		Map.Add(10, 100);
		Map.Empty();
		if (Map.Num() != 0 || Map.Contains(10))
		{
			return false;
		}

		Map.Add(20, 200);
		Map.Add(30, 300);
		Map.Empty();
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * In-only: read an emptied TMap<int, int> from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty(const TMap<int, int>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TMap<int, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing three-pair TMap<int, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Map received as TMap<int, int>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace(TMap<int, int>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Empty_FString: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TMap.Empty
	 * @Inputs Default TMap<FString, int>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_FString()
	{
		TMap<FString, int> Map;
		Map.Empty();
		if (Map.Num() != 0)
		{
			return false;
		}

		Map.Add("alpha", 100);
		Map.Empty();
		if (Map.Num() != 0 || Map.Contains("alpha"))
		{
			return false;
		}

		Map.Add("beta", 200);
		Map.Add("gamma", 300);
		Map.Empty();
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * In-only: read an emptied TMap<FString, int> from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty_FString(const TMap<FString, int>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TMap<FString, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_FString(TMap<FString, int>&out Result)
	{
		Result.Add("alpha", 100);
		Result.Add("beta", 200);
		Result.Add("gamma", 300);
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing three-pair TMap<FString, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Map received as TMap<FString, int>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_FString(TMap<FString, int>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Empty_FName: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TMap.Empty
	 * @Inputs Default TMap<FName, int>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_FName()
	{
		TMap<FName, int> Map;
		Map.Empty();
		if (Map.Num() != 0)
		{
			return false;
		}

		Map.Add(n"Red", 1);
		Map.Empty();
		if (Map.Num() != 0 || Map.Contains(n"Red"))
		{
			return false;
		}

		Map.Add(n"Green", 2);
		Map.Add(n"Blue", 3);
		Map.Empty();
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * In-only: read an emptied TMap<FName, int> from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty_FName(const TMap<FName, int>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TMap<FName, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_FName(TMap<FName, int>&out Result)
	{
		Result.Add(n"Red", 1);
		Result.Add(n"Green", 2);
		Result.Add(n"Blue", 3);
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing three-pair TMap<FName, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Map received as TMap<FName, int>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_FName(TMap<FName, int>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Empty_bool: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TMap.Empty
	 * @Inputs Default TMap<int, bool>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_bool()
	{
		TMap<int, bool> Map;
		Map.Empty();
		if (Map.Num() != 0)
		{
			return false;
		}

		Map.Add(1, true);
		Map.Empty();
		if (Map.Num() != 0 || Map.Contains(1))
		{
			return false;
		}

		Map.Add(2, false);
		Map.Add(3, true);
		Map.Empty();
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * In-only: read an emptied TMap<int, bool> from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty_bool(const TMap<int, bool>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TMap<int, bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_bool(TMap<int, bool>&out Result)
	{
		Result.Add(1, true);
		Result.Add(2, false);
		Result.Add(3, true);
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing three-pair TMap<int, bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Map received as TMap<int, bool>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_bool(TMap<int, bool>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Empty_FVector: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TMap.Empty
	 * @Inputs Default TMap<int, FVector>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_FVector()
	{
		TMap<int, FVector> Map;
		Map.Empty();
		if (Map.Num() != 0)
		{
			return false;
		}

		Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Map.Empty();
		if (Map.Num() != 0 || Map.Contains(1))
		{
			return false;
		}

		Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Map.Add(3, FVector(0.0f, 0.0f, 1.0f));
		Map.Empty();
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * In-only: read an emptied TMap<int, FVector> from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty_FVector(const TMap<int, FVector>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TMap<int, FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_FVector(TMap<int, FVector>&out Result)
	{
		Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing three-pair TMap<int, FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Map received as TMap<int, FVector>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_FVector(TMap<int, FVector>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Empty_UObject: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TMap.Empty
	 * @Inputs Default TMap<int, UObject>; Empty(); Add; Empty(); Add again
	 * @Return true when Num is 0 after each Empty and Add after Empty works
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_UObject()
	{
		TMap<int, UObject> Map;
		UObject First = NewObject(GetTransientPackage(), UTMapEmptyClearObject::StaticClass(), n"TMapEmpty_First", true);
		Map.Empty();
		if (Map.Num() != 0)
		{
			return false;
		}
		Map.Add(10, First);
		Map.Empty();
		if (Map.Num() != 0 || Map.Contains(10))
		{
			return false;
		}
		Map.Add(20, First);
		return Map.Num() == 1 && Map.Contains(20);
	}

	/**
	 * In-only: read an emptied TMap<int, UObject> from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool ReadEmpty_UObject(const TMap<int, UObject>&in Values)
	{
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Out-only: Add then Empty on an empty &out TMap<int, UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_UObject(TMap<int, UObject>&out Result)
	{
		Result.Add(10, NewObject(GetTransientPackage(), UTMapEmptyClearObject::StaticClass(), n"UTMapEmptyClearObject_Fill_0", true));
		Result.Add(20, NewObject(GetTransientPackage(), UTMapEmptyClearObject::StaticClass(), n"UTMapEmptyClearObject_Fill_1", true));
		Result.Add(30, NewObject(GetTransientPackage(), UTMapEmptyClearObject::StaticClass(), n"UTMapEmptyClearObject_Fill_2", true));
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing three-pair TMap<int, UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Param Values Map received as TMap<int, UObject>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_UObject(TMap<int, UObject>&inout Values)
	{
		Values.Empty();
	}


	/**
	 * Observe Reset: clears pairs while remaining usable for Add.
	 *
	 * @Kind Observe
	 * @Covers TMap.Reset
	 * @Inputs TMap<int, int> [10->100, 20->200]; Reset(); Add(30, 300)
	 * @Return true when Reset leaves Num 0 and Add after Reset works
	 */
	UFUNCTION()
	bool ResetClearsThenAllowsAdd()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		Map.Add(20, 200);
		Map.Reset();
		if (Map.Num() != 0 || Map.Contains(10))
		{
			return false;
		}
		Map.Add(30, 300);
		return Map.Num() == 1 && Map[30] == 300;
	}

}
