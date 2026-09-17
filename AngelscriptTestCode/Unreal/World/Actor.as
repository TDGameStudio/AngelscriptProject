/**
 * @version v1
 * @summary World actor spawn, query, and lifecycle stories.
 * @topic Unreal
 * @topic World
 *
 * factories-and-transform-mutators
 * actor-authority-query-branches-execute-headless
 * actor-begin-overlap
 * actor-collision-events
 * actor-end-overlap
 * actor-network-role-queries-are-visible
 * actor-overlap-generated-by-movement
 * actor-replication-defaults
 * any-damage
 * begin-play
 * begin-play-idempotent
 * character-movement-mode-query-states
 * character-movement-velocity-query
 * construction-script
 * cross-call
 * default-values
 * destroy-lifecycle-order
 * handle-destroy-actor-invalidates-reference
 * interface-bound-methods
 * interface-spawn-and-query
 * multiple-spawn-syntaxes-produce-valid-actors
 * multi-spawn
 * pause-unpause-and-clear-transitions-are-observable
 * pawn-controller-and-local-control-queries
 * point-damage
 * radial-damage
 * receive-destroyed
 * receive-end-play
 * receive-end-play-reason
 * reset
 * spawn-actor-invalid-class-throws-exception
 * spawn-parameters-drive-transform-typed-and-deferred-spawns
 * tick
 * tick-registered-dispatch
 * timer-actor-destroy-stops-callbacks
 * timer-delayed-spawn-use-case-runs-from-world-timer
 * set-actor-scale-3-d
 * set-actor-tick-interval
 * enable-input
 * disable-input
 * set-replicates
 * spawn-actor
 * spawn-persistent-actor
 * spawn
 * finish-spawning-actor
 * is-actor-initialized
 * has-actor-begun-play
 * is-hidden
 * get-actor-location
 * get-actor-rotation
 * get-actor-name-or-label
 * get-game-instance
 * get-components-by-class
 * get-instigator
 * get-instigator-controller
 * get-input-component
 * get-all-actors-of-class
 * get-all-actors-of-class-with-tag
 * world-context
 * server-travel
 * world-worldtype-published-eworldtype
 * gframenumber-process-global-unsigned
 * eworldtype-copy-equals-source
 * enetmode-copy-equals-source
 * set-game-instance
 * eworldtype-none-copies-equal
 * eworldtype-game-equals-game
 * eworldtype-editor-equals-editor
 * eworldtype-pie-equals-pie
 * eworldtype-editorpreview-equals-editorpreview
 * eworldtype-gamepreview-equals-gamepreview
 * eworldtype-gamerpc-equals-gamerpc
 * eworldtype-inactive-equals-inactive
 * enetmode-nm-client-equals
 * enetmode-nm-dedicatedserver-equals
 * enetmode-nm-listenserver-equals
 * enetmode-nm-standalone-equals
 * enetmode-nm-max-equals
 * get-current-world
 * is-game-world
 * is-editor-world
 * is-preview-world
 * get-net-mode
 * get-game-state
 * get-time-seconds
 * get-unpaused-time-seconds
 * get-real-time-seconds
 * get-audio-time-seconds
 * get-delta-seconds
 * is-starting-up
 * is-tearing-down
 * get-game-instance-host
 * get-level-script-actor
 * get-persistent-level
 * is-visible
 * is-being-removed
 * get-actors
 */
/**
 * @begin factories-and-transform-mutators
 * @summary FRotator and FQuat factories plus the FTransform Blend, BlendWith and SetRotation mutators. C++ runs ExecuteAndExtractStruct against each Get* entrypoint and compares the result with the native equivalent, so those names.
 * @topic Actor
 */
