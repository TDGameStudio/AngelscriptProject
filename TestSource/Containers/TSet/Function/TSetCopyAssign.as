/**
 * Whole-set assign and equality. opAssign is the RoundTrip surface;
 * opEquals stays Observe (int, including different insertion order).
 *
 * @Theme Containers.TSet
 * @Subject TSet.CopyAssign
 * @Harness Function
 * @Tag Containers.TSet.TSetCopyAssign
 * @Namespace TSetTest
 */

UCLASS()
class UTSetCopyAssignObject : UObject
{
}

namespace TSetTest
{
	/**
	 * opAssign copies members; mutating dest does not write the source.
	 *
	 * @Kind Observe
	 * @Covers TSet.opAssign
	 * @Inputs Dest starts with a dummy; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent()
	{
		TSet<int> Source;
		Source.Add(10);
		Source.Add(20);
		TSet<int> Dest;
		Dest.Add(99);
		Dest = Source;
		if (Dest.Num() != 2 || !Dest.Contains(10) || !Dest.Contains(20))
		{
			return false;
		}
		Dest.Add(30);
		return Source.Num() == 2 && !Source.Contains(30) && Dest.Contains(30);
	}

	/**
	 * In-only: read assigned members from a const&in TSet<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num matches
	 */
	UFUNCTION()
	bool ReadAssignedMembers(const TSet<int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TSet<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAssign(TSet<int>&out Result)
	{
		TSet<int> Source;
		Source.Add(10);
		Source.Add(20);
		Source.Add(30);
		Result = Source;
	}

	/**
	 * Inout: replace existing members by assigning a new set.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values holds the canonical members
	 */
	UFUNCTION()
	void AssignInPlace(TSet<int>&inout Values)
	{
		TSet<int> Source;
		Source.Add(10);
		Source.Add(20);
		Source.Add(30);
		Values = Source;
	}


	/**
	 * opAssign copies members; mutating dest does not write the source_FString.
	 *
	 * @Kind Observe
	 * @Covers TSet.opAssign
	 * @Inputs Dest starts with a dummy; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_FString()
	{
		TSet<FString> Source;
		Source.Add("alpha");
		Source.Add("beta");
		TSet<FString> Dest;
		Dest.Add("missing");
		Dest = Source;
		if (Dest.Num() != 2 || !Dest.Contains("alpha") || !Dest.Contains("beta"))
		{
			return false;
		}
		Dest.Add("gamma");
		return Source.Num() == 2 && !Source.Contains("gamma") && Dest.Contains("gamma");
	}

	/**
	 * In-only: read assigned members from a const&in TSet<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Source set received as const TSet<FString>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num matches
	 */
	UFUNCTION()
	bool ReadAssignedMembers_FString(const TSet<FString>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TSet<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Result Destination received as TSet<FString>&out
	 * @Inputs Empty &out TSet<FString>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAssign_FString(TSet<FString>&out Result)
	{
		TSet<FString> Source;
		Source.Add("alpha");
		Source.Add("beta");
		Source.Add("gamma");
		Result = Source;
	}

	/**
	 * Inout: replace existing members by assigning a new set_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Set received as TSet<FString>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values holds the canonical members
	 */
	UFUNCTION()
	void AssignInPlace_FString(TSet<FString>&inout Values)
	{
		TSet<FString> Source;
		Source.Add("alpha");
		Source.Add("beta");
		Source.Add("gamma");
		Values = Source;
	}


	/**
	 * opAssign copies members; mutating dest does not write the source_FName.
	 *
	 * @Kind Observe
	 * @Covers TSet.opAssign
	 * @Inputs Dest starts with a dummy; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_FName()
	{
		TSet<FName> Source;
		Source.Add(n"Red");
		Source.Add(n"Green");
		TSet<FName> Dest;
		Dest.Add(n"Missing");
		Dest = Source;
		if (Dest.Num() != 2 || !Dest.Contains(n"Red") || !Dest.Contains(n"Green"))
		{
			return false;
		}
		Dest.Add(n"Blue");
		return Source.Num() == 2 && !Source.Contains(n"Blue") && Dest.Contains(n"Blue");
	}

	/**
	 * In-only: read assigned members from a const&in TSet<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Source set received as const TSet<FName>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num matches
	 */
	UFUNCTION()
	bool ReadAssignedMembers_FName(const TSet<FName>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TSet<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Result Destination received as TSet<FName>&out
	 * @Inputs Empty &out TSet<FName>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAssign_FName(TSet<FName>&out Result)
	{
		TSet<FName> Source;
		Source.Add(n"Red");
		Source.Add(n"Green");
		Source.Add(n"Blue");
		Result = Source;
	}

	/**
	 * Inout: replace existing members by assigning a new set_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Set received as TSet<FName>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values holds the canonical members
	 */
	UFUNCTION()
	void AssignInPlace_FName(TSet<FName>&inout Values)
	{
		TSet<FName> Source;
		Source.Add(n"Red");
		Source.Add(n"Green");
		Source.Add(n"Blue");
		Values = Source;
	}


	/**
	 * opAssign copies members; mutating dest does not write the source_bool.
	 *
	 * @Kind Observe
	 * @Covers TSet.opAssign
	 * @Inputs Dest starts with a dummy; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_bool()
	{
		TSet<bool> Source;
		Source.Add(true);
		Source.Add(false);
		TSet<bool> Dest;
		Dest.Add(true);
		Dest = Source;
		if (Dest.Num() != 2 || !Dest.Contains(true) || !Dest.Contains(false))
		{
			return false;
		}
		return Source.Num() == 2;
	}

	/**
	 * In-only: read assigned members from a const&in TSet<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Source set received as const TSet<bool>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num matches
	 */
	UFUNCTION()
	bool ReadAssignedMembers_bool(const TSet<bool>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: assign a local source into an empty &out TSet<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Result Destination received as TSet<bool>&out
	 * @Inputs Empty &out TSet<bool>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAssign_bool(TSet<bool>&out Result)
	{
		TSet<bool> Source;
		Source.Add(true);
		Source.Add(false);
		Result = Source;
	}

	/**
	 * Inout: replace existing members by assigning a new set_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Set received as TSet<bool>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values holds the canonical members
	 */
	UFUNCTION()
	void AssignInPlace_bool(TSet<bool>&inout Values)
	{
		TSet<bool> Source;
		Source.Add(true);
		Source.Add(false);
		Values = Source;
	}


	/**
	 * opAssign copies members; mutating dest does not write the source_FVector.
	 *
	 * @Kind Observe
	 * @Covers TSet.opAssign
	 * @Inputs Dest starts with a dummy; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_FVector()
	{
		TSet<FVector> Source;
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Source.Add(FVector(0.0f, 1.0f, 0.0f));
		TSet<FVector> Dest;
		Dest.Add(FVector(9.0f, 9.0f, 9.0f));
		Dest = Source;
		if (Dest.Num() != 2 || !Dest.Contains(FVector(1.0f, 0.0f, 0.0f)) || !Dest.Contains(FVector(0.0f, 1.0f, 0.0f)))
		{
			return false;
		}
		Dest.Add(FVector(0.0f, 0.0f, 1.0f));
		return Source.Num() == 2 && !Source.Contains(FVector(0.0f, 0.0f, 1.0f)) && Dest.Contains(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * In-only: read assigned members from a const&in TSet<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Source set received as const TSet<FVector>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num matches
	 */
	UFUNCTION()
	bool ReadAssignedMembers_FVector(const TSet<FVector>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TSet<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Result Destination received as TSet<FVector>&out
	 * @Inputs Empty &out TSet<FVector>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAssign_FVector(TSet<FVector>&out Result)
	{
		TSet<FVector> Source;
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Source.Add(FVector(0.0f, 1.0f, 0.0f));
		Source.Add(FVector(0.0f, 0.0f, 1.0f));
		Result = Source;
	}

	/**
	 * Inout: replace existing members by assigning a new set_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Set received as TSet<FVector>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values holds the canonical members
	 */
	UFUNCTION()
	void AssignInPlace_FVector(TSet<FVector>&inout Values)
	{
		TSet<FVector> Source;
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Source.Add(FVector(0.0f, 1.0f, 0.0f));
		Source.Add(FVector(0.0f, 0.0f, 1.0f));
		Values = Source;
	}


	/**
	 * opAssign copies members; mutating dest does not write the source_UObject.
	 *
	 * @Kind Observe
	 * @Covers TSet.opAssign
	 * @Inputs Dest starts with a dummy; Dest = Source; Dest.Add extra
	 * @Return true when Dest matches Source then Source stays independent
	 */
	UFUNCTION()
	bool AssignCopiesThenDestIsIndependent_UObject()
	{
		TSet<UObject> Source;
		UObject First = NewObject(GetTransientPackage(), UTSetCopyAssignObject::StaticClass(), n"TSetAssign_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTSetCopyAssignObject::StaticClass(), n"TSetAssign_Second", true);
		Source.Add(First);
		Source.Add(Second);
		TSet<UObject> Dest;
		Dest.Add(First);
		Dest = Source;
		if (Dest.Num() != 2 || !Dest.Contains(First) || !Dest.Contains(Second))
		{
			return false;
		}
		UObject Third = NewObject(GetTransientPackage(), UTSetCopyAssignObject::StaticClass(), n"TSetAssign_Third", true);
		Dest.Add(Third);
		return Source.Num() == 2 && !Source.Contains(Third) && Dest.Contains(Third);
	}

	/**
	 * In-only: read assigned members from a const&in TSet<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Source set received as const TSet<UObject>&in
	 * @Inputs Values holds the canonical members
	 * @Return true when Num matches
	 */
	UFUNCTION()
	bool ReadAssignedMembers_UObject(const TSet<UObject>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: assign a local source into an empty &out TSet<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Result Destination received as TSet<UObject>&out
	 * @Inputs Empty &out TSet<UObject>
	 * @Return void; Result holds the canonical members
	 */
	UFUNCTION()
	void FillSetByAssign_UObject(TSet<UObject>&out Result)
	{
		TSet<UObject> Source;
		Source.Add(NewObject(GetTransientPackage(), UTSetCopyAssignObject::StaticClass(), n"TSetAssign_Fill_0", true));
		Source.Add(NewObject(GetTransientPackage(), UTSetCopyAssignObject::StaticClass(), n"TSetAssign_Fill_1", true));
		Source.Add(NewObject(GetTransientPackage(), UTSetCopyAssignObject::StaticClass(), n"TSetAssign_Fill_2", true));
		Result = Source;
	}

	/**
	 * Inout: replace existing members by assigning a new set_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.opAssign
	 * @Param Values Set received as TSet<UObject>&inout
	 * @Inputs Values may be non-empty
	 * @Return void; Values holds the canonical members
	 */
	UFUNCTION()
	void AssignInPlace_UObject(TSet<UObject>&inout Values)
	{
		TSet<UObject> Source;
		Source.Add(NewObject(GetTransientPackage(), UTSetCopyAssignObject::StaticClass(), n"TSetAssign_In_0", true));
		Source.Add(NewObject(GetTransientPackage(), UTSetCopyAssignObject::StaticClass(), n"TSetAssign_In_1", true));
		Source.Add(NewObject(GetTransientPackage(), UTSetCopyAssignObject::StaticClass(), n"TSetAssign_In_2", true));
		Values = Source;
	}


	/**
	 * opEquals is true for the same members regardless of insertion order.
	 *
	 * @Kind Observe
	 * @Covers TSet.opEquals
	 * @Inputs [10, 20] vs same members inserted backwards vs a mismatch
	 * @Return true when equal members compare true and a mismatch compares false
	 */
	UFUNCTION()
	bool EqualsMatchesSameMembersRegardlessOfOrder()
	{
		TSet<int> Left;
		Left.Add(10);
		Left.Add(20);
		TSet<int> SameOrder;
		SameOrder.Add(20);
		SameOrder.Add(10);
		TSet<int> Different;
		Different.Add(10);
		Different.Add(21);
		return Left == SameOrder && !(Left == Different);
	}

}
