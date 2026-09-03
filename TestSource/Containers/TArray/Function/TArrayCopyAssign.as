/**
 * Whole-array assign, equality, slice Copy, and MoveAssignFrom.
 * opAssign is the RoundTrip surface; Copy / MoveAssignFrom / opEquals stay Observe.
 *
 * int is the canonical case; other element types repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.CopyAssign
 * @Harness Function
 * @Tag Containers.TArray.TArrayCopyAssign
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayCopyAssignObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * opAssign copies values; mutating dest does not write the source.
	 *
	 * @Kind Observe
	 * @Covers TArray.opAssign
	 * @Inputs Dest starts [9]; Dest = [1, 2]; Dest[0] = 8
	 * @Return true when Dest becomes [8, 2] and Source stays [1, 2]
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent()
	{
		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);
		TArray<int> Dest;
		Dest.Add(9);
		Dest = Source;
		if (Dest.Num() != 2 || Dest[0] != 1 || Dest[1] != 2)
		{
			return false;
		}

		Dest[0] = 8;
		return Source[0] == 1 && Source[1] == 2 && Dest[0] == 8;
	}

	/**
	 * In-only: read assigned order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [1, 2]
	 * @Return true when Num() == 2 and elements are [1, 2]
	 */
	UFUNCTION()
	bool ReadAssignedOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 2 && Values[0] == 1 && Values[1] == 2;
	}

	/**
	 * Out-only: assign a local source into an empty &out array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [1, 2]
	 */
	UFUNCTION()
	void FillArrayByAssign(TArray<int>&out Result)
	{
		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);
		Result = Source;
	}

	/**
	 * Inout: replace existing elements by assigning a new sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Array received as TArray<int>&inout, starts as [9]
	 * @Inputs Values.Num() == 1 with [9]
	 * @Return void; Values becomes [1, 2]
	 */
	UFUNCTION()
	void AssignInPlace(TArray<int>&inout Values)
	{
		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);
		Values = Source;
	}

	/**
	 * opEquals is true for the same sequence and false otherwise.
	 *
	 * @Kind Observe
	 * @Covers TArray.opEquals
	 * @Inputs [1, 2] vs [1, 2] vs [1, 3]
	 * @Return true when equal sequences compare true and a mismatch compares false
	 */
	UFUNCTION()
	bool EqualsMatchesSameSequence()
	{
		TArray<int> Left;
		Left.Add(1);
		Left.Add(2);
		TArray<int> Same;
		Same.Add(1);
		Same.Add(2);
		TArray<int> Different;
		Different.Add(1);
		Different.Add(3);
		return Left == Same && !(Left == Different);
	}

	/**
	 * Copy writes a source slice onto dest slots that already exist.
	 *
	 * @Kind Observe
	 * @Covers TArray.Copy
	 * @Inputs Source [10,20,30,40]; Dest four zeros; Copy(Source, 1, 2, 1)
	 * @Return true when Dest is [0, 20, 30, 0]
	 */
	UFUNCTION()
	bool CopyWritesSourceSliceIntoDest()
	{
		TArray<int> Source;
		Source.Add(10);
		Source.Add(20);
		Source.Add(30);
		Source.Add(40);
		TArray<int> Dest;
		Dest.Add(0);
		Dest.Add(0);
		Dest.Add(0);
		Dest.Add(0);
		Dest.Copy(Source, 1, 2, 1);
		return Dest.Num() == 4
			&& Dest[0] == 0 && Dest[1] == 20 && Dest[2] == 30 && Dest[3] == 0;
	}

	/**
	 * MoveAssignFrom takes source contents and leaves the source empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.MoveAssignFrom
	 * @Inputs Dest [9]; Source [1, 2, 3]; Dest.MoveAssignFrom(Source)
	 * @Return true when Dest is [1, 2, 3] and Source.Num() == 0
	 */
	UFUNCTION()
	bool MoveAssignFromTakesSourceAndEmptiesIt()
	{
		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);
		Source.Add(3);
		TArray<int> Dest;
		Dest.Add(9);
		Dest.MoveAssignFrom(Source);
		return Dest.Num() == 3 && Dest[0] == 1 && Dest[1] == 2 && Dest[2] == 3
			&& Source.Num() == 0;
	}

	/**
	 * Assigning an empty array clears dest. opAssign of empty is not a Throw.
	 *
	 * @Kind Observe
	 * @Covers TArray.opAssign
	 * @Inputs Dest [9]; Dest = empty
	 * @Return true when Dest.Num() == 0
	 */
	UFUNCTION()
	bool AssignEmptyClearsDest()
	{
		TArray<int> Dest;
		Dest.Add(9);
		TArray<int> Empty;
		Dest = Empty;
		return Dest.Num() == 0;
	}

	/**
	 * Self-assign leaves values unchanged. Unlike Copy(self) this does not throw.
	 *
	 * @Kind Observe
	 * @Covers TArray.opAssign
	 * @Inputs [1, 2]; Values = Values
	 * @Return true when the array stays [1, 2]
	 */
	UFUNCTION()
	bool AssignSelfLeavesValuesUnchanged()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values = Values;
		return Values.Num() == 2 && Values[0] == 1 && Values[1] == 2;
	}

	/**
	 * opAssign copies float values; mutating dest does not write the source.
	 *
	 * @Kind Observe
	 * @Covers TArray.opAssign
	 * @Inputs Dest starts [nine]; Dest = [a,b]; Dest[0] = eight
	 * @Return true when Dest becomes [eight, b] and Source stays [a, b]
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_float()
	{
		TArray<float> Source;
		Source.Add(1.0f);
		Source.Add(2.0f);
		TArray<float> Dest;
		Dest.Add(9.0f);
		Dest = Source;
		if (Dest.Num() != 2 || Dest[0] != 1.0f || Dest[1] != 2.0f)
		{
			return false;
		}
		Dest[0] = 8.0f;
		return Source[0] == 1.0f && Source[1] == 2.0f && Dest[0] == 8.0f;
	}

	/**
	 * In-only: read assigned float order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs [a, b]
	 * @Return true when Num() == 2 and order matches
	 */
	UFUNCTION()
	bool ReadAssignedOrder_float(const TArray<float>&in Values)
	{
		return Values.Num() == 2 && Values[0] == 1.0f && Values[1] == 2.0f;
	}

	/**
	 * Out-only: assign a local float source into an empty &out array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result becomes [a, b]
	 */
	UFUNCTION()
	void FillArrayByAssign_float(TArray<float>&out Result)
	{
		TArray<float> Source;
		Source.Add(1.0f);
		Source.Add(2.0f);
		Result = Source;
	}

	/**
	 * Inout: replace existing float elements by assigning a new sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs Values.Num() == 1
	 * @Return void; Values becomes [a, b]
	 */
	UFUNCTION()
	void AssignInPlace_float(TArray<float>&inout Values)
	{
		TArray<float> Source;
		Source.Add(1.0f);
		Source.Add(2.0f);
		Values = Source;
	}

	/**
	 * opAssign copies FString values; mutating dest does not write the source.
	 *
	 * @Kind Observe
	 * @Covers TArray.opAssign
	 * @Inputs Dest starts [nine]; Dest = [a,b]; Dest[0] = eight
	 * @Return true when Dest becomes [eight, b] and Source stays [a, b]
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_FString()
	{
		TArray<FString> Source;
		Source.Add("alpha");
		Source.Add("beta");
		TArray<FString> Dest;
		Dest.Add("india");
		Dest = Source;
		if (Dest.Num() != 2 || Dest[0] != "alpha" || Dest[1] != "beta")
		{
			return false;
		}
		Dest[0] = "hotel";
		return Source[0] == "alpha" && Source[1] == "beta" && Dest[0] == "hotel";
	}

	/**
	 * In-only: read assigned FString order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs [a, b]
	 * @Return true when Num() == 2 and order matches
	 */
	UFUNCTION()
	bool ReadAssignedOrder_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 2 && Values[0] == "alpha" && Values[1] == "beta";
	}

	/**
	 * Out-only: assign a local FString source into an empty &out array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result becomes [a, b]
	 */
	UFUNCTION()
	void FillArrayByAssign_FString(TArray<FString>&out Result)
	{
		TArray<FString> Source;
		Source.Add("alpha");
		Source.Add("beta");
		Result = Source;
	}

	/**
	 * Inout: replace existing FString elements by assigning a new sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs Values.Num() == 1
	 * @Return void; Values becomes [a, b]
	 */
	UFUNCTION()
	void AssignInPlace_FString(TArray<FString>&inout Values)
	{
		TArray<FString> Source;
		Source.Add("alpha");
		Source.Add("beta");
		Values = Source;
	}

	/**
	 * opAssign copies FVector values; mutating dest does not write the source.
	 *
	 * @Kind Observe
	 * @Covers TArray.opAssign
	 * @Inputs Dest starts [nine]; Dest = [a,b]; Dest[0] = eight
	 * @Return true when Dest becomes [eight, b] and Source stays [a, b]
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_FVector()
	{
		TArray<FVector> Source;
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Source.Add(FVector(0.0f, 1.0f, 0.0f));
		TArray<FVector> Dest;
		Dest.Add(FVector(1.0f, 1.0f, 1.0f));
		Dest = Source;
		if (Dest.Num() != 2 || !Dest[0].Equals(FVector(1.0f, 0.0f, 0.0f)) || !Dest[1].Equals(FVector(0.0f, 1.0f, 0.0f)))
		{
			return false;
		}
		Dest[0] = FVector(1.0f, 0.0f, 1.0f);
		return Source[0].Equals(FVector(1.0f, 0.0f, 0.0f)) && Source[1].Equals(FVector(0.0f, 1.0f, 0.0f)) && Dest[0].Equals(FVector(1.0f, 0.0f, 1.0f));
	}

	/**
	 * In-only: read assigned FVector order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs [a, b]
	 * @Return true when Num() == 2 and order matches
	 */
	UFUNCTION()
	bool ReadAssignedOrder_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 2 && Values[0].Equals(FVector(1.0f, 0.0f, 0.0f)) && Values[1].Equals(FVector(0.0f, 1.0f, 0.0f));
	}

	/**
	 * Out-only: assign a local FVector source into an empty &out array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result becomes [a, b]
	 */
	UFUNCTION()
	void FillArrayByAssign_FVector(TArray<FVector>&out Result)
	{
		TArray<FVector> Source;
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Source.Add(FVector(0.0f, 1.0f, 0.0f));
		Result = Source;
	}

	/**
	 * Inout: replace existing FVector elements by assigning a new sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs Values.Num() == 1
	 * @Return void; Values becomes [a, b]
	 */
	UFUNCTION()
	void AssignInPlace_FVector(TArray<FVector>&inout Values)
	{
		TArray<FVector> Source;
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Source.Add(FVector(0.0f, 1.0f, 0.0f));
		Values = Source;
	}

	/**
	 * opAssign copies bool values; mutating dest does not write the source.
	 *
	 * @Kind Observe
	 * @Covers TArray.opAssign
	 * @Inputs Dest starts [true]; Dest = [false, true]; Dest[0] = true
	 * @Return true when Dest[0] is true and Source stays [false, true]
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_bool()
	{
		TArray<bool> Source;
		Source.Add(false);
		Source.Add(true);
		TArray<bool> Dest;
		Dest.Add(true);
		Dest = Source;
		if (Dest.Num() != 2 || Dest[0] != false || Dest[1] != true)
		{
			return false;
		}
		Dest[0] = true;
		return Source[0] == false && Source[1] == true && Dest[0] == true;
	}

	/**
	 * In-only: read assigned bool order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs [false, true]
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAssignedOrder_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 2 && Values[0] == false && Values[1] == true;
	}

	/**
	 * Out-only: assign a local bool source into an empty &out array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result becomes [false, true]
	 */
	UFUNCTION()
	void FillArrayByAssign_bool(TArray<bool>&out Result)
	{
		TArray<bool> Source;
		Source.Add(false);
		Source.Add(true);
		Result = Source;
	}

	/**
	 * Inout: replace existing bool elements by assigning a new sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs Values.Num() == 1
	 * @Return void; Values becomes [false, true]
	 */
	UFUNCTION()
	void AssignInPlace_bool(TArray<bool>&inout Values)
	{
		TArray<bool> Source;
		Source.Add(false);
		Source.Add(true);
		Values = Source;
	}

	/**
	 * opAssign copies UObject handles; mutating dest does not write the source.
	 *
	 * @Kind Observe
	 * @Covers TArray.opAssign
	 * @Inputs Dest starts [Nine]; Dest = [A, B]; Dest[0] = Eight
	 * @Return true when Dest[0] is Eight and Source stays [A, B]
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_UObject()
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayCopyAssignObject::StaticClass(), n"TArrayCopy_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayCopyAssignObject::StaticClass(), n"TArrayCopy_B", true);
		UObject Nine = NewObject(GetTransientPackage(), UTArrayCopyAssignObject::StaticClass(), n"TArrayCopy_Nine", true);
		UObject Eight = NewObject(GetTransientPackage(), UTArrayCopyAssignObject::StaticClass(), n"TArrayCopy_Eight", true);
		if (A == nullptr || B == nullptr || Nine == nullptr || Eight == nullptr)
		{
			return false;
		}
		TArray<UObject> Source;
		Source.Add(A);
		Source.Add(B);
		TArray<UObject> Dest;
		Dest.Add(Nine);
		Dest = Source;
		if (Dest.Num() != 2 || Dest[0] != A || Dest[1] != B)
		{
			return false;
		}
		Dest[0] = Eight;
		return Source[0] == A && Source[1] == B && Dest[0] == Eight;
	}

	/**
	 * In-only: read assigned UObject order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs two distinct handles
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAssignedOrder_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: assign a local UObject source into an empty &out array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 2
	 */
	UFUNCTION()
	void FillArrayByAssign_UObject(TArray<UObject>&out Result)
	{
		TArray<UObject> Source;
		Source.Add(NewObject(GetTransientPackage(), UTArrayCopyAssignObject::StaticClass(), n"TArrayCopy_Fill_A", true));
		Source.Add(NewObject(GetTransientPackage(), UTArrayCopyAssignObject::StaticClass(), n"TArrayCopy_Fill_B", true));
		Result = Source;
	}

	/**
	 * Inout: replace existing UObject elements by assigning a new sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opAssign
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Values.Num() == 1
	 * @Return void; Values.Num() == 2
	 */
	UFUNCTION()
	void AssignInPlace_UObject(TArray<UObject>&inout Values)
	{
		TArray<UObject> Source;
		Source.Add(NewObject(GetTransientPackage(), UTArrayCopyAssignObject::StaticClass(), n"TArrayCopy_Inout_A", true));
		Source.Add(NewObject(GetTransientPackage(), UTArrayCopyAssignObject::StaticClass(), n"TArrayCopy_Inout_B", true));
		Values = Source;
	}

}
