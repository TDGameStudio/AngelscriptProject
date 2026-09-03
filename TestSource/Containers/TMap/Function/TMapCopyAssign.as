/**
 * Whole-map assign and equality. opAssign is the RoundTrip surface;
 * opEquals stays Observe (int, including different insertion order).
 * int/int is canonical; other shapes repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TMap
 * @Subject TMap.CopyAssign
 * @Harness Function
 * @Tag Containers.TMap.TMapCopyAssign
 * @Namespace TMapTest
 */

UCLASS()
class UTMapCopyAssignObject : UObject
{
}

namespace TMapTest
{
	/**
	 * opAssign copies pairs; mutating dest does not write the source.
	 *
	 * @Kind Observe
	 * @Covers TMap.opAssign
	 * @Inputs Dest starts with a dummy pair; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent()
	{
		TMap<int, int> Source;
		Source.Add(10, 100);
		Source.Add(20, 200);
		TMap<int, int> Dest;
		Dest.Add(99, 999);
		Dest = Source;
		if (Dest.Num() != 2 || Dest[10] != 100 || Dest[20] != 200)
		{
			return false;
		}
		Dest.Add(30, 300);
		return Source.Num() == 2 && !Source.Contains(30) && Dest.Contains(30);
	}

	/**
	 * In-only: read assigned pairs from a const&in TMap<int, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadAssignedPairs(const TMap<int, int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TMap<int, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByAssign(TMap<int, int>&out Result)
	{
		TMap<int, int> Source;
		Source.Add(10, 100);
		Source.Add(20, 200);
		Source.Add(30, 300);
		Result = Source;
	}

	/**
	 * Inout: replace existing pairs by assigning a new map.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Map received as TMap<int, int>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AssignInPlace(TMap<int, int>&inout Values)
	{
		TMap<int, int> Source;
		Source.Add(10, 100);
		Source.Add(20, 200);
		Source.Add(30, 300);
		Values = Source;
	}


	/**
	 * opAssign copies pairs; mutating dest does not write the source_FString.
	 *
	 * @Kind Observe
	 * @Covers TMap.opAssign
	 * @Inputs Dest starts with a dummy pair; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_FString()
	{
		TMap<FString, int> Source;
		Source.Add("alpha", 100);
		Source.Add("beta", 200);
		TMap<FString, int> Dest;
		Dest.Add("missing", 999);
		Dest = Source;
		if (Dest.Num() != 2 || Dest["alpha"] != 100 || Dest["beta"] != 200)
		{
			return false;
		}
		Dest.Add("gamma", 300);
		return Source.Num() == 2 && !Source.Contains("gamma") && Dest.Contains("gamma");
	}

	/**
	 * In-only: read assigned pairs from a const&in TMap<FString, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadAssignedPairs_FString(const TMap<FString, int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TMap<FString, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByAssign_FString(TMap<FString, int>&out Result)
	{
		TMap<FString, int> Source;
		Source.Add("alpha", 100);
		Source.Add("beta", 200);
		Source.Add("gamma", 300);
		Result = Source;
	}

	/**
	 * Inout: replace existing pairs by assigning a new map_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Map received as TMap<FString, int>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AssignInPlace_FString(TMap<FString, int>&inout Values)
	{
		TMap<FString, int> Source;
		Source.Add("alpha", 100);
		Source.Add("beta", 200);
		Source.Add("gamma", 300);
		Values = Source;
	}


	/**
	 * opAssign copies pairs; mutating dest does not write the source_FName.
	 *
	 * @Kind Observe
	 * @Covers TMap.opAssign
	 * @Inputs Dest starts with a dummy pair; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_FName()
	{
		TMap<FName, int> Source;
		Source.Add(n"Red", 1);
		Source.Add(n"Green", 2);
		TMap<FName, int> Dest;
		Dest.Add(n"Missing", 9);
		Dest = Source;
		if (Dest.Num() != 2 || Dest[n"Red"] != 1 || Dest[n"Green"] != 2)
		{
			return false;
		}
		Dest.Add(n"Blue", 3);
		return Source.Num() == 2 && !Source.Contains(n"Blue") && Dest.Contains(n"Blue");
	}

	/**
	 * In-only: read assigned pairs from a const&in TMap<FName, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadAssignedPairs_FName(const TMap<FName, int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TMap<FName, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByAssign_FName(TMap<FName, int>&out Result)
	{
		TMap<FName, int> Source;
		Source.Add(n"Red", 1);
		Source.Add(n"Green", 2);
		Source.Add(n"Blue", 3);
		Result = Source;
	}

	/**
	 * Inout: replace existing pairs by assigning a new map_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Map received as TMap<FName, int>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AssignInPlace_FName(TMap<FName, int>&inout Values)
	{
		TMap<FName, int> Source;
		Source.Add(n"Red", 1);
		Source.Add(n"Green", 2);
		Source.Add(n"Blue", 3);
		Values = Source;
	}


	/**
	 * opAssign copies pairs; mutating dest does not write the source_bool.
	 *
	 * @Kind Observe
	 * @Covers TMap.opAssign
	 * @Inputs Dest starts with a dummy pair; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_bool()
	{
		TMap<int, bool> Source;
		Source.Add(1, true);
		Source.Add(2, false);
		TMap<int, bool> Dest;
		Dest.Add(99, false);
		Dest = Source;
		if (Dest.Num() != 2 || Dest[1] != true || Dest[2] != false)
		{
			return false;
		}
		Dest.Add(3, true);
		return Source.Num() == 2 && !Source.Contains(3) && Dest.Contains(3);
	}

	/**
	 * In-only: read assigned pairs from a const&in TMap<int, bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadAssignedPairs_bool(const TMap<int, bool>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TMap<int, bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByAssign_bool(TMap<int, bool>&out Result)
	{
		TMap<int, bool> Source;
		Source.Add(1, true);
		Source.Add(2, false);
		Source.Add(3, true);
		Result = Source;
	}

	/**
	 * Inout: replace existing pairs by assigning a new map_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Map received as TMap<int, bool>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AssignInPlace_bool(TMap<int, bool>&inout Values)
	{
		TMap<int, bool> Source;
		Source.Add(1, true);
		Source.Add(2, false);
		Source.Add(3, true);
		Values = Source;
	}


	/**
	 * opAssign copies pairs; mutating dest does not write the source_FVector.
	 *
	 * @Kind Observe
	 * @Covers TMap.opAssign
	 * @Inputs Dest starts with a dummy pair; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_FVector()
	{
		TMap<int, FVector> Source;
		Source.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Source.Add(2, FVector(0.0f, 1.0f, 0.0f));
		TMap<int, FVector> Dest;
		Dest.Add(99, FVector(9.0f, 9.0f, 9.0f));
		Dest = Source;
		if (Dest.Num() != 2 || !Dest[1].Equals(FVector(1.0f, 0.0f, 0.0f)) || !Dest[2].Equals(FVector(0.0f, 1.0f, 0.0f)))
		{
			return false;
		}
		Dest.Add(3, FVector(0.0f, 0.0f, 1.0f));
		return Source.Num() == 2 && !Source.Contains(3) && Dest.Contains(3);
	}

	/**
	 * In-only: read assigned pairs from a const&in TMap<int, FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadAssignedPairs_FVector(const TMap<int, FVector>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TMap<int, FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByAssign_FVector(TMap<int, FVector>&out Result)
	{
		TMap<int, FVector> Source;
		Source.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Source.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Source.Add(3, FVector(0.0f, 0.0f, 1.0f));
		Result = Source;
	}

	/**
	 * Inout: replace existing pairs by assigning a new map_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Map received as TMap<int, FVector>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AssignInPlace_FVector(TMap<int, FVector>&inout Values)
	{
		TMap<int, FVector> Source;
		Source.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Source.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Source.Add(3, FVector(0.0f, 0.0f, 1.0f));
		Values = Source;
	}


	/**
	 * opAssign copies pairs; mutating dest does not write the source_UObject.
	 *
	 * @Kind Observe
	 * @Covers TMap.opAssign
	 * @Inputs Dest starts with a dummy pair; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_UObject()
	{
		TMap<int, UObject> Source;
		UObject First = NewObject(GetTransientPackage(), UTMapCopyAssignObject::StaticClass(), n"TMapAssign_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTMapCopyAssignObject::StaticClass(), n"TMapAssign_Second", true);
		Source.Add(10, First);
		Source.Add(20, Second);
		TMap<int, UObject> Dest;
		Dest.Add(30, First);
		Dest = Source;
		if (Dest.Num() != 2 || Dest[10] != First || Dest[20] != Second)
		{
			return false;
		}
		Dest.Add(30, First);
		return Source.Num() == 2 && !Source.Contains(30) && Dest.Contains(30);
	}

	/**
	 * In-only: read assigned pairs from a const&in TMap<int, UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadAssignedPairs_UObject(const TMap<int, UObject>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TMap<int, UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByAssign_UObject(TMap<int, UObject>&out Result)
	{
		TMap<int, UObject> Source;
		Source.Add(10, NewObject(GetTransientPackage(), UTMapCopyAssignObject::StaticClass(), n"TMapAssign_Fill_0", true));
		Source.Add(20, NewObject(GetTransientPackage(), UTMapCopyAssignObject::StaticClass(), n"TMapAssign_Fill_1", true));
		Result = Source;
	}

	/**
	 * Inout: replace existing pairs by assigning a new map_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opAssign
	 * @Param Values Map received as TMap<int, UObject>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AssignInPlace_UObject(TMap<int, UObject>&inout Values)
	{
		TMap<int, UObject> Source;
		Source.Add(10, NewObject(GetTransientPackage(), UTMapCopyAssignObject::StaticClass(), n"TMapAssign_In_0", true));
		Source.Add(20, NewObject(GetTransientPackage(), UTMapCopyAssignObject::StaticClass(), n"TMapAssign_In_1", true));
		Source.Add(30, NewObject(GetTransientPackage(), UTMapCopyAssignObject::StaticClass(), n"TMapAssign_In_2", true));
		Values = Source;
	}


	/**
	 * opEquals is true for the same pairs regardless of insertion order.
	 *
	 * @Kind Observe
	 * @Covers TMap.opEquals
	 * @Inputs [10->100, 20->200] vs same pairs inserted backwards vs a mismatch
	 * @Return true when equal pairs compare true and a mismatch compares false
	 */
	UFUNCTION()
	bool EqualsMatchesSamePairsRegardlessOfOrder()
	{
		TMap<int, int> Left;
		Left.Add(10, 100);
		Left.Add(20, 200);
		TMap<int, int> SameOrder;
		SameOrder.Add(20, 200);
		SameOrder.Add(10, 100);
		TMap<int, int> Different;
		Different.Add(10, 100);
		Different.Add(20, 201);
		return Left == SameOrder && !(Left == Different);
	}

}
