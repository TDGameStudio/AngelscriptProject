/**
 * Contains is true for present elements and false for absent ones.
 * Empty Contains is also a first step here; EmptyConstruction owns the empty
 * type matrix. Presence is observed locally, then through UFUNCTION in, out, and inout.
 *
 * int is the canonical case; other element types repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Contains
 * @Harness Function
 * @Tag Containers.TArray.TArrayContains
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayContainsObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Empty array contains nothing; after Add, present values match and others do not.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs Default-constructed TArray<int>; Contains(5); Add(5); Contains(5/9); Add(1,2,3)
	 * @Return true when empty is false, 5 is present, 9 is absent, and 1/2/3 are present
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent()
	{
		TArray<int> Array;
		if (Array.Contains(5))
		{
			return false;
		}

		Array.Add(5);
		if (!Array.Contains(5) || Array.Contains(9))
		{
			return false;
		}

		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		return Array.Contains(5)
			&& Array.Contains(1)
			&& Array.Contains(2)
			&& Array.Contains(3)
			&& !Array.Contains(4);
	}

	/**
	 * In-only: Contains on a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [5, 1, 2, 3]
	 * @Return true when 5/1/2/3 are present and 4/9 are absent
	 */
	UFUNCTION()
	bool ReadContains(const TArray<int>&in Values)
	{
		return Values.Contains(5)
			&& Values.Contains(1)
			&& Values.Contains(2)
			&& Values.Contains(3)
			&& !Values.Contains(4)
			&& !Values.Contains(9);
	}

	/**
	 * Out-only: fill an empty &out array with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [5, 1, 2, 3]
	 */
	UFUNCTION()
	void FillArrayForContains(TArray<int>&out Result)
	{
		Result.Add(5);
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
	}

	/**
	 * Inout: Add 3 onto an existing [5, 1, 2] so Contains(3) becomes true.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Array received as TArray<int>&inout, starts as [5, 1, 2]
	 * @Inputs Values.Num() == 3 with [5, 1, 2]
	 * @Return void; Values becomes [5, 1, 2, 3]
	 */
	UFUNCTION()
	void AppendForContains(TArray<int>&inout Values)
	{
		Values.Add(3);
	}

	/**
	 * Empty float array contains nothing; after Add, present values match and others do not.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs TArray<float>; Contains miss; Add present values
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent_float()
	{
		TArray<float> Array;
		if (Array.Contains(5.0f))
		{
			return false;
		}
		Array.Add(5.0f);
		if (!Array.Contains(5.0f) || Array.Contains(9.0f))
		{
			return false;
		}
		Array.Add(1.0f);
		Array.Add(2.0f);
		Array.Add(3.0f);
		return Array.Contains(5.0f) && Array.Contains(1.0f) && Array.Contains(2.0f) && Array.Contains(3.0f) && !Array.Contains(4.0f);
	}

	/**
	 * In-only: Contains on a const&in float array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs four present values
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ReadContains_float(const TArray<float>&in Values)
	{
		return Values.Contains(5.0f) && Values.Contains(1.0f) && Values.Contains(2.0f) && Values.Contains(3.0f)
			&& !Values.Contains(4.0f) && !Values.Contains(9.0f);
	}

	/**
	 * Out-only: fill an empty &out float array with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result has the four present values
	 */
	UFUNCTION()
	void FillArrayForContains_float(TArray<float>&out Result)
	{
		Result.Add(5.0f);
		Result.Add(1.0f);
		Result.Add(2.0f);
		Result.Add(3.0f);
	}

	/**
	 * Inout: Add the last present float so Contains becomes true.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs three present values
	 * @Return void; last present value appended
	 */
	UFUNCTION()
	void AppendForContains_float(TArray<float>&inout Values)
	{
		Values.Add(3.0f);
	}

	/**
	 * Empty FString array contains nothing; after Add, present values match and others do not.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs TArray<FString>; Contains miss; Add present values
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent_FString()
	{
		TArray<FString> Array;
		if (Array.Contains("echo"))
		{
			return false;
		}
		Array.Add("echo");
		if (!Array.Contains("echo") || Array.Contains("india"))
		{
			return false;
		}
		Array.Add("alpha");
		Array.Add("beta");
		Array.Add("gamma");
		return Array.Contains("echo") && Array.Contains("alpha") && Array.Contains("beta") && Array.Contains("gamma") && !Array.Contains("delta");
	}

	/**
	 * In-only: Contains on a const&in FString array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs four present values
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ReadContains_FString(const TArray<FString>&in Values)
	{
		return Values.Contains("echo") && Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma")
			&& !Values.Contains("delta") && !Values.Contains("india");
	}

	/**
	 * Out-only: fill an empty &out FString array with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result has the four present values
	 */
	UFUNCTION()
	void FillArrayForContains_FString(TArray<FString>&out Result)
	{
		Result.Add("echo");
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
	}

	/**
	 * Inout: Add the last present FString so Contains becomes true.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs three present values
	 * @Return void; last present value appended
	 */
	UFUNCTION()
	void AppendForContains_FString(TArray<FString>&inout Values)
	{
		Values.Add("gamma");
	}

	/**
	 * Empty FVector array contains nothing; after Add, present values match and others do not.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs TArray<FVector>; Contains miss; Add present values
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent_FVector()
	{
		TArray<FVector> Array;
		if (Array.Contains(FVector(0.0f, 1.0f, 1.0f)))
		{
			return false;
		}
		Array.Add(FVector(0.0f, 1.0f, 1.0f));
		if (!Array.Contains(FVector(0.0f, 1.0f, 1.0f)) || Array.Contains(FVector(1.0f, 1.0f, 1.0f)))
		{
			return false;
		}
		Array.Add(FVector(1.0f, 0.0f, 0.0f));
		Array.Add(FVector(0.0f, 1.0f, 0.0f));
		Array.Add(FVector(0.0f, 0.0f, 1.0f));
		return Array.Contains(FVector(0.0f, 1.0f, 1.0f)) && Array.Contains(FVector(1.0f, 0.0f, 0.0f)) && Array.Contains(FVector(0.0f, 1.0f, 0.0f)) && Array.Contains(FVector(0.0f, 0.0f, 1.0f)) && !Array.Contains(FVector(1.0f, 1.0f, 0.0f));
	}

	/**
	 * In-only: Contains on a const&in FVector array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs four present values
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	bool ReadContains_FVector(const TArray<FVector>&in Values)
	{
		return Values.Contains(FVector(0.0f, 1.0f, 1.0f)) && Values.Contains(FVector(1.0f, 0.0f, 0.0f)) && Values.Contains(FVector(0.0f, 1.0f, 0.0f)) && Values.Contains(FVector(0.0f, 0.0f, 1.0f))
			&& !Values.Contains(FVector(1.0f, 1.0f, 0.0f)) && !Values.Contains(FVector(1.0f, 1.0f, 1.0f));
	}

	/**
	 * Out-only: fill an empty &out FVector array with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result has the four present values
	 */
	UFUNCTION()
	void FillArrayForContains_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(0.0f, 1.0f, 1.0f));
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: Add the last present FVector so Contains becomes true.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs three present values
	 * @Return void; last present value appended
	 */
	UFUNCTION()
	void AppendForContains_FVector(TArray<FVector>&inout Values)
	{
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Empty bool array contains nothing; after Add, both values are present.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs Contains(true) on empty; Add(true); Add(false)
	 * @Return true when empty is false and both values are present
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent_bool()
	{
		TArray<bool> Array;
		if (Array.Contains(true))
		{
			return false;
		}
		Array.Add(true);
		if (!Array.Contains(true) || Array.Contains(false))
		{
			return false;
		}
		Array.Add(false);
		return Array.Contains(true) && Array.Contains(false);
	}

	/**
	 * In-only: Contains on a const&in bool array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs [true, false]
	 * @Return true when both values are present
	 */
	UFUNCTION()
	bool ReadContains_bool(const TArray<bool>&in Values)
	{
		return Values.Contains(true) && Values.Contains(false);
	}

	/**
	 * Out-only: fill an empty &out bool array with both values.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result becomes [true, false]
	 */
	UFUNCTION()
	void FillArrayForContains_bool(TArray<bool>&out Result)
	{
		Result.Add(true);
		Result.Add(false);
	}

	/**
	 * Inout: Add false onto an existing [true] so Contains(false) becomes true.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs [true]
	 * @Return void; Values becomes [true, false]
	 */
	UFUNCTION()
	void AppendForContains_bool(TArray<bool>&inout Values)
	{
		Values.Add(false);
	}

	/**
	 * Empty UObject array contains nothing; after Add, present handles match and others do not.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs NewObject temps; Contains miss then present
	 * @Return true when present handles match and a stranger does not
	 */
	UFUNCTION()
	bool ContainsPresentAndAbsent_UObject()
	{
		TArray<UObject> Array;
		UObject Present = NewObject(GetTransientPackage(), UTArrayContainsObject::StaticClass(), n"TArrayContains_Present", true);
		UObject Stranger = NewObject(GetTransientPackage(), UTArrayContainsObject::StaticClass(), n"TArrayContains_Stranger", true);
		if (Present == nullptr || Stranger == nullptr || Array.Contains(Present))
		{
			return false;
		}
		Array.Add(Present);
		if (!Array.Contains(Present) || Array.Contains(Stranger))
		{
			return false;
		}
		UObject Extra = NewObject(GetTransientPackage(), UTArrayContainsObject::StaticClass(), n"TArrayContains_Extra", true);
		Array.Add(Extra);
		return Array.Contains(Present) && Array.Contains(Extra) && !Array.Contains(Stranger);
	}

	/**
	 * In-only: Contains on a const&in UObject array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs two distinct non-null handles
	 * @Return true when both handles are present
	 */
	UFUNCTION()
	bool ReadContains_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 2 && Values.Contains(Values[0]) && Values.Contains(Values[1]);
	}

	/**
	 * Out-only: fill an empty &out UObject array with two handles.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result has two distinct handles
	 */
	UFUNCTION()
	void FillArrayForContains_UObject(TArray<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTArrayContainsObject::StaticClass(), n"TArrayContains_Fill_0", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayContainsObject::StaticClass(), n"TArrayContains_Fill_1", true));
	}

	/**
	 * Inout: Add one more UObject handle so Contains can see a new identity.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Contains
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() becomes 3
	 */
	UFUNCTION()
	void AppendForContains_UObject(TArray<UObject>&inout Values)
	{
		Values.Add(NewObject(GetTransientPackage(), UTArrayContainsObject::StaticClass(), n"TArrayContains_Append", true));
	}

}
