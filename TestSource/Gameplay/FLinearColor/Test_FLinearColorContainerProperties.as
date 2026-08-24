// Theme: Gameplay.FLinearColor. WorldStory TArray/TMap FLinearColor after BeginPlay.
// C++: AngelscriptCoverageFLinearColorPropertyTests.cpp::FLinearColorContainerProperties
// Oracle: ColorArray Num 3; [0].R 1 [0].G 0 (Red); [1].G 1 (Green); [2].B 1 (Blue);
// IntToColorMap Num 3; [1] White R/G 1; [2] Black R 0.
// Extra: empty containers before BeginPlay. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFLinearColorContainerActor : AActor
{
	UPROPERTY()
	TArray<FLinearColor> ColorArray;

	UPROPERTY()
	TMap<int, FLinearColor> IntToColorMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ColorArray.Add(FLinearColor::Red);
		ColorArray.Add(FLinearColor::Green);
		ColorArray.Add(FLinearColor::Blue);

		IntToColorMap.Add(1, FLinearColor::White);
		IntToColorMap.Add(2, FLinearColor::Black);
		IntToColorMap.Add(3, FLinearColor::Yellow);
	}
}

bool Observe_Containers_DefaultEmpty(ACoverageFLinearColorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorContainerProperties setup: required Actor is null");
	}
	return Actor.ColorArray.Num() == 0 && Actor.IntToColorMap.Num() == 0;
}

bool Observe_ColorArray_AfterBeginPlay(ACoverageFLinearColorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ColorArray.Num() == 3
		&& Actor.ColorArray[0].R == 1.0
		&& Actor.ColorArray[0].G == 0.0
		&& Actor.ColorArray[1].G == 1.0
		&& Actor.ColorArray[2].B == 1.0;
}

bool Observe_IntToColorMap_AfterBeginPlay(ACoverageFLinearColorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.IntToColorMap.Num() == 3
		&& Actor.IntToColorMap[1].R == 1.0
		&& Actor.IntToColorMap[1].G == 1.0
		&& Actor.IntToColorMap[2].R == 0.0;
}

bool Observe_ColorArray_CopyIndependence(ACoverageFLinearColorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	FLinearColor Copy = Actor.ColorArray[0];
	Copy.R = 0.0;
	return Actor.ColorArray[0].Equals(FLinearColor::Red);
}