namespace ActorTest
{
	/**
	 * Build a rotator from three orthonormal axes.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the X, Y and Z axes of an identity basis
	 * @Return FRotator::MakeFromAxes of the identity basis
	 */
	UFUNCTION()
	FRotator GetAxesRotator()
	{
		return FRotator::MakeFromAxes(FVector(1.0f, 0.0f, 0.0f), FVector(0.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Read the forward vector straight off the factory result.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator
	 * @Return its forward vector
	 */
	UFUNCTION()
	FVector GetAxesForward()
	{
		return GetAxesRotator().GetForwardVector();
	}

	/**
	 * Read the forward vector through a named rotator instead of the temporary.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator held in a local
	 * @Return its forward vector
	 */
	UFUNCTION()
	FVector GetAxesForwardMember()
	{
		const FRotator Rotator = GetAxesRotator();
		return Rotator.GetForwardVector();
	}

	/**
	 * Read the right vector straight off the factory result.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator
	 * @Return its right vector
	 */
	UFUNCTION()
	FVector GetAxesRight()
	{
		return GetAxesRotator().GetRightVector();
	}

	/**
	 * Read the right vector through a named rotator instead of the temporary.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator held in a local
	 * @Return its right vector
	 */
	UFUNCTION()
	FVector GetAxesRightMember()
	{
		const FRotator Rotator = GetAxesRotator();
		return Rotator.GetRightVector();
	}

	/**
	 * Read the up vector straight off the factory result.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator
	 * @Return its up vector
	 */
	UFUNCTION()
	FVector GetAxesUp()
	{
		return GetAxesRotator().GetUpVector();
	}

	/**
	 * Read the up vector through a named rotator instead of the temporary.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator held in a local
	 * @Return its up vector
	 */
	UFUNCTION()
	FVector GetAxesUpMember()
	{
		const FRotator Rotator = GetAxesRotator();
		return Rotator.GetUpVector();
	}

	/**
	 * Compose two rotators.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs rotator A yaw 90 and rotator B pitch 45
	 * @Return A.Compose(B)
	 */
	UFUNCTION()
	FRotator GetComposedRotator()
	{
		const FRotator A = FRotator(0.0f, 90.0f, 0.0f);
		const FRotator B = FRotator(45.0f, 0.0f, 0.0f);
		return A.Compose(B);
	}

	/**
	 * Measure the angular distance between two rotators.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs an identity rotator and one yawed 90 degrees
	 * @Return the angular distance between them
	 */
	UFUNCTION()
	double GetRotatorAngularDistance()
	{
		const FRotator A = FRotator(0.0f, 0.0f, 0.0f);
		const FRotator B = FRotator(0.0f, 90.0f, 0.0f);
		return A.AngularDistance(B);
	}

	/**
	 * Build a quaternion with X as the forward axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the X axis direction
	 * @Return FQuat::MakeFromX
	 */
	UFUNCTION()
	FQuat GetQuatFromX()
	{
		return FQuat::MakeFromX(FVector(1.0f, 1.0f, 0.0f));
	}

	/**
	 * Build a quaternion with Y as the forward axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Y axis direction
	 * @Return FQuat::MakeFromY
	 */
	UFUNCTION()
	FQuat GetQuatFromY()
	{
		return FQuat::MakeFromY(FVector(-1.0f, 1.0f, 0.0f));
	}

	/**
	 * Build a quaternion with Z as the forward axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Z axis direction
	 * @Return FQuat::MakeFromZ
	 */
	UFUNCTION()
	FQuat GetQuatFromZ()
	{
		return FQuat::MakeFromZ(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Build a quaternion from an X forward and a Y right axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the X forward and Y right directions
	 * @Return FQuat::MakeFromXY
	 */
	UFUNCTION()
	FQuat GetQuatFromXY()
	{
		return FQuat::MakeFromXY(FVector(1.0f, 1.0f, 0.0f), FVector(-1.0f, 1.0f, 0.0f));
	}

	/**
	 * Build a quaternion from an X forward and a Z up axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the X forward and Z up directions
	 * @Return FQuat::MakeFromXZ
	 */
	UFUNCTION()
	FQuat GetQuatFromXZ()
	{
		return FQuat::MakeFromXZ(FVector(1.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Build a quaternion from a Y forward and an X right axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Y forward and X right directions
	 * @Return FQuat::MakeFromYX
	 */
	UFUNCTION()
	FQuat GetQuatFromYX()
	{
		return FQuat::MakeFromYX(FVector(-1.0f, 1.0f, 0.0f), FVector(1.0f, 1.0f, 0.0f));
	}

	/**
	 * Build a quaternion from a Y forward and a Z up axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Y forward and Z up directions
	 * @Return FQuat::MakeFromYZ
	 */
	UFUNCTION()
	FQuat GetQuatFromYZ()
	{
		return FQuat::MakeFromYZ(FVector(-1.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Build a quaternion from a Z forward and an X right axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Z forward and X right directions
	 * @Return FQuat::MakeFromZX
	 */
	UFUNCTION()
	FQuat GetQuatFromZX()
	{
		return FQuat::MakeFromZX(FVector(0.0f, 0.0f, 1.0f), FVector(1.0f, 1.0f, 0.0f));
	}

	/**
	 * Build a quaternion from a Z forward and a Y right axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Z forward and Y right directions
	 * @Return FQuat::MakeFromZY
	 */
	UFUNCTION()
	FQuat GetQuatFromZY()
	{
		return FQuat::MakeFromZY(FVector(0.0f, 0.0f, 1.0f), FVector(-1.0f, 1.0f, 0.0f));
	}

	/**
	 * Blend two transforms into a fresh result.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs transforms A and B, blended at alpha 0.25
	 * @Return the blended transform
	 */
	UFUNCTION()
	FTransform GetBlendTransform()
	{
		FTransform Result;
		const FTransform A = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
		const FTransform B = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
		Result.Blend(A, B, 0.25f);
		return Result;
	}

	/**
	 * Blend another transform into an existing one in place.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs transform A blended towards B at alpha 0.5
	 * @Return the transform after BlendWith
	 */
	UFUNCTION()
	FTransform GetBlendWithTransform()
	{
		FTransform Result = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
		const FTransform Other = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
		Result.BlendWith(Other, 0.5f);
		return Result;
	}

	/**
	 * Replace the rotation of an existing transform.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs transform A with its rotation replaced by (-30, 15, 45)
	 * @Return the transform after SetRotation
	 */
	UFUNCTION()
	FTransform GetSetRotationTransform()
	{
		FTransform Result = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
		Result.SetRotation(FRotator(-30.0f, 15.0f, 45.0f));
		return Result;
	}

	/**
	 * Observe that an identity rotator is at zero distance from itself.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs an identity rotator compared with itself
	 * @Return the angular distance, expected to be 0
	 * @Boundary empty rotator
	 */
	UFUNCTION()
	double EmptyAngularDistanceZero()
	{
		const FRotator Empty = FRotator(0.0f, 0.0f, 0.0f);
		return Empty.AngularDistance(Empty);
	}

	/**
	 * Observe that reading the axes through a member agrees with the free function.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the free and member forward, right and up vectors
	 * @Return true when all three pairs agree
	 * @Boundary member versus free axes
	 */
	UFUNCTION()
	bool AxesMemberCopyIndependence()
	{
		if (!GetAxesForward().Equals(GetAxesForwardMember()))
		{
			return false;
		}
		if (!GetAxesRight().Equals(GetAxesRightMember()))
		{
			return false;
		}
		return GetAxesUp().Equals(GetAxesUpMember());
	}

	/**
	 * Observe that blending at zero alpha leaves the first transform untouched.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs transforms A and B blended at alpha 0
	 * @Return the blended transform, expected to equal A
	 * @Boundary zero alpha
	 */
	UFUNCTION()
	FTransform BlendZeroAlphaKeepsA()
	{
		FTransform Result;
		const FTransform A = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
		const FTransform B = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
		Result.Blend(A, B, 0.0f);
		return Result;
	}
}
/** @end */
/**
 * @begin actor-authority-query-branches-execute-headless
 * @summary Authority and role branch mask collected into one integer on a replicated actor, with an unreplicated sibling that runs the same branches. C++ runs QueryAuthorityRoleMask on both and compares the mask with the native.
 * @topic Actor
 */
UCLASS()
class ACoverageNetworkingAuthorityBranchActor : AActor
{
	default SetReplicates(true);

	UPROPERTY()
	int LastRoleMask = 0;

	/**
	 * Collect the four authority and role branches into one bitmask.
	 *
	 * @Kind Observe
	 * @Covers Actor.AuthorityQueryBranchesExecuteHeadless
	 * @Inputs none
	 * @Return the mask, with bit 1 for HasAuthority, 2 for the authority local role,
	 * 4 for a local role below authority and 8 for a None remote role
	 */
	UFUNCTION()
	int QueryAuthorityRoleMask()
	{
		int Mask = 0;
		ENetRole LocalRole = GetLocalRole();

		if (HasAuthority())
		{
			Mask |= 1;
		}
		if (LocalRole == ENetRole::ROLE_Authority)
		{
			Mask |= 2;
		}
		if (int(LocalRole) < int(ENetRole::ROLE_Authority))
		{
			Mask |= 4;
		}
		if (GetRemoteRole() == ENetRole::ROLE_None)
		{
			Mask |= 8;
		}

		LastRoleMask = Mask;
		return Mask;
	}
}

/**
 * The unreplicated sibling that runs the same branches with replication off, so
 * C++ can compare the two masks.
 *
 * @Covers Actor.AuthorityQueryBranchesExecuteHeadless
 * @Inputs none
 * @Return an actor identical to the replicated one except for SetReplicates(false)
 */
UCLASS()
class ACoverageNetworkingAuthorityBranchActorUnreplicated : AActor
{
	default SetReplicates(false);

	UPROPERTY()
	int LastRoleMask = 0;

	/**
	 * Collect the four authority and role branches into one bitmask.
	 *
	 * @Kind Observe
	 * @Covers Actor.AuthorityQueryBranchesExecuteHeadless
	 * @Inputs none
	 * @Return the mask, with bit 1 for HasAuthority, 2 for the authority local role,
	 * 4 for a local role below authority and 8 for a None remote role
	 */
	UFUNCTION()
	int QueryAuthorityRoleMask()
	{
		int Mask = 0;
		ENetRole LocalRole = GetLocalRole();

		if (HasAuthority())
		{
			Mask |= 1;
		}
		if (LocalRole == ENetRole::ROLE_Authority)
		{
			Mask |= 2;
		}
		if (int(LocalRole) < int(ENetRole::ROLE_Authority))
		{
			Mask |= 4;
		}
		if (GetRemoteRole() == ENetRole::ROLE_None)
		{
			Mask |= 8;
		}

		LastRoleMask = Mask;
		return Mask;
	}
}
/** @end */
/**
 * @begin actor-begin-overlap
 * @summary The ActorBeginOverlap BlueprintOverride recording how many times it fired and the actor that last overlapped. C++ drives the overlap and verifies both by path. ATestOverlapTrigger is the empty sibling that C++ also.
 * @topic Actor
 */
UCLASS()
class ATestOverlapReceiver : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	/**
	 * WorldStory: the begin overlap override records the other actor and counts the
	 * call.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.BeginOverlap
	 * @Inputs the actor that began overlapping
	 * @Return EventCallCount incremented and LastActorRef set to the trigger
	 * @Param OtherActor the actor that began overlapping
	 */
	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		LastActorRef = OtherActor;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed receiver has not fired.
	 *
	 * @Kind Observe
	 * @Covers Actor.BeginOverlap
	 * @Inputs a receiver that has not overlapped anything
	 * @Return true when the count is 0 and the last actor is null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return LastActorRef == nullptr;
	}
}

/**
 * The empty trigger actor that C++ compiles alongside the receiver.
 *
 * @Covers Actor.BeginOverlap
 * @Inputs none
 * @Return a declared but empty actor used as the overlap trigger
 */
UCLASS()
class ATestOverlapTrigger : AActor
{
}
/** @end */
/**
 * @begin actor-collision-events
 * @summary The three actor-level collision delegates bound through AddUFunction. C++ broadcasts each once and verifies the binding flag and the three counts. Nothing is recorded until BeginPlay binds the delegates.
 * @topic Actor
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
/** @end */
/**
 * @begin actor-end-overlap
 * @summary The ActorEndOverlap BlueprintOverride recording how many times it fired and the actor that last stopped overlapping. C++ drives the end-overlap and verifies both by path. ATestEndOverlapTrigger is the empty sibling that.
 * @topic Actor
 */
UCLASS()
class ATestEndOverlapReceiver : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	/**
	 * WorldStory: the end overlap override records the other actor and counts the
	 * call.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.EndOverlap
	 * @Inputs the actor that stopped overlapping
	 * @Return EventCallCount incremented and LastActorRef set to the trigger
	 * @Param OtherActor the actor that stopped overlapping
	 */
	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		LastActorRef = OtherActor;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed receiver has not fired.
	 *
	 * @Kind Observe
	 * @Covers Actor.EndOverlap
	 * @Inputs a receiver that has not ended an overlap
	 * @Return true when the count is 0 and the last actor is null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return LastActorRef == nullptr;
	}
}

/**
 * The empty trigger actor that C++ compiles alongside the receiver.
 *
 * @Covers Actor.EndOverlap
 * @Inputs none
 * @Return a declared but empty actor used as the overlap trigger
 */
UCLASS()
class ATestEndOverlapTrigger : AActor
{
}
/** @end */
/**
 * @begin actor-network-role-queries-are-visible
 * @summary HasAuthority, GetLocalRole and GetRemoteRole queried on a replicated actor, with an unreplicated sibling that runs the same query. The query returns -1 when the local authority checks fail, so C++ can tell "the bindings.
 * @topic Actor
 */
UCLASS()
class ACoverageNetworkingRoleQueryActor : AActor
{
	default SetReplicates(true);

	/**
	 * Return the remote role, but only after the local authority checks hold.
	 *
	 * @Kind Observe
	 * @Covers Actor.NetworkRoleQueriesAreVisible
	 * @Inputs none
	 * @Return the remote role as an integer, or -1 when any local authority check fails
	 */
	UFUNCTION()
	int QueryRemoteRoleAfterCheckingLocalAuthority()
	{
		ENetRole LocalRole = GetLocalRole();
		if (!HasAuthority()
			|| LocalRole != ENetRole::ROLE_Authority
			|| int(LocalRole) <= int(ENetRole::ROLE_AutonomousProxy))
		{
			return -1;
		}

		return int(GetRemoteRole());
	}
}

/**
 * The unreplicated sibling that runs the same query with replication off, so C++
 * can compare the two results.
 *
 * @Covers Actor.NetworkRoleQueriesAreVisible
 * @Inputs none
 * @Return an actor identical to the replicated one except for SetReplicates(false)
 */
UCLASS()
class ACoverageNetworkingRoleQueryActorUnreplicated : AActor
{
	default SetReplicates(false);

	/**
	 * Return the remote role, but only after the local authority checks hold.
	 *
	 * @Kind Observe
	 * @Covers Actor.NetworkRoleQueriesAreVisible
	 * @Inputs none
	 * @Return the remote role as an integer, or -1 when any local authority check fails
	 */
	UFUNCTION()
	int QueryRemoteRoleAfterCheckingLocalAuthority()
	{
		ENetRole LocalRole = GetLocalRole();
		if (!HasAuthority()
			|| LocalRole != ENetRole::ROLE_Authority
			|| int(LocalRole) <= int(ENetRole::ROLE_AutonomousProxy))
		{
			return -1;
		}

		return int(GetRemoteRole());
	}
}
/** @end */
/**
 * @begin actor-overlap-generated-by-movement
 * @summary The begin and end overlap overrides counted when another actor is moved into and out of the sphere, with each handler also checking that the payload names the other actor rather than this one. C++ moves the other actor.
 * @topic Actor
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
/** @end */
/**
 * @begin actor-replication-defaults
 * @summary Default SetReplicates and SetReplicateMovement applied at instance construction, with Health marked Replicated. C++ spawns the instance and verifies both flags and the health value. The unreplicated sibling is the.
 * @topic Actor
 */
UCLASS()
class ACoverageNetworkingConfigActor : AActor
{
	default SetReplicates(true);
	default SetReplicateMovement(true);

	UPROPERTY(Replicated)
	int Health = 100;
}

/**
 * The unreplicated sibling, whose zeroed health is the false/empty boundary that
 * C++ compares against.
 *
 * @Covers Actor.ReplicationDefaults
 * @Inputs none
 * @Return an actor with replication and movement replication off and Health 0
 * @Boundary unreplicated defaults
 */
UCLASS()
class ACoverageNetworkingConfigActorUnreplicated : AActor
{
	default SetReplicates(false);
	default SetReplicateMovement(false);

	UPROPERTY()
	int Health = 0;
}
/** @end */
/**
 * @begin any-damage
 * @summary The AnyDamage BlueprintOverride recording the damage amount and the causer. C++ applies damage and verifies the recorded value, actor and call count by path.
 * @topic Actor
 */
UCLASS()
class ATestActorAnyDamage : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	/**
	 * WorldStory: the damage override records the amount, the causer and the call.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.AnyDamage
	 * @Inputs the damage amount, its type, the instigating controller and the causer
	 * @Return LastFloatValue 55, LastActorRef the causer, EventCallCount 1
	 * @Param Damage the amount of damage applied
	 * @Param DamageType the type of damage applied
	 * @Param InstigatedBy the controller that instigated the damage
	 * @Param DamageCauser the actor that caused the damage
	 */
	UFUNCTION(BlueprintOverride)
	void AnyDamage(float Damage, const UDamageType DamageType, AController InstigatedBy, AActor DamageCauser)
	{
		LastFloatValue = Damage;
		LastActorRef = DamageCauser;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has received no damage.
	 *
	 * @Kind Observe
	 * @Covers Actor.AnyDamage
	 * @Inputs an actor that has not been damaged
	 * @Return true when the count is 0, the value is 0 and the causer is null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		if (LastFloatValue != 0.0)
		{
			return false;
		}
		return LastActorRef == nullptr;
	}
}
/** @end */
/**
 * @begin begin-play
 * @summary A BeginPlay override counting how many times the engine dispatched it. C++ verifies the count is 1 after the world has begun play.
 * @topic Actor
 */
UCLASS()
class ATestActorBeginPlay : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * WorldStory: BeginPlay counts each dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.BeginPlay
	 * @Inputs none
	 * @Return EventCallCount == 1 after the world has begun play
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Actor.BeginPlay
	 * @Inputs an actor that has not begun play
	 * @Return true when EventCallCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return EventCallCount == 0;
	}
}
/** @end */
/**
 * @begin begin-play-idempotent
 * @summary A BeginPlay override that must not increment a second time when the engine dispatches BeginPlay again. C++ attempts two BeginPlay dispatches and verifies the count is still 1.
 * @topic Actor
 */
UCLASS()
class ATestActorBeginPlayIdempotent : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * WorldStory: BeginPlay counts each dispatch, and a second dispatch is expected
	 * not to happen.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.BeginPlayIdempotent
	 * @Inputs none
	 * @Return EventCallCount == 1 even after two dispatch attempts
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Actor.BeginPlayIdempotent
	 * @Inputs an actor that has not begun play
	 * @Return true when EventCallCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return EventCallCount == 0;
	}
}
/** @end */
/**
 * @begin character-movement-mode-query-states
 * @summary A harness that walks a UCharacterMovementComponent through every movement mode and records whether each one read back. C++ spawns the native character and runs the harness, expecting 1. A null movement component is the.
 * @topic Actor
 */
UCLASS()
class UCoveragePhysicsCharacterMovementModeQueryHarness : UObject
{
	UPROPERTY()
	bool WalkingStateMatched = false;

	UPROPERTY()
	bool FallingStateMatched = false;

	UPROPERTY()
	bool SwimmingStateMatched = false;

	UPROPERTY()
	bool FlyingStateMatched = false;

	UPROPERTY()
	bool CustomStateMatched = false;

	/**
	 * Walk the movement component through every movement mode and record which ones
	 * read back.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementModeQueryStates
	 * @Inputs a character movement component
	 * @Return 1 when all five modes read back, 0 when the movement component is null
	 * or any mode failed
	 * @Param Movement the movement component to drive
	 */
	UFUNCTION()
	int Run(UCharacterMovementComponent Movement)
	{
		if (Movement == nullptr)
		{
			return 0;
		}

		Movement.SetMovementMode(EMovementMode::MOVE_Walking);
		WalkingStateMatched =
			Movement.MovementMode == EMovementMode::MOVE_Walking;

		Movement.SetMovementMode(EMovementMode::MOVE_Falling);
		FallingStateMatched =
			Movement.MovementMode == EMovementMode::MOVE_Falling;

		Movement.SetMovementMode(EMovementMode::MOVE_Swimming);
		SwimmingStateMatched =
			Movement.MovementMode == EMovementMode::MOVE_Swimming;

		Movement.SetMovementMode(EMovementMode::MOVE_Flying);
		FlyingStateMatched =
			Movement.MovementMode == EMovementMode::MOVE_Flying;

		Movement.SetMovementMode(EMovementMode::MOVE_Custom);
		CustomStateMatched =
			Movement.MovementMode == EMovementMode::MOVE_Custom;

		if (!WalkingStateMatched)
		{
			return 0;
		}
		if (!FallingStateMatched)
		{
			return 0;
		}
		if (!SwimmingStateMatched)
		{
			return 0;
		}
		if (!FlyingStateMatched)
		{
			return 0;
		}
		if (!CustomStateMatched)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a fresh harness has matched nothing.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementModeQueryStates
	 * @Inputs a harness that has not been run
	 * @Return true when all five flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (WalkingStateMatched)
		{
			return false;
		}
		if (FallingStateMatched)
		{
			return false;
		}
		if (SwimmingStateMatched)
		{
			return false;
		}
		if (FlyingStateMatched)
		{
			return false;
		}
		return !CustomStateMatched;
	}

	/**
	 * Observe that driving the harness with a null movement component reports failure.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementModeQueryStates
	 * @Inputs a null movement component
	 * @Return Run(nullptr), expected to be 0
	 * @Boundary null movement
	 */
	UFUNCTION()
	int NullMovementReturnsZero()
	{
		return Run(nullptr);
	}
}
/** @end */
/**
 * @begin character-movement-velocity-query
 * @summary A harness that writes and reads a character movement component's velocity, then queries the current acceleration. C++ runs the harness and expects 1. A null movement component is the early-out vector.
 * @topic Actor
 */
UCLASS()
class UCoveragePhysicsCharacterMovementVelocityQueryHarness : UObject
{
	UPROPERTY()
	bool VelocityRoundTripped = false;

	UPROPERTY()
	bool CurrentAccelerationQueried = false;

	/**
	 * Write a velocity, read it back within a tolerance, then query the current
	 * acceleration.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementVelocityQuery
	 * @Inputs a character movement component
	 * @Return 1 when the velocity read back and the acceleration was queried, 0 when the
	 * movement component is null or either step failed
	 * @Param Movement the movement component to drive
	 */
	UFUNCTION()
	int Run(UCharacterMovementComponent Movement)
	{
		if (Movement == nullptr)
		{
			return 0;
		}

		FVector TargetVelocity = FVector(120.0f, -30.0f, 45.0f);
		Movement.Velocity = TargetVelocity;
		FVector QueriedVelocity = Movement.Velocity;
		VelocityRoundTripped =
			QueriedVelocity.X > 119.99f
			&& QueriedVelocity.X < 120.01f
			&& QueriedVelocity.Y > -30.01f
			&& QueriedVelocity.Y < -29.99f
			&& QueriedVelocity.Z > 44.99f
			&& QueriedVelocity.Z < 45.01f;

		FVector CurrentAcceleration = Movement.GetCurrentAcceleration();
		CurrentAccelerationQueried = CurrentAcceleration.Equals(FVector::ZeroVector, 0.01f);

		if (!VelocityRoundTripped)
		{
			return 0;
		}
		if (!CurrentAccelerationQueried)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a fresh harness has queried nothing.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementVelocityQuery
	 * @Inputs a harness that has not been run
	 * @Return true when both flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (VelocityRoundTripped)
		{
			return false;
		}
		return !CurrentAccelerationQueried;
	}

	/**
	 * Observe that driving the harness with a null movement component reports failure.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementVelocityQuery
	 * @Inputs a null movement component
	 * @Return Run(nullptr), expected to be 0
	 * @Boundary null movement
	 */
	UFUNCTION()
	int NullMovementReturnsZero()
	{
		return Run(nullptr);
	}
}
/** @end */
/**
 * @begin construction-script
 * @summary A UserConstructionScript override computing the product of two editable values. C++ verifies the count and product after the first construction, then mutates the values and verifies them again.
 * @topic Actor
 */
UCLASS()
class ATestActorConstructionScript : AActor
{
	UPROPERTY()
	int ConstructionCallCount = 0;

	UPROPERTY()
	int ValueA = 3;

	UPROPERTY()
	int ValueB = 4;

	UPROPERTY()
	int Product = 0;

	/**
	 * WorldStory: the construction script counts each run and recomputes the product.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.ConstructionScript
	 * @Inputs none
	 * @Return ConstructionCallCount 1 with Product 12, then 2 with Product 30 once the values change
	 */
	UFUNCTION(BlueprintOverride)
	void UserConstructionScript()
	{
		ConstructionCallCount += 1;
		Product = ValueA * ValueB;
	}

	/**
	 * Observe that a locally constructed actor has not run its construction script.
	 *
	 * @Kind Observe
	 * @Covers Actor.ConstructionScript
	 * @Inputs an actor whose construction script has not run
	 * @Return true when the count is 0 and the product is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ConstructionCallCount != 0)
		{
			return false;
		}
		return Product == 0;
	}

	/**
	 * Observe that the product follows the two editable values.
	 *
	 * @Kind Observe
	 * @Covers Actor.ConstructionScript
	 * @Inputs the declared values 3 and 4
	 * @Return ValueA * ValueB
	 */
	UFUNCTION()
	int DeclaredProduct()
	{
		return ValueA * ValueB;
	}
}
/** @end */
/**
 * @begin cross-call
 * @summary Two script actors where one calls a UFUNCTION on the other from its Tick. C++ assigns the target and ticks, then verifies the callee's count. Nothing happens until the target has been assigned.
 * @topic Actor
 */
UCLASS()
class ATestActorCrossCallB : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * Count each call received from the other actor.
	 *
	 * @Kind Action
	 * @Covers Actor.CrossCall
	 * @Inputs none
	 * @Return EventCallCount incremented once per call
	 */
	UFUNCTION()
	void ReceiveCallFromA()
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed callee has received no calls.
	 *
	 * @Kind Observe
	 * @Covers Actor.CrossCall
	 * @Inputs a callee that has not been called
	 * @Return true when EventCallCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return EventCallCount == 0;
	}
}

