// Theme: Containers.TSet. WorldStory: TSet returned by value from MakeSet.
// C++: AngelscriptCoverageContainerParameterTests.cpp::TSetAsReturnValue
// CompileScriptModule + spawn + BeginPlay + VerifyByPath SetSize=3, bContains100/200 true.
// Extra: local construct leaves SetSize=0; returned copies are independent.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageContainerReturnTSetActor : AActor
{
	UPROPERTY()
	int SetSize;

	UPROPERTY()
	bool bContains100;

	UPROPERTY()
	bool bContains200;

	// Return TSet
	TSet<int> MakeSet()
	{
		Print("=== MakeSet ===");
		TSet<int> Result;
		Result.Add(100);
		Result.Add(200);
		Result.Add(300);
		Print("Created set with " + Result.Num() + " elements");
		return Result;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== TSet as Return Value Test ===");

		TSet<int> MySet = MakeSet();
		SetSize = MySet.Num();
		bContains100 = MySet.Contains(100);
		bContains200 = MySet.Contains(200);

		Print("Received set size: " + SetSize);
		Print("Contains 100: " + bContains100);
		Print("Contains 200: " + bContains200);
	}
}

bool Observe_TSetReturn_DefaultEmpty(ACoverageContainerReturnTSetActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAsReturnValue setup: required Actor is null");
	}
	return Actor.SetSize == 0 && Actor.bContains100 == false && Actor.bContains200 == false;
}

int Observe_MakeSet_NominalSize(ACoverageContainerReturnTSetActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAsReturnValue setup: required Actor is null");
	}
	TSet<int> MySet = Actor.MakeSet();
	return MySet.Num();
}

bool Observe_MakeSet_CopyIndependence(ACoverageContainerReturnTSetActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAsReturnValue setup: required Actor is null");
	}
	TSet<int> First = Actor.MakeSet();
	TSet<int> Second = Actor.MakeSet();
	First.Add(999);
	return First.Num() == 4 && Second.Num() == 3 && Second.Contains(100) && !Second.Contains(999);
}
