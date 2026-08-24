// Theme: Containers.TMap. WorldStory: TMap by-value / &in / &out / &inout.
// C++: AngelscriptCoverageContainerParameterTests.cpp::TMapAsParameter compiles and
// VerifyByPath ResultByValue=3, ResultByIn=3, ResultByOut=3, ResultByInout=3, OriginalSize=3.
// CSV NegativeDiagnostic is wrong; C++ spawns the actor. Extra: Result* default 0 until
// BeginPlay; by-value copy leaves OriginalSize 3. FixtureIsolated.

UCLASS()
class ACoverageContainerParamTMapActor : AActor
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
	int CountByValue(TMap<int, FString> Map)
	{
		Print("=== CountByValue ===");
		int Count = Map.Num();
		Print("Local map count: " + Count);
		return Count;
	}

	// Pass by const reference (&in) - read-only
	int CountByIn(const TMap<int, FString>&in Map)
	{
		Print("=== CountByIn ===");
		int Count = Map.Num();
		// Cannot modify (const)
		Print("Count: " + Count);
		return Count;
	}

	// Out parameter - function fills it
	void FillOut(TMap<int, FString>&out Result)
	{
		Print("=== FillOut ===");
		Result.Add(100, "Hundred");
		Result.Add(200, "TwoHundred");
		Result.Add(300, "ThreeHundred");
		Print("Filled with " + Result.Num() + " entries");
	}

	// Pass by reference (can modify)
	void ModifyByInout(TMap<int, FString>&inout Map)
	{
		Print("=== ModifyByInout ===");
		Print("Before: " + Map.Num());
		Map.Add(888, "Modified");
		Print("After: " + Map.Num());
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== TMap as Parameter Test ===");

		// Test by value
		TMap<int, FString> Values;
		Values.Add(1, "One");
		Values.Add(2, "Two");
		Values.Add(3, "Three");
		OriginalSize = Values.Num();
		ResultByValue = CountByValue(Values);
		// Original should be unchanged
		Print("Original map after by-value call: " + Values.Num());

		// Test by const reference (&in)
		ResultByIn = CountByIn(Values);

		// Test out parameter
		TMap<int, FString> OutMap;
		FillOut(OutMap);
		ResultByOut = OutMap.Num();

		// Test inout parameter
		TMap<int, FString> InoutMap;
		InoutMap.Add(10, "Ten");
		InoutMap.Add(20, "Twenty");
		ModifyByInout(InoutMap);
		ResultByInout = InoutMap.Num();
	}
}