UCLASS()
class ATestActorCrossCallA : AActor
{
	UPROPERTY()
	ATestActorCrossCallB TargetActor;

	/**
	 * WorldStory: each Tick calls into the target actor.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.CrossCall
	 * @Inputs the frame delta and the assigned target actor
	 * @Return one ReceiveCallFromA call per tick once the target is set
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TargetActor != null)
		{
			TargetActor.ReceiveCallFromA();
		}
	}

	/**
	 * Observe that a locally constructed caller has no target assigned.
	 *
	 * @Kind Observe
	 * @Covers Actor.CrossCall
	 * @Inputs a caller whose target has not been assigned
	 * @Return true when TargetActor is null
	 * @Boundary null target
	 */
	UFUNCTION()
	bool DefaultNullTarget()
	{
		return TargetActor == nullptr;
	}
}
/** @end */
/**
 * @begin default-values
 * @summary A default tick interval applied at instance construction. C++ spawns the actor and verifies the interval. The sibling keeps the engine default interval, so the two together separate "the default was applied" from "the.
 * @topic Actor
 */
UCLASS()
class ATestActorDefaultValues : AActor
{
	default PrimaryActorTick.TickInterval = 0.5f;
}

/**
 * The sibling that keeps the engine default interval, which is the boundary C++
 * compares the overridden interval against.
 *
 * @Covers Actor.DefaultValues
 * @Inputs none
 * @Return an actor with no tick interval override
 * @Boundary engine default interval
 */
UCLASS()
class ATestActorDefaultValuesUnreplicated : AActor
{
	default PrimaryActorTick.TickInterval = 0.0f;
}
/** @end */
/**
 * @begin destroy-lifecycle-order
 * @summary The EndPlay and Destroyed overrides recording the order in which the engine ran them when the actor was destroyed. C++ verifies both counts and the relative order. Nothing is recorded until the actor is destroyed.
 * @topic Actor
 */
UCLASS()
class ATestActorDestroyLifecycleOrder : AActor
{
	UPROPERTY()
	int EndPlayCallCount = 0;

	UPROPERTY()
	int DestroyedCallCount = 0;

	UPROPERTY()
	int NextOrder = 0;

	UPROPERTY()
	int EndPlayOrder = 0;

	UPROPERTY()
	int DestroyedOrder = 0;

	/**
	 * WorldStory: EndPlay counts the call and claims the next order token.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.DestroyLifecycleOrder
	 * @Inputs the end play reason supplied by the engine
	 * @Return EndPlayCallCount incremented and EndPlayOrder set to the claimed token
	 * @Param Reason why the actor is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCallCount += 1;
		NextOrder += 1;
		EndPlayOrder = NextOrder;
	}

	/**
	 * WorldStory: Destroyed counts the call and claims the next order token.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.DestroyLifecycleOrder
	 * @Inputs none
	 * @Return DestroyedCallCount incremented and DestroyedOrder set to the claimed token
	 */
	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCallCount += 1;
		NextOrder += 1;
		DestroyedOrder = NextOrder;
	}

	/**
	 * Observe that a locally constructed actor has recorded nothing.
	 *
	 * @Kind Observe
	 * @Covers Actor.DestroyLifecycleOrder
	 * @Inputs an actor that has not been destroyed
	 * @Return true when both counts and all three order fields are 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EndPlayCallCount != 0)
		{
			return false;
		}
		if (DestroyedCallCount != 0)
		{
			return false;
		}
		if (NextOrder != 0)
		{
			return false;
		}
		if (EndPlayOrder != 0)
		{
			return false;
		}
		return DestroyedOrder == 0;
	}
}
/** @end */
/**
 * @begin handle-destroy-actor-invalidates-reference
 * @summary An actor handle invalidated by DestroyActor. C++ verifies DestroyCalled and InvalidAfterDestroy by path. The CSV NegativeDiagnostic label is a heuristic: the method is a lifecycle oracle, not a compile failure. A missing.
 * @topic Actor
 */
UCLASS()
class ACoverageHandleDestroyActor : AActor
{
	UPROPERTY()
	AActor Victim;

	UPROPERTY()
	bool DestroyCalled = false;

	UPROPERTY()
	bool InvalidAfterDestroy = false;

	/**
	 * WorldStory: BeginPlay spawns a victim, destroys it, then records that the handle
	 * went invalid.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.HandleDestroyActorInvalidatesReference
	 * @Inputs none
	 * @Return DestroyCalled true once the victim was destroyed; InvalidAfterDestroy true once
	 * the handle no longer resolves
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Victim = SpawnActor(AActor::StaticClass());
		if (Victim != nullptr)
		{
			Victim.DestroyActor();
			DestroyCalled = true;
		}
		InvalidAfterDestroy = !IsValid(Victim);
	}

	/**
	 * Observe that a locally constructed actor has destroyed nothing.
	 *
	 * @Kind Observe
	 * @Covers Actor.HandleDestroyActorInvalidatesReference
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the victim is null, DestroyCalled is clear and InvalidAfterDestroy is clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (Victim != nullptr)
		{
			return false;
		}
		if (DestroyCalled)
		{
			return false;
		}
		return !InvalidAfterDestroy;
	}
}
/** @end */
/**
 * @begin interface-bound-methods
 * @summary AActor bound methods exercised before and after BeginPlay, plus the instigator pair. C++ runs the three entrypoints on the spawned actor and expects 1 from each. The null instigator pair is the empty vector that still.
 * @topic Actor
 */
UCLASS()
class ATestActorInterfaceBoundMethods : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	/**
	 * Exercise the bound methods that must already work before BeginPlay has run, then
	 * mutate the scale and tick interval.
	 *
	 * @Kind Observe
	 * @Covers Actor.InterfaceBoundMethods
	 * @Inputs none
	 * @Return 1 on success; 10 through 70 naming the step that failed
	 */
	UFUNCTION()
	int CheckBeforeBeginPlay()
	{
		if (!IsActorInitialized())
		{
			return 10;
		}
		if (HasActorBegunPlay())
		{
			return 20;
		}
		if (!IsHidden())
		{
			return 30;
		}
		if (!GetActorLocation().Equals(FVector(10.0, 20.0, 30.0)))
		{
			return 40;
		}
		if (!GetActorRotation().Equals(FRotator(5.0, 45.0, 15.0), 0.01))
		{
			return 50;
		}

		SetActorScale3D(FVector(2.0, 3.0, 4.0));
		SetActorTickInterval(0.25f);

		if (GetActorNameOrLabel().Len() <= 0)
		{
			return 60;
		}
		if (!IsValid(GetGameInstance()))
		{
			return 70;
		}

		return 1;
	}

	/**
	 * Confirm that the instigator pair matches what the caller supplies.
	 *
	 * @Kind Observe
	 * @Covers Actor.InterfaceBoundMethods
	 * @Inputs the expected instigator pawn and controller
	 * @Return 1 on success; 100 or 110 naming the step that failed
	 * @Param BaselinePawn the pawn the instigator is expected to be, or null for unset
	 * @Param BaselineController the controller expected, or null for unset
	 * @Boundary null instigator pair
	 */
	UFUNCTION()
	int CheckInstigator(APawn BaselinePawn, AController BaselineController)
	{
		if (GetInstigator() != BaselinePawn)
		{
			return 100;
		}
		if (GetInstigatorController() != BaselineController)
		{
			return 110;
		}

		return 1;
	}

	/**
	 * Exercise the bound methods that only hold once BeginPlay has run.
	 *
	 * @Kind Observe
	 * @Covers Actor.InterfaceBoundMethods
	 * @Inputs none
	 * @Return 1 on success; 80 or 90 naming the step that failed
	 */
	UFUNCTION()
	int CheckAfterBeginPlay()
	{
		if (!HasActorBegunPlay())
		{
			return 80;
		}
		if (!GetActorLocation().Equals(FVector(10.0, 20.0, 30.0)))
		{
			return 90;
		}

		return 1;
	}

	/**
	 * Observe that the instigator check passes when both native instigators are unset.
	 *
	 * @Kind Observe
	 * @Covers Actor.InterfaceBoundMethods
	 * @Inputs no instigator pawn and no instigator controller
	 * @Return CheckInstigator(nullptr, nullptr), expected to be 1
	 * @Boundary null instigator pair
	 */
	UFUNCTION()
	int NullInstigatorReturnsOne()
	{
		return CheckInstigator(nullptr, nullptr);
	}
}
/** @end */
/**
 * @begin interface-spawn-and-query
 * @summary Every spawn syntax followed by the three GetAllActorsOfClass query shapes. C++ runs the entrypoint and expects 1. The spawned class carries a tag and a default marker so both the class and tag queries can resolve it.
 * @topic Actor
 */
UCLASS()
class ATestActorInterfaceSpawned : AActor
{
	default Tags.Add(n"ActorInterfaceSpawned");

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY()
	int Marker = 7;
}

