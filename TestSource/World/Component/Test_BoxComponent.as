// Theme: World.Component. WorldStory: SetBoxExtent / GetUnscaledBoxExtent.
// C++: AngelscriptCoverageSpecialComponentTests.cpp::BoxComponent
// sha256=0397a56c424236955a01ca83e433cea514eb0dc2d8c4ea8a24044b36df647200; lines 406-429.
// Oracle NewExtent=(100,200,300). Extra: local construct Initial/NewExtent
// empty, BoxComp null. FixtureIsolated.

UCLASS()
class ACoverageSpecialBoxActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent BoxComp;

	UPROPERTY()
	FVector InitialExtent;

	UPROPERTY()
	FVector NewExtent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialExtent = BoxComp.GetUnscaledBoxExtent();

		BoxComp.SetBoxExtent(FVector(100.0f, 200.0f, 300.0f));

		NewExtent = BoxComp.GetUnscaledBoxExtent();
	}
}

bool Observe_BoxComponent_DefaultEmpty(ACoverageSpecialBoxActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BoxComponent setup: required Actor is null");
	}
	return Actor.InitialExtent.X == 0.0f
		&& Actor.NewExtent.X == 0.0f
		&& Actor.NewExtent.Y == 0.0f
		&& Actor.NewExtent.Z == 0.0f
		&& Actor.BoxComp == nullptr;
}

bool Observe_BoxComponent_CopyIndependence(ACoverageSpecialBoxActor First, ACoverageSpecialBoxActor Second)
{
	if (First is null)
	{
		throw("Test_BoxComponent setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_BoxComponent setup: required Second is null");
	}
	First.NewExtent = FVector(100.0f, 200.0f, 300.0f);
	return First.NewExtent.X == 100.0f
		&& First.NewExtent.Z == 300.0f
		&& Second.NewExtent.X == 0.0f
		&& Second.NewExtent.Z == 0.0f;
}
