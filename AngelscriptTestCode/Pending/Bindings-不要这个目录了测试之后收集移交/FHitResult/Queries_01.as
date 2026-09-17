/**
 * @version v1
 * @summary Observe FHitResult component/actor getters and the blocking / start-penetrating flags.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FHitResult component/actor getters and the blocking / start-penetrating flags.
 * @topic Baseline
 */
// AActor Hit.GetActor() const; bool Hit.GetbBlockingHit() const;
// bool Hit.GetbStartPenetrating() const;
// Inputs: Trace-segment hit (0,0,0)-(100,0,0), actor/component constructor
// with AActor CDO and UBoxComponent CDO, and SetBlockingHit /
// SetbStartPenetrating true/false.
// Expected observations: Empty trace GetComponent/GetActor are null. CDO
// constructor preserves those identities. Default blocking and start-
// penetrating flags are false; setters make them true then false.
// Boundary/ownership: GetComponent/GetActor return borrowed weak handles.
// Null means no associated primitive or actor.

namespace TS_FHitResult_Queries_01
{
	bool Observe_GetComponent_Nominal()
	{
		FHitResult Empty(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		UPrimitiveComponent EmptyComponent = Empty.GetComponent();
		AActor ActorCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		UBoxComponent BoxCdo = TSubclassOf<UBoxComponent>(UBoxComponent::StaticClass()).GetDefaultObject();
		if (ActorCdo is null)
		{
			throw("TS_FHitResult_Queries_01 setup: required Actor CDO is null");
		}
		if (BoxCdo is null)
		{
			throw("TS_FHitResult_Queries_01 setup: required UBoxComponent CDO is null");
		}
		FHitResult Hit(ActorCdo, BoxCdo, FVector(1.0, 2.0, 3.0), FVector(0.0, 0.0, 1.0));
		UPrimitiveComponent HitComponent = Hit.GetComponent();
		return EmptyComponent == nullptr && HitComponent == BoxCdo;
	}

	bool Observe_GetActor_Nominal()
	{
		FHitResult Empty(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		AActor EmptyActor = Empty.GetActor();
		AActor ActorCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		UBoxComponent BoxCdo = TSubclassOf<UBoxComponent>(UBoxComponent::StaticClass()).GetDefaultObject();
		if (ActorCdo is null)
		{
			throw("TS_FHitResult_Queries_01 setup: required Actor CDO is null");
		}
		if (BoxCdo is null)
		{
			throw("TS_FHitResult_Queries_01 setup: required UBoxComponent CDO is null");
		}
		FHitResult Hit(ActorCdo, BoxCdo, FVector(1.0, 2.0, 3.0), FVector(0.0, 0.0, 1.0));
		AActor HitActor = Hit.GetActor();
		return EmptyActor == nullptr && HitActor == ActorCdo;
	}

	bool Observe_GetbBlockingHit_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		bool bDefaultBlocking = Hit.GetbBlockingHit();
		Hit.SetBlockingHit(true);
		bool bSetTrue = Hit.GetbBlockingHit();
		Hit.SetBlockingHit(false);
		bool bSetFalse = Hit.GetbBlockingHit();
		return !bDefaultBlocking && bSetTrue && !bSetFalse;
	}

	bool Observe_GetbStartPenetrating_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		bool bDefaultPenetrating = Hit.GetbStartPenetrating();
		Hit.SetbStartPenetrating(true);
		bool bSetTrue = Hit.GetbStartPenetrating();
		Hit.SetbStartPenetrating(false);
		bool bSetFalse = Hit.GetbStartPenetrating();
		return !bDefaultPenetrating && bSetTrue && !bSetFalse;
	}
}
/** @end */
