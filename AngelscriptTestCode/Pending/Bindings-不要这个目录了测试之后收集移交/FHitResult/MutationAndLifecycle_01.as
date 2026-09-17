/**
 * @version v1
 * @summary Observe FHitResult weak-handle setters, Reset, and both blocking aliases plus start-penetrating.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FHitResult weak-handle setters, Reset, and both blocking aliases plus start-penetrating.
 * @topic Baseline
 */
// void Hit.SetActor(AActor InActor); void Hit.Reset();
// void Hit.SetBlockingHit(bool bIsBlocking); void Hit.SetbBlockingHit(bool bIsBlocking);
// void Hit.SetbStartPenetrating(bool bStartPenetrating);
// Inputs: Empty trace hit, AActor CDO, UBoxComponent CDO, null handles, and
// true/false flags.
// Expected observations: SetComponent/GetComponent preserve identity.
// SetActor/GetActor preserve identity. Null setters store null. Reset clears
// blocking and start-penetrating. SetBlockingHit and SetbBlockingHit are
// aliases.
// Boundary/ownership: Setters store weak references. Reset restores an empty
// hit without destroying the value.

namespace TS_FHitResult_MutationAndLifecycle_01
{
	bool Observe_SetComponent_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		UBoxComponent BoxCdo = TSubclassOf<UBoxComponent>(UBoxComponent::StaticClass()).GetDefaultObject();
		if (BoxCdo is null)
		{
			throw("TS_FHitResult_MutationAndLifecycle_01 setup: required UBoxComponent CDO is null");
		}
		Hit.SetComponent(BoxCdo);
		UPrimitiveComponent After = Hit.GetComponent();
		UPrimitiveComponent NullComponent;
		Hit.SetComponent(NullComponent);
		UPrimitiveComponent AfterNull = Hit.GetComponent();
		return After == BoxCdo && AfterNull == nullptr;
	}

	bool Observe_SetActor_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		AActor ActorCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (ActorCdo is null)
		{
			throw("TS_FHitResult_MutationAndLifecycle_01 setup: required Actor CDO is null");
		}
		Hit.SetActor(ActorCdo);
		AActor After = Hit.GetActor();
		AActor NullActor;
		Hit.SetActor(NullActor);
		AActor AfterNull = Hit.GetActor();
		return After == ActorCdo && AfterNull == nullptr;
	}

	bool Observe_Reset_Nominal()
	{
		AActor ActorCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		UBoxComponent BoxCdo = TSubclassOf<UBoxComponent>(UBoxComponent::StaticClass()).GetDefaultObject();
		if (ActorCdo is null)
		{
			throw("TS_FHitResult_MutationAndLifecycle_01 setup: required Actor CDO is null");
		}
		if (BoxCdo is null)
		{
			throw("TS_FHitResult_MutationAndLifecycle_01 setup: required UBoxComponent CDO is null");
		}
		FHitResult Hit(ActorCdo, BoxCdo, FVector(1.0, 2.0, 3.0), FVector(0.0, 0.0, 1.0));
		Hit.SetBlockingHit(true);
		Hit.SetbStartPenetrating(true);
		Hit.Reset();
		return Hit.GetbBlockingHit() == false && Hit.GetbStartPenetrating() == false;
	}

	bool Observe_SetBlockingHit_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.SetBlockingHit(true);
		bool bTrue = Hit.GetbBlockingHit();
		Hit.SetBlockingHit(false);
		bool bFalse = Hit.GetbBlockingHit();
		return bTrue && !bFalse;
	}

	bool Observe_SetbBlockingHit_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.SetbBlockingHit(true);
		bool bTrue = Hit.GetbBlockingHit();
		Hit.SetbBlockingHit(false);
		bool bFalse = Hit.GetbBlockingHit();
		return bTrue && !bFalse;
	}

	bool Observe_SetbStartPenetrating_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.SetbStartPenetrating(true);
		bool bTrue = Hit.GetbStartPenetrating();
		Hit.SetbStartPenetrating(false);
		bool bFalse = Hit.GetbStartPenetrating();
		return bTrue && !bFalse;
	}
}
/** @end */
