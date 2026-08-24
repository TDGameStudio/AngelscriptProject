// Purpose: Observe FOverlapResult weak-handle mutation for component, actor,
// and blocking classification, including repeated writes.
// AS-facing API: void FOverlapResult.SetComponent(UPrimitiveComponent InComp);
// void FOverlapResult.SetActor(AActor InActor);
// void FOverlapResult.SetBlockingHit(bool bIsBlocking);
// Inputs: Default overlap, a primitive CDO, an actor CDO, nullptr clears,
// blocking true then false.
// Expected observations: SetComponent stores the primitive for GetComponent.
// A second SetComponent replaces the previous identity. SetActor stores the
// actor handle. SetBlockingHit(true) then SetBlockingHit(false) is visible on
// GetbBlockingHit.
// Boundary/ownership: SetComponent stores a weak object reference and does not
// own the primitive. SetActor writes the actor-instance handle. Clearing with
// nullptr leaves the overlap value intact.

namespace TS_FOverlapResult_MutationAndLifecycle_01
{
	bool Observe_SetComponent_Nominal()
	{
		FOverlapResult Overlap;
		UPrimitiveComponent Primitive = TSubclassOf<UPrimitiveComponent>(UPrimitiveComponent::StaticClass()).GetDefaultObject();
		if (Primitive is null)
		{
			throw("TS_FOverlapResult_MutationAndLifecycle_01 setup: required Primitive is null");
		}
		Overlap.SetComponent(Primitive);
		UPrimitiveComponent First = Overlap.GetComponent();
		Overlap.SetComponent(Primitive);
		UPrimitiveComponent Repeated = Overlap.GetComponent();
		Overlap.SetComponent(nullptr);
		UPrimitiveComponent Cleared = Overlap.GetComponent();
		return First == Primitive && Repeated == Primitive && Cleared is null;
	}

	bool Observe_SetActor_Nominal()
	{
		FOverlapResult Overlap;
		AActor Actor = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (Actor is null)
		{
			throw("TS_FOverlapResult_MutationAndLifecycle_01 setup: required Actor is null");
		}
		Overlap.SetActor(Actor);
		AActor First = Overlap.GetActor();
		Overlap.SetActor(Actor);
		AActor Repeated = Overlap.GetActor();
		Overlap.SetActor(nullptr);
		AActor Cleared = Overlap.GetActor();
		return First == Actor && Repeated == Actor && Cleared is null;
	}

	bool Observe_SetBlockingHit_Nominal()
	{
		FOverlapResult Overlap;
		Overlap.SetBlockingHit(true);
		bool bBecameBlocking = Overlap.GetbBlockingHit();
		Overlap.SetBlockingHit(true);
		bool bRepeatedTrueStable = Overlap.GetbBlockingHit();
		Overlap.SetBlockingHit(false);
		bool bBecameNonBlocking = !Overlap.GetbBlockingHit();
		return bBecameBlocking && bRepeatedTrueStable && bBecameNonBlocking;
	}
}
