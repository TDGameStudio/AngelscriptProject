// Theme: Gameplay.FTransform. WorldStory SetLocation/SetScale3D member access.
// C++: AngelscriptCoverageFTransformPropertyTests.cpp::FTransformMemberAccess
// Oracle after BeginPlay: MyTransform.Translation (100,200,300);
// MyTransform.Scale3D (5,5,5). Extra: default identity empty before BeginPlay.
// FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFTransformMemberActor : AActor
{
	UPROPERTY()
	FTransform MyTransform;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MyTransform.SetLocation(FVector(100, 200, 300));
		MyTransform.SetScale3D(FVector(5, 5, 5));
	}
}

bool Observe_MyTransform_DefaultEmpty(ACoverageFTransformMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformMemberAccess setup: required Actor is null");
	}
	return Actor.MyTransform.GetLocation().X == 0.0
		&& Actor.MyTransform.GetLocation().Y == 0.0
		&& Actor.MyTransform.GetLocation().Z == 0.0
		&& Actor.MyTransform.GetScale3D().X == 1.0
		&& Actor.MyTransform.GetScale3D().Y == 1.0
		&& Actor.MyTransform.GetScale3D().Z == 1.0;
}

bool Observe_MyTransform_AfterBeginPlay(ACoverageFTransformMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformMemberAccess setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.MyTransform.GetLocation().X == 100.0
		&& Actor.MyTransform.GetLocation().Y == 200.0
		&& Actor.MyTransform.GetLocation().Z == 300.0
		&& Actor.MyTransform.GetScale3D().X == 5.0
		&& Actor.MyTransform.GetScale3D().Y == 5.0
		&& Actor.MyTransform.GetScale3D().Z == 5.0;
}

bool Observe_MyTransform_CopyIndependence(ACoverageFTransformMemberActor First, ACoverageFTransformMemberActor Second)
{
	if (First is null)
	{
		throw("Test_FTransformMemberAccess setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FTransformMemberAccess setup: required Second is null");
	}
	First.BeginPlay();
	return First.MyTransform.GetLocation().X == 100.0
		&& Second.MyTransform.GetLocation().X == 0.0
		&& Second.MyTransform.GetScale3D().X == 1.0;
}
