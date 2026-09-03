/**
 * TArray/TMap/TSet in, out, inout, and return. CountArray({10,15,17}) is 42
 * and LastArrayCount 3. FillArray writes 7,11,13. ScoreMap Alpha20+Beta20 is
 * 42 and LastMapScore 40. FillMap writes Gamma17 Delta19. MutateSet({5}) Num
 * is 2, adds 42, and bSetInoutSawOriginal is true. ReturnArray is 3/4/5.
 * Empty CountArray is 0. Empty MutateSet does not see original 5 and Num
 * becomes 1.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ContainerParameterAndReturnReflectionMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.ContainerParameterAndReturnReflectionMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: TArray/TMap/TSet in, out, inout, and return.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::ContainerParameterAndReturnReflectionMatrix
 * @Provenance Oracle: CountArray({10,15,17})==42 LastArrayCount 3; FillArray writes 7,11,13;
 * @Provenance ScoreMap Alpha20+Beta20==42 LastMapScore 40; FillMap Gamma17 Delta19;
 * @Provenance MutateSet({5}) Num 2 adds 42 and bSetInoutSawOriginal true;
 * @Provenance ReturnArray 3/4/5; ReturnMap ReturnA 23 ReturnB 29; ReturnSet 31 and 37.
 * @Provenance Extra: empty CountArray 0; empty MutateSet does not see original 5, Num becomes 1.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionContainerActor : AActor
{
	UPROPERTY()
	int LastArrayCount = 0;

	UPROPERTY()
	int LastMapScore = 0;

	UPROPERTY()
	bool bSetInoutSawOriginal = false;

	/**
	 * Sum Values and store LastArrayCount.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Values Integers received as const TArray<int>&in
	 * @Inputs Values
	 * @Return the array sum
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	int CountArray(const TArray<int>&in Values)
	{
		LastArrayCount = Values.Num();
		int Total = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			Total += Values[Index];
		}
		return Total;
	}

	/**
	 * Fill an out array with 7, 11, and 13.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Values Destination received as TArray<int>&out
	 * @Inputs empty Values
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	void FillArray(TArray<int>&out Values)
	{
		Values.Add(7);
		Values.Add(11);
		Values.Add(13);
	}

	/**
	 * Score Alpha plus Beta and return that plus Num.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Scores Name-to-int map
	 * @Inputs Scores
	 * @Return LastMapScore + Scores.Num()
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	int ScoreMap(TMap<FName, int> Scores)
	{
		int Alpha = 0;
		int Beta = 0;
		Scores.Find(n"Alpha", Alpha);
		Scores.Find(n"Beta", Beta);
		LastMapScore = Alpha + Beta;
		return LastMapScore + Scores.Num();
	}

	/**
	 * Fill an out map with Gamma 17 and Delta 19.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Scores Destination received as TMap<FName, int>&out
	 * @Inputs empty Scores
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	void FillMap(TMap<FName, int>&out Scores)
	{
		Scores.Add(n"Gamma", 17);
		Scores.Add(n"Delta", 19);
	}

	/**
	 * Add 42 into Values and report whether 5 was already present.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Values Slot received as TSet<int>&inout
	 * @Inputs Values
	 * @Return Values.Num() after adding 42
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	int MutateSet(TSet<int>&inout Values)
	{
		bSetInoutSawOriginal = Values.Contains(5);
		Values.Add(42);
		return Values.Num();
	}

	/**
	 * Return {3, 4, 5}.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return a three-element array
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	TArray<int> ReturnArray()
	{
		TArray<int> Values;
		Values.Add(3);
		Values.Add(4);
		Values.Add(5);
		return Values;
	}

	/**
	 * Return ReturnA 23 and ReturnB 29.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return a two-entry map
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	TMap<FName, int> ReturnMap()
	{
		TMap<FName, int> Scores;
		Scores.Add(n"ReturnA", 23);
		Scores.Add(n"ReturnB", 29);
		return Scores;
	}

	/**
	 * Return {31, 37}.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return a two-element set
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	TSet<int> ReturnSet()
	{
		TSet<int> Values;
		Values.Add(31);
		Values.Add(37);
		return Values;
	}

	/**
	 * Observe CountArray({10, 15, 17}).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs CountArray with 10, 15, 17
	 * @Return 42
	 */
	UFUNCTION()
	int ContainerCountArrayLive()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(15);
		Values.Add(17);
		return CountArray(Values);
	}

	/**
	 * Observe CountArray of an empty array.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs CountArray with no elements
	 * @Return 0
	 * @Boundary empty array
	 */
	UFUNCTION()
	int ContainerCountArrayEmpty()
	{
		TArray<int> Values;
		return CountArray(Values);
	}

	/**
	 * Observe FillArray writing 7, 11, and 13.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs FillArray on an empty out slot
	 * @Return true when Num is 3 and the values are 7, 11, 13
	 */
	UFUNCTION()
	bool ContainerFillArray()
	{
		TArray<int> Values;
		FillArray(Values);
		if (Values.Num() != 3)
		{
			return false;
		}
		if (Values[0] != 7)
		{
			return false;
		}
		if (Values[1] != 11)
		{
			return false;
		}
		return Values[2] == 13;
	}

	/**
	 * Observe ScoreMap Alpha 20 and Beta 20.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs ScoreMap with Alpha 20 and Beta 20
	 * @Return 42
	 */
	UFUNCTION()
	int ContainerScoreMapLive()
	{
		TMap<FName, int> Scores;
		Scores.Add(n"Alpha", 20);
		Scores.Add(n"Beta", 20);
		return ScoreMap(Scores);
	}

	/**
	 * Observe FillMap writing Gamma 17 and Delta 19.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs FillMap on an empty out slot
	 * @Return true when Num is 2, Gamma is 17, and Delta is 19
	 */
	UFUNCTION()
	bool ContainerFillMap()
	{
		TMap<FName, int> Scores;
		FillMap(Scores);
		int Gamma = 0;
		int Delta = 0;
		Scores.Find(n"Gamma", Gamma);
		Scores.Find(n"Delta", Delta);
		if (Scores.Num() != 2)
		{
			return false;
		}
		if (Gamma != 17)
		{
			return false;
		}
		return Delta == 19;
	}

	/**
	 * Observe MutateSet starting with {5}.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs MutateSet with 5 already present
	 * @Return 2 when the original 5 was seen and 42 was added, otherwise -1
	 */
	UFUNCTION()
	int ContainerMutateSetLive()
	{
		TSet<int> Values;
		Values.Add(5);
		int Num = MutateSet(Values);
		if (!bSetInoutSawOriginal)
		{
			return -1;
		}
		if (!Values.Contains(42))
		{
			return -1;
		}
		return Num;
	}

	/**
	 * Observe MutateSet starting empty.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs MutateSet with no elements
	 * @Return 1 when the original 5 was not seen, otherwise -1
	 * @Boundary empty set
	 */
	UFUNCTION()
	int ContainerMutateSetEmptyBoundary()
	{
		TSet<int> Values;
		int Num = MutateSet(Values);
		if (bSetInoutSawOriginal)
		{
			return -1;
		}
		return Num;
	}

	/**
	 * Observe ReturnArray, ReturnMap, and ReturnSet together.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnArray, ReturnMap, and ReturnSet
	 * @Return true when the returned containers match the oracle
	 */
	UFUNCTION()
	bool ContainerReturnContainers()
	{
		TArray<int> Values = ReturnArray();
		TMap<FName, int> Scores = ReturnMap();
		TSet<int> Unique = ReturnSet();
		int ReturnA = 0;
		int ReturnB = 0;
		Scores.Find(n"ReturnA", ReturnA);
		Scores.Find(n"ReturnB", ReturnB);
		if (Values.Num() != 3)
		{
			return false;
		}
		if (Values[0] != 3)
		{
			return false;
		}
		if (Values[1] != 4)
		{
			return false;
		}
		if (Values[2] != 5)
		{
			return false;
		}
		if (ReturnA != 23)
		{
			return false;
		}
		if (ReturnB != 29)
		{
			return false;
		}
		if (!Unique.Contains(31))
		{
			return false;
		}
		return Unique.Contains(37);
	}

	/**
	 * Observe the default LastArrayCount.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs LastArrayCount on a freshly constructed actor
	 * @Return 0
	 * @Boundary default LastArrayCount
	 */
	UFUNCTION()
	int ContainerDefaultArrayCount()
	{
		return LastArrayCount;
	}
}
