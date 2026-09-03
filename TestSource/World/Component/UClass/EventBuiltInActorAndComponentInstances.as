/**
 * AddUFunction bindings on both the actor-level and the component-level built-in
 * overlap, hit, click and release delegates. C++ broadcasts once and compares the
 * handler counts. The observers cover the local-construct default and copy
 * independence.
 *
 * @Theme World.Component
 * @Subject Component.BuiltInActorAndComponentEvents
 * @Harness UClass
 * @Tag World.Component.EventBuiltInActorAndComponentInstances
 * @Provenance Theme: World.Component. WorldStory: AddUFunction on actor and sphere
 * @Provenance overlap/hit/click/release delegates.
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventBuiltInActorAndComponentInstances
 * @Provenance sha256=62e3adb9ec250080a6f2b1f7f8e04094901a4ef27e7f1104d50a2d03770f90a5; lines 646-739.
 * @Provenance Oracle after C++ broadcasts: ActorBeginOverlapCount=1, ActorHitCount=1,
 * @Provenance and the other handler counts increment once. Extra: local construct all
 * @Provenance counts 0, SphereComp null. FixtureIsolated.
 */

UCLASS()
class ACoverageEventBuiltInActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	int ActorBeginOverlapCount = 0;

	UPROPERTY()
	int ActorHitCount = 0;

	UPROPERTY()
	int ActorClickCount = 0;

	UPROPERTY()
	int ActorReleaseCount = 0;

	UPROPERTY()
	int ComponentHitCount = 0;

	UPROPERTY()
	int ComponentBeginOverlapCount = 0;

	UPROPERTY()
	int ComponentClickCount = 0;

	UPROPERTY()
	int ComponentReleaseCount = 0;

	/**
	 * WorldStory: bind all four actor delegates and all four sphere delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs a default-attached USphereComponent
	 * @Return all eight handlers bound
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnActorBeginOverlap.AddUFunction(this, n"HandleActorBeginOverlap");
		OnActorHit.AddUFunction(this, n"HandleActorHit");
		OnClicked.AddUFunction(this, n"HandleActorClicked");
		OnReleased.AddUFunction(this, n"HandleActorReleased");

		SphereComp.OnComponentHit.AddUFunction(this, n"HandleComponentHit");
		SphereComp.OnComponentBeginOverlap.AddUFunction(this, n"HandleComponentBeginOverlap");
		SphereComp.OnClicked.AddUFunction(this, n"HandleComponentClicked");
		SphereComp.OnReleased.AddUFunction(this, n"HandleComponentReleased");
	}

	/**
	 * Count an actor begin overlap broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs the overlapped actor and the other actor
	 * @Return ActorBeginOverlapCount incremented
	 * @Param OverlappedActor the actor that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 */
	UFUNCTION()
	void HandleActorBeginOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		ActorBeginOverlapCount += 1;
	}

	/**
	 * Count an actor hit broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs both actors, the impulse and the hit result
	 * @Return ActorHitCount incremented
	 * @Param SelfActor the actor that was hit
	 * @Param OtherActor the other actor in the hit
	 * @Param NormalImpulse the impulse delivered by the hit
	 * @Param Hit the hit result
	 */
	UFUNCTION()
	void HandleActorHit(AActor SelfActor, AActor OtherActor, FVector NormalImpulse, const FHitResult&in Hit)
	{
		ActorHitCount += 1;
	}

	/**
	 * Count an actor click broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs the touched actor and the button used
	 * @Return ActorClickCount incremented
	 * @Param TouchedActor the actor that was clicked
	 * @Param ButtonPressed the key that was used
	 */
	UFUNCTION()
	void HandleActorClicked(AActor TouchedActor, FKey ButtonPressed)
	{
		ActorClickCount += 1;
	}

	/**
	 * Count an actor release broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs the touched actor and the button released
	 * @Return ActorReleaseCount incremented
	 * @Param TouchedActor the actor that was released
	 * @Param ButtonReleased the key that was let go
	 */
	UFUNCTION()
	void HandleActorReleased(AActor TouchedActor, FKey ButtonReleased)
	{
		ActorReleaseCount += 1;
	}

	/**
	 * Count a component hit broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs both components, both actors, the impulse and the hit result
	 * @Return ComponentHitCount incremented
	 * @Param HitComponent the component that was hit
	 * @Param OtherActor the other actor in the hit
	 * @Param OtherComp the other component in the hit
	 * @Param NormalImpulse the impulse delivered by the hit
	 * @Param Hit the hit result
	 */
	UFUNCTION()
	void HandleComponentHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		ComponentHitCount += 1;
	}

	/**
	 * Count a component begin overlap broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs both components, both actors, the body index, the sweep flag and the sweep result
	 * @Return ComponentBeginOverlapCount incremented
	 * @Param OverlappedComponent the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index of the other component
	 * @Param bFromSweep whether the overlap came from a sweep
	 * @Param SweepResult the sweep result
	 */
	UFUNCTION()
	void HandleComponentBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
	{
		ComponentBeginOverlapCount += 1;
	}

	/**
	 * Count a component click broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs the touched component and the button used
	 * @Return ComponentClickCount incremented
	 * @Param TouchedComponent the component that was clicked
	 * @Param ButtonPressed the key that was used
	 */
	UFUNCTION()
	void HandleComponentClicked(UPrimitiveComponent TouchedComponent, FKey ButtonPressed)
	{
		ComponentClickCount += 1;
	}

	/**
	 * Count a component release broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs the touched component and the button released
	 * @Return ComponentReleaseCount incremented
	 * @Param TouchedComponent the component that was released
	 * @Param ButtonReleased the key that was let go
	 */
	UFUNCTION()
	void HandleComponentReleased(UPrimitiveComponent TouchedComponent, FKey ButtonReleased)
	{
		ComponentReleaseCount += 1;
	}

	/**
	 * Observe that a locally constructed actor holds no counts and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all eight counts are 0 and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ActorBeginOverlapCount != 0)
		{
			return false;
		}
		if (ActorHitCount != 0)
		{
			return false;
		}
		if (ActorClickCount != 0)
		{
			return false;
		}
		if (ActorReleaseCount != 0)
		{
			return false;
		}
		if (ComponentHitCount != 0)
		{
			return false;
		}
		if (ComponentBeginOverlapCount != 0)
		{
			return false;
		}
		if (ComponentClickCount != 0)
		{
			return false;
		}
		if (ComponentReleaseCount != 0)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both counts and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageEventBuiltInActor Second)
	{
		if (Second is null)
		{
			throw("EventBuiltInActorAndComponentInstances setup: required Second is null");
		}
		ActorBeginOverlapCount = 1;
		ComponentHitCount = 1;

		if (ActorBeginOverlapCount != 1)
		{
			return false;
		}
		if (ComponentHitCount != 1)
		{
			return false;
		}
		if (Second.ActorBeginOverlapCount != 0)
		{
			return false;
		}
		return Second.ComponentHitCount == 0;
	}
}
