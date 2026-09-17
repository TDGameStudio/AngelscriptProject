/**
 * @version v1
 * @summary A spline DefaultComponent attached to a scripted root. C++ checks after BeginPlay that RootChildCountAtBeginPlay >= 1 and bSawSplineAtBeginPlay is true. The observers cover the local construct default.
 * @topic Feature
 */
/**
 * @version root
 * @summary A spline DefaultComponent attached to a scripted root. C++ checks after BeginPlay that RootChildCountAtBeginPlay >= 1 and bSawSplineAtBeginPlay is true. The observers cover the local construct default.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay records how many children Root has and whether Spline
	 * materialized.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.SplineDefaultComponentRegistersAndMaterializes
	 * @Inputs Root and Spline default components
	 * @Return RootChildCountAtBeginPlay >= 1 and bSawSplineAtBeginPlay true after BeginPlay
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RootChildCountAtBeginPlay = Root.GetNumChildrenComponents();
		bSawSplineAtBeginPlay = Spline != null;
	}

	/**
	 * Observe that a locally constructed actor has not seen a spline and has a
	 * zero child count.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.SplineDefaultComponentRegistersAndMaterializes
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the count is 0 and bSawSplineAtBeginPlay is false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RootChildCountAtBeginPlay != 0)
		{
			return false;
		}
		return !bSawSplineAtBeginPlay;
	}

	/**
	 * Observe the child count recorded at BeginPlay, which stays 0 until then.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.SplineDefaultComponentRegistersAndMaterializes
	 * @Inputs an actor that has not run BeginPlay
	 * @Return RootChildCountAtBeginPlay, expected to be 0
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int ChildCountBeforeBeginPlay()
	{
		return RootChildCountAtBeginPlay;
	}

	/**
	 * Observe whether BeginPlay saw the spline, which stays false until then.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.SplineDefaultComponentRegistersAndMaterializes
	 * @Inputs an actor that has not run BeginPlay
	 * @Return bSawSplineAtBeginPlay, expected to be false
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool SawSplineDefaultFalse()
	{
		return bSawSplineAtBeginPlay;
	}
}
/** @end */
