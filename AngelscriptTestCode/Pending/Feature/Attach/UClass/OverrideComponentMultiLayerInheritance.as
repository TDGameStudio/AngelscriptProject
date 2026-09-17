/**
 * @version v1
 * @summary OverrideComponent across base/mid/top actor layers. C++ materializes ATopLayerActor; MidReplacement overrides BaseChild; TopExtra is an extra default. The observers cover the local-construct default, the mid replacement.
 * @topic Feature
 */
/**
 * @version root
 * @summary OverrideComponent across base/mid/top actor layers. C++ materializes ATopLayerActor; MidReplacement overrides BaseChild; TopExtra is an extra default. The observers cover the local-construct default, the mid replacement.
 * @topic Baseline
 */
UCLASS()
class ABaseLayerActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USceneComponent BaseChild;
}

UCLASS()
class AMidLayerActor : ABaseLayerActor
{
	UPROPERTY(OverrideComponent = BaseChild)
	UStaticMeshComponent MidReplacement;

	/**
	 * Observe that a locally constructed mid actor has not materialized MidReplacement.
	 *
	 * @Kind Observe
	 * @Covers Attach.OverrideComponentMultiLayerInheritance
	 * @Inputs a mid actor that has not been spawned
	 * @Return true when MidReplacement is null
	 * @Boundary null override component
	 */
	UFUNCTION()
	bool MidReplacementNullBoundary()
	{
		return MidReplacement == nullptr;
	}
}

UCLASS()
class ATopLayerActor : AMidLayerActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent TopExtra;

	/**
	 * Observe that a locally constructed top actor has not materialized any of the
	 * four component handles.
	 *
	 * @Kind Observe
	 * @Covers Attach.OverrideComponentMultiLayerInheritance
	 * @Inputs a top actor that has not been spawned
	 * @Return true when RootScene, BaseChild, MidReplacement and TopExtra are all null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RootScene != nullptr)
		{
			return false;
		}
		if (BaseChild != nullptr)
		{
			return false;
		}
		if (MidReplacement != nullptr)
		{
			return false;
		}
		return TopExtra == nullptr;
	}

	/**
	 * Observe that a second top instance is a different object.
	 *
	 * @Kind Observe
	 * @Covers Attach.OverrideComponentMultiLayerInheritance
	 * @Inputs this top actor plus a second top actor
	 * @Return true when the two actors are not the same object
	 * @Param Second the other top actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATopLayerActor Second)
	{
		if (Second is null)
		{
			throw("OverrideComponentMultiLayerInheritance setup: required Second is null");
		}
		return this != Second;
	}
}
/** @end */
