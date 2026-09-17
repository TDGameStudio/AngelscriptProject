/**
 * @version v1
 * @summary Empty() clears elements. Idempotent on an already-empty array; Add after Empty starts a new sequence. Clear is observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types.
 * @topic Containers
 */
/**
 * @version root
 * @summary Empty() clears elements. Idempotent on an already-empty array; Add after Empty starts a new sequence. Clear is observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types.
 * @topic Baseline
 */
UCLASS()
class UTArrayEmptyClearObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Empty: no-op on empty, clears after Add, Add again works, clears multi.
	 *
	 * @Kind Observe
	 * @Covers TArray.Empty
	 * @Inputs Default TArray<int>; Empty(); Add(1); Empty(); Add(2); Add(3,4); Empty()
	 * @Return true when Num is 0 after each Empty and Add after Empty yields [2]
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd()
	{
		TArray<int> Array;

		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}

		Array.Add(1);
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}

		Array.Add(2);
		if (Array.Num() != 1 || Array[0] != 2)
		{
			return false;
		}

		Array.Add(3);
		Array.Add(4);
		Array.Empty();
		return Array.Num() == 0;
	}

	/**
	 * In-only: read an emptied array from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0
	 */
	UFUNCTION()
	bool ReadEmpty(const TArray<int>&in Values)
	{
		return Values.Num() == 0;
	}

	/**
	 * Out-only: Add then Empty on an empty &out array so the payload is cleared.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing [1, 2, 3].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Array received as TArray<int>&inout, starts as [1, 2, 3]
	 * @Inputs Values.Num() == 3 with [1, 2, 3]
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace(TArray<int>&inout Values)
	{
		Values.Empty();
	}

	/**
	 * Observe Empty for float: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TArray.Empty
	 * @Inputs TArray<float>; Empty(); Add; Empty(); Add; Empty()
	 * @Return true when Num is 0 after each Empty
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_float()
	{
		TArray<float> Array;
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add(1.0f);
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add(2.0f);
		if (Array.Num() != 1 || Array[0] == 2.0f)
		{
			return false;
		}
		Array.Add(3.0f);
		Array.Add(4.0f);
		Array.Empty();
		return Array.Num() == 0;
	}

	/**
	 * In-only: read an emptied float array from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0
	 */
	UFUNCTION()
	bool ReadEmpty_float(const TArray<float>&in Values)
	{
		return Values.Num() == 0;
	}

	/**
	 * Out-only: Add then Empty on an empty &out float array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_float(TArray<float>&out Result)
	{
		Result.Add(1.0f);
		Result.Add(2.0f);
		Result.Add(3.0f);
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing three-element float array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Array received as TArray<float>&inout, starts with three elements
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_float(TArray<float>&inout Values)
	{
		Values.Empty();
	}

	/**
	 * Observe Empty for FString: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TArray.Empty
	 * @Inputs TArray<FString>; Empty(); Add; Empty(); Add; Empty()
	 * @Return true when Num is 0 after each Empty
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_FString()
	{
		TArray<FString> Array;
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add("alpha");
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add("beta");
		if (Array.Num() != 1 || Array[0] == "beta")
		{
			return false;
		}
		Array.Add("gamma");
		Array.Add("delta");
		Array.Empty();
		return Array.Num() == 0;
	}

	/**
	 * In-only: read an emptied FString array from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0
	 */
	UFUNCTION()
	bool ReadEmpty_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 0;
	}

	/**
	 * Out-only: Add then Empty on an empty &out FString array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_FString(TArray<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing three-element FString array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Array received as TArray<FString>&inout, starts with three elements
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_FString(TArray<FString>&inout Values)
	{
		Values.Empty();
	}

	/**
	 * Observe Empty for FVector: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TArray.Empty
	 * @Inputs TArray<FVector>; Empty(); Add; Empty(); Add; Empty()
	 * @Return true when Num is 0 after each Empty
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_FVector()
	{
		TArray<FVector> Array;
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add(FVector(1.0f, 0.0f, 0.0f));
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add(FVector(0.0f, 1.0f, 0.0f));
		if (Array.Num() != 1 || Array[0].Equals(FVector(0.0f, 1.0f, 0.0f)))
		{
			return false;
		}
		Array.Add(FVector(0.0f, 0.0f, 1.0f));
		Array.Add(FVector(1.0f, 1.0f, 0.0f));
		Array.Empty();
		return Array.Num() == 0;
	}

	/**
	 * In-only: read an emptied FVector array from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0
	 */
	UFUNCTION()
	bool ReadEmpty_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 0;
	}

	/**
	 * Out-only: Add then Empty on an empty &out FVector array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing three-element FVector array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Array received as TArray<FVector>&inout, starts with three elements
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_FVector(TArray<FVector>&inout Values)
	{
		Values.Empty();
	}

	/**
	 * Observe Empty for bool: no-op on empty, clears after Add, Add again works.
	 *
	 * @Kind Observe
	 * @Covers TArray.Empty
	 * @Inputs TArray<bool>; Empty(); Add; Empty(); Add; Empty()
	 * @Return true when Num is 0 after each Empty
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_bool()
	{
		TArray<bool> Array;
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add(false);
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add(true);
		if (Array.Num() != 1 || Array[0] == true)
		{
			return false;
		}
		Array.Add(false);
		Array.Add(true);
		Array.Empty();
		return Array.Num() == 0;
	}

	/**
	 * In-only: read an emptied bool array from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0
	 */
	UFUNCTION()
	bool ReadEmpty_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 0;
	}

	/**
	 * Out-only: Add then Empty on an empty &out bool array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_bool(TArray<bool>&out Result)
	{
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing three-element bool array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Array received as TArray<bool>&inout, starts with three elements
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_bool(TArray<bool>&inout Values)
	{
		Values.Empty();
	}

	/**
	 * Observe Empty for UObject handles.
	 *
	 * @Kind Observe
	 * @Covers TArray.Empty
	 * @Inputs NewObject temps; Empty between Adds
	 * @Return true when Num is 0 after each Empty
	 */
	UFUNCTION()
	bool EmptyClearsThenAllowsAdd_UObject()
	{
		TArray<UObject> Array;
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add(NewObject(GetTransientPackage(), UTArrayEmptyClearObject::StaticClass(), n"TArrayEmpty_A", true));
		Array.Empty();
		if (Array.Num() != 0)
		{
			return false;
		}
		UObject Keep = NewObject(GetTransientPackage(), UTArrayEmptyClearObject::StaticClass(), n"TArrayEmpty_Keep", true);
		Array.Add(Keep);
		if (Array.Num() != 1 || Array[0] != Keep)
		{
			return false;
		}
		Array.Add(NewObject(GetTransientPackage(), UTArrayEmptyClearObject::StaticClass(), n"TArrayEmpty_C", true));
		Array.Add(NewObject(GetTransientPackage(), UTArrayEmptyClearObject::StaticClass(), n"TArrayEmpty_D", true));
		Array.Empty();
		return Array.Num() == 0;
	}

	/**
	 * In-only: read an emptied UObject array from const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs Values.Num() == 0
	 * @Return true when Num() == 0
	 */
	UFUNCTION()
	bool ReadEmpty_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 0;
	}

	/**
	 * Out-only: Add then Empty on an empty &out UObject array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 0
	 */
	UFUNCTION()
	void FillThenEmpty_UObject(TArray<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTArrayEmptyClearObject::StaticClass(), n"TArrayEmpty_Fill_0", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayEmptyClearObject::StaticClass(), n"TArrayEmpty_Fill_1", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayEmptyClearObject::StaticClass(), n"TArrayEmpty_Fill_2", true));
		Result.Empty();
	}

	/**
	 * Inout: Empty an existing UObject array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 0
	 */
	UFUNCTION()
	void EmptyInPlace_UObject(TArray<UObject>&inout Values)
	{
		Values.Empty();
	}

}
/** @end */
