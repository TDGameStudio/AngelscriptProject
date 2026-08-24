// Theme: Language.Syntax.EdgeCases. WorldStory bool containers filled in BeginPlay.
// C++: AngelscriptCoverageBoolPropertyTests.cpp::BoolContainerProperties
// sha256=5abc62565f51b3c98025408ed063633b1dad39d33fd2778294781bd40e25d168; lines 249-289.
// Oracle after spawn+BeginPlay: BoolArray 3 elems true/false/true; IntToBoolMap
// 2 entries; BoolToIntMap true=100 false=200; StringToBoolMap Enabled/Hidden;
// BoolSet size 2 after duplicate true. Extra: local construct leaves containers
// empty. FixtureIsolated.

UCLASS()
class ACoverageBoolContainerActor : AActor
{
	UPROPERTY()
	TArray<bool> BoolArray;

	UPROPERTY()
	TMap<int, bool> IntToBoolMap;

	UPROPERTY()
	TMap<bool, int> BoolToIntMap;

	UPROPERTY()
	TMap<FString, bool> StringToBoolMap;

	UPROPERTY()
	TSet<bool> BoolSet;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BoolArray.Add(true);
		BoolArray.Add(false);
		BoolArray.Add(true);

		IntToBoolMap.Add(1, true);
		IntToBoolMap.Add(2, false);

		BoolToIntMap.Add(true, 100);
		BoolToIntMap.Add(false, 200);

		StringToBoolMap.Add("Enabled", true);
		StringToBoolMap.Add("Hidden", false);

		BoolSet.Add(true);
		BoolSet.Add(false);
		BoolSet.Add(true);  // Duplicate
	}
}

bool Observe_BoolContainers_DefaultEmpty(ACoverageBoolContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BoolContainerProperties setup: required Actor is null");
	}
	return Actor.BoolArray.Num() == 0 && Actor.IntToBoolMap.Num() == 0 && Actor.BoolToIntMap.Num() == 0 && Actor.StringToBoolMap.Num() == 0 && Actor.BoolSet.Num() == 0;
}

bool Observe_BoolContainers_Nominal(ACoverageBoolContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BoolContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	bool IntTrue = false;
	int TrueMapped = 0;
	int FalseMapped = 0;
	bool Enabled = false;
	bool Hidden = true;
	return Actor.BoolArray.Num() == 3
		&& Actor.BoolArray[0] == true
		&& Actor.BoolArray[1] == false
		&& Actor.BoolArray[2] == true
		&& Actor.IntToBoolMap.Num() == 2
		&& Actor.IntToBoolMap.Find(1, IntTrue)
		&& IntTrue == true
		&& Actor.BoolToIntMap.Num() == 2
		&& Actor.BoolToIntMap.Find(true, TrueMapped)
		&& TrueMapped == 100
		&& Actor.BoolToIntMap.Find(false, FalseMapped)
		&& FalseMapped == 200
		&& Actor.StringToBoolMap.Num() == 2
		&& Actor.StringToBoolMap.Find("Enabled", Enabled)
		&& Enabled == true
		&& Actor.StringToBoolMap.Find("Hidden", Hidden)
		&& Hidden == false
		&& Actor.BoolSet.Num() == 2
		&& Actor.BoolSet.Contains(true)
		&& Actor.BoolSet.Contains(false);
}
