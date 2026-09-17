/**
 * @version v1
 * @summary Component lookup by class and by tag across a base/derived component pair. C++ verifies the found flag and the three counts. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary Component lookup by class and by tag across a base/derived component pair. C++ verifies the found flag and the three counts. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
UCLASS()
class UCoverageFindBaseComponent : UActorComponent
{
}

/**
 * The derived component that the base-class lookup must also resolve.
 *
 * @Covers Component.FindingByClassAndTag
 * @Inputs none
 * @Return a component derived from UCoverageFindBaseComponent
 */
UCLASS()
class UCoverageFindDerivedComponent : UCoverageFindBaseComponent
{
}

UCLASS()
class ACoverageComponentFindingByClassAndTagActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageFindDerivedComponent DerivedA;

	UPROPERTY(DefaultComponent)
	UCoverageFindDerivedComponent DerivedB;

	UPROPERTY()
	bool GetComponentByClassFound = false;

	UPROPERTY()
	int TaggedComponentCount = 0;

	UPROPERTY()
	int TaggedQueryCount = 0;

	UPROPERTY()
	int DerivedComponentCount = 0;

	/**
	 * WorldStory: BeginPlay tags both derived components, resolves one by the base
	 * class, then counts tagged components two different ways and counts the
	 * derived components.
	 *
	 * @Kind WorldStory
	 * @Covers Component.FindingByClassAndTag
	 * @Inputs two default-attached derived components
	 * @Return GetComponentByClassFound true, TaggedComponentCount 2, TaggedQueryCount 2, DerivedComponentCount 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DerivedA.ComponentTags.Add(n"CoverageTag");
		DerivedB.ComponentTags.Add(n"CoverageTag");

		UActorComponent FoundBase = GetComponentByClass(UCoverageFindBaseComponent::StaticClass());
		GetComponentByClassFound = FoundBase != nullptr;

		TArray<UActorComponent> AllComponents;
		GetComponentsByClass(UActorComponent::StaticClass(), AllComponents);
		for (UActorComponent Component : AllComponents)
		{
			if (Component.ComponentHasTag(n"CoverageTag"))
			{
				TaggedComponentCount++;
			}
		}

		TArray<UActorComponent> TaggedComponents = GetComponentsByTag(UActorComponent::StaticClass(), n"CoverageTag");
		TaggedQueryCount = TaggedComponents.Num();

		TArray<UCoverageFindDerivedComponent> DerivedComponents;
		GetComponentsByClass(UCoverageFindDerivedComponent::StaticClass(), DerivedComponents);
		DerivedComponentCount = DerivedComponents.Num();
	}

	/**
	 * Observe that a locally constructed actor found nothing and has no handles.
	 *
	 * @Kind Observe
	 * @Covers Component.FindingByClassAndTag
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the flag is clear, all counts are 0 and both handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (GetComponentByClassFound)
		{
			return false;
		}
		if (TaggedComponentCount != 0)
		{
			return false;
		}
		if (TaggedQueryCount != 0)
		{
			return false;
		}
		if (DerivedComponentCount != 0)
		{
			return false;
		}
		if (DerivedA != nullptr)
		{
			return false;
		}
		return DerivedB == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.FindingByClassAndTag
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the found state and the other holds nothing
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentFindingByClassAndTagActor Second)
	{
		if (Second is null)
		{
			throw("ComponentFindingByClassAndTag setup: required Second is null");
		}
		GetComponentByClassFound = true;
		TaggedComponentCount = 2;

		if (!GetComponentByClassFound)
		{
			return false;
		}
		if (TaggedComponentCount != 2)
		{
			return false;
		}
		if (Second.GetComponentByClassFound)
		{
			return false;
		}
		return Second.TaggedComponentCount == 0;
	}
}
/** @end */
