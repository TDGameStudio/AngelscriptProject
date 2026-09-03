/**
 * AddUnique appends only when the value is not already present.
 * First insert vs duplicate is observed locally, then through UFUNCTION in, out, and inout.
 *
 * int is the canonical case; other element types repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.AddUnique
 * @Harness Function
 * @Tag Containers.TArray.TArrayAddUnique
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayAddUniqueObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe AddUnique: first insert returns true, duplicate returns false and Num stays.
	 *
	 * @Kind Observe
	 * @Covers TArray.AddUnique
	 * @Inputs AddUnique 5, 10, 5, 15, 10
	 * @Return true when the array is [5, 10, 15] and duplicate calls returned false
	 */
	UFUNCTION()
	bool AddUniqueSkipsDuplicates()
	{
		TArray<int> Values;
		if (!Values.AddUnique(5) || !Values.AddUnique(10))
		{
			return false;
		}

		if (Values.AddUnique(5) || Values.Num() != 2)
		{
			return false;
		}

		if (!Values.AddUnique(15) || Values.AddUnique(10))
		{
			return false;
		}

		return Values.Num() == 3 && Values[0] == 5 && Values[1] == 10 && Values[2] == 15;
	}

	/**
	 * In-only: read unique order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [5, 10, 15]
	 * @Return true when Num() == 3 and elements are [5, 10, 15]
	 */
	UFUNCTION()
	bool ReadUniqueOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 3 && Values[0] == 5 && Values[1] == 10 && Values[2] == 15;
	}

	/**
	 * Out-only: fill an empty &out array with AddUnique, including a skipped duplicate.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [5, 10, 15]
	 */
	UFUNCTION()
	void FillArrayByAddUnique(TArray<int>&out Result)
	{
		Result.AddUnique(5);
		Result.AddUnique(10);
		Result.AddUnique(5);
		Result.AddUnique(15);
		Result.AddUnique(10);
	}

	/**
	 * Inout: AddUnique a new value and skip a duplicate on an existing [5, 10].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Array received as TArray<int>&inout, starts as [5, 10]
	 * @Inputs Values.Num() == 2 with [5, 10]
	 * @Return void; Values becomes [5, 10, 15]
	 */
	UFUNCTION()
	void AddUniqueInto(TArray<int>&inout Values)
	{
		Values.AddUnique(15);
		Values.AddUnique(10);
	}

	/**
	 * Observe AddUnique for float: first insert returns true, duplicate returns false.
	 *
	 * @Kind Observe
	 * @Covers TArray.AddUnique
	 * @Inputs AddUnique a, b, a, c, b
	 * @Return true when the array is [a, b, c] and duplicates returned false
	 */
	UFUNCTION()
	bool AddUniqueSkipsDuplicates_float()
	{
		TArray<float> Values;
		if (!Values.AddUnique(5.0f) || !Values.AddUnique(10.0f))
		{
			return false;
		}
		if (Values.AddUnique(5.0f) || Values.Num() != 2)
		{
			return false;
		}
		if (!Values.AddUnique(15.0f) || Values.AddUnique(10.0f))
		{
			return false;
		}
		return Values.Num() == 3 && Values[0] == 5.0f && Values[1] == 10.0f && Values[2] == 15.0f;
	}

	/**
	 * In-only: read unique float order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs [a, b, c]
	 * @Return true when Num() == 3 and order matches
	 */
	UFUNCTION()
	bool ReadUniqueOrder_float(const TArray<float>&in Values)
	{
		return Values.Num() == 3 && Values[0] == 5.0f && Values[1] == 10.0f && Values[2] == 15.0f;
	}

	/**
	 * Out-only: fill an empty &out float array with AddUnique, including a skipped duplicate.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result is [a, b, c]
	 */
	UFUNCTION()
	void FillArrayByAddUnique_float(TArray<float>&out Result)
	{
		Result.AddUnique(5.0f);
		Result.AddUnique(10.0f);
		Result.AddUnique(5.0f);
		Result.AddUnique(15.0f);
		Result.AddUnique(10.0f);
	}

	/**
	 * Inout: AddUnique a new float and skip a duplicate.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs [a, b]
	 * @Return void; Values becomes [a, b, c]
	 */
	UFUNCTION()
	void AddUniqueInto_float(TArray<float>&inout Values)
	{
		Values.AddUnique(15.0f);
		Values.AddUnique(10.0f);
	}

	/**
	 * Observe AddUnique for FString: first insert returns true, duplicate returns false.
	 *
	 * @Kind Observe
	 * @Covers TArray.AddUnique
	 * @Inputs AddUnique a, b, a, c, b
	 * @Return true when the array is [a, b, c] and duplicates returned false
	 */
	UFUNCTION()
	bool AddUniqueSkipsDuplicates_FString()
	{
		TArray<FString> Values;
		if (!Values.AddUnique("echo") || !Values.AddUnique("juliet"))
		{
			return false;
		}
		if (Values.AddUnique("echo") || Values.Num() != 2)
		{
			return false;
		}
		if (!Values.AddUnique("kilo") || Values.AddUnique("juliet"))
		{
			return false;
		}
		return Values.Num() == 3 && Values[0] == "echo" && Values[1] == "juliet" && Values[2] == "kilo";
	}

	/**
	 * In-only: read unique FString order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs [a, b, c]
	 * @Return true when Num() == 3 and order matches
	 */
	UFUNCTION()
	bool ReadUniqueOrder_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 3 && Values[0] == "echo" && Values[1] == "juliet" && Values[2] == "kilo";
	}

	/**
	 * Out-only: fill an empty &out FString array with AddUnique, including a skipped duplicate.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result is [a, b, c]
	 */
	UFUNCTION()
	void FillArrayByAddUnique_FString(TArray<FString>&out Result)
	{
		Result.AddUnique("echo");
		Result.AddUnique("juliet");
		Result.AddUnique("echo");
		Result.AddUnique("kilo");
		Result.AddUnique("juliet");
	}

	/**
	 * Inout: AddUnique a new FString and skip a duplicate.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs [a, b]
	 * @Return void; Values becomes [a, b, c]
	 */
	UFUNCTION()
	void AddUniqueInto_FString(TArray<FString>&inout Values)
	{
		Values.AddUnique("kilo");
		Values.AddUnique("juliet");
	}

	/**
	 * Observe AddUnique for FVector: first insert returns true, duplicate returns false.
	 *
	 * @Kind Observe
	 * @Covers TArray.AddUnique
	 * @Inputs AddUnique a, b, a, c, b
	 * @Return true when the array is [a, b, c] and duplicates returned false
	 */
	UFUNCTION()
	bool AddUniqueSkipsDuplicates_FVector()
	{
		TArray<FVector> Values;
		if (!Values.AddUnique(FVector(0.0f, 1.0f, 1.0f)) || !Values.AddUnique(FVector(2.0f, 0.0f, 0.0f)))
		{
			return false;
		}
		if (Values.AddUnique(FVector(0.0f, 1.0f, 1.0f)) || Values.Num() != 2)
		{
			return false;
		}
		if (!Values.AddUnique(FVector(0.0f, 2.0f, 0.0f)) || Values.AddUnique(FVector(2.0f, 0.0f, 0.0f)))
		{
			return false;
		}
		return Values.Num() == 3 && Values[0].Equals(FVector(0.0f, 1.0f, 1.0f)) && Values[1].Equals(FVector(2.0f, 0.0f, 0.0f)) && Values[2].Equals(FVector(0.0f, 2.0f, 0.0f));
	}

	/**
	 * In-only: read unique FVector order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs [a, b, c]
	 * @Return true when Num() == 3 and order matches
	 */
	UFUNCTION()
	bool ReadUniqueOrder_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 3 && Values[0].Equals(FVector(0.0f, 1.0f, 1.0f)) && Values[1].Equals(FVector(2.0f, 0.0f, 0.0f)) && Values[2].Equals(FVector(0.0f, 2.0f, 0.0f));
	}

	/**
	 * Out-only: fill an empty &out FVector array with AddUnique, including a skipped duplicate.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result is [a, b, c]
	 */
	UFUNCTION()
	void FillArrayByAddUnique_FVector(TArray<FVector>&out Result)
	{
		Result.AddUnique(FVector(0.0f, 1.0f, 1.0f));
		Result.AddUnique(FVector(2.0f, 0.0f, 0.0f));
		Result.AddUnique(FVector(0.0f, 1.0f, 1.0f));
		Result.AddUnique(FVector(0.0f, 2.0f, 0.0f));
		Result.AddUnique(FVector(2.0f, 0.0f, 0.0f));
	}

	/**
	 * Inout: AddUnique a new FVector and skip a duplicate.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs [a, b]
	 * @Return void; Values becomes [a, b, c]
	 */
	UFUNCTION()
	void AddUniqueInto_FVector(TArray<FVector>&inout Values)
	{
		Values.AddUnique(FVector(0.0f, 2.0f, 0.0f));
		Values.AddUnique(FVector(2.0f, 0.0f, 0.0f));
	}

	/**
	 * Observe AddUnique for bool: only two unique values exist.
	 *
	 * @Kind Observe
	 * @Covers TArray.AddUnique
	 * @Inputs AddUnique true, false, true
	 * @Return true when the array is [true, false] and the duplicate returned false
	 */
	UFUNCTION()
	bool AddUniqueSkipsDuplicates_bool()
	{
		TArray<bool> Values;
		if (!Values.AddUnique(true) || !Values.AddUnique(false))
		{
			return false;
		}
		if (Values.AddUnique(true) || Values.Num() != 2)
		{
			return false;
		}
		return Values.Num() == 2 && Values[0] == true && Values[1] == false;
	}

	/**
	 * In-only: read unique bool order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs [true, false]
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadUniqueOrder_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 2 && Values[0] == true && Values[1] == false;
	}

	/**
	 * Out-only: fill an empty &out bool array with AddUnique.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result becomes [true, false]
	 */
	UFUNCTION()
	void FillArrayByAddUnique_bool(TArray<bool>&out Result)
	{
		Result.AddUnique(true);
		Result.AddUnique(false);
		Result.AddUnique(true);
	}

	/**
	 * Inout: AddUnique false onto [true] and skip duplicate true.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs [true]
	 * @Return void; Values becomes [true, false]
	 */
	UFUNCTION()
	void AddUniqueInto_bool(TArray<bool>&inout Values)
	{
		Values.AddUnique(false);
		Values.AddUnique(true);
	}

	/**
	 * Observe AddUnique for UObject handles: first insert returns true, duplicate identity returns false.
	 *
	 * @Kind Observe
	 * @Covers TArray.AddUnique
	 * @Inputs AddUnique A, B, A, C, B
	 * @Return true when the array is [A, B, C]
	 */
	UFUNCTION()
	bool AddUniqueSkipsDuplicates_UObject()
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayAddUniqueObject::StaticClass(), n"TArrayAddUnique_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayAddUniqueObject::StaticClass(), n"TArrayAddUnique_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayAddUniqueObject::StaticClass(), n"TArrayAddUnique_C", true);
		if (A == nullptr || B == nullptr || C == nullptr)
		{
			return false;
		}
		TArray<UObject> Values;
		if (!Values.AddUnique(A) || !Values.AddUnique(B))
		{
			return false;
		}
		if (Values.AddUnique(A) || Values.Num() != 2)
		{
			return false;
		}
		if (!Values.AddUnique(C) || Values.AddUnique(B))
		{
			return false;
		}
		return Values.Num() == 3 && Values[0] == A && Values[1] == B && Values[2] == C;
	}

	/**
	 * In-only: read unique UObject order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs three distinct handles
	 * @Return true when Num() == 3 and identities differ
	 */
	UFUNCTION()
	bool ReadUniqueOrder_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 3 && Values[0] != Values[1] && Values[1] != Values[2] && Values[0] != Values[2];
	}

	/**
	 * Out-only: fill an empty &out UObject array with AddUnique, including a skipped duplicate.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result has three distinct handles
	 */
	UFUNCTION()
	void FillArrayByAddUnique_UObject(TArray<UObject>&out Result)
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayAddUniqueObject::StaticClass(), n"TArrayAddUnique_Fill_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayAddUniqueObject::StaticClass(), n"TArrayAddUnique_Fill_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayAddUniqueObject::StaticClass(), n"TArrayAddUnique_Fill_C", true);
		Result.AddUnique(A);
		Result.AddUnique(B);
		Result.AddUnique(A);
		Result.AddUnique(C);
		Result.AddUnique(B);
	}

	/**
	 * Inout: AddUnique a new handle and skip a duplicate identity.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.AddUnique
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs two distinct handles
	 * @Return void; Values.Num() becomes 3
	 */
	UFUNCTION()
	void AddUniqueInto_UObject(TArray<UObject>&inout Values)
	{
		Values.AddUnique(NewObject(GetTransientPackage(), UTArrayAddUniqueObject::StaticClass(), n"TArrayAddUnique_Inout", true));
		UObject Duplicate = Values[1];
		Values.AddUnique(Duplicate);
	}

}
