// Theme: World.Component. WorldStory: ComponentTags.Add and ComponentHasTag.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentTags
// sha256=54079036589c699e1ebb49ca4d0e589eee5e4a1d6cbcedcb232274282553be96; lines 2133-2165.
// Oracle VerifyByPath: HasTestTag=true, HasOtherTag=false, TagCount=2.
// Extra: local construct HasTestTag false, HasOtherTag false, TagCount 0,
// TestComp null. FixtureIsolated.

UCLASS()
class UCoverageTagsComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentTagsActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageTagsComponent TestComp;

	UPROPERTY()
	bool HasTestTag = false;

	UPROPERTY()
	bool HasOtherTag = false;

	UPROPERTY()
	int TagCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TestComp.ComponentTags.Add(n"TestTag");
		TestComp.ComponentTags.Add(n"AnotherTag");

		HasTestTag = TestComp.ComponentHasTag(n"TestTag");
		HasOtherTag = TestComp.ComponentHasTag(n"OtherTag");
		TagCount = TestComp.ComponentTags.Num();
	}
}

bool Observe_ComponentTags_DefaultEmpty(ACoverageComponentTagsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentTags setup: required Actor is null");
	}
	return !Actor.HasTestTag
		&& !Actor.HasOtherTag
		&& Actor.TagCount == 0
		&& Actor.TestComp == nullptr;
}

bool Observe_ComponentTags_CopyIndependence(ACoverageComponentTagsActor First, ACoverageComponentTagsActor Second)
{
	if (First is null)
	{
		throw("Test_ComponentTags setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ComponentTags setup: required Second is null");
	}
	First.HasTestTag = true;
	First.TagCount = 2;
	return First.HasTestTag
		&& First.TagCount == 2
		&& !Second.HasTestTag
		&& Second.TagCount == 0
		&& !Second.HasOtherTag;
}
