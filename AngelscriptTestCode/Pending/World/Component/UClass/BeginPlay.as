/**
 * @version v1
 * @summary A component whose BeginPlay sets bReady. C++ creates the component, runs BeginPlay and verifies bReady through its path. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary A component whose BeginPlay sets bReady. C++ creates the component, runs BeginPlay and verifies bReady through its path. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
UCLASS()
class UTestComponentBeginPlay : UActorComponent
{
	UPROPERTY()
	bool bReady = false;

	/**
	 * WorldStory: BeginPlay flips bReady to true.
	 *
	 * @Kind WorldStory
	 * @Covers Component.BeginPlay
	 * @Inputs none
	 * @Return bReady == true once BeginPlay has run
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bReady = true;
	}

	/**
	 * Observe that a locally constructed component is not ready.
	 *
	 * @Kind Observe
	 * @Covers Component.BeginPlay
	 * @Inputs a component that has not run BeginPlay
	 * @Return true when bReady is false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		return bReady == false;
	}

	/**
	 * Observe that writing this component leaves another component untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.BeginPlay
	 * @Inputs this component plus a second component
	 * @Return true when this is ready and the other is not
	 * @Param Second the other component, expected to stay false
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentBeginPlay Second)
	{
		if (Second is null)
		{
			throw("BeginPlay setup: required Second is null");
		}
		bReady = true;
		if (!bReady)
		{
			return false;
		}
		return Second.bReady == false;
	}
}
/** @end */
