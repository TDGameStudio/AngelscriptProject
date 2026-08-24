// Theme: Language.Syntax.EdgeCases. WorldStory TArray/TMap of float and double.
// C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatContainerProperties
// sha256=5a9ed8771832eb66db86015f3cd3efc461c26659ac2dc39b9efb6fb5c9717ee2; lines 564-597.
// Oracle after BeginPlay: FloatArray [1.1, 2.2, 3.3]; DoubleArray [4.4, 5.5];
// IntToFloatMap 10->100.5, 20->200.5; StringToDoubleMap Pi and E.
// Extra: local construct leaves empty containers. FixtureIsolated.

UCLASS()
class ACoverageFloatContainerActor : AActor
{
	UPROPERTY()
	TArray<float> FloatArray;

	UPROPERTY()
	TArray<double> DoubleArray;

	UPROPERTY()
	TMap<int, float> IntToFloatMap;

	UPROPERTY()
	TMap<FString, double> StringToDoubleMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FloatArray.Add(1.1f);
		FloatArray.Add(2.2f);
		FloatArray.Add(3.3f);

		DoubleArray.Add(4.4);
		DoubleArray.Add(5.5);

		IntToFloatMap.Add(10, 100.5f);
		IntToFloatMap.Add(20, 200.5f);

		StringToDoubleMap.Add("Pi", 3.141592653589793);
		StringToDoubleMap.Add("E", 2.718281828459045);
	}
}

bool Observe_FloatContainer_DefaultEmpty(ACoverageFloatContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatContainerProperties setup: required Actor is null");
	}
	return Actor.FloatArray.Num() == 0 && Actor.DoubleArray.Num() == 0 && Actor.IntToFloatMap.Num() == 0 && Actor.StringToDoubleMap.Num() == 0;
}

bool Observe_FloatContainer_ScriptFillBoundary(ACoverageFloatContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatContainerProperties setup: required Actor is null");
	}
	Actor.FloatArray.Add(1.1f);
	Actor.FloatArray.Add(2.2f);
	Actor.FloatArray.Add(3.3f);
	Actor.DoubleArray.Add(4.4);
	Actor.DoubleArray.Add(5.5);
	return Actor.FloatArray.Num() == 3 && Math::IsNearlyEqual(Actor.FloatArray[0], 1.1, 0.001) && Actor.DoubleArray.Num() == 2 && Math::IsNearlyEqual(Actor.DoubleArray[0], 4.4, 0.001);
}
