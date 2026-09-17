/**
 * @version v1
 * @summary FHitResult host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FHitResult
 *
 * hit
 * fhitresult-faceindex
 * fhitresult-elementindex
 * fhitresult-item
 * fhitresult-myitem
 * fhitresult-penetrationdepth
 * fhitresult-distance
 * fhitresult-time
 * oracle-equals-zerovector
 * surface-011
 * fhitresult-impactnormal
 * fhitresult-impactpoint
 * fhitresult-location
 * fhitresult-normal
 * oracle-name-none-assigned
 * FHitResult-Behavior_02-oracle-name-none-assigned
 * set-component
 * set-actor
 * reset
 * set-blocking-hit
 * setb-blocking-hit
 * setb-start-penetrating
 * get-component
 * get-actor
 * getb-blocking-hit
 * getb-start-penetrating
 */
/**
 * @begin hit
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveHitNominal
 * @summary Observe the container API.
 * @covers FHitResult.hit
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FHitResult Hit(const FVector& TraceStart, const FVector& TraceEnd);
// int Hit.FaceIndex; uint8 Hit.ElementIndex; int Hit.Item; int Hit.MyItem;
// float32 Hit.PenetrationDepth; float32 Hit.Distance; float32 Hit.Time;
// FVector Hit.TraceStart;
// Inputs: AActor CDO, UBoxComponent CDO, HitLoc (1,2,3), HitNorm (0,0,1),
// TraceStart ZeroVector, TraceEnd (100,0,0), FaceIndex 3, ElementIndex 2,
// Item 7, MyItem 8, PenetrationDepth 1.5, Distance 50, Time 0.5.
// Expected observations: Actor/component constructor stores location and
// normal. Trace constructor stores start/end. Each field round-trips.
// Boundary/ownership: Constructors copy contact data. FaceIndex is the
// triangle index. Null actor/component is the diagnostic companion.
// FHitResult actor/component and trace-segment constructors.
// Inputs: Actor CDO, Box CDO, HitLoc (1,2,3), HitNorm (0,0,1), start Zero, end (100,0,0).
// Oracle: stored handles and vectors match. Null CDO is setup failure.
bool ObserveHitNominal()
{
	AActor ActorCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	UBoxComponent BoxCdo = TSubclassOf<UBoxComponent>(UBoxComponent::StaticClass()).GetDefaultObject();
	if (ActorCdo is null)
	{
		throw("TS_FHitResult_Behavior_01 setup: required Actor CDO is null");
	}
	if (BoxCdo is null)
	{
		throw("TS_FHitResult_Behavior_01 setup: required UBoxComponent CDO is null");
	}
	FVector HitLoc(1.0, 2.0, 3.0);
	FVector HitNorm(0.0, 0.0, 1.0);
	FHitResult Contact(ActorCdo, BoxCdo, HitLoc, HitNorm);
	FVector TraceStart = FVector::ZeroVector;
	FVector TraceEnd(100.0, 0.0, 0.0);
	FHitResult Trace(TraceStart, TraceEnd);
	return Contact.GetActor() == ActorCdo && Contact.GetComponent() == BoxCdo && Contact.Location.Equals(HitLoc) && Contact.Normal.Equals(HitNorm) && Trace.TraceStart.Equals(TraceStart) && Trace.TraceEnd.Equals(TraceEnd);
}
/** @end */
/**
 * @begin fhitresult-faceindex
 * @summary FHitResult.FaceIndex.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary FHitResult.FaceIndex.
 * @covers FHitResult.fhitresult-faceindex
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface003Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	int DefaultIndex = Hit.FaceIndex;
	Hit.FaceIndex = 3;
	int Assigned = Hit.FaceIndex;
	return Assigned == 3 && DefaultIndex != 3;
}
/** @end */
/**
 * @begin fhitresult-elementindex
 * @summary FHitResult.ElementIndex.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary FHitResult.ElementIndex.
 * @covers FHitResult.fhitresult-elementindex
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface004Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.ElementIndex = 2;
	uint8 Assigned = Hit.ElementIndex;
	return Assigned == 2;
}
/** @end */
/**
 * @begin fhitresult-item
 * @summary FHitResult.Item.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary FHitResult.Item.
 * @covers FHitResult.fhitresult-item
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface005Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.Item = 7;
	int Assigned = Hit.Item;
	return Assigned == 7;
}
/** @end */
/**
 * @begin fhitresult-myitem
 * @summary FHitResult.MyItem.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FHitResult.MyItem.
 * @covers FHitResult.fhitresult-myitem
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface006Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.MyItem = 8;
	int Assigned = Hit.MyItem;
	return Assigned == 8;
}
/** @end */
/**
 * @begin fhitresult-penetrationdepth
 * @summary FHitResult.PenetrationDepth.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FHitResult.PenetrationDepth.
 * @covers FHitResult.fhitresult-penetrationdepth
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface007Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.PenetrationDepth = 1.5;
	float32 Assigned = Hit.PenetrationDepth;
	return Assigned == 1.5;
}
/** @end */
/**
 * @begin fhitresult-distance
 * @summary FHitResult.Distance.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FHitResult.Distance.
 * @covers FHitResult.fhitresult-distance
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface008Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.Distance = 50.0;
	float32 Assigned = Hit.Distance;
	return Assigned == 50.0;
}
/** @end */
/**
 * @begin fhitresult-time
 * @summary FHitResult.Time.
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary FHitResult.Time.
 * @covers FHitResult.fhitresult-time
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface009Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.Time = 0.5;
	float32 Assigned = Hit.Time;
	return Assigned == 0.5;
}
/** @end */
/**
 * @begin oracle-equals-zerovector
 * @summary Oracle: default equals ZeroVector,
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary Oracle: default equals ZeroVector,
 * @covers FHitResult.oracle-equals-zerovector
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 assigned equals (5,6,7).
bool ObserveSurface010Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	FVector DefaultStart = Hit.TraceStart;
	Hit.TraceStart = FVector(5.0, 6.0, 7.0);
	FVector Assigned = Hit.TraceStart;
	return DefaultStart.Equals(FVector::ZeroVector) && Assigned.Equals(FVector(5.0, 6.0, 7.0));
}
/** @end */
/**
 * @begin surface-011
 * @summary Inputs:
 * @topic Unreal
 */