UCLASS()
class ATestActorInterfaceSpawnAndQuery : AActor
{
	/**
	 * Spawn through every supported syntax, then query the results by class and by tag.
	 *
	 * @Kind Observe
	 * @Covers Actor.InterfaceSpawnAndQuery
	 * @Inputs none
	 * @Return 1 on success; 10 through 80 naming the step that failed
	 */
	UFUNCTION()
	int RunSpawnAndQuery()
	{
		AActor NativeSpawned = AActor::Spawn(FVector(100.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfaceNativeSpawned");
		if (!IsValid(NativeSpawned))
		{
			return 10;
		}

		AActor GenericSpawned = SpawnActor(ATestActorInterfaceSpawned::StaticClass(), FVector(200.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfaceGenericSpawned");
		if (!IsValid(GenericSpawned))
		{
			return 20;
		}

		AActor DeferredSpawned = SpawnActor(ATestActorInterfaceSpawned::StaticClass(), FVector(300.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfaceDeferredSpawned", true);
		if (!IsValid(DeferredSpawned))
		{
			return 30;
		}
		FinishSpawningActor(DeferredSpawned);
		if (!DeferredSpawned.GetActorLocation().Equals(FVector(300.0, 0.0, 0.0)))
		{
			return 40;
		}

		AActor DeferredTransformSpawned = SpawnActor(ATestActorInterfaceSpawned::StaticClass(), FVector::ZeroVector, FRotator::ZeroRotator, n"ActorInterfaceDeferredTransformSpawned", true);
		if (!IsValid(DeferredTransformSpawned))
		{
			return 45;
		}
		FinishSpawningActor(DeferredTransformSpawned, FTransform(FRotator::ZeroRotator, FVector(350.0, 0.0, 0.0), FVector::OneVector));
		if (!DeferredTransformSpawned.GetActorLocation().Equals(FVector(350.0, 0.0, 0.0)))
		{
			return 46;
		}

		AActor PersistentSpawned = SpawnPersistentActor(ATestActorInterfaceSpawned::StaticClass(), FVector(400.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfacePersistentSpawned");
		if (!IsValid(PersistentSpawned))
		{
			return 50;
		}

		AActor PersistentDeferredSpawned = SpawnPersistentActor(ATestActorInterfaceSpawned::StaticClass(), FVector(450.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfacePersistentDeferredSpawned", true);
		if (!IsValid(PersistentDeferredSpawned))
		{
			return 55;
		}
		FinishSpawningActor(PersistentDeferredSpawned);
		if (!PersistentDeferredSpawned.GetActorLocation().Equals(FVector(450.0, 0.0, 0.0)))
		{
			return 56;
		}

		TArray<ATestActorInterfaceSpawned> TypedActors;
		GetAllActorsOfClass(TypedActors);
		if (TypedActors.Num() < 5)
		{
			return 60;
		}

		TArray<AActor> ExplicitClassActors;
		GetAllActorsOfClass(ATestActorInterfaceSpawned::StaticClass(), ExplicitClassActors);
		if (ExplicitClassActors.Num() < 5)
		{
			return 70;
		}

		TArray<AActor> TaggedActors;
		GetAllActorsOfClassWithTag(n"ActorInterfaceSpawned", TaggedActors);
		if (TaggedActors.Num() < 5)
		{
			return 80;
		}

		return 1;
	}
}
/** @end */
/**
 * @begin multiple-spawn-syntaxes-produce-valid-actors
 * @summary Positional, named-argument, deferred and TSubclassOf SpawnActor calls, each counted separately. C++ verifies all four counts by path. The deferred spawn also writes a tag onto the actor before finishing it.
 * @topic Actor
 */
UCLASS()
class AFunctionalSpawnTargetActor : AActor
{
	UPROPERTY()
	int32 TargetTag = 0;
}

UCLASS()
class AFunctionalSpawnSourceActor : AActor
{
	UPROPERTY()
	int32 PositionalSpawnedCount = 0;

	UPROPERTY()
	int32 NamedSpawnedCount = 0;

	UPROPERTY()
	int32 DeferredSpawnedCount = 0;

	UPROPERTY()
	int32 CastSpawnedCount = 0;

	/**
	 * WorldStory: BeginPlay spawns one target through each of the four supported
	 * syntaxes and counts the ones that resolved.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.MultipleSpawnSyntaxesProduceValidActors
	 * @Inputs none
	 * @Return all four counts == 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AFunctionalSpawnTargetActor PositionalSpawn = Cast<AFunctionalSpawnTargetActor>(SpawnActor(
			AFunctionalSpawnTargetActor::StaticClass(),
			FVector(100.0, 0.0, 0.0),
			FRotator::ZeroRotator));
		if (PositionalSpawn != nullptr)
		{
			PositionalSpawnedCount += 1;
		}

		AFunctionalSpawnTargetActor NamedSpawn = Cast<AFunctionalSpawnTargetActor>(SpawnActor(
			AFunctionalSpawnTargetActor::StaticClass(),
			Location = FVector(0.0, 100.0, 0.0),
			Rotation = FRotator::ZeroRotator));
		if (NamedSpawn != nullptr)
		{
			NamedSpawnedCount += 1;
		}

		AActor DeferredSpawn = SpawnActor(
			AFunctionalSpawnTargetActor::StaticClass(),
			Location = FVector(0.0, 0.0, 100.0),
			Rotation = FRotator::ZeroRotator,
			bDeferredSpawn = true);
		if (DeferredSpawn != nullptr)
		{
			AFunctionalSpawnTargetActor TypedDeferred = Cast<AFunctionalSpawnTargetActor>(DeferredSpawn);
			if (TypedDeferred != nullptr)
			{
				TypedDeferred.TargetTag = 99;
			}
			FinishSpawningActor(DeferredSpawn);
			DeferredSpawnedCount += 1;
		}

		TSubclassOf<AFunctionalSpawnTargetActor> TargetSubclass = AFunctionalSpawnTargetActor::StaticClass();
		AFunctionalSpawnTargetActor TypedSpawn = Cast<AFunctionalSpawnTargetActor>(SpawnActor(TargetSubclass));
		if (TypedSpawn != nullptr)
		{
			CastSpawnedCount += 1;
		}
	}

	/**
	 * Observe that a locally constructed source has spawned nothing.
	 *
	 * @Kind Observe
	 * @Covers Actor.MultipleSpawnSyntaxesProduceValidActors
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four counts are 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (PositionalSpawnedCount != 0)
		{
			return false;
		}
		if (NamedSpawnedCount != 0)
		{
			return false;
		}
		if (DeferredSpawnedCount != 0)
		{
			return false;
		}
		return CastSpawnedCount == 0;
	}
}
/** @end */
/**
 * @begin multi-spawn
 * @summary A BeginPlay override counted on every spawned instance. C++ spawns three instances and verifies each count reaches 1. The spawn is the C++ fixture oracle rather than a script-side SpawnActor.
 * @topic Actor
 */
UCLASS()
class ATestActorMultiSpawn : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * WorldStory: BeginPlay counts each dispatch on this instance.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.MultiSpawn
	 * @Inputs none
	 * @Return EventCallCount == 1 on every spawned instance
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed instance has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Actor.MultiSpawn
	 * @Inputs an instance that has not begun play
	 * @Return true when EventCallCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return EventCallCount == 0;
	}
}
/** @end */
/**
 * @begin pause-unpause-and-clear-transitions-are-observable
 * @summary A looping timer walked through set, pause, unpause and clear, with the paused state recorded after each transition. The CSV NegativeDiagnostic label is a heuristic: the method is a timer state-machine oracle, not a.
 * @topic Actor
 */
UCLASS()
class AFunctionalTimerActor : AActor
{
	UPROPERTY()
	FTimerHandle LoopingHandle;

	UPROPERTY()
	bool bAfterSetIsPaused = false;

	UPROPERTY()
	bool bAfterPauseIsPaused = false;

	UPROPERTY()
	bool bAfterUnPauseIsPaused = false;

	UPROPERTY()
	bool bAfterClearIsPaused = false;

	/**
	 * The callback the looping timer fires into.
	 *
	 * @Kind EventHandler
	 * @Covers Actor.PauseUnpauseAndClearTransitionsAreObservable
	 * @Inputs none
	 * @Return nothing; the timer state machine is what the test observes
	 */
	UFUNCTION()
	void NoopTimerCallback()
	{
	}

	/**
	 * WorldStory: BeginPlay starts a looping timer, then records the paused state
	 * after each of the pause, unpause and clear transitions.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.PauseUnpauseAndClearTransitionsAreObservable
	 * @Inputs none
	 * @Return false, true, false, false in that order
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		LoopingHandle = System::SetTimer(this, n"NoopTimerCallback", 0.5f, true);
		bAfterSetIsPaused = System::IsTimerPausedHandle(LoopingHandle);

		System::PauseTimerHandle(LoopingHandle);
		bAfterPauseIsPaused = System::IsTimerPausedHandle(LoopingHandle);

		System::UnPauseTimerHandle(LoopingHandle);
		bAfterUnPauseIsPaused = System::IsTimerPausedHandle(LoopingHandle);

		System::ClearAndInvalidateTimerHandle(LoopingHandle);
		bAfterClearIsPaused = System::IsTimerPausedHandle(LoopingHandle);
	}

	/**
	 * Observe that a locally constructed actor has recorded no timer state.
	 *
	 * @Kind Observe
	 * @Covers Actor.PauseUnpauseAndClearTransitionsAreObservable
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bAfterSetIsPaused)
		{
			return false;
		}
		if (bAfterPauseIsPaused)
		{
			return false;
		}
		if (bAfterUnPauseIsPaused)
		{
			return false;
		}
		return !bAfterClearIsPaused;
	}
}
/** @end */
/**
 * @begin pawn-controller-and-local-control-queries
 * @summary Controller and local-control queries on an unpossessed pawn, collected into one bitmask. C++ spawns the pawn and compares the mask with the native query results. Nothing is recorded until the query runs.
 * @topic Actor
 */
UCLASS()
class ACoverageNetworkingPawnControllerQueries : APawn
{
	UPROPERTY()
	int LastQueriedMask = 0;

	/**
	 * Collect the six controller and local-control states of an unpossessed pawn into
	 * one bitmask.
	 *
	 * @Kind Observe
	 * @Covers Actor.PawnControllerAndLocalControlQueries
	 * @Inputs none
	 * @Return the mask, with a bit per query that reports the unpossessed value
	 */
	UFUNCTION()
	int QueryUnpossessedPawnControllerState()
	{
		int Mask = 0;

		if (GetController() == null)
		{
			Mask |= 1;
		}
		if (GetPlayerController() == null)
		{
			Mask |= 2;
		}
		if (!IsLocallyControlled())
		{
			Mask |= 4;
		}
		if (!IsPlayerControlled())
		{
			Mask |= 8;
		}
		if (!IsBotControlled())
		{
			Mask |= 16;
		}
		if (GetPlayerState() == null)
		{
			Mask |= 32;
		}

		LastQueriedMask = Mask;
		return Mask;
	}

	/**
	 * Observe that a locally constructed pawn has not been queried.
	 *
	 * @Kind Observe
	 * @Covers Actor.PawnControllerAndLocalControlQueries
	 * @Inputs a pawn whose query has not run
	 * @Return true when LastQueriedMask is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return LastQueriedMask == 0;
	}
}
/** @end */
/**
 * @begin point-damage
 * @summary The PointDamage BlueprintOverride recording the amount, hit location and bone name. C++ applies point damage and verifies all four recorded values by path.
 * @topic Actor
 */
UCLASS()
class ATestActorPointDamage : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UPROPERTY()
	FVector LastVectorValue = FVector::ZeroVector;

	UPROPERTY()
	FName LastNameValue;

	/**
	 * WorldStory: the point damage override records the amount, location and bone.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.PointDamage
	 * @Inputs the damage amount, its type, the hit geometry, the bone, the shot
	 * direction, the instigator, the causer and the full hit result
	 * @Return LastFloatValue 42, LastVectorValue (100, 200, 300), LastNameValue spine_01, EventCallCount 1
	 * @Param Damage the amount of damage applied
	 * @Param DamageType the type of damage applied
	 * @Param HitLocation where the hit landed
	 * @Param HitNormal the surface normal at the hit
	 * @Param HitComponent the component that was hit
	 * @Param BoneName the bone that was hit
	 * @Param ShotFromDirection the direction the shot came from
	 * @Param InstigatedBy the controller that instigated the damage
	 * @Param DamageCauser the actor that caused the damage
	 * @Param HitInfo the full hit result
	 */
	UFUNCTION(BlueprintOverride)
	void PointDamage(float Damage, const UDamageType DamageType, FVector HitLocation,
		FVector HitNormal, UPrimitiveComponent HitComponent, FName BoneName,
		FVector ShotFromDirection, AController InstigatedBy,
		AActor DamageCauser, FHitResult HitInfo)
	{
		LastFloatValue = Damage;
		LastVectorValue = HitLocation;
		LastNameValue = BoneName;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has received no damage.
	 *
	 * @Kind Observe
	 * @Covers Actor.PointDamage
	 * @Inputs an actor that has not been damaged
	 * @Return true when the count is 0, the value is 0, the vector is zero and the name is empty
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		if (LastFloatValue != 0.0)
		{
			return false;
		}
		if (!LastVectorValue.Equals(FVector::ZeroVector))
		{
			return false;
		}
		return LastNameValue.IsNone();
	}
}
/** @end */
/**
 * @begin radial-damage
 * @summary The RadialDamage BlueprintOverride recording the amount and the blast origin. C++ applies radial damage and verifies the recorded values by path. The sphere root is sized in the class defaults.
 * @topic Actor
 */
UCLASS()
class UTestActorRadialDamageSphere : USphereComponent
{
}

UCLASS()
class ATestActorRadialDamage : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestActorRadialDamageSphere DamageSphere;

	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UPROPERTY()
	FVector LastVectorValue = FVector::ZeroVector;

	default DamageSphere.SetSphereRadius(64.0f);

	/**
	 * WorldStory: the radial damage override records the amount and the blast origin.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.RadialDamage
	 * @Inputs the damage amount, its type, the blast origin, the hit result, the
	 * instigator and the causer
	 * @Return LastFloatValue 24, LastVectorValue the actor location, EventCallCount 1
	 * @Param DamageReceived the amount of damage applied
	 * @Param DamageType the type of damage applied
	 * @Param Origin where the blast originated
	 * @Param HitInfo the full hit result
	 * @Param InstigatedBy the controller that instigated the damage
	 * @Param DamageCauser the actor that caused the damage
	 */
	UFUNCTION(BlueprintOverride)
	void RadialDamage(float DamageReceived, const UDamageType DamageType, FVector Origin,
		FHitResult HitInfo, AController InstigatedBy, AActor DamageCauser)
	{
		LastFloatValue = DamageReceived;
		LastVectorValue = Origin;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has received no damage.
	 *
	 * @Kind Observe
	 * @Covers Actor.RadialDamage
	 * @Inputs an actor that has not been damaged
	 * @Return true when the count is 0, the value is 0, the vector is zero and the sphere is null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		if (LastFloatValue != 0.0)
		{
			return false;
		}
		if (!LastVectorValue.Equals(FVector::ZeroVector))
		{
			return false;
		}
		return DamageSphere == nullptr;
	}
}
/** @end */
/**
 * @begin receive-destroyed
 * @summary The Destroyed BlueprintOverride counting how many times the engine dispatched it. C++ verifies the count is 1 after the actor is destroyed.
 * @topic Actor
 */
UCLASS()
class ATestActorReceiveDestroyed : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * WorldStory: Destroyed counts each dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.ReceiveDestroyed
	 * @Inputs none
	 * @Return EventCallCount == 1 after the actor is destroyed
	 */
	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has not been destroyed.
	 *
	 * @Kind Observe
	 * @Covers Actor.ReceiveDestroyed
	 * @Inputs an actor that has not been destroyed
	 * @Return true when EventCallCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return EventCallCount == 0;
	}
}
/** @end */
/**
 * @begin receive-end-play
 * @summary The EndPlay BlueprintOverride counting how many times the engine dispatched it. C++ verifies the count is 1 after a destroy or end of play.
 * @topic Actor
 */
UCLASS()
class ATestActorReceiveEndPlay : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * WorldStory: EndPlay counts each dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.ReceiveEndPlay
	 * @Inputs the end play reason supplied by the engine
	 * @Return EventCallCount == 1 after a destroy or end of play
	 * @Param Reason why the actor is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has not ended play.
	 *
	 * @Kind Observe
	 * @Covers Actor.ReceiveEndPlay
	 * @Inputs an actor that has not ended play
	 * @Return true when EventCallCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return EventCallCount == 0;
	}
}
/** @end */
/**
 * @begin receive-end-play-reason
 * @summary The EndPlay BlueprintOverride recording the reason it was given. C++ verifies the count and that the reason came through as Destroyed.
 * @topic Actor
 */
UCLASS()
class ATestActorReceiveEndPlayReason : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	EEndPlayReason LastReason = EEndPlayReason::Quit;

	/**
	 * WorldStory: EndPlay records the reason and counts the dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.ReceiveEndPlayReason
	 * @Inputs the end play reason supplied by the engine
	 * @Return EventCallCount 1 and LastReason set to Destroyed
	 * @Param Reason why the actor is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		LastReason = Reason;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Actor.ReceiveEndPlayReason
	 * @Inputs an actor that has not ended play
	 * @Return true when the count is 0 and the reason is still Quit
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return LastReason == EEndPlayReason::Quit;
	}
}
/** @end */
/**
 * @begin reset
 * @summary The OnReset override writing a new value and counting the dispatch. C++ verifies both by path. Nothing changes until the reset is requested.
 * @topic Actor
 */
UCLASS()
class ATestActorReset : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	int ResetValue = 3;

	/**
	 * WorldStory: the reset override rewrites the value and counts the dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.Reset
	 * @Inputs none
	 * @Return EventCallCount 1 and ResetValue 7
	 */
	UFUNCTION(BlueprintOverride)
	void OnReset()
	{
		ResetValue = 7;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Actor.Reset
	 * @Inputs an actor that has not been reset
	 * @Return true when the count is 0 and the value is still 3
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return ResetValue == 3;
	}
}
/** @end */
/**
 * @begin spawn-actor-invalid-class-throws-exception
 * @summary SpawnActor called with a null class, which must raise a script exception at runtime. C++ compiles this actor and then invokes the entrypoint expecting the exception, so this is a runtime exception oracle rather than a.
 * @topic Actor
 */
UCLASS()
class ATestActorSpawnInvalidClass : AActor
{
	/**
	 * The throwing entrypoint: SpawnActor with a null class raises at runtime. C++
	 * invokes this and expects the exception; no observer calls it.
	 *
	 * @Kind Action
	 * @Covers Actor.SpawnActorInvalidClassThrowsException
	 * @Inputs none
	 * @Return nothing; throws before it can return
	 */
	UFUNCTION()
	void RunSpawnInvalidClassTest()
	{
		AActor Spawned = SpawnActor(nullptr, FVector::ZeroVector, FRotator::ZeroRotator, n"InvalidSpawn");
	}
}
/** @end */
/**
 * @begin spawn-parameters-drive-transform-typed-and-deferred-spawns
 * @summary FActorSpawnParameters driving typed, deferred, world and persistent spawns. C++ verifies the result code is 1 after the owner, transform and tag checks. The deferred spawn writes a tag onto the actor before it is.
 * @topic Actor
 */
UCLASS()
class ASpawnParametersTargetActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY()
	int32 TargetTag = 0;
}

UCLASS()
class ASpawnParametersSourceActor : AActor
{
	UPROPERTY()
	int32 SpawnParametersResult = 0;

	/**
	 * WorldStory: BeginPlay spawns a target through each parameter-driven syntax,
	 * checking the owner, the transform and the deferred tag write as it goes.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.SpawnParametersDriveTransform
	 * @Inputs none
	 * @Return SpawnParametersResult 1 on success; 10 through 70 naming the step that failed
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FActorSpawnParameters Parameters;
		Parameters.Name = n"SpawnParametersTarget";
		Parameters.Owner = this;
		Parameters.NameMode = ESpawnActorNameMode::Requested;
		Parameters.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
		Parameters.SetbDeferConstruction(true);

		FTransform SpawnTransform = FTransform(FRotator::ZeroRotator, FVector(125.0, 250.0, 375.0), FVector::OneVector);
		ASpawnParametersTargetActor Spawned = ASpawnParametersTargetActor::Spawn(SpawnTransform, Parameters);
		if (Spawned == nullptr)
		{
			SpawnParametersResult = 10;
			return;
		}
		if (Spawned.GetOwner() != this)
		{
			SpawnParametersResult = 20;
			return;
		}
		Spawned.TargetTag = 42;
		FinishSpawningActor(Spawned, SpawnTransform);
		if (!Spawned.GetActorLocation().Equals(FVector(125.0, 250.0, 375.0)))
		{
			SpawnParametersResult = 30;
			return;
		}
		if (Spawned.TargetTag != 42)
		{
			SpawnParametersResult = 40;
			return;
		}

		FActorSpawnParameters GlobalParameters = Parameters;
		GlobalParameters.Name = n"GlobalSpawnParametersTarget";
		GlobalParameters.SetbDeferConstruction(false);
		AActor GlobalSpawned = SpawnActor(ASpawnParametersTargetActor::StaticClass(), SpawnTransform, GlobalParameters);
		if (GlobalSpawned == nullptr || GlobalSpawned.GetOwner() != this)
		{
			SpawnParametersResult = 50;
			return;
		}

		FActorSpawnParameters WorldParameters;
		WorldParameters.Name = n"WorldSpawnParametersTarget";
		WorldParameters.Owner = this;
		AActor WorldSpawned = GetWorld().SpawnActor(ASpawnParametersTargetActor::StaticClass(), SpawnTransform, WorldParameters);
		if (WorldSpawned == nullptr || WorldSpawned.GetOwner() != this)
		{
			SpawnParametersResult = 60;
			return;
		}

		FActorSpawnParameters PersistentParameters;
		PersistentParameters.Name = n"PersistentSpawnParametersTarget";
		PersistentParameters.Owner = this;
		AActor PersistentSpawned = SpawnPersistentActor(ASpawnParametersTargetActor::StaticClass(), SpawnTransform, PersistentParameters);
		SpawnParametersResult = PersistentSpawned != nullptr && PersistentSpawned.GetOwner() == this ? 1 : 70;
	}

	/**
	 * Observe that a locally constructed source has no result recorded.
	 *
	 * @Kind Observe
	 * @Covers Actor.SpawnParametersDriveTransform
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when SpawnParametersResult is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return SpawnParametersResult == 0;
	}
}
/** @end */
/**
 * @begin tick
 * @summary A Tick override counting dispatches and storing the last frame delta. C++ ticks the world manually and verifies the count and the delta.
 * @topic Actor
 */
UCLASS()
class ATestActorTick : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastDeltaTime = 0.0f;

	/**
	 * WorldStory: Tick counts each dispatch and keeps the delta it was given.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.Tick
	 * @Inputs the frame delta
	 * @Return EventCallCount at least 5 and LastDeltaTime greater than 0 after manual ticks
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		EventCallCount += 1;
		LastDeltaTime = DeltaTime;
	}

	/**
	 * Observe that a locally constructed actor has not ticked.
	 *
	 * @Kind Observe
	 * @Covers Actor.Tick
	 * @Inputs an actor that has not been ticked
	 * @Return true when the count is 0 and the delta is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return LastDeltaTime == 0.0f;
	}
}
/** @end */
/**
 * @begin tick-registered-dispatch
 * @summary A Tick override reached through the world tick manager rather than a manual tick. C++ dispatches a world tick and verifies the count and the delta.
 * @topic Actor
 */
UCLASS()
class ATestActorTickRegisteredDispatch : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastDeltaTime = 0.0f;

	/**
	 * WorldStory: a world tick dispatch reaches this override, which counts it and
	 * keeps the delta.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.TickRegisteredDispatch
	 * @Inputs the frame delta
	 * @Return EventCallCount at least 1 and LastDeltaTime greater than 0 after a dispatch
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		EventCallCount += 1;
		LastDeltaTime = DeltaTime;
	}

	/**
	 * Observe that a locally constructed actor has not ticked.
	 *
	 * @Kind Observe
	 * @Covers Actor.TickRegisteredDispatch
	 * @Inputs an actor that has not been ticked
	 * @Return true when the count is 0 and the delta is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return LastDeltaTime == 0.0f;
	}
}
/** @end */
/**
 * @begin timer-actor-destroy-stops-callbacks
 * @summary A looping timer on an actor, whose callbacks must stop once the actor is destroyed. C++ verifies the timer was active before the destroy and that the callback count stayed at zero throughout.
 * @topic Actor
 */
UCLASS()
class ACoverageTimerDestroyCleanupActor : AActor
{
	UPROPERTY()
	int CallbackCount = 0;

	UPROPERTY()
	bool bTimerActiveBeforeDestroy = false;

	FTimerHandle DestroyCleanupHandle;

	/**
	 * Count each timer callback and print the running total.
	 *
	 * @Kind EventHandler
	 * @Covers Actor.TimerActorDestroyStopsCallbacks
	 * @Inputs none
	 * @Return CallbackCount incremented once per callback
	 */
	UFUNCTION()
	void CleanupCallback()
	{
		CallbackCount++;
		Print("CleanupCallback executed, count: " + CallbackCount);
	}

	/**
	 * WorldStory: BeginPlay starts the looping timer and records that it went active.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.TimerActorDestroyStopsCallbacks
	 * @Inputs none
	 * @Return bTimerActiveBeforeDestroy true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DestroyCleanupHandle = System::SetTimer(this, n"CleanupCallback", 0.1f, true);
		bTimerActiveBeforeDestroy = SystemLibrary::IsTimerActiveHandle(DestroyCleanupHandle);
	}

	/**
	 * Observe that a locally constructed actor has no count and no timer state.
	 *
	 * @Kind Observe
	 * @Covers Actor.TimerActorDestroyStopsCallbacks
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the count is 0 and the flag is clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (CallbackCount != 0)
		{
			return false;
		}
		return !bTimerActiveBeforeDestroy;
	}
}
/** @end */
/**
 * @begin timer-delayed-spawn-use-case-runs-from-world-timer
 * @summary A delayed world timer that spawns an actor when it fires. C++ verifies the timer went active, that nothing had spawned yet immediately after setup, and that the remaining time fell inside the requested delay.
 * @topic Actor
 */
UCLASS()
class ACoverageTimerDelayedSpawnActor : AActor
{
	UPROPERTY()
	AActor SpawnedActor;

	UPROPERTY()
	bool bSpawnTimerActiveAfterSetup = false;

	UPROPERTY()
	bool bSpawnedAfterDelay = false;

	UPROPERTY()
	bool bSpawnedActorValid = false;

	UPROPERTY()
	int SpawnCount = 0;

	UPROPERTY()
	float SpawnRemainingAfterSetup = 0.0f;

	UPROPERTY()
	bool bSpawnRemainingWithinDelay = false;

	FTimerHandle SpawnHandle;

	/**
	 * Spawn an actor, record the attempt, and mark that the delayed callback ran.
	 *
	 * @Kind Action
	 * @Covers Actor.TimerDelayedSpawnUseCase
	 * @Inputs none
	 * @Return SpawnCount incremented, bSpawnedAfterDelay set, bSpawnedActorValid set from the spawn
	 */
	UFUNCTION()
	void SpawnDelayedActor()
	{
		SpawnedActor = SpawnActor(AActor::StaticClass());
		SpawnCount++;
		bSpawnedAfterDelay = true;
		bSpawnedActorValid = (SpawnedActor != nullptr);
	}

	/**
	 * WorldStory: BeginPlay arms the delayed spawn timer, then records that it went
	 * active and how much time was left on it.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.TimerDelayedSpawnUseCase
	 * @Inputs none
	 * @Return bSpawnTimerActiveAfterSetup true, bSpawnedAfterDelay false, bSpawnRemainingWithinDelay true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SpawnHandle = System::SetTimer(this, n"SpawnDelayedActor", 0.2f, false);
		bSpawnTimerActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(SpawnHandle);
		SpawnRemainingAfterSetup = SystemLibrary::GetTimerRemainingTimeHandle(SpawnHandle);
		bSpawnRemainingWithinDelay = SpawnRemainingAfterSetup > 0.0f && SpawnRemainingAfterSetup <= 0.25f;
	}

	/**
	 * Observe that a locally constructed actor has spawned nothing and armed no timer.
	 *
	 * @Kind Observe
	 * @Covers Actor.TimerDelayedSpawnUseCase
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear, the count is 0, the remaining time is 0 and
	 * the spawned handle is null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (SpawnedActor != nullptr)
		{
			return false;
		}
		if (bSpawnTimerActiveAfterSetup)
		{
			return false;
		}
		if (bSpawnedAfterDelay)
		{
			return false;
		}
		if (bSpawnedActorValid)
		{
			return false;
		}
		if (SpawnCount != 0)
		{
			return false;
		}
		if (SpawnRemainingAfterSetup != 0.0f)
		{
			return false;
		}
		return !bSpawnRemainingWithinDelay;
	}
}
/** @end */
/**
 * @begin set-actor-scale-3-d
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveSetActorScale3DNominal
 * @summary Expected observations:
 * @covers AActor.set-actor-scale-3-d
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Scale becomes (2,3,4). Tick interval becomes 0.25
// then 0. EnableInput creates an input component; DisableInput is issued
// after. SetReplicates(true) then false is visible on GetIsReplicated. Spawn
// helpers return a live actor; null Class is the diagnostic path.
// Boundary/ownership: SetupOwner=Runner for mutations. Spawn cleanup is
// Source via DestroyActor. FixtureIsolated. Null Class is DiagnosticOnly.
bool ObserveSetActorScale3DNominal(AActor Actor)
{
	if (Actor is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: required Actor is null");
	}
	FVector Before = Actor.GetActorScale3D();
	Actor.SetActorScale3D(FVector(2.0, 3.0, 4.0));
	FVector After = Actor.GetActorScale3D();
	Actor.SetActorScale3D(Before);
	return After.Equals(FVector(2.0, 3.0, 4.0));
}
/** @end */
/**
 * @begin set-actor-tick-interval
 * @summary Source via DestroyActor.
 * @topic Unreal
 */
/**
 * @function ObserveSetActorTickIntervalNominal
 * @summary Source via DestroyActor.
 * @covers AActor.set-actor-tick-interval
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSetActorTickIntervalNominal(AActor Actor)
{
	if (Actor is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: required Actor is null");
	}
	float32 Before = Actor.GetActorTickInterval();
	Actor.SetActorTickInterval(0.25);
	float32 After = Actor.GetActorTickInterval();
	Actor.SetActorTickInterval(0.0);
	float32 Restored = Actor.GetActorTickInterval();
	Actor.SetActorTickInterval(Before);
	return After == 0.25 && Restored == 0.0;
}
/** @end */
/**
 * @begin enable-input
 * @summary Source via DestroyActor.
 * @topic Unreal
 */
/**
 * @function ObserveEnableInputNominal
 * @summary Source via DestroyActor.
 * @covers AActor.enable-input
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveEnableInputNominal(AActor Actor, APlayerController Controller)
{
	if (Actor is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: required Actor is null");
	}
	if (Controller is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: required Controller is null");
	}
	Actor.EnableInput(Controller);
	UInputComponent After = Actor.GetInputComponent();
	Actor.DisableInput(Controller);
	return After != nullptr;
}
/** @end */
/**
 * @begin disable-input
 * @summary Source via DestroyActor.
 * @topic Unreal
 */
/**
 * @function ObserveDisableInputNominal
 * @summary Source via DestroyActor.
 * @covers AActor.disable-input
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveDisableInputNominal(AActor Actor, APlayerController Controller)
{
	if (Actor is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: required Actor is null");
	}
	if (Controller is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: required Controller is null");
	}
	Actor.EnableInput(Controller);
	UInputComponent Before = Actor.GetInputComponent();
	Actor.DisableInput(Controller);
	UInputComponent After = Actor.GetInputComponent();
	return Before != nullptr && After == Before;
}
/** @end */
/**
 * @begin set-replicates
 * @summary Source via DestroyActor.
 * @topic Unreal
 */
/**
 * @function ObserveSetReplicatesNominal
 * @summary Source via DestroyActor.
 * @covers AActor.set-replicates
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSetReplicatesNominal(AActor Actor)
{
	if (Actor is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: required Actor is null");
	}
	Actor.SetReplicates(true);
	bool bEnabled = Actor.GetIsReplicated();
	Actor.SetReplicates(false);
	bool bDisabled = Actor.GetIsReplicated();
	return bEnabled && !bDisabled;
}
/** @end */
/**
 * @begin spawn-actor
 * @summary Source via DestroyActor.
 * @topic Unreal
 */
/**
 * @function ObserveSpawnActorNominal
 * @summary Source via DestroyActor.
 * @covers AActor.spawn-actor
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSpawnActorNominal()
{
	TSubclassOf<AActor> ActorClass = AActor::StaticClass();
	FTransform SpawnTransform(FRotator::ZeroRotator, FVector(100.0, 0.0, 0.0), FVector::OneVector);
	FActorSpawnParameters Params;
	Params.Name = n"TS_AActor_SpawnWithParams";
	Params.NameMode = ESpawnActorNameMode::Requested;
	Params.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
	AActor FromParams = AActor::SpawnActor(ActorClass, SpawnTransform, Params);
	if (FromParams is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: spawn with params returned null");
	}
	bool bParamsLocation = FromParams.GetActorLocation().Equals(FVector(100.0, 0.0, 0.0));
	FromParams.DestroyActor();

	AActor FromLocation = AActor::SpawnActor(ActorClass, FVector(200.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_SpawnLocation");
	if (FromLocation is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: spawn at location returned null");
	}
	bool bLocation = FromLocation.GetActorLocation().Equals(FVector(200.0, 0.0, 0.0));
	UWorld World = FromLocation.GetWorld();
	FromLocation.DestroyActor();

	AActor FromDefaults = AActor::SpawnActor(ActorClass);
	if (FromDefaults is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: default spawn returned null");
	}
	FromDefaults.DestroyActor();

	ULevel Level;
	AActor FromLevel = AActor::SpawnActor(ActorClass, FVector::ZeroVector, FRotator::ZeroRotator, NAME_None, false, Level);
	if (FromLevel is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: spawn with level returned null");
	}
	FromLevel.DestroyActor();

	AActor Deferred = AActor::SpawnActor(ActorClass, FVector(300.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_SpawnDeferred", true);
	if (Deferred is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: deferred spawn returned null");
	}
	AActor::FinishSpawningActor(Deferred);
	bool bDeferredLocation = Deferred.GetActorLocation().Equals(FVector(300.0, 0.0, 0.0));
	Deferred.DestroyActor();

	if (World is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: required World is null");
	}
	FActorSpawnParameters WorldParams;
	WorldParams.Name = n"TS_AActor_WorldSpawn";
	WorldParams.NameMode = ESpawnActorNameMode::Requested;
	WorldParams.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
	AActor FromWorld = World.SpawnActor(ActorClass, SpawnTransform, WorldParams);
	if (FromWorld is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: world spawn returned null");
	}
	FromWorld.DestroyActor();
	return bParamsLocation && bLocation && bDeferredLocation;
}
/** @end */
/**
 * @begin spawn-persistent-actor
 * @summary Source via DestroyActor.
 * @topic Unreal
 */
/**
 * @function ObserveSpawnPersistentActorNominal
 * @summary Source via DestroyActor.
 * @covers AActor.spawn-persistent-actor
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSpawnPersistentActorNominal()
{
	TSubclassOf<AActor> ActorClass = AActor::StaticClass();
	FTransform SpawnTransform(FRotator::ZeroRotator, FVector(400.0, 0.0, 0.0), FVector::OneVector);
	FActorSpawnParameters Params;
	Params.Name = n"TS_AActor_PersistentParams";
	Params.NameMode = ESpawnActorNameMode::Requested;
	Params.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
	AActor FromParams = AActor::SpawnPersistentActor(ActorClass, SpawnTransform, Params);
	if (FromParams is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: persistent spawn with params returned null");
	}
	bool bParamsLocation = FromParams.GetActorLocation().Equals(FVector(400.0, 0.0, 0.0));
	FromParams.DestroyActor();

	AActor FromLocation = AActor::SpawnPersistentActor(ActorClass, FVector(450.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_PersistentLocation");
	if (FromLocation is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: persistent spawn at location returned null");
	}
	bool bLocation = FromLocation.GetActorLocation().Equals(FVector(450.0, 0.0, 0.0));
	FromLocation.DestroyActor();

	AActor FromDefaults = AActor::SpawnPersistentActor(ActorClass);
	if (FromDefaults is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: default persistent spawn returned null");
	}
	FromDefaults.DestroyActor();

	AActor Deferred = AActor::SpawnPersistentActor(ActorClass, FVector::ZeroVector, FRotator::ZeroRotator, NAME_None, true);
	if (Deferred is null)
	{
		throw("TS_AActor_MutationAndLifecycle_01 setup: deferred persistent spawn returned null");
	}
	AActor::FinishSpawningActor(Deferred);
	Deferred.DestroyActor();
	return bParamsLocation && bLocation;
}
/** @end */
/**
 * @begin spawn
 * @summary Inputs:
 * @topic Unreal
 */
/**
 * @function ObserveSpawnNominal
 * @summary Inputs:
 * @covers AActor.spawn
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

 Default Spawn(), location (100,0,0), NAME_None, explicit name
// n"TS_AActor_TypedSpawn", null ULevel, Identity transform, and
// FActorSpawnParameters with NameMode Requested then Required_ErrorAndReturnNull.
// Expected observations: Each Spawn returns a live actor of the requested type
// at the requested location. Duplicate Required_ErrorAndReturnNull is the
// diagnostic companion.
// Boundary/ownership: Source owns spawn cleanup via DestroyActor.
// FixtureIsolated. Duplicate-name path is DiagnosticOnly.
bool ObserveSpawnNominal()
{
	AActor DefaultSpawned = AActor::Spawn();
	if (DefaultSpawned is null)
	{
		throw("TS_AActor_MutationAndLifecycle_02 setup: AActor::Spawn() returned null");
	}
	DefaultSpawned.DestroyActor();

	AActor LocationSpawned = AActor::Spawn(FVector(100.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_TypedSpawn");
	if (LocationSpawned is null)
	{
		throw("TS_AActor_MutationAndLifecycle_02 setup: AActor::Spawn(location) returned null");
	}
	bool bLocation = LocationSpawned.GetActorLocation().Equals(FVector(100.0, 0.0, 0.0));
	LocationSpawned.DestroyActor();

	ULevel Level;
	AActor LevelSpawned = AActor::Spawn(FVector::ZeroVector, FRotator::ZeroRotator, NAME_None, Level);
	if (LevelSpawned is null)
	{
		throw("TS_AActor_MutationAndLifecycle_02 setup: AActor::Spawn(level) returned null");
	}
	LevelSpawned.DestroyActor();

	FTransform SpawnTransform(FRotator::ZeroRotator, FVector(125.0, 250.0, 375.0), FVector::OneVector);
	FActorSpawnParameters Params;
	Params.Name = n"TS_AActor_TypedParams";
	Params.NameMode = ESpawnActorNameMode::Requested;
	Params.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
	AActor ParamSpawned = AActor::Spawn(SpawnTransform, Params);
	if (ParamSpawned is null)
	{
		throw("TS_AActor_MutationAndLifecycle_02 setup: AActor::Spawn(params) returned null");
	}
	bool bParamsLocation = ParamSpawned.GetActorLocation().Equals(FVector(125.0, 250.0, 375.0));
	ParamSpawned.DestroyActor();

	APlayerController Controller = APlayerController::Spawn();
	if (Controller is null)
	{
		throw("TS_AActor_MutationAndLifecycle_02 setup: APlayerController::Spawn() returned null");
	}
	Controller.DestroyActor();

	APawn Pawn = APawn::Spawn(FVector(0.0, 100.0, 0.0));
	if (Pawn is null)
	{
		throw("TS_AActor_MutationAndLifecycle_02 setup: APawn::Spawn() returned null");
	}
	bool bPawnLocation = Pawn.GetActorLocation().Equals(FVector(0.0, 100.0, 0.0));
	Pawn.DestroyActor();
	return bLocation && bParamsLocation && bPawnLocation;
}
/** @end */
/**
 * @begin finish-spawning-actor
 * @summary handle, current actor transform, and
 * @topic Unreal
 */
/**
 * @function ObserveFinishSpawningActorNominal
 * @summary handle, current actor transform, and
 * @covers AActor.finish-spawning-actor
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// handle, current actor transform, and

 FTransform at (350,0,0).
// Expected observations: nullptr is ignored. A deferred actor becomes
// finishable and reports the requested location after the transform overload.
// Boundary/ownership: nullptr is ignored (API contract, not setup failure).
// An actor that has begun play raises a script exception. Source destroys
// finished actors. FixtureIsolated.
bool ObserveFinishSpawningActorNominal()
{
	AActor NullActor;
	AActor::FinishSpawningActor(NullActor);
	AActor::FinishSpawningActor(NullActor, FTransform());
	bool bNullIgnored = NullActor is null;

	TSubclassOf<AActor> ActorClass = AActor::StaticClass();
	AActor Deferred = AActor::SpawnActor(ActorClass, FVector(300.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_FinishDeferred", true);
	if (Deferred is null)
	{
		throw("TS_AActor_NamespaceAndGlobalFunctions_01 setup: deferred SpawnActor returned null");
	}
	AActor::FinishSpawningActor(Deferred);
	FVector AfterCurrent = Deferred.GetActorLocation();
	bool bCurrentTransformUsed = AfterCurrent.Equals(FVector(300.0, 0.0, 0.0));
	Deferred.DestroyActor();

	AActor DeferredTransform = AActor::SpawnActor(ActorClass, FVector::ZeroVector, FRotator::ZeroRotator, n"TS_AActor_FinishTransform", true);
	if (DeferredTransform is null)
	{
		throw("TS_AActor_NamespaceAndGlobalFunctions_01 setup: deferred transform SpawnActor returned null");
	}
	FTransform SpawnTransform(FRotator::ZeroRotator, FVector(350.0, 0.0, 0.0), FVector::OneVector);
	AActor::FinishSpawningActor(DeferredTransform, SpawnTransform);
	FVector AfterExplicit = DeferredTransform.GetActorLocation();
	bool bExplicitTransformUsed = AfterExplicit.Equals(FVector(350.0, 0.0, 0.0));
	DeferredTransform.DestroyActor();

	AActor PersistentDeferred = AActor::SpawnPersistentActor(ActorClass, FVector(450.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_FinishPersistent", true);
	if (PersistentDeferred is null)
	{
		throw("TS_AActor_NamespaceAndGlobalFunctions_01 setup: deferred SpawnPersistentActor returned null");
	}
	AActor::FinishSpawningActor(PersistentDeferred);
	FVector AfterPersistent = PersistentDeferred.GetActorLocation();
	bool bPersistentFinished = AfterPersistent.Equals(FVector(450.0, 0.0, 0.0));
	PersistentDeferred.DestroyActor();
	return bNullIgnored && bCurrentTransformUsed && bExplicitTransformUsed && bPersistentFinished;
}
/** @end */
/**
 * @begin is-actor-initialized
 * @summary keeps a sentinel at
 * @topic Unreal
 */
/**
 * @function ObserveIsActorInitializedNominal
 * @summary keeps a sentinel at
 * @covers AActor.is-actor-initialized
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

 index 0 (append-without-clear).
// Boundary/ownership: SetupOwner=Runner. CleanupOwner=Runner. FixtureIsolated.
bool ObserveIsActorInitializedNominal(AActor Actor, bool bExpectInitialized)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_01 setup: required Actor is null");
	}
	return Actor.IsActorInitialized() == bExpectInitialized;
}
/** @end */
/**
 * @begin has-actor-begun-play
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveHasActorBegunPlayNominal
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @covers AActor.has-actor-begun-play
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveHasActorBegunPlayNominal(AActor Actor, bool bExpectBegunPlay)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_01 setup: required Actor is null");
	}
	return Actor.HasActorBegunPlay() == bExpectBegunPlay;
}
/** @end */
/**
 * @begin is-hidden
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveIsHiddenNominal
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @covers AActor.is-hidden
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveIsHiddenNominal(AActor Actor, bool bExpectHidden)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_01 setup: required Actor is null");
	}
	return Actor.IsHidden() == bExpectHidden;
}
/** @end */
/**
 * @begin get-actor-location
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetActorLocationNominal
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @covers AActor.get-actor-location
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveGetActorLocationNominal(AActor Actor, const FVector& Expected)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_01 setup: required Actor is null");
	}
	return Actor.GetActorLocation().Equals(Expected);
}
/** @end */
/**
 * @begin get-actor-rotation
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetActorRotationNominal
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @covers AActor.get-actor-rotation
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveGetActorRotationNominal(AActor Actor, const FRotator& Expected)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_01 setup: required Actor is null");
	}
	return Actor.GetActorRotation().Equals(Expected, 0.01);
}
/** @end */
/**
 * @begin get-actor-name-or-label
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetActorNameOrLabelNominal
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @covers AActor.get-actor-name-or-label
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveGetActorNameOrLabelNominal(AActor Actor)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_01 setup: required Actor is null");
	}
	return Actor.GetActorNameOrLabel().Len() > 0;
}
/** @end */
/**
 * @begin get-game-instance
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetGameInstanceNominal
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @covers AActor.get-game-instance
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveGetGameInstanceNominal(AActor Actor, bool bExpectInstance)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_01 setup: required Actor is null");
	}
	UGameInstance Instance = Actor.GetGameInstance();
	if (bExpectInstance)
	{
		return Instance != nullptr;
	}
	return Instance is null;
}
/** @end */
/**
 * @begin get-components-by-class
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetComponentsByClassNominal
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @covers AActor.get-components-by-class
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveGetComponentsByClassNominal(AActor Actor, UActorComponent Sentinel)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_01 setup: required Actor is null");
	}
	TArray<UActorComponent> Inferred;
	Inferred.Add(Sentinel);
	int32 InferredBefore = Inferred.Num();
	Actor.GetComponentsByClass(Inferred);
	TArray<UActorComponent> Explicit;
	Explicit.Add(Sentinel);
	int32 ExplicitBefore = Explicit.Num();
	Actor.GetComponentsByClass(UActorComponent::StaticClass(), Explicit);
	return Inferred.Num() >= InferredBefore && Inferred[0] == Sentinel && Explicit.Num() >= ExplicitBefore && Explicit[0] == Sentinel;
}
/** @end */
/**
 * @begin get-instigator
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetInstigatorNominal
 * @summary Boundary/ownership: SetupOwner=Runner.
 * @covers AActor.get-instigator
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveGetInstigatorNominal(AActor Actor, APawn Expected)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_01 setup: required Actor is null");
	}
	return Actor.GetInstigator() == Expected;
}
/** @end */
/**
 * @begin get-instigator-controller
 * @summary Null required fixtures throw.
 * @topic Unreal
 */
/**
 * @function ObserveGetInstigatorControllerNominal
 * @summary Null required fixtures throw.
 * @covers AActor.get-instigator-controller
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetInstigatorControllerNominal(AActor Actor, AController Expected)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_02 setup: required Actor is null");
	}
	TSubclassOf<AActor> ActorClass = AActor::StaticClass();
	AActor Cdo = ActorClass.GetDefaultObject();
	AController CdoController = Cdo.GetInstigatorController();
	return CdoController is null && Actor.GetInstigatorController() == Expected;
}
/** @end */
/**
 * @begin get-input-component
 * @summary Null required fixtures throw.
 * @topic Unreal
 */
/**
 * @function ObserveGetInputComponentNominal
 * @summary Null required fixtures throw.
 * @covers AActor.get-input-component
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetInputComponentNominal(AActor Actor, APlayerController Controller)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_02 setup: required Actor is null");
	}
	if (Controller is null)
	{
		throw("TS_AActor_Queries_02 setup: required Controller is null");
	}
	TSubclassOf<AActor> ActorClass = AActor::StaticClass();
	AActor Cdo = ActorClass.GetDefaultObject();
	UInputComponent CdoInput = Cdo.GetInputComponent();
	UInputComponent Before = Actor.GetInputComponent();
	Actor.EnableInput(Controller);
	UInputComponent After = Actor.GetInputComponent();
	Actor.DisableInput(Controller);
	return CdoInput is null && Before is null && After != nullptr;
}
/** @end */
/**
 * @begin get-all-actors-of-class
 * @summary Null required fixtures throw.
 * @topic Unreal
 */
/**
 * @function ObserveGetAllActorsOfClassNominal
 * @summary Null required fixtures throw.
 * @covers AActor.get-all-actors-of-class
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAllActorsOfClassNominal(AActor Actor)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_02 setup: required Actor is null");
	}
	TArray<AActor> Inferred;
	AActor InferredSentinel;
	Inferred.Add(InferredSentinel);
	int32 InferredBefore = Inferred.Num();
	AActor::GetAllActorsOfClass(Inferred);

	TArray<AActor> Explicit;
	AActor ExplicitSentinel;
	Explicit.Add(ExplicitSentinel);
	int32 ExplicitBefore = Explicit.Num();
	AActor::GetAllActorsOfClass(AActor::StaticClass(), Explicit);

	TArray<AActor> AfterPawnFilter;
	AActor PawnSentinel;
	AfterPawnFilter.Add(PawnSentinel);
	AActor::GetAllActorsOfClass(APawn::StaticClass(), AfterPawnFilter);

	bool bInferred = Inferred.Num() >= InferredBefore && Inferred[0] == InferredSentinel;
	bool bExplicit = Explicit.Num() >= ExplicitBefore && Explicit[0] == ExplicitSentinel;
	bool bPawnSentinel = AfterPawnFilter.Num() >= 1 && AfterPawnFilter[0] == PawnSentinel;
	bool bFoundActor = false;
	for (int32 Index = 1; Index < Explicit.Num(); ++Index)
	{
		if (Explicit[Index] == Actor)
		{
			bFoundActor = true;
		}
	}
	return bInferred && bExplicit && bPawnSentinel && bFoundActor;
}
/** @end */
/**
 * @begin get-all-actors-of-class-with-tag
 * @summary Null required fixtures throw.
 * @topic Unreal
 */
/**
 * @function ObserveGetAllActorsOfClassWithTagNominal
 * @summary Null required fixtures throw.
 * @covers AActor.get-all-actors-of-class-with-tag
 * @inputs AActor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAllActorsOfClassWithTagNominal(AActor Actor)
{
	if (Actor is null)
	{
		throw("TS_AActor_Queries_02 setup: required Actor is null");
	}
	Actor.Tags.Add(n"TestTag");

	TArray<AActor> Tagged;
	AActor Sentinel;
	Tagged.Add(Sentinel);
	int32 Before = Tagged.Num();
	AActor::GetAllActorsOfClassWithTag(n"TestTag", Tagged);

	TArray<AActor> Missing;
	AActor MissingSentinel;
	Missing.Add(MissingSentinel);
	AActor::GetAllActorsOfClassWithTag(n"MissingTestTag", Missing);

	bool bPreserved = Tagged.Num() >= Before && Tagged[0] == Sentinel;
	bool bFound = false;
	for (int32 Index = 1; Index < Tagged.Num(); ++Index)
	{
		if (Tagged[Index] == Actor)
		{
			bFound = true;
		}
	}
	bool bMissingKeepsSentinel = Missing.Num() >= 1 && Missing[0] == MissingSentinel;
	return bPreserved && bFound && bMissingKeepsSentinel;
}
/** @end */
/**
 * @begin world-context
 * @summary Boundary/ownership: ServerTravel can change the
 * @topic Unreal
 */
/**
 * @function ObserveWorldContextNominal
 * @summary Boundary/ownership: ServerTravel can change the
 * @covers UWorld.world-context
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership: ServerTravel can change the

 running map (SubprocessOnly).
// WorldType aliases the world field. GFrameNumber is process global.
// Missing World or allow-flag is setup failure.
// __WorldContext returns the implicit script world object, or null.
bool ObserveWorldContextNominal(bool bExpectContext)
{
	UObject Context = __WorldContext();
	if (bExpectContext)
	{
		return Context != nullptr;
	}
	return Context is null;
}
/** @end */
/**
 * @begin server-travel
 * @summary ServerTravel changes the running map.
 * @topic Unreal
 */
/**
 * @function ObserveServerTravelNominal
 * @summary ServerTravel changes the running map.
 * @covers UWorld.server-travel
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership: ServerTravel can change the

bool ObserveServerTravelNominal(UWorld World, bool bAllowTravel, const FString& Url, bool bAbsolute, bool bShouldSkipGameNotify, bool bExpectTravel)
{
	if (World is null)
	{
		throw("TS_UWorld_Behavior_01 setup: required World is null");
	}
	if (!bAllowTravel)
	{
		throw("TS_UWorld_Behavior_01 setup: ServerTravel requires SubprocessOnly host");
	}
	return World.ServerTravel(Url, bAbsolute, bShouldSkipGameNotify) == bExpectTravel;
}
/** @end */
/**
 * @begin world-worldtype-published-eworldtype
 * @summary World.WorldType is the published EWorldType field.
 * @topic Unreal
 */
/**
 * @function ObserveSurface035Nominal
 * @summary World.WorldType is the published EWorldType field.
 * @covers UWorld.world-worldtype-published-eworldtype
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership: ServerTravel can change the

bool ObserveSurface035Nominal(UWorld World, EWorldType Expected)
{
	if (World is null)
	{
		throw("TS_UWorld_Behavior_01 setup: required World is null");
	}
	return World.WorldType == Expected;
}
/** @end */
/**
 * @begin gframenumber-process-global-unsigned
 * @summary GFrameNumber is the process-global unsigned frame counter.
 * @topic Unreal
 */
/**
 * @function ObserveSurface036Nominal
 * @summary GFrameNumber is the process-global unsigned frame counter.
 * @covers UWorld.gframenumber-process-global-unsigned
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership: ServerTravel can change the

bool ObserveSurface036Nominal(uint ExpectedMinimum)
{
	return GFrameNumber >= ExpectedMinimum;
}
/** @end */
/**
 * @begin eworldtype-copy-equals-source
 * @summary EWorldType copy equals the source.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary EWorldType copy equals the source.
 * @covers UWorld.eworldtype-copy-equals-source
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	EWorldType Game = EWorldType::Game;
	EWorldType Copied = Game;
	Copied = EWorldType::Editor;
	return Copied == EWorldType::Editor && Game == EWorldType::Game && Game != EWorldType::None;
}
/** @end */
/**
 * @begin enetmode-copy-equals-source
 * @summary ENetMode copy equals the source.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary ENetMode copy equals the source.
 * @covers UWorld.enetmode-copy-equals-source
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface010Nominal()
{
	ENetMode Standalone = ENetMode::NM_Standalone;
	ENetMode Copied = Standalone;
	Copied = ENetMode::NM_Client;
	return Copied == ENetMode::NM_Client && Standalone == ENetMode::NM_Standalone && Standalone != ENetMode::NM_MAX;
}
/** @end */
/**
 * @begin set-game-instance
 * @summary Missing World or GameInstance is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveSetGameInstanceNominal
 * @summary Missing World or GameInstance is setup failure.
 * @covers UWorld.set-game-instance
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetGameInstanceNominal(UWorld World, UGameInstance GameInstance)
{
	if (World is null)
	{
		throw("TS_UWorld_MutationAndLifecycle_01 setup: required World is null");
	}
	if (GameInstance is null)
	{
		throw("TS_UWorld_MutationAndLifecycle_01 setup: required GameInstance is null");
	}
	UGameInstance Original = World.GetGameInstance();
	World.SetGameInstance(GameInstance);
	UGameInstance After = World.GetGameInstance();
	World.SetGameInstance(Original);
	UGameInstance Restored = World.GetGameInstance();
	return After == GameInstance && Restored == Original;
}
/** @end */
/**
 * @begin eworldtype-none-copies-equal
 * @summary EWorldType::None copies equal to None and differs from Game.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary EWorldType::None copies equal to None and differs from Game.
 * @covers UWorld.eworldtype-none-copies-equal
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	EWorldType Value = EWorldType::None;
	EWorldType Copied = Value;
	return Copied == EWorldType::None && Value != EWorldType::Game;
}
/** @end */
/**
 * @begin eworldtype-game-equals-game
 * @summary EWorldType::Game equals Game and differs from None.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary EWorldType::Game equals Game and differs from None.
 * @covers UWorld.eworldtype-game-equals-game
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
{
	EWorldType Value = EWorldType::Game;
	return Value == EWorldType::Game && Value != EWorldType::None;
}
/** @end */
/**
 * @begin eworldtype-editor-equals-editor
 * @summary EWorldType::Editor equals Editor and differs from Game.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary EWorldType::Editor equals Editor and differs from Game.
 * @covers UWorld.eworldtype-editor-equals-editor
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface004Nominal()
{
	EWorldType Value = EWorldType::Editor;
	return Value == EWorldType::Editor && Value != EWorldType::Game;
}
/** @end */
/**
 * @begin eworldtype-pie-equals-pie
 * @summary EWorldType::PIE equals PIE and differs from Editor.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary EWorldType::PIE equals PIE and differs from Editor.
 * @covers UWorld.eworldtype-pie-equals-pie
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface005Nominal()
{
	EWorldType Value = EWorldType::PIE;
	return Value == EWorldType::PIE && Value != EWorldType::Editor;
}
/** @end */
/**
 * @begin eworldtype-editorpreview-equals-editorpreview
 * @summary EWorldType::EditorPreview equals EditorPreview and differs from PIE.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary EWorldType::EditorPreview equals EditorPreview and differs from PIE.
 * @covers UWorld.eworldtype-editorpreview-equals-editorpreview
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface006Nominal()
{
	EWorldType Value = EWorldType::EditorPreview;
	return Value == EWorldType::EditorPreview && Value != EWorldType::PIE;
}
/** @end */
/**
 * @begin eworldtype-gamepreview-equals-gamepreview
 * @summary EWorldType::GamePreview equals GamePreview and differs from EditorPreview.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary EWorldType::GamePreview equals GamePreview and differs from EditorPreview.
 * @covers UWorld.eworldtype-gamepreview-equals-gamepreview
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface007Nominal()
{
	EWorldType Value = EWorldType::GamePreview;
	return Value == EWorldType::GamePreview && Value != EWorldType::EditorPreview;
}
/** @end */
/**
 * @begin eworldtype-gamerpc-equals-gamerpc
 * @summary EWorldType::GameRPC equals GameRPC and differs from GamePreview.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary EWorldType::GameRPC equals GameRPC and differs from GamePreview.
 * @covers UWorld.eworldtype-gamerpc-equals-gamerpc
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface008Nominal()
{
	EWorldType Value = EWorldType::GameRPC;
	return Value == EWorldType::GameRPC && Value != EWorldType::GamePreview;
}
/** @end */
/**
 * @begin eworldtype-inactive-equals-inactive
 * @summary EWorldType::Inactive equals Inactive and differs from GameRPC.
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary EWorldType::Inactive equals Inactive and differs from GameRPC.
 * @covers UWorld.eworldtype-inactive-equals-inactive
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface009Nominal()
{
	EWorldType Value = EWorldType::Inactive;
	return Value == EWorldType::Inactive && Value != EWorldType::GameRPC;
}
/** @end */
/**
 * @begin enetmode-nm-client-equals
 * @summary ENetMode::NM_Client equals NM_Client and differs from NM_DedicatedServer.
 * @topic Unreal
 */
/**
 * @function ObserveSurface011Nominal
 * @summary ENetMode::NM_Client equals NM_Client and differs from NM_DedicatedServer.
 * @covers UWorld.enetmode-nm-client-equals
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface011Nominal()
{
	ENetMode Value = ENetMode::NM_Client;
	return Value == ENetMode::NM_Client && Value != ENetMode::NM_DedicatedServer;
}
/** @end */
/**
 * @begin enetmode-nm-dedicatedserver-equals
 * @summary ENetMode::NM_DedicatedServer equals NM_DedicatedServer and differs from NM_Client.
 * @topic Unreal
 */
/**
 * @function ObserveSurface012Nominal
 * @summary ENetMode::NM_DedicatedServer equals NM_DedicatedServer and differs from NM_Client.
 * @covers UWorld.enetmode-nm-dedicatedserver-equals
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface012Nominal()
{
	ENetMode Value = ENetMode::NM_DedicatedServer;
	return Value == ENetMode::NM_DedicatedServer && Value != ENetMode::NM_Client;
}
/** @end */
/**
 * @begin enetmode-nm-listenserver-equals
 * @summary ENetMode::NM_ListenServer equals NM_ListenServer and differs from NM_Client.
 * @topic Unreal
 */
/**
 * @function ObserveSurface013Nominal
 * @summary ENetMode::NM_ListenServer equals NM_ListenServer and differs from NM_Client.
 * @covers UWorld.enetmode-nm-listenserver-equals
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface013Nominal()
{
	ENetMode Value = ENetMode::NM_ListenServer;
	return Value == ENetMode::NM_ListenServer && Value != ENetMode::NM_Client;
}
/** @end */
/**
 * @begin enetmode-nm-standalone-equals
 * @summary ENetMode::NM_Standalone equals NM_Standalone and differs from NM_ListenServer.
 * @topic Unreal
 */
/**
 * @function ObserveSurface014Nominal
 * @summary ENetMode::NM_Standalone equals NM_Standalone and differs from NM_ListenServer.
 * @covers UWorld.enetmode-nm-standalone-equals
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface014Nominal()
{
	ENetMode Value = ENetMode::NM_Standalone;
	return Value == ENetMode::NM_Standalone && Value != ENetMode::NM_ListenServer;
}
/** @end */
/**
 * @begin enetmode-nm-max-equals
 * @summary ENetMode::NM_MAX equals NM_MAX and differs from NM_Standalone.
 * @topic Unreal
 */
/**
 * @function ObserveSurface015Nominal
 * @summary ENetMode::NM_MAX equals NM_MAX and differs from NM_Standalone.
 * @covers UWorld.enetmode-nm-max-equals
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface015Nominal()
{
	ENetMode Value = ENetMode::NM_MAX;
	return Value == ENetMode::NM_MAX && Value != ENetMode::NM_Standalone;
}
/** @end */
/**
 * @begin get-current-world
 * @summary AS-facing API:
 * @topic Unreal
 */
/**
 * @function ObserveGetCurrentWorldNominal
 * @summary AS-facing API:
 * @covers UWorld.get-current-world
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

 UWorld GetCurrentWorld();
// bool UWorld.IsGameWorld() const;
// bool UWorld.IsEditorWorld() const;
// bool UWorld.IsPreviewWorld() const;
// ENetMode UWorld.GetNetMode() const;
// AGameStateBase UWorld.GetGameState() const;
// float64 UWorld.GetTimeSeconds() const;
// float64 UWorld.GetUnpausedTimeSeconds() const;
// float64 UWorld.GetRealTimeSeconds() const;
// float64 UWorld.GetAudioTimeSeconds() const;
// Inputs: Runner-owned UWorld, expected kind flags, expected ENetMode, expected
// game-state presence, and clock lower bounds.
// Expected observations: returned bool is the exact comparison.
// Boundary/ownership: GetCurrentWorld uses the AngelScript world context.
// Clock values are copies. Do not call ServerTravel. SetupOwner=Runner.
bool ObserveGetCurrentWorldNominal(UWorld World)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_01 setup: required World is null");
	}
	return GetCurrentWorld() == World;
}
/** @end */
/**
 * @begin is-game-world
 * @summary Clock values are copies.
 * @topic Unreal
 */
/**
 * @function ObserveIsGameWorldNominal
 * @summary Clock values are copies.
 * @covers UWorld.is-game-world
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveIsGameWorldNominal(UWorld World, bool bExpectGameWorld)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_01 setup: required World is null");
	}
	return World.IsGameWorld() == bExpectGameWorld;
}
/** @end */
/**
 * @begin is-editor-world
 * @summary Clock values are copies.
 * @topic Unreal
 */
/**
 * @function ObserveIsEditorWorldNominal
 * @summary Clock values are copies.
 * @covers UWorld.is-editor-world
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveIsEditorWorldNominal(UWorld World, bool bExpectEditorWorld)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_01 setup: required World is null");
	}
	return World.IsEditorWorld() == bExpectEditorWorld;
}
/** @end */
/**
 * @begin is-preview-world
 * @summary Clock values are copies.
 * @topic Unreal
 */
/**
 * @function ObserveIsPreviewWorldNominal
 * @summary Clock values are copies.
 * @covers UWorld.is-preview-world
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveIsPreviewWorldNominal(UWorld World, bool bExpectPreviewWorld)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_01 setup: required World is null");
	}
	return World.IsPreviewWorld() == bExpectPreviewWorld;
}
/** @end */
/**
 * @begin get-net-mode
 * @summary Clock values are copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetNetModeNominal
 * @summary Clock values are copies.
 * @covers UWorld.get-net-mode
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveGetNetModeNominal(UWorld World, ENetMode Expected)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_01 setup: required World is null");
	}
	return World.GetNetMode() == Expected;
}
/** @end */
/**
 * @begin get-game-state
 * @summary Clock values are copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetGameStateNominal
 * @summary Clock values are copies.
 * @covers UWorld.get-game-state
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveGetGameStateNominal(UWorld World, bool bExpectGameState)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_01 setup: required World is null");
	}
	AGameStateBase GameState = World.GetGameState();
	if (bExpectGameState)
	{
		return GameState != nullptr;
	}
	return GameState is null;
}
/** @end */
/**
 * @begin get-time-seconds
 * @summary Clock values are copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetTimeSecondsNominal
 * @summary Clock values are copies.
 * @covers UWorld.get-time-seconds
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveGetTimeSecondsNominal(UWorld World, float64 ExpectedMinimum)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_01 setup: required World is null");
	}
	return World.GetTimeSeconds() >= ExpectedMinimum;
}
/** @end */
/**
 * @begin get-unpaused-time-seconds
 * @summary Clock values are copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetUnpausedTimeSecondsNominal
 * @summary Clock values are copies.
 * @covers UWorld.get-unpaused-time-seconds
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveGetUnpausedTimeSecondsNominal(UWorld World, float64 ExpectedMinimum)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_01 setup: required World is null");
	}
	return World.GetUnpausedTimeSeconds() >= ExpectedMinimum;
}
/** @end */
/**
 * @begin get-real-time-seconds
 * @summary Clock values are copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetRealTimeSecondsNominal
 * @summary Clock values are copies.
 * @covers UWorld.get-real-time-seconds
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveGetRealTimeSecondsNominal(UWorld World, float64 ExpectedMinimum)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_01 setup: required World is null");
	}
	return World.GetRealTimeSeconds() >= ExpectedMinimum;
}
/** @end */
/**
 * @begin get-audio-time-seconds
 * @summary Clock values are copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetAudioTimeSecondsNominal
 * @summary Clock values are copies.
 * @covers UWorld.get-audio-time-seconds
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveGetAudioTimeSecondsNominal(UWorld World, float64 ExpectedMinimum)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_01 setup: required World is null");
	}
	return World.GetAudioTimeSeconds() >= ExpectedMinimum;
}
/** @end */
/**
 * @begin get-delta-seconds
 * @summary expected game-instance presence, and a follow-
 * @topic Unreal
 */
/**
 * @function ObserveGetDeltaSecondsNominal
 * @summary expected game-instance presence, and a follow-
 * @covers UWorld.get-delta-seconds
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// expected game-instance presence, and a follow-

up Num() read on the returned
// actor array reference.
// Expected observations: returned bool is the exact comparison. GetActors
// Num is stable across two aliasing reads.
// Boundary/ownership: GetActors aliases level storage; entries may be null.
// GetGameInstance does not transfer ownership. SetupOwner=Runner.
bool ObserveGetDeltaSecondsNominal(UWorld World, float32 ExpectedMinimum)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_02 setup: required World is null");
	}
	return World.GetDeltaSeconds() >= ExpectedMinimum;
}
/** @end */
/**
 * @begin is-starting-up
 * @summary GetGameInstance does not transfer ownership.
 * @topic Unreal
 */
/**
 * @function ObserveIsStartingUpNominal
 * @summary GetGameInstance does not transfer ownership.
 * @covers UWorld.is-starting-up
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// expected game-instance presence, and a follow-

bool ObserveIsStartingUpNominal(UWorld World, bool bExpectStartingUp)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_02 setup: required World is null");
	}
	return World.IsStartingUp() == bExpectStartingUp;
}
/** @end */
/**
 * @begin is-tearing-down
 * @summary GetGameInstance does not transfer ownership.
 * @topic Unreal
 */
/**
 * @function ObserveIsTearingDownNominal
 * @summary GetGameInstance does not transfer ownership.
 * @covers UWorld.is-tearing-down
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// expected game-instance presence, and a follow-

bool ObserveIsTearingDownNominal(UWorld World, bool bExpectTearingDown)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_02 setup: required World is null");
	}
	return World.IsTearingDown() == bExpectTearingDown;
}
/** @end */
/**
 * @begin get-game-instance-host
 * @summary GetGameInstance does not transfer ownership.
 * @topic Unreal
 */
/**
 * @function ObserveGetGameInstanceNominal
 * @summary GetGameInstance does not transfer ownership.
 * @covers UWorld.get-game-instance
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// expected game-instance presence, and a follow-

bool ObserveGetGameInstanceNominal(UWorld World, bool bExpectInstance)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_02 setup: required World is null");
	}
	UGameInstance GameInstance = World.GetGameInstance();
	if (bExpectInstance)
	{
		return GameInstance != nullptr;
	}
	return GameInstance is null;
}
/** @end */
/**
 * @begin get-level-script-actor
 * @summary GetGameInstance does not transfer ownership.
 * @topic Unreal
 */
/**
 * @function ObserveGetLevelScriptActorNominal
 * @summary GetGameInstance does not transfer ownership.
 * @covers UWorld.get-level-script-actor
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// expected game-instance presence, and a follow-

bool ObserveGetLevelScriptActorNominal(UWorld World, bool bExpectWorldScript, bool bExpectLevelScript)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_02 setup: required World is null");
	}
	ULevel PersistentLevel = World.GetPersistentLevel();
	if (PersistentLevel is null)
	{
		throw("TS_UWorld_Queries_02 setup: required PersistentLevel is null");
	}
	ALevelScriptActor WorldLevelScript = World.GetLevelScriptActor();
	ALevelScriptActor LevelScript = PersistentLevel.GetLevelScriptActor();
	if (bExpectWorldScript)
	{
		if (WorldLevelScript is null)
		{
			return false;
		}
	}
	else if (WorldLevelScript != nullptr)
	{
		return false;
	}
	if (bExpectLevelScript)
	{
		return LevelScript != nullptr;
	}
	return LevelScript is null;
}
/** @end */
/**
 * @begin get-persistent-level
 * @summary GetGameInstance does not transfer ownership.
 * @topic Unreal
 */
/**
 * @function ObserveGetPersistentLevelNominal
 * @summary GetGameInstance does not transfer ownership.
 * @covers UWorld.get-persistent-level
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// expected game-instance presence, and a follow-

bool ObserveGetPersistentLevelNominal(UWorld World)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_02 setup: required World is null");
	}
	ULevel PersistentLevel = World.GetPersistentLevel();
	return PersistentLevel != nullptr;
}
/** @end */
/**
 * @begin is-visible
 * @summary GetGameInstance does not transfer ownership.
 * @topic Unreal
 */
/**
 * @function ObserveIsVisibleNominal
 * @summary GetGameInstance does not transfer ownership.
 * @covers UWorld.is-visible
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// expected game-instance presence, and a follow-

bool ObserveIsVisibleNominal(UWorld World, bool bExpectVisible)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_02 setup: required World is null");
	}
	ULevel PersistentLevel = World.GetPersistentLevel();
	if (PersistentLevel is null)
	{
		throw("TS_UWorld_Queries_02 setup: required PersistentLevel is null");
	}
	return PersistentLevel.IsVisible() == bExpectVisible;
}
/** @end */
/**
 * @begin is-being-removed
 * @summary GetGameInstance does not transfer ownership.
 * @topic Unreal
 */
/**
 * @function ObserveIsBeingRemovedNominal
 * @summary GetGameInstance does not transfer ownership.
 * @covers UWorld.is-being-removed
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// expected game-instance presence, and a follow-

bool ObserveIsBeingRemovedNominal(UWorld World, bool bExpectBeingRemoved)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_02 setup: required World is null");
	}
	ULevel PersistentLevel = World.GetPersistentLevel();
	if (PersistentLevel is null)
	{
		throw("TS_UWorld_Queries_02 setup: required PersistentLevel is null");
	}
	return PersistentLevel.IsBeingRemoved() == bExpectBeingRemoved;
}
/** @end */
/**
 * @begin get-actors
 * @summary GetGameInstance does not transfer ownership.
 * @topic Unreal
 */
/**
 * @function ObserveGetActorsNominal
 * @summary GetGameInstance does not transfer ownership.
 * @covers UWorld.get-actors
 * @inputs UWorld values exercised by this observe
 * @return true when the observe comparison holds
 */
// expected game-instance presence, and a follow-

bool ObserveGetActorsNominal(UWorld World)
{
	if (World is null)
	{
		throw("TS_UWorld_Queries_02 setup: required World is null");
	}
	ULevel PersistentLevel = World.GetPersistentLevel();
	if (PersistentLevel is null)
	{
		throw("TS_UWorld_Queries_02 setup: required PersistentLevel is null");
	}
	const TArray<AActor>& Actors = PersistentLevel.GetActors();
	int32 FirstNum = Actors.Num();
	const TArray<AActor>& Alias = PersistentLevel.GetActors();
	int32 SecondNum = Alias.Num();
	return FirstNum == SecondNum && (FirstNum == 0 || Actors[0] == Alias[0]);
}
/** @end */
