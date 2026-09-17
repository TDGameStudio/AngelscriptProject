/**
 * @version v1
 * @summary Component tags added to a root and a child scene component, then queried and counted. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this actor and verifies the results by path, so this is a value oracle.
 * @topic World
 */
/**
 * @version root
 * @summary Component tags added to a root and a child scene component, then queried and counted. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this actor and verifies the results by path, so this is a value oracle.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay tags the root once and the child twice, then queries both
	 * plus a tag that was never added.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SceneComponentTags
	 * @Inputs a root and an attached child scene component
	 * @Return both present tags found, the missing tag rejected, RootTagCount 1, ChildTagCount 2
	 */
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

	/**
	 * Observe that a locally constructed actor holds no tags and no components.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentTags
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear, both counts are 0 and both handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RootHasCoverageTag)
		{
			return false;
		}
		if (ChildHasCoverageTag)
		{
			return false;
		}
		if (ChildRejectsMissingTag)
		{
			return false;
		}
		if (RootTagCount != 0)
		{
			return false;
		}
		if (ChildTagCount != 0)
		{
			return false;
		}
		if (Root != nullptr)
		{
			return false;
		}
		return Child == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentTags
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the tagged state and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentTagsActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentTags setup: required Second is null");
		}
		RootHasCoverageTag = true;
		ChildTagCount = 2;

		if (!RootHasCoverageTag)
		{
			return false;
		}
		if (ChildTagCount != 2)
		{
			return false;
		}
		if (Second.RootHasCoverageTag)
		{
			return false;
		}
		return Second.ChildTagCount == 0;
	}
}
/** @end */
