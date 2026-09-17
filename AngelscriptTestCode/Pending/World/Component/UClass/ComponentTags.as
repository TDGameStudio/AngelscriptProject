/**
 * @version v1
 * @summary ComponentTags.Add followed by ComponentHasTag and a tag count. C++ verifies the three results by path. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary ComponentTags.Add followed by ComponentHasTag and a tag count. C++ verifies the three results by path. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay adds two tags, then queries one present tag, one absent
	 * tag and the resulting count.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Tags
	 * @Inputs a default-attached component
	 * @Return HasTestTag true, HasOtherTag false, TagCount == 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TestComp.ComponentTags.Add(n"TestTag");
		TestComp.ComponentTags.Add(n"AnotherTag");

		HasTestTag = TestComp.ComponentHasTag(n"TestTag");
		HasOtherTag = TestComp.ComponentHasTag(n"OtherTag");
		TagCount = TestComp.ComponentTags.Num();
	}

	/**
	 * Observe that a locally constructed actor holds no tags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.Tags
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are clear, the count is 0 and TestComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (HasTestTag)
		{
			return false;
		}
		if (HasOtherTag)
		{
			return false;
		}
		if (TagCount != 0)
		{
			return false;
		}
		return TestComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.Tags
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the tagged state and the other stays at its defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentTagsActor Second)
	{
		if (Second is null)
		{
			throw("ComponentTags setup: required Second is null");
		}
		HasTestTag = true;
		TagCount = 2;

		if (!HasTestTag)
		{
			return false;
		}
		if (TagCount != 2)
		{
			return false;
		}
		if (Second.HasTestTag)
		{
			return false;
		}
		if (Second.TagCount != 0)
		{
			return false;
		}
		return !Second.HasOtherTag;
	}
}
/** @end */
