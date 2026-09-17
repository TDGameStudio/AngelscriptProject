/**
 * @version v1
 * @summary Insert puts a value at an index and shifts later elements right. Index may be Num() (append). Out of range throws, not this file. Placement is observed locally, then through UFUNCTION in, out, and inout. int is the.
 * @topic Containers
 */
/**
 * @version root
 * @summary Insert puts a value at an index and shifts later elements right. Index may be Num() (append). Out of range throws, not this file. Placement is observed locally, then through UFUNCTION in, out, and inout. int is the.
 * @topic Baseline
 */
UCLASS()
class UTArrayInsertObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Insert: middle, head, then end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Insert
	 * @Inputs [10, 20, 30]; Insert(15, 1); Insert(5, 0); Insert(35, Num())
	 * @Return true when the array is [5, 10, 15, 20, 30, 35]
	 */
	UFUNCTION()
	bool InsertAtHeadMiddleAndEnd()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);

		Values.Insert(15, 1);
		if (Values.Num() != 4 || Values[0] != 10 || Values[1] != 15 || Values[2] != 20 || Values[3] != 30)
		{
			return false;
		}

		Values.Insert(5, 0);
		if (Values[0] != 5 || Values[1] != 10)
		{
			return false;
		}

		Values.Insert(35, Values.Num());
		return Values.Num() == 6
			&& Values[0] == 5 && Values[1] == 10 && Values[2] == 15
			&& Values[3] == 20 && Values[4] == 30 && Values[5] == 35;
	}

	/**
	 * In-only: read Insert order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [5, 10, 15, 20, 30, 35]
	 * @Return true when Num() == 6 and elements are [5, 10, 15, 20, 30, 35]
	 */
	UFUNCTION()
	bool ReadInsertOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 6
			&& Values[0] == 5 && Values[1] == 10 && Values[2] == 15
			&& Values[3] == 20 && Values[4] == 30 && Values[5] == 35;
	}

	/**
	 * Out-only: fill an empty &out array with Insert at head, middle, and end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [5, 10, 15, 20, 30, 35]
	 */
	UFUNCTION()
	void FillArrayByInsert(TArray<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Result.Insert(15, 1);
		Result.Insert(5, 0);
		Result.Insert(35, Result.Num());
	}

	/**
	 * Inout: Insert 15 at index 1 into an existing [10, 20, 30].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Array received as TArray<int>&inout, starts as [10, 20, 30]
	 * @Inputs Values.Num() == 3 with [10, 20, 30]
	 * @Return void; Values becomes [10, 15, 20, 30]
	 */
	UFUNCTION()
	void InsertInto(TArray<int>&inout Values)
	{
		Values.Insert(15, 1);
	}

	/**
	 * Observe Insert for float: middle, head, then end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Insert
	 * @Inputs [10,20,30] analogs; Insert middle/head/end
	 * @Return true when six-element order matches
	 */
	UFUNCTION()
	bool InsertAtHeadMiddleAndEnd_float()
	{
		TArray<float> Values;
		Values.Add(10.0f);
		Values.Add(20.0f);
		Values.Add(30.0f);
		Values.Insert(15.0f, 1);
		if (Values.Num() != 4 || Values[0] != 10.0f || Values[1] != 15.0f || Values[2] != 20.0f || Values[3] != 30.0f)
		{
			return false;
		}
		Values.Insert(5.0f, 0);
		if (Values[0] != 5.0f || Values[1] != 10.0f)
		{
			return false;
		}
		Values.Insert(35.0f, Values.Num());
		return Values.Num() == 6 && Values[0] == 5.0f && Values[1] == 10.0f && Values[2] == 15.0f
			&& Values[3] == 20.0f && Values[4] == 30.0f && Values[5] == 35.0f;
	}

	/**
	 * In-only: read Insert order from a const&in float array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs six-element inserted order
	 * @Return true when Num() == 6 and order matches
	 */
	UFUNCTION()
	bool ReadInsertOrder_float(const TArray<float>&in Values)
	{
		return Values.Num() == 6 && Values[0] == 5.0f && Values[1] == 10.0f && Values[2] == 15.0f
			&& Values[3] == 20.0f && Values[4] == 30.0f && Values[5] == 35.0f;
	}

	/**
	 * Out-only: fill an empty &out float array with Insert at head, middle, and end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result is the six-element inserted order
	 */
	UFUNCTION()
	void FillArrayByInsert_float(TArray<float>&out Result)
	{
		Result.Add(10.0f);
		Result.Add(20.0f);
		Result.Add(30.0f);
		Result.Insert(15.0f, 1);
		Result.Insert(5.0f, 0);
		Result.Insert(35.0f, Result.Num());
	}

	/**
	 * Inout: Insert at index 1 into an existing three-element float array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs three elements
	 * @Return void; middle value inserted at index 1
	 */
	UFUNCTION()
	void InsertInto_float(TArray<float>&inout Values)
	{
		Values.Insert(15.0f, 1);
	}

	/**
	 * Observe Insert for FString: middle, head, then end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Insert
	 * @Inputs [10,20,30] analogs; Insert middle/head/end
	 * @Return true when six-element order matches
	 */
	UFUNCTION()
	bool InsertAtHeadMiddleAndEnd_FString()
	{
		TArray<FString> Values;
		Values.Add("juliet");
		Values.Add("lima");
		Values.Add("mike");
		Values.Insert("kilo", 1);
		if (Values.Num() != 4 || Values[0] != "juliet" || Values[1] != "kilo" || Values[2] != "lima" || Values[3] != "mike")
		{
			return false;
		}
		Values.Insert("echo", 0);
		if (Values[0] != "echo" || Values[1] != "juliet")
		{
			return false;
		}
		Values.Insert("november", Values.Num());
		return Values.Num() == 6 && Values[0] == "echo" && Values[1] == "juliet" && Values[2] == "kilo"
			&& Values[3] == "lima" && Values[4] == "mike" && Values[5] == "november";
	}

	/**
	 * In-only: read Insert order from a const&in FString array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs six-element inserted order
	 * @Return true when Num() == 6 and order matches
	 */
	UFUNCTION()
	bool ReadInsertOrder_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 6 && Values[0] == "echo" && Values[1] == "juliet" && Values[2] == "kilo"
			&& Values[3] == "lima" && Values[4] == "mike" && Values[5] == "november";
	}

	/**
	 * Out-only: fill an empty &out FString array with Insert at head, middle, and end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result is the six-element inserted order
	 */
	UFUNCTION()
	void FillArrayByInsert_FString(TArray<FString>&out Result)
	{
		Result.Add("juliet");
		Result.Add("lima");
		Result.Add("mike");
		Result.Insert("kilo", 1);
		Result.Insert("echo", 0);
		Result.Insert("november", Result.Num());
	}

	/**
	 * Inout: Insert at index 1 into an existing three-element FString array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs three elements
	 * @Return void; middle value inserted at index 1
	 */
	UFUNCTION()
	void InsertInto_FString(TArray<FString>&inout Values)
	{
		Values.Insert("kilo", 1);
	}

	/**
	 * Observe Insert for FVector: middle, head, then end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Insert
	 * @Inputs [10,20,30] analogs; Insert middle/head/end
	 * @Return true when six-element order matches
	 */
	UFUNCTION()
	bool InsertAtHeadMiddleAndEnd_FVector()
	{
		TArray<FVector> Values;
		Values.Add(FVector(2.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 2.0f));
		Values.Add(FVector(2.0f, 2.0f, 0.0f));
		Values.Insert(FVector(0.0f, 2.0f, 0.0f), 1);
		if (Values.Num() != 4 || !Values[0].Equals(FVector(2.0f, 0.0f, 0.0f)) || !Values[1].Equals(FVector(0.0f, 2.0f, 0.0f)) || !Values[2].Equals(FVector(0.0f, 0.0f, 2.0f)) || !Values[3].Equals(FVector(2.0f, 2.0f, 0.0f)))
		{
			return false;
		}
		Values.Insert(FVector(0.0f, 1.0f, 1.0f), 0);
		if (!Values[0].Equals(FVector(0.0f, 1.0f, 1.0f)) || !Values[1].Equals(FVector(2.0f, 0.0f, 0.0f)))
		{
			return false;
		}
		Values.Insert(FVector(0.0f, 2.0f, 2.0f), Values.Num());
		return Values.Num() == 6 && Values[0].Equals(FVector(0.0f, 1.0f, 1.0f)) && Values[1].Equals(FVector(2.0f, 0.0f, 0.0f)) && Values[2].Equals(FVector(0.0f, 2.0f, 0.0f))
			&& Values[3].Equals(FVector(0.0f, 0.0f, 2.0f)) && Values[4].Equals(FVector(2.0f, 2.0f, 0.0f)) && Values[5].Equals(FVector(0.0f, 2.0f, 2.0f));
	}

	/**
	 * In-only: read Insert order from a const&in FVector array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs six-element inserted order
	 * @Return true when Num() == 6 and order matches
	 */
	UFUNCTION()
	bool ReadInsertOrder_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 6 && Values[0].Equals(FVector(0.0f, 1.0f, 1.0f)) && Values[1].Equals(FVector(2.0f, 0.0f, 0.0f)) && Values[2].Equals(FVector(0.0f, 2.0f, 0.0f))
			&& Values[3].Equals(FVector(0.0f, 0.0f, 2.0f)) && Values[4].Equals(FVector(2.0f, 2.0f, 0.0f)) && Values[5].Equals(FVector(0.0f, 2.0f, 2.0f));
	}

	/**
	 * Out-only: fill an empty &out FVector array with Insert at head, middle, and end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result is the six-element inserted order
	 */
	UFUNCTION()
	void FillArrayByInsert_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(2.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 2.0f));
		Result.Add(FVector(2.0f, 2.0f, 0.0f));
		Result.Insert(FVector(0.0f, 2.0f, 0.0f), 1);
		Result.Insert(FVector(0.0f, 1.0f, 1.0f), 0);
		Result.Insert(FVector(0.0f, 2.0f, 2.0f), Result.Num());
	}

	/**
	 * Inout: Insert at index 1 into an existing three-element FVector array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs three elements
	 * @Return void; middle value inserted at index 1
	 */
	UFUNCTION()
	void InsertInto_FVector(TArray<FVector>&inout Values)
	{
		Values.Insert(FVector(0.0f, 2.0f, 0.0f), 1);
	}

	/**
	 * Observe Insert for bool: middle, head, then end (duplicates allowed).
	 *
	 * @Kind Observe
	 * @Covers TArray.Insert
	 * @Inputs [false, true, false]; Insert true at 1; false at 0; true at Num()
	 * @Return true when Num is 6
	 */
	UFUNCTION()
	bool InsertAtHeadMiddleAndEnd_bool()
	{
		TArray<bool> Values;
		Values.Add(false);
		Values.Add(true);
		Values.Add(false);
		Values.Insert(true, 1);
		if (Values.Num() != 4 || Values[0] != false || Values[1] != true || Values[2] != true || Values[3] != false)
		{
			return false;
		}
		Values.Insert(false, 0);
		if (Values[0] != false || Values[1] != false)
		{
			return false;
		}
		Values.Insert(true, Values.Num());
		return Values.Num() == 6 && Values[0] == false && Values[5] == true;
	}

	/**
	 * In-only: read Inserted bool array from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs Num() == 6
	 * @Return true when Num() == 6
	 */
	UFUNCTION()
	bool ReadInsertOrder_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 6;
	}

	/**
	 * Out-only: fill an empty &out bool array with Insert at head, middle, and end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result.Num() == 6
	 */
	UFUNCTION()
	void FillArrayByInsert_bool(TArray<bool>&out Result)
	{
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
		Result.Insert(true, 1);
		Result.Insert(false, 0);
		Result.Insert(true, Result.Num());
	}

	/**
	 * Inout: Insert true at index 1 into [false, true, false].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs [false, true, false]
	 * @Return void; Values.Num() == 4
	 */
	UFUNCTION()
	void InsertInto_bool(TArray<bool>&inout Values)
	{
		Values.Insert(true, 1);
	}

	/**
	 * Observe Insert for UObject handles: middle, head, then end.
	 *
	 * @Kind Observe
	 * @Covers TArray.Insert
	 * @Inputs three temps; Insert extra at 1, 0, and Num()
	 * @Return true when Num is 6
	 */
	UFUNCTION()
	bool InsertAtHeadMiddleAndEnd_UObject()
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_C", true);
		UObject Mid = NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_Mid", true);
		UObject Head = NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_Head", true);
		UObject Tail = NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_Tail", true);
		if (A == nullptr || B == nullptr || C == nullptr || Mid == nullptr || Head == nullptr || Tail == nullptr)
		{
			return false;
		}
		TArray<UObject> Values;
		Values.Add(A);
		Values.Add(B);
		Values.Add(C);
		Values.Insert(Mid, 1);
		if (Values.Num() != 4 || Values[1] != Mid)
		{
			return false;
		}
		Values.Insert(Head, 0);
		if (Values[0] != Head)
		{
			return false;
		}
		Values.Insert(Tail, Values.Num());
		return Values.Num() == 6 && Values[0] == Head && Values[5] == Tail;
	}

	/**
	 * In-only: read Inserted UObject order from const&in without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs Num() == 6
	 * @Return true when Num() == 6
	 */
	UFUNCTION()
	bool ReadInsertOrder_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 6;
	}

	/**
	 * Out-only: fill an empty &out UObject array with Insert at head, middle, and end.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 6
	 */
	UFUNCTION()
	void FillArrayByInsert_UObject(TArray<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_Fill_A", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_Fill_B", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_Fill_C", true));
		Result.Insert(NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_Fill_Mid", true), 1);
		Result.Insert(NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_Fill_Head", true), 0);
		Result.Insert(NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_Fill_Tail", true), Result.Num());
	}

	/**
	 * Inout: Insert a new handle at index 1.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 4
	 */
	UFUNCTION()
	void InsertInto_UObject(TArray<UObject>&inout Values)
	{
		Values.Insert(NewObject(GetTransientPackage(), UTArrayInsertObject::StaticClass(), n"TArrayInsert_Inout", true), 1);
	}

}
/** @end */
