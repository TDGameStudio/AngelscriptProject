/**
 * ShowOnActor together with DefaultComponent is valid. C++ preprocesses this successfully
 * despite the CSV NegativeDiagnostic heuristic. RootScene is part of the contract and is
 * kept verbatim.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.ShowOnActorWithDefaultComponent
 * @Harness UClass
 * @Tag Feature.DefaultComponent.ShowOnActorWithDefaultComponent
 * @Provenance Theme: Feature.DefaultComponent. ShowOnActor with DefaultComponent is valid.
 * @Provenance C++: AngelscriptPreprocessorPropertyTests.cpp::ShowOnActorRequiresDefaultComponent block 2
 * @Provenance CSV NegativeDiagnostic is wrong: this block preprocesses successfully.
 * @Provenance Oracle: RootScene is instanced, editable on defaults/instances, blueprint-readable,
 * @Provenance and carries DefaultComponent metadata.
 * @Provenance Extra: empty actor is null; RootScene default handle is null. Isolation=none.
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
