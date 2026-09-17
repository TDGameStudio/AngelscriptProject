/**
 * @version v1
 * @summary FindIndex returns the first matching slot, or -1 when absent. Hits and misses are observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types repeat the same four entries.
 * @topic Containers
 */
/**
 * @version root
 * @summary FindIndex returns the first matching slot, or -1 when absent. Hits and misses are observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types repeat the same four entries.
 * @topic Baseline
 */
UCLASS()
class UTArrayFindObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe FindIndex: hit, first duplicate, miss.
	 *
	 * @Kind Observe
	 * @Covers TArray.FindIndex
	 * @Inputs TArray<int> [100, 200, 300, 200]; FindIndex 100/200/300/999
	 * @Return true when indices are 0, 1, 2, and -1
	 */
	UFUNCTION()
	bool FindIndexHitsFirstAndMissesAbsent()
	{
		TArray<int> Values;
		Values.Add(100);
		Values.Add(200);
		Values.Add(300);
		Values.Add(200);
		return Values.FindIndex(100) == 0
			&& Values.FindIndex(200) == 1
			&& Values.FindIndex(300) == 2
			&& Values.FindIndex(999) == -1;
	}

	/**
	 * In-only: FindIndex on a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [100, 200, 300, 200]
	 * @Return true when FindIndex 100/200/300/999 is 0, 1, 2, and -1
	 */
	UFUNCTION()
	bool ReadFindIndex(const TArray<int>&in Values)
	{
		return Values.FindIndex(100) == 0
			&& Values.FindIndex(200) == 1
			&& Values.FindIndex(300) == 2
			&& Values.FindIndex(999) == -1;
	}

	/**
	 * Out-only: fill an empty &out array with the FindIndex sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [100, 200, 300, 200]
	 */
	UFUNCTION()
	void FillArrayForFindIndex(TArray<int>&out Result)
	{
		Result.Add(100);
		Result.Add(200);
		Result.Add(300);
		Result.Add(200);
	}

	/**
	 * Inout: append a duplicate 200 so FindIndex still hits the first slot.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Array received as TArray<int>&inout, starts as [100, 200, 300]
	 * @Inputs Values.Num() == 3 with [100, 200, 300]
	 * @Return void; Values becomes [100, 200, 300, 200]
	 */
	UFUNCTION()
	void AppendDuplicateForFindIndex(TArray<int>&inout Values)
	{
		Values.Add(200);
	}

	/**
	 * Observe FindIndex for float: hit, first duplicate, miss.
	 *
	 * @Kind Observe
	 * @Covers TArray.FindIndex
	 * @Inputs [a, b, c, b]; FindIndex a/b/c/miss
	 * @Return true when indices are 0, 1, 2, and -1
	 */
	UFUNCTION()
	bool FindIndexHitsFirstAndMissesAbsent_float()
	{
		TArray<float> Values;
		Values.Add(100.0f);
		Values.Add(200.0f);
		Values.Add(300.0f);
		Values.Add(200.0f);
		return Values.FindIndex(100.0f) == 0 && Values.FindIndex(200.0f) == 1 && Values.FindIndex(300.0f) == 2 && Values.FindIndex(999.0f) == -1;
	}

	/**
	 * In-only: FindIndex on a const&in float array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs [a, b, c, b]
	 * @Return true when indices are 0, 1, 2, and -1
	 */
	UFUNCTION()
	bool ReadFindIndex_float(const TArray<float>&in Values)
	{
		return Values.FindIndex(100.0f) == 0 && Values.FindIndex(200.0f) == 1 && Values.FindIndex(300.0f) == 2 && Values.FindIndex(999.0f) == -1;
	}

	/**
	 * Out-only: fill an empty &out float array with the FindIndex sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result becomes [a, b, c, b]
	 */
	UFUNCTION()
	void FillArrayForFindIndex_float(TArray<float>&out Result)
	{
		Result.Add(100.0f);
		Result.Add(200.0f);
		Result.Add(300.0f);
		Result.Add(200.0f);
	}

	/**
	 * Inout: append a duplicate float so FindIndex still hits the first slot.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs [a, b, c]
	 * @Return void; Values becomes [a, b, c, b]
	 */
	UFUNCTION()
	void AppendDuplicateForFindIndex_float(TArray<float>&inout Values)
	{
		Values.Add(200.0f);
	}

	/**
	 * Observe FindIndex for FString: hit, first duplicate, miss.
	 *
	 * @Kind Observe
	 * @Covers TArray.FindIndex
	 * @Inputs [a, b, c, b]; FindIndex a/b/c/miss
	 * @Return true when indices are 0, 1, 2, and -1
	 */
	UFUNCTION()
	bool FindIndexHitsFirstAndMissesAbsent_FString()
	{
		TArray<FString> Values;
		Values.Add("romeo");
		Values.Add("sierra");
		Values.Add("tango");
		Values.Add("sierra");
		return Values.FindIndex("romeo") == 0 && Values.FindIndex("sierra") == 1 && Values.FindIndex("tango") == 2 && Values.FindIndex("zulu") == -1;
	}

	/**
	 * In-only: FindIndex on a const&in FString array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs [a, b, c, b]
	 * @Return true when indices are 0, 1, 2, and -1
	 */
	UFUNCTION()
	bool ReadFindIndex_FString(const TArray<FString>&in Values)
	{
		return Values.FindIndex("romeo") == 0 && Values.FindIndex("sierra") == 1 && Values.FindIndex("tango") == 2 && Values.FindIndex("zulu") == -1;
	}

	/**
	 * Out-only: fill an empty &out FString array with the FindIndex sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result becomes [a, b, c, b]
	 */
	UFUNCTION()
	void FillArrayForFindIndex_FString(TArray<FString>&out Result)
	{
		Result.Add("romeo");
		Result.Add("sierra");
		Result.Add("tango");
		Result.Add("sierra");
	}

	/**
	 * Inout: append a duplicate FString so FindIndex still hits the first slot.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs [a, b, c]
	 * @Return void; Values becomes [a, b, c, b]
	 */
	UFUNCTION()
	void AppendDuplicateForFindIndex_FString(TArray<FString>&inout Values)
	{
		Values.Add("sierra");
	}

	/**
	 * Observe FindIndex for FVector: hit, first duplicate, miss.
	 *
	 * @Kind Observe
	 * @Covers TArray.FindIndex
	 * @Inputs [a, b, c, b]; FindIndex a/b/c/miss
	 * @Return true when indices are 0, 1, 2, and -1
	 */
	UFUNCTION()
	bool FindIndexHitsFirstAndMissesAbsent_FVector()
	{
		TArray<FVector> Values;
		Values.Add(FVector(4.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 4.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 4.0f));
		Values.Add(FVector(0.0f, 4.0f, 0.0f));
		return Values.FindIndex(FVector(4.0f, 0.0f, 0.0f)) == 0 && Values.FindIndex(FVector(0.0f, 4.0f, 0.0f)) == 1 && Values.FindIndex(FVector(0.0f, 0.0f, 4.0f)) == 2 && Values.FindIndex(FVector(9.0f, 0.0f, 0.0f)) == -1;
	}

	/**
	 * In-only: FindIndex on a const&in FVector array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs [a, b, c, b]
	 * @Return true when indices are 0, 1, 2, and -1
	 */
	UFUNCTION()
	bool ReadFindIndex_FVector(const TArray<FVector>&in Values)
	{
		return Values.FindIndex(FVector(4.0f, 0.0f, 0.0f)) == 0 && Values.FindIndex(FVector(0.0f, 4.0f, 0.0f)) == 1 && Values.FindIndex(FVector(0.0f, 0.0f, 4.0f)) == 2 && Values.FindIndex(FVector(9.0f, 0.0f, 0.0f)) == -1;
	}

	/**
	 * Out-only: fill an empty &out FVector array with the FindIndex sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result becomes [a, b, c, b]
	 */
	UFUNCTION()
	void FillArrayForFindIndex_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(4.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 4.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 4.0f));
		Result.Add(FVector(0.0f, 4.0f, 0.0f));
	}

	/**
	 * Inout: append a duplicate FVector so FindIndex still hits the first slot.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs [a, b, c]
	 * @Return void; Values becomes [a, b, c, b]
	 */
	UFUNCTION()
	void AppendDuplicateForFindIndex_FVector(TArray<FVector>&inout Values)
	{
		Values.Add(FVector(0.0f, 4.0f, 0.0f));
	}

	/**
	 * Observe FindIndex for bool: first false, first true. Both values exist so there is no miss.
	 *
	 * @Kind Observe
	 * @Covers TArray.FindIndex
	 * @Inputs [false, true, false, true]
	 * @Return true when FindIndex(false)==0 and FindIndex(true)==1
	 */
	UFUNCTION()
	bool FindIndexHitsFirstAndMissesAbsent_bool()
	{
		TArray<bool> Values;
		Values.Add(false);
		Values.Add(true);
		Values.Add(false);
		Values.Add(true);
		return Values.FindIndex(false) == 0 && Values.FindIndex(true) == 1;
	}

	/**
	 * In-only: FindIndex on a const&in bool array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs [false, true, false, true]
	 * @Return true when FindIndex(false)==0 and FindIndex(true)==1
	 */
	UFUNCTION()
	bool ReadFindIndex_bool(const TArray<bool>&in Values)
	{
		return Values.FindIndex(false) == 0 && Values.FindIndex(true) == 1;
	}

	/**
	 * Out-only: fill an empty &out bool array with the FindIndex sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result becomes [false, true, false, true]
	 */
	UFUNCTION()
	void FillArrayForFindIndex_bool(TArray<bool>&out Result)
	{
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
		Result.Add(true);
	}

	/**
	 * Inout: append a duplicate true so FindIndex still hits the first true.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs [false, true, false]
	 * @Return void; Values becomes [false, true, false, true]
	 */
	UFUNCTION()
	void AppendDuplicateForFindIndex_bool(TArray<bool>&inout Values)
	{
		Values.Add(true);
	}

	/**
	 * Observe FindIndex for UObject handles: hit, first duplicate, miss.
	 *
	 * @Kind Observe
	 * @Covers TArray.FindIndex
	 * @Inputs [A, B, C, B]; FindIndex A/B/C/stranger
	 * @Return true when indices are 0, 1, 2, and -1
	 */
	UFUNCTION()
	bool FindIndexHitsFirstAndMissesAbsent_UObject()
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayFindObject::StaticClass(), n"TArrayFind_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayFindObject::StaticClass(), n"TArrayFind_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayFindObject::StaticClass(), n"TArrayFind_C", true);
		UObject Miss = NewObject(GetTransientPackage(), UTArrayFindObject::StaticClass(), n"TArrayFind_Miss", true);
		if (A == nullptr || B == nullptr || C == nullptr || Miss == nullptr)
		{
			return false;
		}
		TArray<UObject> Values;
		Values.Add(A);
		Values.Add(B);
		Values.Add(C);
		Values.Add(B);
		return Values.FindIndex(A) == 0 && Values.FindIndex(B) == 1 && Values.FindIndex(C) == 2 && Values.FindIndex(Miss) == -1;
	}

	/**
	 * In-only: FindIndex on a const&in UObject array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs [A, B, C, B]
	 * @Return true when FindIndex(Values[0])==0 and FindIndex of a later duplicate is 1
	 */
	UFUNCTION()
	bool ReadFindIndex_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 4 && Values.FindIndex(Values[0]) == 0 && Values.FindIndex(Values[1]) == 1 && Values.FindIndex(Values[2]) == 2;
	}

	/**
	 * Out-only: fill an empty &out UObject array with a duplicate handle.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result is [A, B, C, B]
	 */
	UFUNCTION()
	void FillArrayForFindIndex_UObject(TArray<UObject>&out Result)
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayFindObject::StaticClass(), n"TArrayFind_Fill_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayFindObject::StaticClass(), n"TArrayFind_Fill_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayFindObject::StaticClass(), n"TArrayFind_Fill_C", true);
		Result.Add(A);
		Result.Add(B);
		Result.Add(C);
		Result.Add(B);
	}

	/**
	 * Inout: append Values[1] again so FindIndex still hits the first duplicate.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() becomes 4
	 */
	UFUNCTION()
	void AppendDuplicateForFindIndex_UObject(TArray<UObject>&inout Values)
	{
		UObject Duplicate = Values[1];
		Values.Add(Duplicate);
	}

}
/** @end */
