// Theme: Containers.TSet. WorldStory: TSet by-value, &in, &out, and &inout parameters.
// C++: AngelscriptCoverageContainerParameterTests.cpp::TSetAsParameter CompileScriptModule
// + spawn + BeginPlay + VerifyByPath ResultByValue/In/Out/Inout/OriginalSize = 3.
// CSV SourceShape NegativeDiagnostic is wrong; the actor class compiles.
// Extra: empty set CountByValue==0; by-value copy leaves the original Num==3.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageContainerParamTSetActor : AActor
{
	UPROPERTY()
	int ResultByValue;

	UPROPERTY()
	int ResultByIn;

	UPROPERTY()
	int ResultByOut;

	UPROPERTY()
	int ResultByInout;

	UPROPERTY()
	int OriginalSize;

	// Pass by value (copy)
	int CountByValue(TSet<int> Set)
	{
		Print("=== CountByValue ===");
		int Count = Set.Num();
		Print("Local set count: " + Count);
		return Count;
	}

	// Pass by const reference (&in) - read-only
	int CountByIn(const TSet<int>&in Set)
	{
		Print("=== CountByIn ===");
		int Count = Set.Num();
		Print("Count: " + Count);
		return Count;
	}

	// Out parameter - function fills it
	void FillOut(TSet<int>&out Result)
	{
		Print("=== FillOut ===");
		Result.Add(100);
		Result.Add(200);
		Result.Add(300);
		Print("Filled with " + Result.Num() + " elements");
	}

	// Pass by reference (can modify)
	void ModifyByInout(TSet<int>&inout Set)
	{
		Print("=== ModifyByInout ===");
		Print("Before: " + Set.Num());
		Set.Add(888);
		Print("After: " + Set.Num());
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== TSet as Parameter Test ===");

		// Test by value
		TSet<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		OriginalSize = Values.Num();
		ResultByValue = CountByValue(Values);
		// Original should be unchanged
		Print("Original set after by-value call: " + Values.Num());

		// Test by const reference (&in)
		ResultByIn = CountByIn(Values);

		// Test out parameter
		TSet<int> OutSet;
		FillOut(OutSet);
		ResultByOut = OutSet.Num();

		// Test inout parameter
		TSet<int> InoutSet;
		InoutSet.Add(10);
		InoutSet.Add(20);
		ModifyByInout(InoutSet);
		ResultByInout = InoutSet.Num();
	}
}

bool Observe_TSetParam_DefaultEmpty(ACoverageContainerParamTSetActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAsParameter_01 setup: required Actor is null");
	}
	return Actor.ResultByValue == 0
		&& Actor.ResultByIn == 0
		&& Actor.ResultByOut == 0
		&& Actor.ResultByInout == 0
		&& Actor.OriginalSize == 0;
}

int Observe_TSetParam_EmptyByValue(ACoverageContainerParamTSetActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAsParameter_01 setup: required Actor is null");
	}
	TSet<int> Empty;
	return Actor.CountByValue(Empty);
}

int Observe_TSetParam_CopyIndependence(ACoverageContainerParamTSetActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAsParameter_01 setup: required Actor is null");
	}
	TSet<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(3);
	int Count = Actor.CountByValue(Values);
	return Count == 3 && Values.Num() == 3 ? 1 : 0;
}

int Observe_TSetParam_OutFillBoundary(ACoverageContainerParamTSetActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAsParameter_01 setup: required Actor is null");
	}
	TSet<int> OutSet;
	Actor.FillOut(OutSet);
	return OutSet.Num();
}
