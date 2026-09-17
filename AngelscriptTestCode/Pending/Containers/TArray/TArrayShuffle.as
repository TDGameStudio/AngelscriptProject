/**
 * @version v1
 * @summary Shuffle permutes in place. Do not assert a fixed order. Num and multiset are observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types repeat the same four entries with a.
 * @topic Containers
 */
/**
 * @version root
 * @summary Shuffle permutes in place. Do not assert a fixed order. Num and multiset are observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types repeat the same four entries with a.
 * @topic Baseline
 */
UCLASS()
class UTArrayShuffleObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Shuffle: Num stays, the multiset stays.
	 *
	 * @Kind Observe
	 * @Covers TArray.Shuffle
	 * @Inputs [1, 2, 2, 3]; Shuffle()
	 * @Return true when Num is 4, 1 and 3 are present, and 2 occurs twice
	 */
	UFUNCTION()
	bool ShuffleKeepsNumAndMultiset()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(2);
		Values.Add(3);
		Values.Shuffle();

		int Twos = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index] == 2)
			{
				Twos++;
			}
		}
		return Values.Num() == 4
			&& Values.Contains(1)
			&& Values.Contains(3)
			&& Twos == 2;
	}

	/**
	 * In-only: read Num and multiset from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values has four slots: 1, 3, and two 2s in any order
	 * @Return true when Num is 4, 1 and 3 are present, and 2 occurs twice
	 */
	UFUNCTION()
	bool ReadShuffleMultiset(const TArray<int>&in Values)
	{
		int Twos = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index] == 2)
			{
				Twos++;
			}
		}
		return Values.Num() == 4
			&& Values.Contains(1)
			&& Values.Contains(3)
			&& Twos == 2;
	}

	/**
	 * Out-only: fill an empty &out array then Shuffle.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result.Num() == 4 with the same multiset as [1, 2, 2, 3]
	 */
	UFUNCTION()
	void FillAndShuffle(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(2);
		Result.Add(3);
		Result.Shuffle();
	}

	/**
	 * Inout: Shuffle the received array in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Array received as TArray<int>&inout, starts as [1, 2, 2, 3]
	 * @Inputs Values.Num() == 4 with [1, 2, 2, 3]
	 * @Return void; Values.Num() stays 4 and the multiset stays
	 */
	UFUNCTION()
	void ShuffleInPlace(TArray<int>&inout Values)
	{
		Values.Shuffle();
	}

	/**
	 * Observe Shuffle for float: Num stays, the multiset stays.
	 *
	 * @Kind Observe
	 * @Covers TArray.Shuffle
	 * @Inputs [a,b,b,c]; Shuffle()
	 * @Return true when Num is 4, a and c are present, and b occurs twice
	 */
	UFUNCTION()
	bool ShuffleKeepsNumAndMultiset_float()
	{
		TArray<float> Values;
		Values.Add(1.0f);
		Values.Add(2.0f);
		Values.Add(2.0f);
		Values.Add(3.0f);
		Values.Shuffle();
		int Twos = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index] == 2.0f)
			{
				Twos++;
			}
		}
		return Values.Num() == 4 && Values.Contains(1.0f) && Values.Contains(3.0f) && Twos == 2;
	}

	/**
	 * In-only: read Num and multiset from a const&in float array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs four slots: a, c, and two b's
	 * @Return true when Num is 4, a and c are present, and b occurs twice
	 */
	UFUNCTION()
	bool ReadShuffleMultiset_float(const TArray<float>&in Values)
	{
		int Twos = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index] == 2.0f)
			{
				Twos++;
			}
		}
		return Values.Num() == 4 && Values.Contains(1.0f) && Values.Contains(3.0f) && Twos == 2;
	}

	/**
	 * Out-only: fill an empty &out float array then Shuffle.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result.Num() == 4 with the same multiset
	 */
	UFUNCTION()
	void FillAndShuffle_float(TArray<float>&out Result)
	{
		Result.Add(1.0f);
		Result.Add(2.0f);
		Result.Add(2.0f);
		Result.Add(3.0f);
		Result.Shuffle();
	}

	/**
	 * Inout: Shuffle the received float array in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs [a,b,b,c]
	 * @Return void; Num stays 4 and the multiset stays
	 */
	UFUNCTION()
	void ShuffleInPlace_float(TArray<float>&inout Values)
	{
		Values.Shuffle();
	}

	/**
	 * Observe Shuffle for FString: Num stays, the multiset stays.
	 *
	 * @Kind Observe
	 * @Covers TArray.Shuffle
	 * @Inputs [a,b,b,c]; Shuffle()
	 * @Return true when Num is 4, a and c are present, and b occurs twice
	 */
	UFUNCTION()
	bool ShuffleKeepsNumAndMultiset_FString()
	{
		TArray<FString> Values;
		Values.Add("alpha");
		Values.Add("beta");
		Values.Add("beta");
		Values.Add("gamma");
		Values.Shuffle();
		int Twos = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index] == "beta")
			{
				Twos++;
			}
		}
		return Values.Num() == 4 && Values.Contains("alpha") && Values.Contains("gamma") && Twos == 2;
	}

	/**
	 * In-only: read Num and multiset from a const&in FString array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs four slots: a, c, and two b's
	 * @Return true when Num is 4, a and c are present, and b occurs twice
	 */
	UFUNCTION()
	bool ReadShuffleMultiset_FString(const TArray<FString>&in Values)
	{
		int Twos = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index] == "beta")
			{
				Twos++;
			}
		}
		return Values.Num() == 4 && Values.Contains("alpha") && Values.Contains("gamma") && Twos == 2;
	}

	/**
	 * Out-only: fill an empty &out FString array then Shuffle.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result.Num() == 4 with the same multiset
	 */
	UFUNCTION()
	void FillAndShuffle_FString(TArray<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("beta");
		Result.Add("gamma");
		Result.Shuffle();
	}

	/**
	 * Inout: Shuffle the received FString array in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs [a,b,b,c]
	 * @Return void; Num stays 4 and the multiset stays
	 */
	UFUNCTION()
	void ShuffleInPlace_FString(TArray<FString>&inout Values)
	{
		Values.Shuffle();
	}

	/**
	 * Observe Shuffle for FVector: Num stays, the multiset stays.
	 *
	 * @Kind Observe
	 * @Covers TArray.Shuffle
	 * @Inputs [a,b,b,c]; Shuffle()
	 * @Return true when Num is 4, a and c are present, and b occurs twice
	 */
	UFUNCTION()
	bool ShuffleKeepsNumAndMultiset_FVector()
	{
		TArray<FVector> Values;
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
		Values.Shuffle();
		int Twos = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index].Equals(FVector(0.0f, 1.0f, 0.0f)))
			{
				Twos++;
			}
		}
		return Values.Num() == 4 && Values.Contains(FVector(1.0f, 0.0f, 0.0f)) && Values.Contains(FVector(0.0f, 0.0f, 1.0f)) && Twos == 2;
	}

	/**
	 * In-only: read Num and multiset from a const&in FVector array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs four slots: a, c, and two b's
	 * @Return true when Num is 4, a and c are present, and b occurs twice
	 */
	UFUNCTION()
	bool ReadShuffleMultiset_FVector(const TArray<FVector>&in Values)
	{
		int Twos = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index].Equals(FVector(0.0f, 1.0f, 0.0f)))
			{
				Twos++;
			}
		}
		return Values.Num() == 4 && Values.Contains(FVector(1.0f, 0.0f, 0.0f)) && Values.Contains(FVector(0.0f, 0.0f, 1.0f)) && Twos == 2;
	}

	/**
	 * Out-only: fill an empty &out FVector array then Shuffle.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result.Num() == 4 with the same multiset
	 */
	UFUNCTION()
	void FillAndShuffle_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
		Result.Shuffle();
	}

	/**
	 * Inout: Shuffle the received FVector array in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs [a,b,b,c]
	 * @Return void; Num stays 4 and the multiset stays
	 */
	UFUNCTION()
	void ShuffleInPlace_FVector(TArray<FVector>&inout Values)
	{
		Values.Shuffle();
	}

	/**
	 * Observe Shuffle for bool: Num stays, the multiset stays.
	 *
	 * @Kind Observe
	 * @Covers TArray.Shuffle
	 * @Inputs [true, false, false, true]; Shuffle()
	 * @Return true when Num is 4 and false occurs twice
	 */
	UFUNCTION()
	bool ShuffleKeepsNumAndMultiset_bool()
	{
		TArray<bool> Values;
		Values.Add(true);
		Values.Add(false);
		Values.Add(false);
		Values.Add(true);
		Values.Shuffle();
		int Falses = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index] == false)
			{
				Falses++;
			}
		}
		return Values.Num() == 4 && Values.Contains(true) && Falses == 2;
	}

	/**
	 * In-only: read Num and multiset from a const&in bool array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs two true and two false
	 * @Return true when Num is 4 and false occurs twice
	 */
	UFUNCTION()
	bool ReadShuffleMultiset_bool(const TArray<bool>&in Values)
	{
		int Falses = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index] == false)
			{
				Falses++;
			}
		}
		return Values.Num() == 4 && Values.Contains(true) && Falses == 2;
	}

	/**
	 * Out-only: fill an empty &out bool array then Shuffle.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result.Num() == 4
	 */
	UFUNCTION()
	void FillAndShuffle_bool(TArray<bool>&out Result)
	{
		Result.Add(true);
		Result.Add(false);
		Result.Add(false);
		Result.Add(true);
		Result.Shuffle();
	}

	/**
	 * Inout: Shuffle the received bool array in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs Num() == 4
	 * @Return void; Num stays 4
	 */
	UFUNCTION()
	void ShuffleInPlace_bool(TArray<bool>&inout Values)
	{
		Values.Shuffle();
	}

	/**
	 * Observe Shuffle for UObject handles: Num stays, the multiset stays.
	 *
	 * @Kind Observe
	 * @Covers TArray.Shuffle
	 * @Inputs [A,B,B,C]; Shuffle()
	 * @Return true when Num is 4, A and C are present, and B occurs twice
	 */
	UFUNCTION()
	bool ShuffleKeepsNumAndMultiset_UObject()
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayShuffleObject::StaticClass(), n"TArrayShuffle_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayShuffleObject::StaticClass(), n"TArrayShuffle_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayShuffleObject::StaticClass(), n"TArrayShuffle_C", true);
		if (A == nullptr || B == nullptr || C == nullptr)
		{
			return false;
		}
		TArray<UObject> Values;
		Values.Add(A);
		Values.Add(B);
		Values.Add(B);
		Values.Add(C);
		Values.Shuffle();
		int Twos = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index] == B)
			{
				Twos++;
			}
		}
		return Values.Num() == 4 && Values.Contains(A) && Values.Contains(C) && Twos == 2;
	}

	/**
	 * In-only: read Num and multiset from a const&in UObject array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs four handles with one duplicate identity
	 * @Return true when Num is 4
	 */
	UFUNCTION()
	bool ReadShuffleMultiset_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 4;
	}

	/**
	 * Out-only: fill an empty &out UObject array then Shuffle.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 4
	 */
	UFUNCTION()
	void FillAndShuffle_UObject(TArray<UObject>&out Result)
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayShuffleObject::StaticClass(), n"TArrayShuffle_Fill_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayShuffleObject::StaticClass(), n"TArrayShuffle_Fill_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayShuffleObject::StaticClass(), n"TArrayShuffle_Fill_C", true);
		Result.Add(A);
		Result.Add(B);
		Result.Add(B);
		Result.Add(C);
		Result.Shuffle();
	}

	/**
	 * Inout: Shuffle the received UObject array in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Num() == 4
	 * @Return void; Num stays 4
	 */
	UFUNCTION()
	void ShuffleInPlace_UObject(TArray<UObject>&inout Values)
	{
		Values.Shuffle();
	}

}
/** @end */
