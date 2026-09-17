/**
 * @version v1
 * @summary Observe FOverlapResult component, actor, and blocking-hit queries on empty and seeded overlap values.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FOverlapResult component, actor, and blocking-hit queries on empty and seeded overlap values.
 * @topic Baseline
 */
// AActor FOverlapResult.GetActor() const;
// bool FOverlapResult.GetbBlockingHit() const;
// Inputs: Default FOverlapResult, a primitive CDO, an actor CDO, blocking true,
// and blocking false.
// Expected observations: Default GetComponent and GetActor are null and
// GetbBlockingHit is false. After SetComponent/SetActor the getters return the
// same identity. GetbBlockingHit follows SetBlockingHit true and false.
// Boundary/ownership: Component is stored as a weak object reference. Actor is
// stored through the actor-instance handle. Getters return null when the weak
// target is gone.

namespace TS_FOverlapResult_Queries_01
{
	bool Observe_GetComponent_Nominal()
	{
		FOverlapResult Overlap;
		UPrimitiveComponent EmptyComponent = Overlap.GetComponent();
		bool bDefaultComponentIsNull = EmptyComponent is null;

		UPrimitiveComponent Primitive = TSubclassOf<UPrimitiveComponent>(UPrimitiveComponent::StaticClass()).GetDefaultObject();
		if (Primitive is null)
		{
			throw("TS_FOverlapResult_Queries_01 setup: required Primitive is null");
		}
		Overlap.SetComponent(Primitive);
		UPrimitiveComponent Stored = Overlap.GetComponent();
		bool bStoredMatches = Stored == Primitive;

		Overlap.SetComponent(nullptr);
		UPrimitiveComponent Cleared = Overlap.GetComponent();
		return bDefaultComponentIsNull && bStoredMatches && Cleared is null;
	}

	bool Observe_GetActor_Nominal()
	{
		FOverlapResult Overlap;
		AActor EmptyActor = Overlap.GetActor();
		bool bDefaultActorIsNull = EmptyActor is null;

		AActor Actor = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (Actor is null)
		{
			throw("TS_FOverlapResult_Queries_01 setup: required Actor is null");
		}
		Overlap.SetActor(Actor);
		AActor Stored = Overlap.GetActor();
		bool bStoredMatches = Stored == Actor;

		Overlap.SetActor(nullptr);
		AActor Cleared = Overlap.GetActor();
		return bDefaultActorIsNull && bStoredMatches && Cleared is null;
	}

	bool Observe_GetbBlockingHit_Nominal()
	{
		FOverlapResult Overlap;
		bool bDefaultBlocking = Overlap.GetbBlockingHit();
		Overlap.SetBlockingHit(true);
		bool bBlockingTrue = Overlap.GetbBlockingHit();
		Overlap.SetBlockingHit(false);
		bool bBlockingFalse = Overlap.GetbBlockingHit();
		return !bDefaultBlocking && bBlockingTrue && !bBlockingFalse;
	}
}
/** @end */
