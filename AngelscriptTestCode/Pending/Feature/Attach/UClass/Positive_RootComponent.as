/**
 * @version v1
 * @summary DefaultComponent + RootComponent compiles. C++ AssertCompiles ADefCompRootActor. The observers cover the local-construct null Root and copy independence.
 * @topic Feature
 */
/**
 * @version root
 * @summary DefaultComponent + RootComponent compiles. C++ AssertCompiles ADefCompRootActor. The observers cover the local-construct null Root and copy independence.
 * @topic Baseline
 */
UCLASS()
class ADefCompRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	/**
	 * Observe that a locally constructed actor has not materialized Root.
	 *
	 * @Kind Observe
	 * @Covers Attach.Positive_RootComponent
	 * @Inputs an actor that has not been spawned
	 * @Return true when Root is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		return Root == nullptr;
	}

	/**
	 * Observe that a second instance is a different object.
	 *
	 * @Kind Observe
	 * @Covers Attach.Positive_RootComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when the two actors are not the same object
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ADefCompRootActor Second)
	{
		if (Second is null)
		{
			throw("Positive_RootComponent setup: required Second is null");
		}
		return this != Second;
	}
}
/** @end */
