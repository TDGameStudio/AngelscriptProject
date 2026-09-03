/**
 * The three actor-level collision delegates bound through AddUFunction. C++
 * broadcasts each once and verifies the binding flag and the three counts. Nothing
 * is recorded until BeginPlay binds the delegates.
 *
 * @Theme World.Actor
 * @Subject Actor.CollisionEvents
 * @Harness UClass
 * @Tag World.Actor.ActorCollisionEvents
 * @Provenance Theme: World.Actor. WorldStory: OnActorHit / OnActorBeginOverlap / OnActorEndOverlap
 * @Provenance bound through AddUFunction.
 * @Provenance C++: AngelscriptCoveragePhysicsTests.cpp::ActorCollisionEvents
 * @Provenance Oracle: VerifyByPath ActorDelegatesBound true, ActorHitCount 1, ActorBeginOverlapCount 1,
 * @Provenance ActorEndOverlapCount 1 after C++ broadcasts.
 * @Provenance Extra: counts stay 0 and ActorDelegatesBound stays false until BeginPlay binds.
 * @Provenance Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ACoveragePhysicsActorCollisionEventsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	int ActorHitCount = 0;

	UPROPERTY()
	int ActorBeginOverlapCount = 0;

	UPROPERTY()
	int ActorEndOverlapCount = 0;

	UPROPERTY()
	bool ActorDelegatesBound = false;

	/**
	 * WorldStory: BeginPlay configures the sphere for hits and overlaps, then binds
	 * all three actor delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.CollisionEvents
	 * @Inputs a default-attached USphereComponent
	 * @Return ActorDelegatesBound true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Sphere.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		Sphere.SetCollisionProfileName(n"OverlapAllDynamic");
		Sphere.SetNotifyRigidBodyCollision(true);
		Sphere.SetGenerateOverlapEvents(true);

		OnActorHit.AddUFunction(this, n"OnActorHitEvent");
		OnActorBeginOverlap.AddUFunction(this, n"OnActorBeginOverlapEvent");
		OnActorEndOverlap.AddUFunction(this, n"OnActorEndOverlapEvent");
		ActorDelegatesBound = true;
	}

	/**
	 * Count an actor hit broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Actor.CollisionEvents
	 * @Inputs both actors, the impulse and the hit result
	 * @Return ActorHitCount incremented
	 * @Param SelfActor the actor that was hit
	 * @Param OtherActor the other actor in the hit
	 * @Param NormalImpulse the impulse delivered by the hit
	 * @Param Hit the hit result
	 */
	UFUNCTION()
	void OnActorHitEvent(AActor SelfActor, AActor OtherActor, FVector NormalImpulse, const FHitResult&in Hit)
	{
		ActorHitCount += 1;
	}

	/**
	 * Count an actor begin overlap broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Actor.CollisionEvents
	 * @Inputs the overlapped actor and the other actor
	 * @Return ActorBeginOverlapCount incremented
	 * @Param OverlappedActor the actor that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 */
	UFUNCTION()
	void OnActorBeginOverlapEvent(AActor OverlappedActor, AActor OtherActor)
	{
		ActorBeginOverlapCount += 1;
	}

	/**
	 * Count an actor end overlap broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Actor.CollisionEvents
	 * @Inputs the overlapped actor and the other actor
	 * @Return ActorEndOverlapCount incremented
	 * @Param OverlappedActor the actor that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 */
	UFUNCTION()
	void OnActorEndOverlapEvent(AActor OverlappedActor, AActor OtherActor)
	{
		ActorEndOverlapCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has no counts and nothing bound.
	 *
	 * @Kind Observe
	 * @Covers Actor.CollisionEvents
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all counts are 0, the flag is clear and Sphere is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ActorHitCount != 0)
		{
			return false;
		}
		if (ActorBeginOverlapCount != 0)
		{
			return false;
		}
		if (ActorEndOverlapCount != 0)
		{
			return false;
		}
		if (ActorDelegatesBound)
		{
			return false;
		}
		return Sphere == nullptr;
	}
}
