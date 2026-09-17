/**
 * @version v1
 * @summary FOverlapResult host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FOverlapResult
 *
 * int-foverlapresult-itemindex-defaults
 * set-component
 * set-actor
 * set-blocking-hit
 * get-component
 * get-actor
 * getb-blocking-hit
 */
/**
 * @begin int-foverlapresult-itemindex-defaults
 * @summary int FOverlapResult.ItemIndex defaults to 0, write 3 is visible, copy keeps 3.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary int FOverlapResult.ItemIndex defaults to 0, write 3 is visible, copy keeps 3.
 * @covers FOverlapResult.int-foverlapresult-itemindex-defaults
 * @inputs FOverlapResult values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	FOverlapResult Overlap;
	int DefaultIndex = Overlap.ItemIndex;
	Overlap.ItemIndex = 3;
	int WrittenIndex = Overlap.ItemIndex;
	FOverlapResult Copied = Overlap;
	return DefaultIndex == 0 && WrittenIndex == 3 && Copied.ItemIndex == 3;
}
/** @end */
/**
 * @begin set-component
 * @summary actor handle.
 * @topic Unreal
 */
/**
 * @function ObserveSetComponentNominal
 * @summary actor handle.
 * @covers FOverlapResult.set-component
 * @inputs FOverlapResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// actor handle. SetBlockingHit(true)

 then SetBlockingHit(false) is visible on
// GetbBlockingHit.
// Boundary/ownership: SetComponent stores a weak object reference and does not
// own the primitive. SetActor writes the actor-instance handle. Clearing with
// nullptr leaves the overlap value intact.
bool ObserveSetComponentNominal()
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
/** @end */
/**
 * @begin set-actor
 * @summary nullptr leaves the overlap value intact.
 * @topic Unreal
 */
/**
 * @function ObserveSetActorNominal
 * @summary nullptr leaves the overlap value intact.
 * @covers FOverlapResult.set-actor
 * @inputs FOverlapResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// actor handle. SetBlockingHit(true)

bool ObserveSetActorNominal()
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
/** @end */
/**
 * @begin set-blocking-hit
 * @summary nullptr leaves the overlap value intact.
 * @topic Unreal
 */
/**
 * @function ObserveSetBlockingHitNominal
 * @summary nullptr leaves the overlap value intact.
 * @covers FOverlapResult.set-blocking-hit
 * @inputs FOverlapResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// actor handle. SetBlockingHit(true)

bool ObserveSetBlockingHitNominal()
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
/** @end */
/**
 * @begin get-component
 * @summary target is gone.
 * @topic Unreal
 */
/**
 * @function ObserveGetComponentNominal
 * @summary target is gone.
 * @covers FOverlapResult.get-component
 * @inputs FOverlapResult values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetComponentNominal()
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
/** @end */
/**
 * @begin get-actor
 * @summary target is gone.
 * @topic Unreal
 */
/**
 * @function ObserveGetActorNominal
 * @summary target is gone.
 * @covers FOverlapResult.get-actor
 * @inputs FOverlapResult values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetActorNominal()
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
/** @end */
/**
 * @begin getb-blocking-hit
 * @summary target is gone.
 * @topic Unreal
 */
/**
 * @function ObserveGetbBlockingHitNominal
 * @summary target is gone.
 * @covers FOverlapResult.getb-blocking-hit
 * @inputs FOverlapResult values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetbBlockingHitNominal()
{
	FOverlapResult Overlap;
	bool bDefaultBlocking = Overlap.GetbBlockingHit();
	Overlap.SetBlockingHit(true);
	bool bBlockingTrue = Overlap.GetbBlockingHit();
	Overlap.SetBlockingHit(false);
	bool bBlockingFalse = Overlap.GetbBlockingHit();
	return !bDefaultBlocking && bBlockingTrue && !bBlockingFalse;
}
/** @end */
