// Theme: Language.Syntax.EdgeCases. WorldStory container pass-by value/ref/out.
// C++: AngelscriptCoverageContainerAdvancedTests.cpp::ContainerAsParameter
// sha256=309b172c703247a378c43a6936f1cf2b390653f4cb1505926a19d8355fb1c3a3; lines 57-126.
// Oracle after BeginPlay: ResultByValue=6, ResultByRef=3, ResultByOut=3.
// Extra: empty array SumByValue is 0; local construct leaves results 0.
// FixtureIsolated.

UCLASS()
class ACoverageContainerParameterActor : AActor
{
	UPROPERTY()
	int ResultByValue;

	UPROPERTY()
	int ResultByRef;

	UPROPERTY()
	int ResultByOut;

	// Pass by value (copy)
	int SumByValue(TArray<int> Arr)
	{
		Print("=== SumByValue ===");
		int Sum = 0;
		for (int Val : Arr)
		{
			Sum += Val;
		}
		Print("Sum: " + Sum);
		return Sum;
	}

	// Pass by reference (can modify)
	void ModifyByRef(TArray<int>&inout Arr)
	{
		Print("=== ModifyByRef ===");
		Print("Before: " + Arr.Num());
		Arr.Add(999);
		Print("After: " + Arr.Num());
	}

	// Out parameter
	void FillOut(TArray<int>&out Result)
	{
		Print("=== FillOut ===");
		Result.Add(100);
		Result.Add(200);
		Result.Add(300);
		Print("Filled with " + Result.Num() + " elements");
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== Container as Parameter Test ===");

		// Test by value
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		ResultByValue = SumByValue(Values);
		Print("Original array still: " + Values.Num());

		// Test by reference
		TArray<int> RefArray;
		RefArray.Add(10);
		RefArray.Add(20);
		ModifyByRef(RefArray);
		ResultByRef = RefArray.Num();

		// Test out parameter
		TArray<int> OutArray;
		FillOut(OutArray);
		ResultByOut = OutArray.Num();
	}
}

bool Observe_ContainerAsParameter_DefaultEmpty(ACoverageContainerParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerAsParameter setup: required Actor is null");
	}
	return Actor.ResultByValue == 0 && Actor.ResultByRef == 0 && Actor.ResultByOut == 0;
}

bool Observe_ContainerAsParameter_Nominal(ACoverageContainerParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerAsParameter setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ResultByValue == 6 && Actor.ResultByRef == 3 && Actor.ResultByOut == 3;
}

bool Observe_ContainerAsParameter_EmptySumAndCopyIndependence(ACoverageContainerParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerAsParameter setup: required Actor is null");
	}
	TArray<int> Empty;
	int EmptySum = Actor.SumByValue(Empty);
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(3);
	int CopiedSum = Actor.SumByValue(Values);
	return EmptySum == 0 && CopiedSum == 6 && Values.Num() == 3;
}
