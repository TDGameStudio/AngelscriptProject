// Theme: Feature.DefaultComponent. WorldStory spline DefaultComponent attached to a scripted root.
// C++: AngelscriptComponentSplineUsageTests.cpp::SplineDefaultComponentRegistersAndMaterializes
// Oracle after BeginPlay: RootChildCountAtBeginPlay >= 1, bSawSplineAtBeginPlay == true.
// Extra: empty actor is null; pre-BeginPlay count 0 / saw false. FixtureIsolated.

UCLASS()
class AFunctionalSplineActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root)
	USplineComponent Spline;

	UPROPERTY()
	int RootChildCountAtBeginPlay = 0;

	UPROPERTY()
	bool bSawSplineAtBeginPlay = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RootChildCountAtBeginPlay = Root.GetNumChildrenComponents();
		bSawSplineAtBeginPlay = Spline != null;
	}
}

bool Observe_SplineActor_EmptyDefaultIsNull()
{
	AFunctionalSplineActor Actor;
	return Actor == nullptr;
}

int Observe_SplineActor_ChildCountBeforeBeginPlay(AFunctionalSplineActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0189 setup: required AFunctionalSplineActor is null");
	}
	return Actor.RootChildCountAtBeginPlay;
}

bool Observe_SplineActor_SawSplineDefaultFalse(AFunctionalSplineActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0189 setup: required AFunctionalSplineActor is null");
	}
	return Actor.bSawSplineAtBeginPlay;
}
