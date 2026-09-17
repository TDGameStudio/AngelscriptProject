/**
 * @version v1
 * @summary Last reads from the end. IsValidIndex is true in [0, Num). Last is the RoundTrip surface; IsValidIndex stays Observe. int is the canonical case; other element types repeat the same four entries with a type suffix.
 * @topic Containers
 */
/**
 * @version root
 * @summary Last reads from the end. IsValidIndex is true in [0, Num). Last is the RoundTrip surface; IsValidIndex stays Observe. int is the canonical case; other element types repeat the same four entries with a type suffix.
 * @topic Baseline
 */
UCLASS()
class UTArrayLastObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Last: Last() is the tail; Last(1) is one from the end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Last
	 * @Inputs [10, 20, 30]; Last(); Last(0); Last(1); Last(2)
	 * @Return true when those reads are 30, 30, 20, 10
	 */
	UFUNCTION()
	bool LastCountsFromTheEnd()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		return Values.Last() == 30
			&& Values.Last(0) == 30
			&& Values.Last(1) == 20
			&& Values.Last(2) == 10;
	}

	/**
	 * In-only: read Last from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [10, 20, 30]
	 * @Return true when Last() == 30, Last(1) == 20, and Last(2) == 10
	 */
	UFUNCTION()
	bool ReadLast(const TArray<int>&in Values)
	{
		return Values.Last() == 30 && Values.Last(1) == 20 && Values.Last(2) == 10;
	}

	/**
	 * Out-only: fill an empty &out array so Last is 30.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [10, 20, 30]
	 */
	UFUNCTION()
	void FillArrayForLast(TArray<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
	}

	/**
	 * Inout: overwrite Last() on an existing [10, 20, 30].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Array received as TArray<int>&inout, starts as [10, 20, 30]
	 * @Inputs Values.Num() == 3 with [10, 20, 30]
	 * @Return void; Values becomes [10, 20, 99]
	 */
	UFUNCTION()
	void OverwriteLast(TArray<int>&inout Values)
	{
		Values.Last() = 99;
	}

	/**
	 * Observe IsValidIndex: empty has no 0; filled range is [0, Num).
	 *
	 * @Kind Observe
	 * @Covers TArray.IsValidIndex
	 * @Inputs Empty TArray<int>; then 6 elements
	 * @Return true when empty rejects 0, then 0 and 5 are valid, 6 and -1 are not
	 */
	UFUNCTION()
	bool IsValidIndexIsHalfOpenRange()
	{
		TArray<int> Values;
		if (Values.IsValidIndex(0) || Values.IsValidIndex(-1))
		{
			return false;
		}

		Values.Add(5);
		Values.Add(10);
		Values.Add(5);
		Values.Add(15);
		Values.Add(5);
		Values.Add(20);
		return Values.IsValidIndex(0)
			&& Values.IsValidIndex(5)
			&& !Values.IsValidIndex(6)
			&& !Values.IsValidIndex(-1);
	}

	/**
	 * Observe Last for float: Last() is the tail; Last(1) is one from the end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Last
	 * @Inputs [a,b,c]; Last(); Last(0); Last(1); Last(2)
	 * @Return true when those reads are c, c, b, a
	 */
	UFUNCTION()
	bool LastCountsFromTheEnd_float()
	{
		TArray<float> Values;
		Values.Add(10.0f);
		Values.Add(20.0f);
		Values.Add(30.0f);
		return Values.Last() == 30.0f && Values.Last(0) == 30.0f && Values.Last(1) == 20.0f && Values.Last(2) == 10.0f;
	}

	/**
	 * In-only: read Last from a const&in float array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs [a,b,c]
	 * @Return true when Last() is c, Last(1) is b, Last(2) is a
	 */
	UFUNCTION()
	bool ReadLast_float(const TArray<float>&in Values)
	{
		return Values.Last() == 30.0f && Values.Last(1) == 20.0f && Values.Last(2) == 10.0f;
	}

	/**
	 * Out-only: fill an empty &out float array so Last is the third value.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result becomes [a,b,c]
	 */
	UFUNCTION()
	void FillArrayForLast_float(TArray<float>&out Result)
	{
		Result.Add(10.0f);
		Result.Add(20.0f);
		Result.Add(30.0f);
	}

	/**
	 * Inout: overwrite Last() on an existing three-element float array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs [a,b,c]
	 * @Return void; Last() becomes the write value
	 */
	UFUNCTION()
	void OverwriteLast_float(TArray<float>&inout Values)
	{
		Values.Last() = 99.0f;
	}

	/**
	 * Observe Last for FString: Last() is the tail; Last(1) is one from the end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Last
	 * @Inputs [a,b,c]; Last(); Last(0); Last(1); Last(2)
	 * @Return true when those reads are c, c, b, a
	 */
	UFUNCTION()
	bool LastCountsFromTheEnd_FString()
	{
		TArray<FString> Values;
		Values.Add("juliet");
		Values.Add("lima");
		Values.Add("mike");
		return Values.Last() == "mike" && Values.Last(0) == "mike" && Values.Last(1) == "lima" && Values.Last(2) == "juliet";
	}

	/**
	 * In-only: read Last from a const&in FString array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs [a,b,c]
	 * @Return true when Last() is c, Last(1) is b, Last(2) is a
	 */
	UFUNCTION()
	bool ReadLast_FString(const TArray<FString>&in Values)
	{
		return Values.Last() == "mike" && Values.Last(1) == "lima" && Values.Last(2) == "juliet";
	}

	/**
	 * Out-only: fill an empty &out FString array so Last is the third value.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result becomes [a,b,c]
	 */
	UFUNCTION()
	void FillArrayForLast_FString(TArray<FString>&out Result)
	{
		Result.Add("juliet");
		Result.Add("lima");
		Result.Add("mike");
	}

	/**
	 * Inout: overwrite Last() on an existing three-element FString array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs [a,b,c]
	 * @Return void; Last() becomes the write value
	 */
	UFUNCTION()
	void OverwriteLast_FString(TArray<FString>&inout Values)
	{
		Values.Last() = "omega";
	}

	/**
	 * Observe Last for FVector: Last() is the tail; Last(1) is one from the end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Last
	 * @Inputs [a,b,c]; Last(); Last(0); Last(1); Last(2)
	 * @Return true when those reads are c, c, b, a
	 */
	UFUNCTION()
	bool LastCountsFromTheEnd_FVector()
	{
		TArray<FVector> Values;
		Values.Add(FVector(2.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 2.0f));
		Values.Add(FVector(2.0f, 2.0f, 0.0f));
		return Values.Last().Equals(FVector(2.0f, 2.0f, 0.0f)) && Values.Last(0).Equals(FVector(2.0f, 2.0f, 0.0f)) && Values.Last(1).Equals(FVector(0.0f, 0.0f, 2.0f)) && Values.Last(2).Equals(FVector(2.0f, 0.0f, 0.0f));
	}

	/**
	 * In-only: read Last from a const&in FVector array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs [a,b,c]
	 * @Return true when Last() is c, Last(1) is b, Last(2) is a
	 */
	UFUNCTION()
	bool ReadLast_FVector(const TArray<FVector>&in Values)
	{
		return Values.Last().Equals(FVector(2.0f, 2.0f, 0.0f)) && Values.Last(1).Equals(FVector(0.0f, 0.0f, 2.0f)) && Values.Last(2).Equals(FVector(2.0f, 0.0f, 0.0f));
	}

	/**
	 * Out-only: fill an empty &out FVector array so Last is the third value.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result becomes [a,b,c]
	 */
	UFUNCTION()
	void FillArrayForLast_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(2.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 2.0f));
		Result.Add(FVector(2.0f, 2.0f, 0.0f));
	}

	/**
	 * Inout: overwrite Last() on an existing three-element FVector array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs [a,b,c]
	 * @Return void; Last() becomes the write value
	 */
	UFUNCTION()
	void OverwriteLast_FVector(TArray<FVector>&inout Values)
	{
		Values.Last() = FVector(9.0f, 9.0f, 9.0f);
	}

	/**
	 * Observe Last for bool: Last() is the tail; Last(1) is one from the end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Last
	 * @Inputs [false, true, false]
	 * @Return true when Last() is false, Last(1) is true, Last(2) is false
	 */
	UFUNCTION()
	bool LastCountsFromTheEnd_bool()
	{
		TArray<bool> Values;
		Values.Add(false);
		Values.Add(true);
		Values.Add(false);
		return Values.Last() == false && Values.Last(0) == false && Values.Last(1) == true && Values.Last(2) == false;
	}

	/**
	 * In-only: read Last from a const&in bool array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs [false, true, false]
	 * @Return true when Last() is false and Last(1) is true
	 */
	UFUNCTION()
	bool ReadLast_bool(const TArray<bool>&in Values)
	{
		return Values.Last() == false && Values.Last(1) == true && Values.Last(2) == false;
	}

	/**
	 * Out-only: fill an empty &out bool array so Last is false.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result becomes [false, true, false]
	 */
	UFUNCTION()
	void FillArrayForLast_bool(TArray<bool>&out Result)
	{
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
	}

	/**
	 * Inout: overwrite Last() on an existing [false, true, false].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs [false, true, false]
	 * @Return void; Last() becomes true
	 */
	UFUNCTION()
	void OverwriteLast_bool(TArray<bool>&inout Values)
	{
		Values.Last() = true;
	}

	/**
	 * Observe Last for UObject handles: Last() is the tail; Last(1) is one from the end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Last
	 * @Inputs [A,B,C]
	 * @Return true when Last() is C, Last(1) is B, Last(2) is A
	 */
	UFUNCTION()
	bool LastCountsFromTheEnd_UObject()
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayLastObject::StaticClass(), n"TArrayLast_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayLastObject::StaticClass(), n"TArrayLast_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayLastObject::StaticClass(), n"TArrayLast_C", true);
		if (A == nullptr || B == nullptr || C == nullptr)
		{
			return false;
		}
		TArray<UObject> Values;
		Values.Add(A);
		Values.Add(B);
		Values.Add(C);
		return Values.Last() == C && Values.Last(0) == C && Values.Last(1) == B && Values.Last(2) == A;
	}

	/**
	 * In-only: read Last from a const&in UObject array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs three distinct handles
	 * @Return true when Last() equals Values[2]
	 */
	UFUNCTION()
	bool ReadLast_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 3 && Values.Last() == Values[2] && Values.Last(1) == Values[1] && Values.Last(2) == Values[0];
	}

	/**
	 * Out-only: fill an empty &out UObject array so Last is the third handle.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillArrayForLast_UObject(TArray<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTArrayLastObject::StaticClass(), n"TArrayLast_Fill_A", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayLastObject::StaticClass(), n"TArrayLast_Fill_B", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayLastObject::StaticClass(), n"TArrayLast_Fill_C", true));
	}

	/**
	 * Inout: overwrite Last() on an existing three-handle UObject array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Last
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Num() == 3
	 * @Return void; Last() is a new handle
	 */
	UFUNCTION()
	void OverwriteLast_UObject(TArray<UObject>&inout Values)
	{
		Values.Last() = NewObject(GetTransientPackage(), UTArrayLastObject::StaticClass(), n"TArrayLast_Wrote", true);
	}

}
/** @end */
