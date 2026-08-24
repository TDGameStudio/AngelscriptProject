// Theme: Definitions.UFunction. WorldStory: TArray/TMap/TSet in, out, inout, and return.
// C++: AngelscriptCoverageUFunctionTests.cpp::ContainerParameterAndReturnReflectionMatrix
// Oracle: CountArray({10,15,17})==42 LastArrayCount 3; FillArray writes 7,11,13;
// ScoreMap Alpha20+Beta20==42 LastMapScore 40; FillMap Gamma17 Delta19;
// MutateSet({5}) Num 2 adds 42 and bSetInoutSawOriginal true;
// ReturnArray 3/4/5; ReturnMap ReturnA 23 ReturnB 29; ReturnSet 31 and 37.
// Extra: empty CountArray 0; empty MutateSet does not see original 5, Num becomes 1.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionContainerActor : AActor
{
	UPROPERTY()
	int LastArrayCount = 0;

	UPROPERTY()
	int LastMapScore = 0;

	UPROPERTY()
	bool bSetInoutSawOriginal = false;

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

	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	void FillArray(TArray<int>&out Values)
	{
		Values.Add(7);
		Values.Add(11);
		Values.Add(13);
	}

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

	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	void FillMap(TMap<FName, int>&out Scores)
	{
		Scores.Add(n"Gamma", 17);
		Scores.Add(n"Delta", 19);
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	int MutateSet(TSet<int>&inout Values)
	{
		bSetInoutSawOriginal = Values.Contains(5);
		Values.Add(42);
		return Values.Num();
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	TArray<int> ReturnArray()
	{
		TArray<int> Values;
		Values.Add(3);
		Values.Add(4);
		Values.Add(5);
		return Values;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	TMap<FName, int> ReturnMap()
	{
		TMap<FName, int> Scores;
		Scores.Add(n"ReturnA", 23);
		Scores.Add(n"ReturnB", 29);
		return Scores;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Containers")
	TSet<int> ReturnSet()
	{
		TSet<int> Values;
		Values.Add(31);
		Values.Add(37);
		return Values;
	}
}

int Observe_Container_CountArrayNominal(ACoverageUFunctionContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	TArray<int> Values;
	Values.Add(10);
	Values.Add(15);
	Values.Add(17);
	return Actor.CountArray(Values);
}

int Observe_Container_CountArrayEmpty(ACoverageUFunctionContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	TArray<int> Values;
	return Actor.CountArray(Values);
}

bool Observe_Container_FillArray(ACoverageUFunctionContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	TArray<int> Values;
	Actor.FillArray(Values);
	return Values.Num() == 3 && Values[0] == 7 && Values[1] == 11 && Values[2] == 13;
}

int Observe_Container_ScoreMapNominal(ACoverageUFunctionContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	TMap<FName, int> Scores;
	Scores.Add(n"Alpha", 20);
	Scores.Add(n"Beta", 20);
	return Actor.ScoreMap(Scores);
}

bool Observe_Container_FillMap(ACoverageUFunctionContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	TMap<FName, int> Scores;
	Actor.FillMap(Scores);
	int Gamma = 0;
	int Delta = 0;
	Scores.Find(n"Gamma", Gamma);
	Scores.Find(n"Delta", Delta);
	return Scores.Num() == 2 && Gamma == 17 && Delta == 19;
}

int Observe_Container_MutateSetNominal(ACoverageUFunctionContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	TSet<int> Values;
	Values.Add(5);
	int Num = Actor.MutateSet(Values);
	if (!Actor.bSetInoutSawOriginal || !Values.Contains(42))
	{
		return -1;
	}
	return Num;
}

int Observe_Container_MutateSetEmptyBoundary(ACoverageUFunctionContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	TSet<int> Values;
	int Num = Actor.MutateSet(Values);
	if (Actor.bSetInoutSawOriginal)
	{
		return -1;
	}
	return Num;
}

bool Observe_Container_ReturnContainers(ACoverageUFunctionContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	TArray<int> Values = Actor.ReturnArray();
	TMap<FName, int> Scores = Actor.ReturnMap();
	TSet<int> Unique = Actor.ReturnSet();
	int ReturnA = 0;
	int ReturnB = 0;
	Scores.Find(n"ReturnA", ReturnA);
	Scores.Find(n"ReturnB", ReturnB);
	return Values.Num() == 3 && Values[0] == 3 && Values[1] == 4 && Values[2] == 5
		&& ReturnA == 23 && ReturnB == 29
		&& Unique.Contains(31) && Unique.Contains(37);
}

int Observe_Container_DefaultArrayCount(ACoverageUFunctionContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	return Actor.LastArrayCount;
}
