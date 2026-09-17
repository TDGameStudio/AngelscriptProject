/**
 * @version v1
 * @summary Swap exchanges two valid indices. Out of range throws, not this file. Exchange is observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types repeat the same four entries.
 * @topic Containers
 */
/**
 * @version root
 * @summary Swap exchanges two valid indices. Out of range throws, not this file. Exchange is observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types repeat the same four entries.
 * @topic Baseline
 */
UCLASS()
class UTArraySwapObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Swap of first and last, then two middle slots.
	 *
	 * @Kind Observe
	 * @Covers TArray.Swap
	 * @Inputs [10, 20, 30, 40, 50]; Swap(0, 4); Swap(1, 2)
	 * @Return true when the array is [50, 30, 20, 40, 10]
	 */
	UFUNCTION()
	bool SwapExchangesIndexedSlots()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		Values.Add(40);
		Values.Add(50);
		Values.Swap(0, 4);
		if (Values[0] != 50 || Values[4] != 10 || Values[1] != 20)
		{
			return false;
		}

		Values.Swap(1, 2);
		return Values[0] == 50 && Values[1] == 30 && Values[2] == 20
			&& Values[3] == 40 && Values[4] == 10;
	}

	/**
	 * In-only: read swapped order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [50, 30, 20, 40, 10]
	 * @Return true when Num() == 5 and elements are [50, 30, 20, 40, 10]
	 */
	UFUNCTION()
	bool ReadSwappedOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 5
			&& Values[0] == 50 && Values[1] == 30 && Values[2] == 20
			&& Values[3] == 40 && Values[4] == 10;
	}

	/**
	 * Out-only: fill an empty &out array then Swap first/last and two middle slots.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [50, 30, 20, 40, 10]
	 */
	UFUNCTION()
	void FillArrayBySwap(TArray<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Result.Add(40);
		Result.Add(50);
		Result.Swap(0, 4);
		Result.Swap(1, 2);
	}

	/**
	 * Inout: Swap first and last of an existing [10, 20, 30, 40, 50].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Array received as TArray<int>&inout, starts as [10, 20, 30, 40, 50]
	 * @Inputs Values.Num() == 5 with [10, 20, 30, 40, 50]
	 * @Return void; Values becomes [50, 20, 30, 40, 10]
	 */
	UFUNCTION()
	void SwapEnds(TArray<int>&inout Values)
	{
		Values.Swap(0, 4);
	}

	/**
	 * Observe Swap for float: first/last then two middle slots.
	 *
	 * @Kind Observe
	 * @Covers TArray.Swap
	 * @Inputs five elements; Swap(0,4); Swap(1,2)
	 * @Return true when order is swapped
	 */
	UFUNCTION()
	bool SwapExchangesIndexedSlots_float()
	{
		TArray<float> Values;
		Values.Add(10.0f);
		Values.Add(20.0f);
		Values.Add(30.0f);
		Values.Add(40.0f);
		Values.Add(50.0f);
		Values.Swap(0, 4);
		if (Values[0] != 50.0f || Values[4] != 10.0f || Values[1] != 20.0f)
		{
			return false;
		}
		Values.Swap(1, 2);
		return Values[0] == 50.0f && Values[1] == 30.0f && Values[2] == 20.0f && Values[3] == 40.0f && Values[4] == 10.0f;
	}

	/**
	 * In-only: read swapped float order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs fully swapped five-element order
	 * @Return true when order matches both swaps
	 */
	UFUNCTION()
	bool ReadSwappedOrder_float(const TArray<float>&in Values)
	{
		return Values.Num() == 5 && Values[0] == 50.0f && Values[1] == 30.0f && Values[2] == 20.0f
			&& Values[3] == 40.0f && Values[4] == 10.0f;
	}

	/**
	 * Out-only: fill an empty &out float array then Swap first/last and two middle slots.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result is fully swapped
	 */
	UFUNCTION()
	void FillArrayBySwap_float(TArray<float>&out Result)
	{
		Result.Add(10.0f);
		Result.Add(20.0f);
		Result.Add(30.0f);
		Result.Add(40.0f);
		Result.Add(50.0f);
		Result.Swap(0, 4);
		Result.Swap(1, 2);
	}

	/**
	 * Inout: Swap first and last of an existing five-element float array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs five elements
	 * @Return void; first and last swapped
	 */
	UFUNCTION()
	void SwapEnds_float(TArray<float>&inout Values)
	{
		Values.Swap(0, 4);
	}

	/**
	 * Observe Swap for FString: first/last then two middle slots.
	 *
	 * @Kind Observe
	 * @Covers TArray.Swap
	 * @Inputs five elements; Swap(0,4); Swap(1,2)
	 * @Return true when order is swapped
	 */
	UFUNCTION()
	bool SwapExchangesIndexedSlots_FString()
	{
		TArray<FString> Values;
		Values.Add("juliet");
		Values.Add("lima");
		Values.Add("mike");
		Values.Add("oscar");
		Values.Add("papa");
		Values.Swap(0, 4);
		if (Values[0] != "papa" || Values[4] != "juliet" || Values[1] != "lima")
		{
			return false;
		}
		Values.Swap(1, 2);
		return Values[0] == "papa" && Values[1] == "mike" && Values[2] == "lima" && Values[3] == "oscar" && Values[4] == "juliet";
	}

	/**
	 * In-only: read swapped FString order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs fully swapped five-element order
	 * @Return true when order matches both swaps
	 */
	UFUNCTION()
	bool ReadSwappedOrder_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 5 && Values[0] == "papa" && Values[1] == "mike" && Values[2] == "lima"
			&& Values[3] == "oscar" && Values[4] == "juliet";
	}

	/**
	 * Out-only: fill an empty &out FString array then Swap first/last and two middle slots.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result is fully swapped
	 */
	UFUNCTION()
	void FillArrayBySwap_FString(TArray<FString>&out Result)
	{
		Result.Add("juliet");
		Result.Add("lima");
		Result.Add("mike");
		Result.Add("oscar");
		Result.Add("papa");
		Result.Swap(0, 4);
		Result.Swap(1, 2);
	}

	/**
	 * Inout: Swap first and last of an existing five-element FString array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs five elements
	 * @Return void; first and last swapped
	 */
	UFUNCTION()
	void SwapEnds_FString(TArray<FString>&inout Values)
	{
		Values.Swap(0, 4);
	}

	/**
	 * Observe Swap for FVector: first/last then two middle slots.
	 *
	 * @Kind Observe
	 * @Covers TArray.Swap
	 * @Inputs five elements; Swap(0,4); Swap(1,2)
	 * @Return true when order is swapped
	 */
	UFUNCTION()
	bool SwapExchangesIndexedSlots_FVector()
	{
		TArray<FVector> Values;
		Values.Add(FVector(2.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 2.0f));
		Values.Add(FVector(2.0f, 2.0f, 0.0f));
		Values.Add(FVector(2.0f, 0.0f, 2.0f));
		Values.Add(FVector(2.0f, 2.0f, 2.0f));
		Values.Swap(0, 4);
		if (!Values[0].Equals(FVector(2.0f, 2.0f, 2.0f)) || !Values[4].Equals(FVector(2.0f, 0.0f, 0.0f)) || !Values[1].Equals(FVector(0.0f, 0.0f, 2.0f)))
		{
			return false;
		}
		Values.Swap(1, 2);
		return Values[0].Equals(FVector(2.0f, 2.0f, 2.0f)) && Values[1].Equals(FVector(2.0f, 2.0f, 0.0f)) && Values[2].Equals(FVector(0.0f, 0.0f, 2.0f)) && Values[3].Equals(FVector(2.0f, 0.0f, 2.0f)) && Values[4].Equals(FVector(2.0f, 0.0f, 0.0f));
	}

	/**
	 * In-only: read swapped FVector order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs fully swapped five-element order
	 * @Return true when order matches both swaps
	 */
	UFUNCTION()
	bool ReadSwappedOrder_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 5 && Values[0].Equals(FVector(2.0f, 2.0f, 2.0f)) && Values[1].Equals(FVector(2.0f, 2.0f, 0.0f)) && Values[2].Equals(FVector(0.0f, 0.0f, 2.0f))
			&& Values[3].Equals(FVector(2.0f, 0.0f, 2.0f)) && Values[4].Equals(FVector(2.0f, 0.0f, 0.0f));
	}

	/**
	 * Out-only: fill an empty &out FVector array then Swap first/last and two middle slots.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result is fully swapped
	 */
	UFUNCTION()
	void FillArrayBySwap_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(2.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 2.0f));
		Result.Add(FVector(2.0f, 2.0f, 0.0f));
		Result.Add(FVector(2.0f, 0.0f, 2.0f));
		Result.Add(FVector(2.0f, 2.0f, 2.0f));
		Result.Swap(0, 4);
		Result.Swap(1, 2);
	}

	/**
	 * Inout: Swap first and last of an existing five-element FVector array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs five elements
	 * @Return void; first and last swapped
	 */
	UFUNCTION()
	void SwapEnds_FVector(TArray<FVector>&inout Values)
	{
		Values.Swap(0, 4);
	}

	/**
	 * Observe Swap for bool: first/last then two middle slots.
	 *
	 * @Kind Observe
	 * @Covers TArray.Swap
	 * @Inputs [false, true, false, true, true]; Swap(0,4); Swap(1,2)
	 * @Return true when the array is [true, false, true, true, false]
	 */
	UFUNCTION()
	bool SwapExchangesIndexedSlots_bool()
	{
		TArray<bool> Values;
		Values.Add(false);
		Values.Add(true);
		Values.Add(false);
		Values.Add(true);
		Values.Add(true);
		Values.Swap(0, 4);
		if (Values[0] != true || Values[4] != false || Values[1] != true)
		{
			return false;
		}
		Values.Swap(1, 2);
		return Values[0] == true && Values[1] == false && Values[2] == true && Values[3] == true && Values[4] == false;
	}

	/**
	 * In-only: read swapped bool order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs [true, false, true, true, false]
	 * @Return true when order matches both swaps
	 */
	UFUNCTION()
	bool ReadSwappedOrder_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 5 && Values[0] == true && Values[1] == false && Values[2] == true && Values[3] == true && Values[4] == false;
	}

	/**
	 * Out-only: fill an empty &out bool array then Swap.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result is fully swapped
	 */
	UFUNCTION()
	void FillArrayBySwap_bool(TArray<bool>&out Result)
	{
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
		Result.Add(true);
		Result.Add(true);
		Result.Swap(0, 4);
		Result.Swap(1, 2);
	}

	/**
	 * Inout: Swap first and last of [false, true, false, true, true].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs five elements
	 * @Return void; first and last swapped
	 */
	UFUNCTION()
	void SwapEnds_bool(TArray<bool>&inout Values)
	{
		Values.Swap(0, 4);
	}

	/**
	 * Observe Swap for UObject handles: first/last then two middle slots.
	 *
	 * @Kind Observe
	 * @Covers TArray.Swap
	 * @Inputs five temps; Swap(0,4); Swap(1,2)
	 * @Return true when identities swapped
	 */
	UFUNCTION()
	bool SwapExchangesIndexedSlots_UObject()
	{
		UObject A = NewObject(GetTransientPackage(), UTArraySwapObject::StaticClass(), n"TArraySwap_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArraySwapObject::StaticClass(), n"TArraySwap_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArraySwapObject::StaticClass(), n"TArraySwap_C", true);
		UObject D = NewObject(GetTransientPackage(), UTArraySwapObject::StaticClass(), n"TArraySwap_D", true);
		UObject E = NewObject(GetTransientPackage(), UTArraySwapObject::StaticClass(), n"TArraySwap_E", true);
		if (A == nullptr || B == nullptr || C == nullptr || D == nullptr || E == nullptr)
		{
			return false;
		}
		TArray<UObject> Values;
		Values.Add(A);
		Values.Add(B);
		Values.Add(C);
		Values.Add(D);
		Values.Add(E);
		Values.Swap(0, 4);
		if (Values[0] != E || Values[4] != A || Values[1] != B)
		{
			return false;
		}
		Values.Swap(1, 2);
		return Values[0] == E && Values[1] == C && Values[2] == B && Values[3] == D && Values[4] == A;
	}

	/**
	 * In-only: read swapped UObject order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs five distinct handles
	 * @Return true when Num() == 5
	 */
	UFUNCTION()
	bool ReadSwappedOrder_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 5;
	}

	/**
	 * Out-only: fill an empty &out UObject array then Swap.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 5 after swaps
	 */
	UFUNCTION()
	void FillArrayBySwap_UObject(TArray<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTArraySwapObject::StaticClass(), n"TArraySwap_Fill_A", true));
		Result.Add(NewObject(GetTransientPackage(), UTArraySwapObject::StaticClass(), n"TArraySwap_Fill_B", true));
		Result.Add(NewObject(GetTransientPackage(), UTArraySwapObject::StaticClass(), n"TArraySwap_Fill_C", true));
		Result.Add(NewObject(GetTransientPackage(), UTArraySwapObject::StaticClass(), n"TArraySwap_Fill_D", true));
		Result.Add(NewObject(GetTransientPackage(), UTArraySwapObject::StaticClass(), n"TArraySwap_Fill_E", true));
		Result.Swap(0, 4);
		Result.Swap(1, 2);
	}

	/**
	 * Inout: Swap first and last of a five-handle UObject array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Swap
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Num() == 5
	 * @Return void; first and last swapped
	 */
	UFUNCTION()
	void SwapEnds_UObject(TArray<UObject>&inout Values)
	{
		Values.Swap(0, 4);
	}

}
/** @end */