/**
 * @function ObserveSurface011Nominal
 * @summary Inputs:
 * @covers FHitResult.surface-011
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

 Trace hit (0,0,0)-(100,0,0), ImpactNormal (0,0,1), ImpactPoint
// (50,0,0), Location (50,0,0), Normal (0,1,0), BoneName n"spine_01",
// MyBoneName n"weapon_r".
// Expected observations: TraceEnd matches the constructor end. Each vector
// field round-trips. Bone names intern as FName and differ from NAME_None.
// Boundary/ownership: Fields are copies of contact data. BoneName is the
// target bone; MyBoneName is the source bone.
// FHitResult.TraceEnd. Inputs: constructor end (100,0,0), assign (200,0,0).
// Oracle: default equals constructor end, assigned equals (200,0,0).
bool ObserveSurface011Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	FVector DefaultEnd = Hit.TraceEnd;
	Hit.TraceEnd = FVector(200.0, 0.0, 0.0);
	FVector Assigned = Hit.TraceEnd;
	return DefaultEnd.Equals(FVector(100.0, 0.0, 0.0)) && Assigned.Equals(FVector(200.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin fhitresult-impactnormal
 * @summary FHitResult.ImpactNormal.
 * @topic Unreal
 */
/**
 * @function ObserveSurface012Nominal
 * @summary FHitResult.ImpactNormal.
 * @covers FHitResult.fhitresult-impactnormal
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

 Inputs: assign (0,0,1). Oracle: assigned equals (0,0,1).
bool ObserveSurface012Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.ImpactNormal = FVector(0.0, 0.0, 1.0);
	FVector Assigned = Hit.ImpactNormal;
	return Assigned.Equals(FVector(0.0, 0.0, 1.0));
}
/** @end */
/**
 * @begin fhitresult-impactpoint
 * @summary FHitResult.ImpactPoint.
 * @topic Unreal
 */
