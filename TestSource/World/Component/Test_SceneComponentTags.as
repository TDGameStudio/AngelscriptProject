// Theme: World.Component. CSV NegativeDiagnostic; C++ compiles and
// ExpectBoolByPath / ExpectIntByPath. Value/lifecycle oracle.
// C++: AngelscriptCoverageSceneComponentTests.cpp::SceneComponentTags
// sha256=ddfdb4dc24994f44435578aa35b0f5e706f9e4951fd429a48e52be407f889bd5; lines 741-780.
// Oracle RootHasCoverageTag true, ChildHasCoverageTag true,
// ChildRejectsMissingTag true, RootTagCount=1, ChildTagCount=2.
// Extra: local construct flags false, counts 0, Root/Child null.
// FixtureIsolated.

UCLASS()
class ACoverageSceneComponentTagsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child;

	UPROPERTY()
	bool RootHasCoverageTag = false;

	UPROPERTY()
	bool ChildHasCoverageTag = false;

	UPROPERTY()
	bool ChildRejectsMissingTag = false;

	UPROPERTY()
	int RootTagCount = 0;

	UPROPERTY()
	int ChildTagCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Root.ComponentTags.Add(n"RootCoverageTag");
		Child.ComponentTags.Add(n"SceneCoverageTag");
		Child.ComponentTags.Add(n"SharedCoverageTag");

		RootHasCoverageTag = Root.ComponentHasTag(n"RootCoverageTag");
		ChildHasCoverageTag = Child.ComponentHasTag(n"SceneCoverageTag");
		ChildRejectsMissingTag = !Child.ComponentHasTag(n"MissingCoverageTag");
		RootTagCount = Root.ComponentTags.Num();
		ChildTagCount = Child.ComponentTags.Num();
	}
}

bool Observe_SceneComponentTags_DefaultEmpty(ACoverageSceneComponentTagsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SceneComponentTags setup: required Actor is null");
	}
	return !Actor.RootHasCoverageTag
		&& !Actor.ChildHasCoverageTag
		&& !Actor.ChildRejectsMissingTag
		&& Actor.RootTagCount == 0
		&& Actor.ChildTagCount == 0
		&& Actor.Root == nullptr
		&& Actor.Child == nullptr;
}

bool Observe_SceneComponentTags_CopyIndependence(ACoverageSceneComponentTagsActor First, ACoverageSceneComponentTagsActor Second)
{
	if (First is null)
	{
		throw("Test_SceneComponentTags setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SceneComponentTags setup: required Second is null");
	}
	First.RootHasCoverageTag = true;
	First.ChildTagCount = 2;
	return First.RootHasCoverageTag
		&& First.ChildTagCount == 2
		&& !Second.RootHasCoverageTag
		&& Second.ChildTagCount == 0;
}
