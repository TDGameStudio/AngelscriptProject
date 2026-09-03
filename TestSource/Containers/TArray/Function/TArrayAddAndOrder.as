/**
 * TArray.Add appends at the end; insertion order is element order.
 * Add is void; order is observed through Num and [], then through UFUNCTION
 * in, out, and inout directions. int is the canonical case; other element
 * types repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Add
 * @Harness Function
 * @Tag Containers.TArray.TArrayAddAndOrder
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayAddOrderObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Add: first element at 0, later Add appends, existing slots stay.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs Default-constructed TArray<int>; Add(10); Add(20); Add(30)
	 * @Return true when the array is [10, 20, 30] after each append preserves prior order
	 */
	UFUNCTION()
	bool AddAppendsInInsertionOrder()
	{
		TArray<int> Array;

		Array.Add(10);
		if (Array.Num() != 1 || Array[0] != 10)
		{
			return false;
		}

		Array.Add(20);
		if (Array.Num() != 2 || Array[0] != 10 || Array[1] != 20)
		{
			return false;
		}

		Array.Add(30);
		return Array.Num() == 3 && Array[0] == 10 && Array[1] == 20 && Array[2] == 30;
	}

	/**
	 * In-only: read Add order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [10, 20, 30]
	 * @Return true when Num() == 3 and elements are [10, 20, 30]
	 */
	UFUNCTION()
	bool ReadInsertionOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 3 && Values[0] == 10 && Values[1] == 20 && Values[2] == 30;
	}

	/**
	 * Out-only: fill an empty &out array with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [10, 20, 30]
	 */
	UFUNCTION()
	void FillIntArrayByAdd(TArray<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
	}

	/**
	 * Inout: keep existing elements and Add one more at the end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Array received as TArray<int>&inout, starts as [10, 20]
	 * @Inputs Values.Num() == 2 with [10, 20]
	 * @Return void; Values becomes [10, 20, 30]
	 */
	UFUNCTION()
	void AppendWithAdd_int(TArray<int>&inout Values)
	{
		Values.Add(30);
	}

	/**
	 * Observe Add for float: first element at 0, later Add appends, existing slots stay.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs Default-constructed TArray<float>; Add(10.0f); Add(20.0f); Add(30.0f)
	 * @Return true when the array is [10.0f, 20.0f, 30.0f] after each append preserves prior order
	 */
	UFUNCTION()
	bool AddAppendsInInsertionOrder_float()
	{
		TArray<float> Array;

		Array.Add(10.0f);
		if (Array.Num() != 1 || Array[0] != 10.0f)
		{
			return false;
		}

		Array.Add(20.0f);
		if (Array.Num() != 2 || Array[0] != 10.0f || Array[1] != 20.0f)
		{
			return false;
		}

		Array.Add(30.0f);
		return Array.Num() == 3 && Array[0] == 10.0f && Array[1] == 20.0f && Array[2] == 30.0f;
	}

	/**
	 * In-only: read Add order from a const&in float array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs Values == [10.0f, 20.0f, 30.0f]
	 * @Return true when Num() == 3 and elements are [10.0f, 20.0f, 30.0f]
	 */
	UFUNCTION()
	bool ReadInsertionOrder_float(const TArray<float>&in Values)
	{
		return Values.Num() == 3 && Values[0] == 10.0f && Values[1] == 20.0f && Values[2] == 30.0f;
	}

	/**
	 * Out-only: fill an empty &out float array with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result becomes [10.0f, 20.0f, 30.0f]
	 */
	UFUNCTION()
	void FillIntArrayByAdd_float(TArray<float>&out Result)
	{
		Result.Add(10.0f);
		Result.Add(20.0f);
		Result.Add(30.0f);
	}

	/**
	 * Inout: keep existing float elements and Add one more at the end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Array received as TArray<float>&inout, starts as [10.0f, 20.0f]
	 * @Inputs Values.Num() == 2 with [10.0f, 20.0f]
	 * @Return void; Values becomes [10.0f, 20.0f, 30.0f]
	 */
	UFUNCTION()
	void AppendWithAdd_float(TArray<float>&inout Values)
	{
		Values.Add(30.0f);
	}

	/**
	 * Observe Add for bool: first element at 0, later Add appends, existing slots stay.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs Default-constructed TArray<bool>; Add(false); Add(true); Add(false)
	 * @Return true when the array is [false, true, false] after each append preserves prior order
	 */
	UFUNCTION()
	bool AddAppendsInInsertionOrder_bool()
	{
		TArray<bool> Array;

		Array.Add(false);
		if (Array.Num() != 1 || Array[0] != false)
		{
			return false;
		}

		Array.Add(true);
		if (Array.Num() != 2 || Array[0] != false || Array[1] != true)
		{
			return false;
		}

		Array.Add(false);
		return Array.Num() == 3 && Array[0] == false && Array[1] == true && Array[2] == false;
	}

	/**
	 * In-only: read Add order from a const&in bool array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs Values == [false, true, false]
	 * @Return true when Num() == 3 and elements are [false, true, false]
	 */
	UFUNCTION()
	bool ReadInsertionOrder_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 3 && Values[0] == false && Values[1] == true && Values[2] == false;
	}

	/**
	 * Out-only: fill an empty &out bool array with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result becomes [false, true, false]
	 */
	UFUNCTION()
	void FillIntArrayByAdd_bool(TArray<bool>&out Result)
	{
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
	}

	/**
	 * Inout: keep existing bool elements and Add one more at the end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Array received as TArray<bool>&inout, starts as [false, true]
	 * @Inputs Values.Num() == 2 with [false, true]
	 * @Return void; Values becomes [false, true, false]
	 */
	UFUNCTION()
	void AppendWithAdd_bool(TArray<bool>&inout Values)
	{
		Values.Add(false);
	}

	/**
	 * Observe Add for FString: first element at 0, later Add appends, existing slots stay.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs Default-constructed TArray<FString>; Add("alpha"); Add("beta"); Add("gamma"); Add("")
	 * @Return true when the array is ["alpha", "beta", "gamma", ""] and "" is a real last slot
	 */
	UFUNCTION()
	bool AddAppendsInInsertionOrder_FString()
	{
		TArray<FString> Array;

		Array.Add("alpha");
		if (Array.Num() != 1 || Array[0] != "alpha")
		{
			return false;
		}

		Array.Add("beta");
		if (Array.Num() != 2 || Array[0] != "alpha" || Array[1] != "beta")
		{
			return false;
		}

		Array.Add("gamma");
		if (Array.Num() != 3 || Array[0] != "alpha" || Array[1] != "beta" || Array[2] != "gamma")
		{
			return false;
		}

		Array.Add("");
		return Array.Num() == 4
			&& Array[0] == "alpha"
			&& Array[3].Len() == 0;
	}

	/**
	 * In-only: read Add order from a const&in FString array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values == ["alpha", "beta", "gamma"]
	 * @Return true when Num() == 3 and elements are ["alpha", "beta", "gamma"]
	 */
	UFUNCTION()
	bool ReadInsertionOrder_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 3 && Values[0] == "alpha" && Values[1] == "beta" && Values[2] == "gamma";
	}

	/**
	 * Out-only: fill an empty &out FString array with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result becomes ["alpha", "beta", "gamma"]
	 */
	UFUNCTION()
	void FillIntArrayByAdd_FString(TArray<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
	}

	/**
	 * Inout: keep existing FString elements and Add one more at the end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Array received as TArray<FString>&inout, starts as ["alpha", "beta"]
	 * @Inputs Values.Num() == 2 with ["alpha", "beta"]
	 * @Return void; Values becomes ["alpha", "beta", "gamma"]
	 */
	UFUNCTION()
	void AppendWithAdd_FString(TArray<FString>&inout Values)
	{
		Values.Add("gamma");
	}

	/**
	 * Observe Add for FVector: first element at 0, later Add appends, existing slots stay.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs Default-constructed TArray<FVector>; Add((1,0,0)); Add((0,1,0)); Add((0,0,1))
	 * @Return true when the array is [(1,0,0), (0,1,0), (0,0,1)] after each append preserves prior order
	 */
	UFUNCTION()
	bool AddAppendsInInsertionOrder_FVector()
	{
		TArray<FVector> Array;

		Array.Add(FVector(1.0f, 0.0f, 0.0f));
		if (Array.Num() != 1 || !Array[0].Equals(FVector(1.0f, 0.0f, 0.0f)))
		{
			return false;
		}

		Array.Add(FVector(0.0f, 1.0f, 0.0f));
		if (Array.Num() != 2 || !Array[0].Equals(FVector(1.0f, 0.0f, 0.0f)) || !Array[1].Equals(FVector(0.0f, 1.0f, 0.0f)))
		{
			return false;
		}

		Array.Add(FVector(0.0f, 0.0f, 1.0f));
		return Array.Num() == 3
			&& Array[0].Equals(FVector(1.0f, 0.0f, 0.0f))
			&& Array[1].Equals(FVector(0.0f, 1.0f, 0.0f))
			&& Array[2].Equals(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * In-only: read Add order from a const&in FVector array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs Values == [(1,0,0), (0,1,0), (0,0,1)]
	 * @Return true when Num() == 3 and elements are [(1,0,0), (0,1,0), (0,0,1)]
	 */
	UFUNCTION()
	bool ReadInsertionOrder_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 3
			&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
			&& Values[1].Equals(FVector(0.0f, 1.0f, 0.0f))
			&& Values[2].Equals(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Out-only: fill an empty &out FVector array with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result becomes [(1,0,0), (0,1,0), (0,0,1)]
	 */
	UFUNCTION()
	void FillIntArrayByAdd_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: keep existing FVector elements and Add one more at the end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Array received as TArray<FVector>&inout, starts as [(1,0,0), (0,1,0)]
	 * @Inputs Values.Num() == 2 with [(1,0,0), (0,1,0)]
	 * @Return void; Values becomes [(1,0,0), (0,1,0), (0,0,1)]
	 */
	UFUNCTION()
	void AppendWithAdd_FVector(TArray<FVector>&inout Values)
	{
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Observe Add for UObject handles: first element at 0, later Add appends, existing slots stay.
	 * Temps are named NewObject on GetTransientPackage() as UTArrayAddOrderObject (plain UObject;
	 * UObject itself is Abstract and cannot be constructed). Order is pointer identity and GetName.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs Default-constructed TArray<UObject>; three named NewObject temps; Add in that order
	 * @Return true when the array is [First, Second, Third] after each append preserves prior order
	 */
	UFUNCTION()
	bool AddAppendsInInsertionOrder_UObject()
	{
		TArray<UObject> Array;
		UObject First = NewObject(GetTransientPackage(), UTArrayAddOrderObject::StaticClass(), n"TArrayAddAndOrder_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTArrayAddOrderObject::StaticClass(), n"TArrayAddAndOrder_Second", true);
		UObject Third = NewObject(GetTransientPackage(), UTArrayAddOrderObject::StaticClass(), n"TArrayAddAndOrder_Third", true);
		if (First == nullptr || Second == nullptr || Third == nullptr
			|| First == Second || Second == Third || First == Third)
		{
			return false;
		}

		Array.Add(First);
		if (Array.Num() != 1 || Array[0] != First || Array[0].GetName() != n"TArrayAddAndOrder_First")
		{
			return false;
		}

		Array.Add(Second);
		if (Array.Num() != 2 || Array[0] != First || Array[1] != Second
			|| Array[1].GetName() != n"TArrayAddAndOrder_Second")
		{
			return false;
		}

		Array.Add(Third);
		return Array.Num() == 3
			&& Array[0] == First && Array[1] == Second && Array[2] == Third
			&& Array[0].GetName() == n"TArrayAddAndOrder_First"
			&& Array[1].GetName() == n"TArrayAddAndOrder_Second"
			&& Array[2].GetName() == n"TArrayAddAndOrder_Third";
	}

	/**
	 * In-only: read Add order from a const&in UObject array without writing it back.
	 * Runner should pass three distinct NewObject temps in insertion order.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs Values == three distinct non-null UObject handles
	 * @Return true when Num() == 3, every handle is non-null, and all three identities differ
	 */
	UFUNCTION()
	bool ReadInsertionOrder_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 3
			&& Values[0] != nullptr && Values[1] != nullptr && Values[2] != nullptr
			&& Values[0] != Values[1] && Values[1] != Values[2] && Values[0] != Values[2];
	}

	/**
	 * Out-only: fill an empty &out UObject array with Add of three NewObject temps.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result becomes three distinct non-null UObject handles
	 */
	UFUNCTION()
	void FillIntArrayByAdd_UObject(TArray<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTArrayAddOrderObject::StaticClass(), n"TArrayAddAndOrder_Fill_0", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayAddOrderObject::StaticClass(), n"TArrayAddAndOrder_Fill_1", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayAddOrderObject::StaticClass(), n"TArrayAddAndOrder_Fill_2", true));
	}

	/**
	 * Inout: keep existing UObject elements and Add one NewObject temp at the end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Array received as TArray<UObject>&inout, starts with two distinct handles
	 * @Inputs Values.Num() == 2 with two distinct non-null UObject handles
	 * @Return void; Values.Num() == 3 and Values[2] is a new non-null UObject
	 */
	UFUNCTION()
	void AppendWithAdd_UObject(TArray<UObject>&inout Values)
	{
		Values.Add(NewObject(GetTransientPackage(), UTArrayAddOrderObject::StaticClass(), n"TArrayAddAndOrder_Append", true));
	}
}