/**
 * @function ObserveSurface013Nominal
 * @summary FHitResult.ImpactPoint.
 * @covers FHitResult.fhitresult-impactpoint
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

 Inputs: assign (50,0,0). Oracle: assigned equals (50,0,0).
bool ObserveSurface013Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.ImpactPoint = FVector(50.0, 0.0, 0.0);
	FVector Assigned = Hit.ImpactPoint;
	return Assigned.Equals(FVector(50.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin fhitresult-location
 * @summary FHitResult.Location.
 * @topic Unreal
 */
/**
 * @function ObserveSurface014Nominal
 * @summary FHitResult.Location.
 * @covers FHitResult.fhitresult-location
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

 Inputs: assign (50,0,0). Oracle: assigned equals (50,0,0).
bool ObserveSurface014Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.Location = FVector(50.0, 0.0, 0.0);
	FVector Assigned = Hit.Location;
	return Assigned.Equals(FVector(50.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin fhitresult-normal
 * @summary FHitResult.Normal.
 * @topic Unreal
 */
/**
 * @function ObserveSurface015Nominal
 * @summary FHitResult.Normal.
 * @covers FHitResult.fhitresult-normal
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

 Inputs: assign (0,1,0). Oracle: assigned equals (0,1,0).
bool ObserveSurface015Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.Normal = FVector(0.0, 1.0, 0.0);
	FVector Assigned = Hit.Normal;
	return Assigned.Equals(FVector(0.0, 1.0, 0.0));
}
/** @end */
/**
 * @begin oracle-name-none-assigned
 * @summary Oracle: default is NAME_None, assigned is spine_01.
 * @topic Unreal
 */
/**
 * @function ObserveSurface016Nominal
 * @summary Oracle: default is NAME_None, assigned is spine_01.
 * @covers FHitResult.oracle-name-none-assigned
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

bool ObserveSurface016Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	FName DefaultName = Hit.BoneName;
	Hit.BoneName = n"spine_01";
	FName Assigned = Hit.BoneName;
	return DefaultName == NAME_None && Assigned == n"spine_01";
}
/** @end */
/**
 * @begin FHitResult-Behavior_02-oracle-name-none-assigned
 * @summary Oracle: default is NAME_None, assigned is weapon_r.
 * @topic Unreal
 */
/**
 * @function ObserveSurface017Nominal
 * @summary Oracle: default is NAME_None, assigned is weapon_r.
 * @covers FHitResult.oracle-name-none-assigned
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

bool ObserveSurface017Nominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	FName DefaultName = Hit.MyBoneName;
	Hit.MyBoneName = n"weapon_r";
	FName Assigned = Hit.MyBoneName;
	return DefaultName == NAME_None && Assigned == n"weapon_r";
}
/** @end */
/**
 * @begin set-component
 * @summary hit without destroying the value.
 * @topic Unreal
 */
/**
 * @function ObserveSetComponentNominal
 * @summary hit without destroying the value.
 * @covers FHitResult.set-component
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetComponentNominal()
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
/** @end */
/**
 * @begin set-actor
 * @summary hit without destroying the value.
 * @topic Unreal
 */
/**
 * @function ObserveSetActorNominal
 * @summary hit without destroying the value.
 * @covers FHitResult.set-actor
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetActorNominal()
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
/** @end */
/**
 * @begin reset
 * @summary hit without destroying the value.
 * @topic Unreal
 */
/**
 * @function ObserveResetNominal
 * @summary hit without destroying the value.
 * @covers FHitResult.reset
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveResetNominal()
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
/** @end */
/**
 * @begin set-blocking-hit
 * @summary hit without destroying the value.
 * @topic Unreal
 */
