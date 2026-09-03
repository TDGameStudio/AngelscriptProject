/**
 * foreach walks in [] order. Iterator() is the explicit form of the same walk.
 * foreach is the RoundTrip surface; Iterator stays Observe.
 *
 * int is the canonical case; other element types repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.ForEach
 * @Harness Function
 * @Tag Containers.TArray.TArrayForEach
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayForEachObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe foreach by value then by ref; order matches [] and ref mutates.
	 *
	 * @Kind Observe
	 * @Covers TArray.foreach
	 * @Inputs [1, 2, 3, 4, 5]; for-each sum; for-each int& double
	 * @Return true when value sum is 15 and the array becomes [2, 4, 6, 8, 10]
	 */
	UFUNCTION()
	bool ForEachWalksInIndexOrderAndRefMutates()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(4);
		Values.Add(5);

		int SumByValue = 0;
		int Index = 0;
		for (int Val : Values)
		{
			if (Val != Values[Index])
			{
				return false;
			}
			SumByValue += Val;
			Index++;
		}
		if (SumByValue != 15)
		{
			return false;
		}

		for (int& Val : Values)
		{
			Val *= 2;
		}
		return Values[0] == 2 && Values[1] == 4 && Values[2] == 6
			&& Values[3] == 8 && Values[4] == 10;
	}

	/**
	 * In-only: foreach-sum a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [1, 2, 3, 4, 5]
	 * @Return true when the value walk sums to 15
	 */
	UFUNCTION()
	bool ReadForEachSum(const TArray<int>&in Values)
	{
		int Sum = 0;
		for (int Val : Values)
		{
			Sum += Val;
		}
		return Sum == 15;
	}

	/**
	 * Out-only: fill an empty &out array in foreach source order.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [1, 2, 3, 4, 5]
	 */
	UFUNCTION()
	void FillArrayForForEach(TArray<int>&out Result)
	{
		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);
		Source.Add(3);
		Source.Add(4);
		Source.Add(5);
		for (int Val : Source)
		{
			Result.Add(Val);
		}
	}

	/**
	 * Inout: foreach-ref doubles every slot of an existing [1, 2, 3, 4, 5].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Array received as TArray<int>&inout, starts as [1, 2, 3, 4, 5]
	 * @Inputs Values.Num() == 5 with [1, 2, 3, 4, 5]
	 * @Return void; Values becomes [2, 4, 6, 8, 10]
	 */
	UFUNCTION()
	void DoubleEachByRef(TArray<int>&inout Values)
	{
		for (int& Val : Values)
		{
			Val *= 2;
		}
	}

	/**
	 * Observe Iterator: Proceed walks the same sequence as [].
	 *
	 * @Kind Observe
	 * @Covers TArray.Iterator
	 * @Inputs [1, 2, 3, 4, 5]; Iterator until !CanProceed
	 * @Return true when count is 5 and the sum is 15
	 */
	UFUNCTION()
	bool IteratorProceedsInIndexOrder()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(4);
		Values.Add(5);

		int Sum = 0;
		int Count = 0;
		TArrayIterator<int> It = Values.Iterator();
		while (It.CanProceed)
		{
			Sum += It.Proceed();
			Count++;
		}
		return Count == 5 && Sum == 15;
	}

	/**
	 * Observe foreach for float: order matches [] and ref mutates.
	 *
	 * @Kind Observe
	 * @Covers TArray.foreach
	 * @Inputs [1,2,3,4,5] as float; for-each sum; for-each float& double
	 * @Return true when value sum is 15.0f and the array becomes [2,4,6,8,10]
	 */
	UFUNCTION()
	bool ForEachWalksInIndexOrderAndRefMutates_float()
	{
		TArray<float> Values;
		Values.Add(1.0f);
		Values.Add(2.0f);
		Values.Add(3.0f);
		Values.Add(4.0f);
		Values.Add(5.0f);
		float SumByValue = 0.0f;
		int Index = 0;
		for (float Val : Values)
		{
		if (Val != Values[Index])
		{
			return false;
		}
			SumByValue += Val;
			Index++;
		}
		if (SumByValue != 15.0f)
		{
			return false;
		}
		for (float& Val : Values)
		{
			Val *= 2.0f;
		}
		return Values[0] == 2.0f && Values[1] == 4.0f && Values[2] == 6.0f && Values[3] == 8.0f && Values[4] == 10.0f;
	}

	/**
	 * In-only: foreach-sum a const&in float array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs [1,2,3,4,5] as float
	 * @Return true when the value walk sums to 15.0f
	 */
	UFUNCTION()
	bool ReadForEachSum_float(const TArray<float>&in Values)
	{
		float Sum = 0.0f;
		for (float Val : Values)
		{
			Sum += Val;
		}
		return Sum == 15.0f;
	}

	/**
	 * Out-only: fill an empty &out float array in foreach source order.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result becomes [1,2,3,4,5] as float
	 */
	UFUNCTION()
	void FillArrayForForEach_float(TArray<float>&out Result)
	{
		TArray<float> Source;
		Source.Add(1.0f);
		Source.Add(2.0f);
		Source.Add(3.0f);
		Source.Add(4.0f);
		Source.Add(5.0f);
		for (float Val : Source)
		{
			Result.Add(Val);
		}
	}

	/**
	 * Inout: foreach-ref doubles every slot of an existing float array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs [1,2,3,4,5] as float
	 * @Return void; Values becomes [2,4,6,8,10]
	 */
	UFUNCTION()
	void DoubleEachByRef_float(TArray<float>&inout Values)
	{
		for (float& Val : Values)
		{
			Val *= 2.0f;
		}
	}

	/**
	 * Observe foreach for bool: order matches [] and ref inverts.
	 *
	 * @Kind Observe
	 * @Covers TArray.foreach
	 * @Inputs [false, true, false]; for-each check; for-each bool& invert
	 * @Return true when the array becomes [true, false, true]
	 */
	UFUNCTION()
	bool ForEachWalksInIndexOrderAndRefMutates_bool()
	{
		TArray<bool> Values;
		Values.Add(false);
		Values.Add(true);
		Values.Add(false);
		int Index = 0;
		for (bool Val : Values)
		{
		if (Val != Values[Index])
		{
			return false;
		}
			Index++;
		}
		if (Index != 3)
		{
			return false;
		}
		for (bool& Val : Values)
		{
			Val = !Val;
		}
		return Values[0] == true && Values[1] == false && Values[2] == true;
	}

	/**
	 * In-only: foreach-count a const&in bool array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs [false, true, false]
	 * @Return true when the walk visits 3 slots
	 */
	UFUNCTION()
	bool ReadForEachSum_bool(const TArray<bool>&in Values)
	{
		int Count = 0;
		for (bool Val : Values)
		{
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: fill an empty &out bool array in foreach source order.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result becomes [false, true, false]
	 */
	UFUNCTION()
	void FillArrayForForEach_bool(TArray<bool>&out Result)
	{
		TArray<bool> Source;
		Source.Add(false);
		Source.Add(true);
		Source.Add(false);
		for (bool Val : Source)
		{
			Result.Add(Val);
		}
	}

	/**
	 * Inout: foreach-ref inverts every slot of an existing bool array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs [false, true, false]
	 * @Return void; Values becomes [true, false, true]
	 */
	UFUNCTION()
	void DoubleEachByRef_bool(TArray<bool>&inout Values)
	{
		for (bool& Val : Values)
		{
			Val = !Val;
		}
	}

	/**
	 * Observe foreach for FString: order matches [] and ref appends a marker.
	 *
	 * @Kind Observe
	 * @Covers TArray.foreach
	 * @Inputs [alpha, beta, gamma]; for-each check; for-each FString& append !
	 * @Return true when the array becomes [alpha!, beta!, gamma!]
	 */
	UFUNCTION()
	bool ForEachWalksInIndexOrderAndRefMutates_FString()
	{
		TArray<FString> Values;
		Values.Add("alpha");
		Values.Add("beta");
		Values.Add("gamma");
		int Index = 0;
		for (FString Val : Values)
		{
		if (Val != Values[Index])
		{
			return false;
		}
			Index++;
		}
		if (Index != 3)
		{
			return false;
		}
		for (FString& Val : Values)
		{
			Val = Val + "!";
		}
		return Values[0] == "alpha!" && Values[1] == "beta!" && Values[2] == "gamma!";
	}

	/**
	 * In-only: foreach-count a const&in FString array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs [alpha, beta, gamma]
	 * @Return true when the walk visits 3 slots
	 */
	UFUNCTION()
	bool ReadForEachSum_FString(const TArray<FString>&in Values)
	{
		int Count = 0;
		for (FString Val : Values)
		{
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: fill an empty &out FString array in foreach source order.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result becomes [alpha, beta, gamma]
	 */
	UFUNCTION()
	void FillArrayForForEach_FString(TArray<FString>&out Result)
	{
		TArray<FString> Source;
		Source.Add("alpha");
		Source.Add("beta");
		Source.Add("gamma");
		for (FString Val : Source)
		{
			Result.Add(Val);
		}
	}

	/**
	 * Inout: foreach-ref appends a marker to every FString slot.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs [alpha, beta, gamma]
	 * @Return void; Values becomes [alpha!, beta!, gamma!]
	 */
	UFUNCTION()
	void DoubleEachByRef_FString(TArray<FString>&inout Values)
	{
		for (FString& Val : Values)
		{
			Val = Val + "!";
		}
	}

	/**
	 * Observe foreach for FVector: order matches [] and ref scales.
	 *
	 * @Kind Observe
	 * @Covers TArray.foreach
	 * @Inputs three basis vectors; for-each check; for-each FVector& *= 2
	 * @Return true when each vector is doubled
	 */
	UFUNCTION()
	bool ForEachWalksInIndexOrderAndRefMutates_FVector()
	{
		TArray<FVector> Values;
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
		int Index = 0;
		for (FVector Val : Values)
		{
		if (!Val.Equals(Values[Index]))
		{
			return false;
		}
			Index++;
		}
		if (Index != 3)
		{
			return false;
		}
		for (FVector& Val : Values)
		{
			Val *= 2.0f;
		}
		return Values[0].Equals(FVector(2.0f, 0.0f, 0.0f)) && Values[1].Equals(FVector(0.0f, 2.0f, 0.0f)) && Values[2].Equals(FVector(0.0f, 0.0f, 2.0f));
	}

	/**
	 * In-only: foreach-count a const&in FVector array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs three vectors
	 * @Return true when the walk visits 3 slots
	 */
	UFUNCTION()
	bool ReadForEachSum_FVector(const TArray<FVector>&in Values)
	{
		int Count = 0;
		for (FVector Val : Values)
		{
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: fill an empty &out FVector array in foreach source order.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result has three basis vectors
	 */
	UFUNCTION()
	void FillArrayForForEach_FVector(TArray<FVector>&out Result)
	{
		TArray<FVector> Source;
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Source.Add(FVector(0.0f, 1.0f, 0.0f));
		Source.Add(FVector(0.0f, 0.0f, 1.0f));
		for (FVector Val : Source)
		{
			Result.Add(Val);
		}
	}

	/**
	 * Inout: foreach-ref scales every FVector slot by 2.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs three basis vectors
	 * @Return void; each vector is doubled
	 */
	UFUNCTION()
	void DoubleEachByRef_FVector(TArray<FVector>&inout Values)
	{
		for (FVector& Val : Values)
		{
			Val *= 2.0f;
		}
	}

	/**
	 * Observe foreach for UObject handles: order matches [] and ref replaces each slot.
	 *
	 * @Kind Observe
	 * @Covers TArray.foreach
	 * @Inputs three temps; for-each identity check; for-each UObject& assign Replacement
	 * @Return true when every slot is Replacement
	 */
	UFUNCTION()
	bool ForEachWalksInIndexOrderAndRefMutates_UObject()
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayForEachObject::StaticClass(), n"TArrayForEach_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayForEachObject::StaticClass(), n"TArrayForEach_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayForEachObject::StaticClass(), n"TArrayForEach_C", true);
		UObject Replacement = NewObject(GetTransientPackage(), UTArrayForEachObject::StaticClass(), n"TArrayForEach_R", true);
		if (A == nullptr || B == nullptr || C == nullptr || Replacement == nullptr)
		{
			return false;
		}
		TArray<UObject> Values;
		Values.Add(A);
		Values.Add(B);
		Values.Add(C);
		int Index = 0;
		for (UObject Val : Values)
		{
		if (Val != Values[Index])
		{
			return false;
		}
			Index++;
		}
		if (Index != 3)
		{
			return false;
		}
		for (UObject& Val : Values)
		{
			Val = Replacement;
		}
		return Values[0] == Replacement && Values[1] == Replacement && Values[2] == Replacement;
	}

	/**
	 * In-only: foreach-count a const&in UObject array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs three handles
	 * @Return true when the walk visits 3 slots
	 */
	UFUNCTION()
	bool ReadForEachSum_UObject(const TArray<UObject>&in Values)
	{
		int Count = 0;
		for (UObject Val : Values)
		{
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: fill an empty &out UObject array in foreach source order.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillArrayForForEach_UObject(TArray<UObject>&out Result)
	{
		TArray<UObject> Source;
		Source.Add(NewObject(GetTransientPackage(), UTArrayForEachObject::StaticClass(), n"TArrayForEach_Fill_A", true));
		Source.Add(NewObject(GetTransientPackage(), UTArrayForEachObject::StaticClass(), n"TArrayForEach_Fill_B", true));
		Source.Add(NewObject(GetTransientPackage(), UTArrayForEachObject::StaticClass(), n"TArrayForEach_Fill_C", true));
		for (UObject Val : Source)
		{
			Result.Add(Val);
		}
	}

	/**
	 * Inout: foreach-ref replaces every UObject slot with a new handle.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Num() == 3
	 * @Return void; every slot is the replacement handle
	 */
	UFUNCTION()
	void DoubleEachByRef_UObject(TArray<UObject>&inout Values)
	{
		UObject Replacement = NewObject(GetTransientPackage(), UTArrayForEachObject::StaticClass(), n"TArrayForEach_Inout", true);
		for (UObject& Val : Values)
		{
			Val = Replacement;
		}
	}

}
