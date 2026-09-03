/**
 * The begin and end overlap overrides counted when another actor is moved into and
 * out of the sphere, with each handler also checking that the payload names the
 * other actor rather than this one. C++ moves the other actor and verifies the
 * counts and payload flags.
 *
 * @Theme World.Actor
 * @Subject Actor.OverlapGeneratedByMovement
 * @Harness UClass
 * @Tag World.Actor.ActorOverlapGeneratedByMovement
 * @Provenance Theme: World.Actor. WorldStory: ActorBeginOverlap / ActorEndOverlap BlueprintOverride
 * @Provenance payload match when another actor moves into/out of the sphere.
 * @Provenance C++: AngelscriptCoveragePhysicsTests.cpp::ActorOverlapGeneratedByMovement
 * @Provenance Oracle: C++ moves the other actor; counts and payload flags become 1/true.
 * @Provenance Extra: ActorBeginOverlapCount/ActorEndOverlapCount stay 0 and payload flags stay false
 * @Provenance until overlap is generated. Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ACoveragePhysicsActorOverlapGeneratedByMovementActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	int ActorBeginOverlapCount = 0;

	UPROPERTY()
	int ActorEndOverlapCount = 0;

	UPROPERTY()
	bool ActorBeginPayloadMatched = false;

	UPROPERTY()
	bool ActorEndPayloadMatched = false;

	/**
	 * WorldStory: BeginPlay sizes the sphere and configures it to generate overlaps.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.OverlapGeneratedByMovement
	 * @Inputs a default-attached USphereComponent
	 * @Return the sphere left generating overlap events
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Sphere.SetSphereRadius(75.0f);
		Sphere.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		Sphere.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		Sphere.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Overlap);
		Sphere.SetGenerateOverlapEvents(true);
	}

	/**
	 * Count a begin overlap and check the payload names the other actor.
	 *
	 * @Kind EventHandler
	 * @Covers Actor.OverlapGeneratedByMovement
	 * @Inputs the actor that began overlapping
	 * @Return ActorBeginOverlapCount incremented and the payload flag set from the other actor
	 * @Param OtherActor the actor that began overlapping
	 */
	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		ActorBeginOverlapCount += 1;
		ActorBeginPayloadMatched =
			OtherActor != nullptr
			&& OtherActor != this;
	}

	/**
	 * Count an end overlap and check the payload names the other actor.
	 *
	 * @Kind EventHandler
	 * @Covers Actor.OverlapGeneratedByMovement
	 * @Inputs the actor that stopped overlapping
	 * @Return ActorEndOverlapCount incremented and the payload flag set from the other actor
	 * @Param OtherActor the actor that stopped overlapping
	 */
	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		ActorEndOverlapCount += 1;
		ActorEndPayloadMatched =
			OtherActor != nullptr
			&& OtherActor != this;
	}

	/**
	 * Observe that a locally constructed actor has no counts, no payload match and no component.
	 *
	 * @Kind Observe
	 * @Covers Actor.OverlapGeneratedByMovement
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both counts are 0, both flags are clear and Sphere is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ActorBeginOverlapCount != 0)
		{
			return false;
		}
		if (ActorEndOverlapCount != 0)
		{
			return false;
		}
		if (ActorBeginPayloadMatched)
		{
			return false;
		}
		if (ActorEndPayloadMatched)
		{
			return false;
		}
		return Sphere == nullptr;
	}
}
