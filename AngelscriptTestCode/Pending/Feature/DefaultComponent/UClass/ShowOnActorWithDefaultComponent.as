/**
 * @version v1
 * @summary ShowOnActor together with DefaultComponent is valid. C++ preprocesses this successfully despite the CSV NegativeDiagnostic heuristic. RootScene is part of the contract and is kept verbatim.
 * @topic Feature
 */
/**
 * @version root
 * @summary ShowOnActor together with DefaultComponent is valid. C++ preprocesses this successfully despite the CSV NegativeDiagnostic heuristic. RootScene is part of the contract and is kept verbatim.
 * @topic Baseline
 */
UCLASS()
class AShowOnActorValidCarrier : AActor
{
	UPROPERTY(DefaultComponent, ShowOnActor, RootComponent)
	USceneComponent RootScene;

	/**
	 * Observe that constructing a carrier without spawn yields a null handle.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.ShowOnActorWithDefaultComponent
	 * @Inputs none
	 * @Return true when a default-constructed carrier is null
	 * @Boundary empty actor
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		AShowOnActorValidCarrier Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that RootScene is null before spawn.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.ShowOnActorWithDefaultComponent
	 * @Inputs none
	 * @Return true when RootScene is null
	 * @Boundary default handle
	 */
	UFUNCTION()
	bool RootDefaultIsNull()
	{
		return RootScene == nullptr;
	}
}
/** @end */
