// Theme: Definitions.UStruct. WorldStory: copy, assign, and explicit opEquals.
// C++: AngelscriptCoverageUStructTests.cpp::UStructValueSemantics spawn + BeginPlay.
// Oracle: Original/CopyConstructed/Assigned X=100 Y=200 Name Original; AreEqual true.
// Extra: default X=10 Y=20 Name Default; mutating a copy leaves Original. FixtureIsolated.

USTRUCT()
struct FValueStruct
{
	UPROPERTY()
	int X = 10;

	UPROPERTY()
	int Y = 20;

	UPROPERTY()
	FString Name = "Default";

	// Script USTRUCTs do not auto-generate ==; define value equality explicitly.
	bool opEquals(const FValueStruct&in Other) const
	{
		return X == Other.X && Y == Other.Y && Name == Other.Name;
	}
}

UCLASS()
class ACoverageStructValueActor : AActor
{
	UPROPERTY()
	FValueStruct Original;

	UPROPERTY()
	FValueStruct CopyConstructed;

	UPROPERTY()
	FValueStruct Assigned;

	UPROPERTY()
	bool AreEqual = false;

	UPROPERTY()
	bool AreNotEqual = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test default values
		Original.X = 100;
		Original.Y = 200;
		Original.Name = "Original";

		// Copy construction
		CopyConstructed = Original;

		// Assignment
		Assigned.X = 0;
		Assigned.Y = 0;
		Assigned.Name = "Temp";
		Assigned = Original;

		// Comparison
		AreEqual = (CopyConstructed == Original);

		FValueStruct Different;
		Different.X = 999;
		AreNotEqual = (Different != Original);
	}
}

bool Observe_ValueSemantics_DefaultEmpty(ACoverageStructValueActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructValueSemantics setup: required Actor is null");
	}
	return Actor.Original.X == 10
		&& Actor.Original.Y == 20
		&& Actor.Original.Name == "Default"
		&& !Actor.AreEqual
		&& !Actor.AreNotEqual;
}

bool Observe_ValueSemantics_NominalBeginPlay(ACoverageStructValueActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructValueSemantics setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.Original.X == 100
		&& Actor.Original.Y == 200
		&& Actor.Original.Name == "Original"
		&& Actor.CopyConstructed.X == 100
		&& Actor.CopyConstructed.Name == "Original"
		&& Actor.Assigned.X == 100
		&& Actor.Assigned.Y == 200
		&& Actor.AreEqual
		&& Actor.AreNotEqual;
}

bool Observe_ValueSemantics_CopyIndependence()
{
	FValueStruct Original;
	Original.X = 100;
	Original.Y = 200;
	Original.Name = "Original";
	FValueStruct Copy = Original;
	Copy.X = 1;
	Copy.Name = "Copy";
	return Original.X == 100 && Original.Name == "Original" && Copy.X == 1 && !(Copy == Original);
}