/**
 * @function ObserveSetBlockingHitNominal
 * @summary hit without destroying the value.
 * @covers FHitResult.set-blocking-hit
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetBlockingHitNominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.SetBlockingHit(true);
	bool bTrue = Hit.GetbBlockingHit();
	Hit.SetBlockingHit(false);
	bool bFalse = Hit.GetbBlockingHit();
	return bTrue && !bFalse;
}
/** @end */
/**
 * @begin setb-blocking-hit
 * @summary hit without destroying the value.
 * @topic Unreal
 */
/**
 * @function ObserveSetbBlockingHitNominal
 * @summary hit without destroying the value.
 * @covers FHitResult.setb-blocking-hit
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetbBlockingHitNominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.SetbBlockingHit(true);
	bool bTrue = Hit.GetbBlockingHit();
	Hit.SetbBlockingHit(false);
	bool bFalse = Hit.GetbBlockingHit();
	return bTrue && !bFalse;
}
/** @end */
/**
 * @begin setb-start-penetrating
 * @summary hit without destroying the value.
 * @topic Unreal
 */
/**
 * @function ObserveSetbStartPenetratingNominal
 * @summary hit without destroying the value.
 * @covers FHitResult.setb-start-penetrating
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetbStartPenetratingNominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	Hit.SetbStartPenetrating(true);
	bool bTrue = Hit.GetbStartPenetrating();
	Hit.SetbStartPenetrating(false);
	bool bFalse = Hit.GetbStartPenetrating();
	return bTrue && !bFalse;
}
/** @end */
/**
 * @begin get-component
 * @summary Inputs: Trace-
 * @topic Unreal
 */
/**
 * @function ObserveGetComponentNominal
 * @summary Inputs: Trace-
 * @covers FHitResult.get-component
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Trace-

segment hit (0,0,0)-(100,0,0), actor/component constructor
// with AActor CDO and UBoxComponent CDO, and SetBlockingHit /
// SetbStartPenetrating true/false.
// Expected observations: Empty trace GetComponent/GetActor are null. CDO
// constructor preserves those identities. Default blocking and start-
// penetrating flags are false; setters make them true then false.
// Boundary/ownership: GetComponent/GetActor return borrowed weak handles.
// Null means no associated primitive or actor.
bool ObserveGetComponentNominal()
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
/** @end */
/**
 * @begin get-actor
 * @summary Null means no associated primitive or actor.
 * @topic Unreal
 */
/**
 * @function ObserveGetActorNominal
 * @summary Null means no associated primitive or actor.
 * @covers FHitResult.get-actor
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Trace-

bool ObserveGetActorNominal()
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
/** @end */
/**
 * @begin getb-blocking-hit
 * @summary Null means no associated primitive or actor.
 * @topic Unreal
 */
/**
 * @function ObserveGetbBlockingHitNominal
 * @summary Null means no associated primitive or actor.
 * @covers FHitResult.getb-blocking-hit
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Trace-

bool ObserveGetbBlockingHitNominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	bool bDefaultBlocking = Hit.GetbBlockingHit();
	Hit.SetBlockingHit(true);
	bool bSetTrue = Hit.GetbBlockingHit();
	Hit.SetBlockingHit(false);
	bool bSetFalse = Hit.GetbBlockingHit();
	return !bDefaultBlocking && bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin getb-start-penetrating
 * @summary Null means no associated primitive or actor.
 * @topic Unreal
 */
/**
 * @function ObserveGetbStartPenetratingNominal
 * @summary Null means no associated primitive or actor.
 * @covers FHitResult.getb-start-penetrating
 * @inputs FHitResult values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Trace-

bool ObserveGetbStartPenetratingNominal()
{
	FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
	bool bDefaultPenetrating = Hit.GetbStartPenetrating();
	Hit.SetbStartPenetrating(true);
	bool bSetTrue = Hit.GetbStartPenetrating();
	Hit.SetbStartPenetrating(false);
	bool bSetFalse = Hit.GetbStartPenetrating();
	return !bDefaultPenetrating && bSetTrue && !bSetFalse;
}
/** @end */
