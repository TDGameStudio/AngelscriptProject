/**
 * @version v1
 * @summary Append concatenates another array at the end and keeps existing order. Concatenation is observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types repeat the same four.
 * @topic Containers
 */
/**
 * @version root
 * @summary Append concatenates another array at the end and keeps existing order. Concatenation is observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types repeat the same four.
 * @topic Baseline
 */
UCLASS()
class UTArrayAppendObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Append: [1,2,3] + [4,5], then append empty is a no-op.
	 *
	 * @Kind Observe
	 * @Covers TArray.Append
	 * @Inputs TArray<int> [1,2,3] Append [4,5]; Append empty
	 * @Return true when the array is [1,2,3,4,5] and empty Append leaves Num 5
	 */
	UFUNCTION()
	bool AppendConcatenatesThenEmptyIsNoOp()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		TArray<int> Tail;
		Tail.Add(4);
		Tail.Add(5);
		Values.Append(Tail);
		if (Values.Num() != 5
			|| Values[0] != 1 || Values[1] != 2 || Values[2] != 3
			|| Values[3] != 4 || Values[4] != 5)
		{
			return false;
		}

		TArray<int> Empty;
		Values.Append(Empty);
		return Values.Num() == 5 && Values[4] == 5;
	}

	/**
	 * In-only: read Appended order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [1, 2, 3, 4, 5]
	 * @Return true when Num() == 5 and elements are [1, 2, 3, 4, 5]
	 */
	UFUNCTION()
	bool ReadAppendedOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 5
			&& Values[0] == 1 && Values[1] == 2 && Values[2] == 3
			&& Values[3] == 4 && Values[4] == 5;
	}

	/**
	 * Out-only: fill an empty &out array then Append a tail.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [1, 2, 3, 4, 5]
	 */
	UFUNCTION()
	void FillArrayByAppend(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
		TArray<int> Tail;
		Tail.Add(4);
		Tail.Add(5);
		Result.Append(Tail);
	}

	/**
	 * Inout: Append [4, 5] onto an existing [1, 2, 3].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Array received as TArray<int>&inout, starts as [1, 2, 3]
	 * @Inputs Values.Num() == 3 with [1, 2, 3]
	 * @Return void; Values becomes [1, 2, 3, 4, 5]
	 */
	UFUNCTION()
	void AppendTail(TArray<int>&inout Values)
	{
		TArray<int> Tail;
		Tail.Add(4);
		Tail.Add(5);
		Values.Append(Tail);
	}

	/**
	 * Append onto an empty array copies the other sequence.
	 *
	 * @Kind Observe
	 * @Covers TArray.Append
	 * @Inputs Empty TArray<int>; Append [1, 2]
	 * @Return true when the array is [1, 2]
	 */
	UFUNCTION()
	bool AppendWhenSelfEmptyEqualsOther()
	{
		TArray<int> Values;
		TArray<int> Other;
		Other.Add(1);
		Other.Add(2);
		Values.Append(Other);
		return Values.Num() == 2 && Values[0] == 1 && Values[1] == 2;
	}

	/**
	 * Observe Append for float: concatenate then empty is a no-op.
	 *
	 * @Kind Observe
	 * @Covers TArray.Append
	 * @Inputs [1,2,3]+[4,5] analogs; Append empty
	 * @Return true when order is five elements and empty Append is a no-op
	 */
	UFUNCTION()
	bool AppendConcatenatesThenEmptyIsNoOp_float()
	{
		TArray<float> Values;
		Values.Add(1.0f);
		Values.Add(2.0f);
		Values.Add(3.0f);
		TArray<float> Tail;
		Tail.Add(4.0f);
		Tail.Add(5.0f);
		Values.Append(Tail);
		if (Values.Num() != 5 || Values[0] != 1.0f || Values[4] != 5.0f)
		{
			return false;
		}
		TArray<float> Empty;
		Values.Append(Empty);
		return Values.Num() == 5 && Values[4] == 5.0f;
	}

	/**
	 * In-only: read Appended float order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs five-element appended order
	 * @Return true when Num() == 5 and order matches
	 */
	UFUNCTION()
	bool ReadAppendedOrder_float(const TArray<float>&in Values)
	{
		return Values.Num() == 5 && Values[0] == 1.0f && Values[1] == 2.0f && Values[2] == 3.0f
			&& Values[3] == 4.0f && Values[4] == 5.0f;
	}

	/**
	 * Out-only: fill an empty &out float array then Append a tail.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result is the five-element appended order
	 */
	UFUNCTION()
	void FillArrayByAppend_float(TArray<float>&out Result)
	{
		Result.Add(1.0f);
		Result.Add(2.0f);
		Result.Add(3.0f);
		TArray<float> Tail;
		Tail.Add(4.0f);
		Tail.Add(5.0f);
		Result.Append(Tail);
	}

	/**
	 * Inout: Append a two-element tail onto an existing three-element float array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs three elements
	 * @Return void; Values.Num() becomes 5
	 */
	UFUNCTION()
	void AppendTail_float(TArray<float>&inout Values)
	{
		TArray<float> Tail;
		Tail.Add(4.0f);
		Tail.Add(5.0f);
		Values.Append(Tail);
	}

	/**
	 * Observe Append for FString: concatenate then empty is a no-op.
	 *
	 * @Kind Observe
	 * @Covers TArray.Append
	 * @Inputs [1,2,3]+[4,5] analogs; Append empty
	 * @Return true when order is five elements and empty Append is a no-op
	 */
	UFUNCTION()
	bool AppendConcatenatesThenEmptyIsNoOp_FString()
	{
		TArray<FString> Values;
		Values.Add("alpha");
		Values.Add("beta");
		Values.Add("gamma");
		TArray<FString> Tail;
		Tail.Add("delta");
		Tail.Add("echo");
		Values.Append(Tail);
		if (Values.Num() != 5 || Values[0] != "alpha" || Values[4] != "echo")
		{
			return false;
		}
		TArray<FString> Empty;
		Values.Append(Empty);
		return Values.Num() == 5 && Values[4] == "echo";
	}

	/**
	 * In-only: read Appended FString order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs five-element appended order
	 * @Return true when Num() == 5 and order matches
	 */
	UFUNCTION()
	bool ReadAppendedOrder_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 5 && Values[0] == "alpha" && Values[1] == "beta" && Values[2] == "gamma"
			&& Values[3] == "delta" && Values[4] == "echo";
	}

	/**
	 * Out-only: fill an empty &out FString array then Append a tail.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result is the five-element appended order
	 */
	UFUNCTION()
	void FillArrayByAppend_FString(TArray<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
		TArray<FString> Tail;
		Tail.Add("delta");
		Tail.Add("echo");
		Result.Append(Tail);
	}

	/**
	 * Inout: Append a two-element tail onto an existing three-element FString array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs three elements
	 * @Return void; Values.Num() becomes 5
	 */
	UFUNCTION()
	void AppendTail_FString(TArray<FString>&inout Values)
	{
		TArray<FString> Tail;
		Tail.Add("delta");
		Tail.Add("echo");
		Values.Append(Tail);
	}

	/**
	 * Observe Append for FVector: concatenate then empty is a no-op.
	 *
	 * @Kind Observe
	 * @Covers TArray.Append
	 * @Inputs [1,2,3]+[4,5] analogs; Append empty
	 * @Return true when order is five elements and empty Append is a no-op
	 */
	UFUNCTION()
	bool AppendConcatenatesThenEmptyIsNoOp_FVector()
	{
		TArray<FVector> Values;
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
		TArray<FVector> Tail;
		Tail.Add(FVector(1.0f, 1.0f, 0.0f));
		Tail.Add(FVector(0.0f, 1.0f, 1.0f));
		Values.Append(Tail);
		if (Values.Num() != 5 || !Values[0].Equals(FVector(1.0f, 0.0f, 0.0f)) || !Values[4].Equals(FVector(0.0f, 1.0f, 1.0f)))
		{
			return false;
		}
		TArray<FVector> Empty;
		Values.Append(Empty);
		return Values.Num() == 5 && Values[4].Equals(FVector(0.0f, 1.0f, 1.0f));
	}

	/**
	 * In-only: read Appended FVector order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs five-element appended order
	 * @Return true when Num() == 5 and order matches
	 */
	UFUNCTION()
	bool ReadAppendedOrder_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 5 && Values[0].Equals(FVector(1.0f, 0.0f, 0.0f)) && Values[1].Equals(FVector(0.0f, 1.0f, 0.0f)) && Values[2].Equals(FVector(0.0f, 0.0f, 1.0f))
			&& Values[3].Equals(FVector(1.0f, 1.0f, 0.0f)) && Values[4].Equals(FVector(0.0f, 1.0f, 1.0f));
	}

	/**
	 * Out-only: fill an empty &out FVector array then Append a tail.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result is the five-element appended order
	 */
	UFUNCTION()
	void FillArrayByAppend_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
		TArray<FVector> Tail;
		Tail.Add(FVector(1.0f, 1.0f, 0.0f));
		Tail.Add(FVector(0.0f, 1.0f, 1.0f));
		Result.Append(Tail);
	}

	/**
	 * Inout: Append a two-element tail onto an existing three-element FVector array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs three elements
	 * @Return void; Values.Num() becomes 5
	 */
	UFUNCTION()
	void AppendTail_FVector(TArray<FVector>&inout Values)
	{
		TArray<FVector> Tail;
		Tail.Add(FVector(1.0f, 1.0f, 0.0f));
		Tail.Add(FVector(0.0f, 1.0f, 1.0f));
		Values.Append(Tail);
	}

	/**
	 * Observe Append for bool: concatenate then empty is a no-op.
	 *
	 * @Kind Observe
	 * @Covers TArray.Append
	 * @Inputs [false, true, false] + [true, false]
	 * @Return true when Num is 5 and empty Append is a no-op
	 */
	UFUNCTION()
	bool AppendConcatenatesThenEmptyIsNoOp_bool()
	{
		TArray<bool> Values;
		Values.Add(false);
		Values.Add(true);
		Values.Add(false);
		TArray<bool> Tail;
		Tail.Add(true);
		Tail.Add(false);
		Values.Append(Tail);
		if (Values.Num() != 5 || Values[0] != false || Values[4] != false)
		{
			return false;
		}
		TArray<bool> Empty;
		Values.Append(Empty);
		return Values.Num() == 5 && Values[4] == false;
	}

	/**
	 * In-only: read Appended bool order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs Num() == 5
	 * @Return true when Num() == 5
	 */
	UFUNCTION()
	bool ReadAppendedOrder_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 5;
	}

	/**
	 * Out-only: fill an empty &out bool array then Append a tail.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result.Num() == 5
	 */
	UFUNCTION()
	void FillArrayByAppend_bool(TArray<bool>&out Result)
	{
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
		TArray<bool> Tail;
		Tail.Add(true);
		Tail.Add(false);
		Result.Append(Tail);
	}

	/**
	 * Inout: Append [true, false] onto [false, true, false].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs Num() == 3
	 * @Return void; Values.Num() == 5
	 */
	UFUNCTION()
	void AppendTail_bool(TArray<bool>&inout Values)
	{
		TArray<bool> Tail;
		Tail.Add(true);
		Tail.Add(false);
		Values.Append(Tail);
	}

	/**
	 * Observe Append for UObject handles: concatenate then empty is a no-op.
	 *
	 * @Kind Observe
	 * @Covers TArray.Append
	 * @Inputs three handles Append two more
	 * @Return true when Num is 5
	 */
	UFUNCTION()
	bool AppendConcatenatesThenEmptyIsNoOp_UObject()
	{
		TArray<UObject> Values;
		Values.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_A", true));
		Values.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_B", true));
		Values.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_C", true));
		TArray<UObject> Tail;
		Tail.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_D", true));
		Tail.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_E", true));
		Values.Append(Tail);
		if (Values.Num() != 5)
		{
			return false;
		}
		TArray<UObject> Empty;
		Values.Append(Empty);
		return Values.Num() == 5;
	}

	/**
	 * In-only: read Appended UObject order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs Num() == 5
	 * @Return true when Num() == 5
	 */
	UFUNCTION()
	bool ReadAppendedOrder_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 5;
	}

	/**
	 * Out-only: fill an empty &out UObject array then Append a tail.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 5
	 */
	UFUNCTION()
	void FillArrayByAppend_UObject(TArray<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_Fill_A", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_Fill_B", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_Fill_C", true));
		TArray<UObject> Tail;
		Tail.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_Fill_D", true));
		Tail.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_Fill_E", true));
		Result.Append(Tail);
	}

	/**
	 * Inout: Append two handles onto an existing three-handle array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Num() == 3
	 * @Return void; Values.Num() == 5
	 */
	UFUNCTION()
	void AppendTail_UObject(TArray<UObject>&inout Values)
	{
		TArray<UObject> Tail;
		Tail.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_Inout_D", true));
		Tail.Add(NewObject(GetTransientPackage(), UTArrayAppendObject::StaticClass(), n"TArrayAppend_Inout_E", true));
		Values.Append(Tail);
	}

}
/** @end */
