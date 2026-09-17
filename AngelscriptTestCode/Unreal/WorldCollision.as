/**
 * @version v1
 * @summary WorldCollision host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic WorldCollision
 *
 * handle
 * container-api
 * handle-0
 * frame-index-are-0
 * data
 * ftracedatum-start-defaults-zero
 * ftracedatum-end-defaults-zero
 * ftracedatum-rot-defaults-identity
 * adding-fhitresult-grows-outhits
 * WorldCollision-Behavior_02-container-api
 * ftracedatum-tracechannel-round-trips
 * ftracedatum-userdata-defaults-0
 * WorldCollision-Behavior_02-data
 * foverlapdatum-pos-defaults-zero
 * foverlapdatum-rot-defaults-identity
 * adding-blocking-foverlapresult-grows
 * foverlapdatum-tracechannel-round-trips
 * foverlapdatum-userdata-defaults-0
 * easynctracetype-copy-equals-source
 * ftracehandle-invalid
 * ftracedatum-copy-keeps-empty
 * foverlapdatum-copy-keeps-empty
 * async-line-trace-by-channel
 * async-line-trace-by-object-type
 * async-line-trace-by-profile
 * async-sweep-by-channel
 * async-sweep-by-object-type
 * async-sweep-by-profile
 * async-overlap-by-channel
 * async-overlap-by-object-type
 * async-overlap-by-profile
 * easynctracetype-test-distinct-single
 * easynctracetype-single-distinct-multi
 * easynctracetype-multi-distinct-test
 * line-trace-test-by-channel
 * line-trace-test-by-object-type
 * line-trace-test-by-profile
 * line-trace-single-by-channel
 * line-trace-single-by-object-type
 * line-trace-single-by-profile
 * line-trace-multi-by-channel
 * line-trace-multi-by-object-type
 * line-trace-multi-by-profile
 * sweep-test-by-channel
 * sweep-test-by-object-type
 * sweep-test-by-profile
 * sweep-single-by-channel
 * sweep-single-by-object-type
 * sweep-single-by-profile
 * sweep-multi-by-channel
 * sweep-multi-by-object-type
 * sweep-multi-by-profile
 * overlap-blocking-test-by-channel
 * overlap-any-test-by-channel
 * overlap-any-test-by-object-type
 * overlap-blocking-test-by-profile
 * overlap-any-test-by-profile
 * overlap-multi-by-channel
 * overlap-multi-by-object-type
 * overlap-multi-by-profile
 * component-sweep-multi
 * WorldCollision-NamespaceAndGlobalFunctions_04-component-sweep-multi
 * component-sweep-multi-by-channel
 * component-overlap-multi
 * component-overlap-multi-by-channel
 * equality
 * is-valid
 * query-trace-data
 * query-overlap-data
 * is-trace-handle-valid
 */
/**
 * @begin handle
 * @summary uint32 FTraceHandle._Index;
 * @topic Unreal
 */
/**
 * @function ObserveHandleNominal
 * @summary uint32 FTraceHandle._Index;
 * @covers WorldCollision.handle
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
// uint32 FTraceHandle._Index;

 FTraceDatum Data(); FVector FTraceDatum.Start;
// FVector FTraceDatum.End; FQuat FTraceDatum.Rot; TArray<FHitResult> FTraceDatum.OutHits;
// Inputs: Default handle, packed uint64 0 and 1, default FTraceDatum, Start
// (0,0,100), End (0,0,0), identity rotation, and an empty OutHits diagnostic.
// Expected observations: Default handle is invalid and _Handle is 0. Packed
// construction stores _Handle. Default FTraceDatum has empty OutHits. Assigned
// Start/End/Rot round-trip. Adding a hit grows OutHits.
// Boundary/ownership: _FrameNumber/_Index decode the packed handle. OutHits is
// value storage on the datum. Indexing empty OutHits is the expected-failure
// path.
// Default FTraceHandle is invalid and packed _Handle is 0.
bool ObserveHandleNominal()
{
	FTraceHandle Handle;
	return !Handle.IsValid() && Handle._Handle == 0;
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary Observe the container API.
 * @covers WorldCollision.container-api
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
// uint32 FTraceHandle._Index;

 Packed FTraceHandle(0) is invalid; FTraceHandle(1) stores _Handle 1.
bool ObserveSurface010Nominal()
{
	uint64 ZeroValue = 0;
	FTraceHandle Zero(ZeroValue);
	uint64 PackedValue = 1;
	FTraceHandle Packed(PackedValue);
	return !Zero.IsValid() && Packed._Handle == PackedValue && Packed.IsValid();
}
/** @end */
/**
 * @begin handle-0
 * @summary Default _Handle is 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface011Nominal
 * @summary Default _Handle is 0.
 * @covers WorldCollision.handle-0
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
// uint32 FTraceHandle._Index;

bool ObserveSurface011Nominal()
{
	FTraceHandle Handle;
	uint64 PackedValue = 1;
	FTraceHandle Packed(PackedValue);
	return Handle._Handle == 0 && Packed._Handle == PackedValue;
}
/** @end */
/**
 * @begin frame-index-are-0
 * @summary Default frame/index are 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface012Nominal
 * @summary Default frame/index are 0.
 * @covers WorldCollision.frame-index-are-0
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
// uint32 FTraceHandle._Index;

bool ObserveSurface012Nominal()
{
	FTraceHandle Handle;
	uint64 PackedValue = 1;
	FTraceHandle Packed(PackedValue);
	return Handle._FrameNumber == 0 && Handle._Index == 0 && Packed._FrameNumber == 1 && Packed._Index == 0;
}
/** @end */
/**
 * @begin data
 * @summary Default FTraceDatum OutHits is empty.
 * @topic Unreal
 */
/**
 * @function ObserveDataNominal
 * @summary Default FTraceDatum OutHits is empty.
 * @covers WorldCollision.data
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
// uint32 FTraceHandle._Index;

bool ObserveDataNominal()
{
	FTraceDatum Data;
	FTraceDatum Copied = Data;
	return Data.OutHits.Num() == 0 && Copied.OutHits.Num() == 0;
}
/** @end */
/**
 * @begin ftracedatum-start-defaults-zero
 * @summary FTraceDatum.Start defaults to zero and round-trips (0,0,100).
 * @topic Unreal
 */
/**
 * @function ObserveSurface015Nominal
 * @summary FTraceDatum.Start defaults to zero and round-trips (0,0,100).
 * @covers WorldCollision.ftracedatum-start-defaults-zero
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
// uint32 FTraceHandle._Index;

bool ObserveSurface015Nominal()
{
	FTraceDatum Data;
	FVector DefaultStart = Data.Start;
	Data.Start = FVector(0.0, 0.0, 100.0);
	FVector Written = Data.Start;
	return DefaultStart.IsNearlyZero() && Written.Z == 100.0;
}
/** @end */
/**
 * @begin ftracedatum-end-defaults-zero
 * @summary FTraceDatum.End defaults to zero and round-trips (0,0,0).
 * @topic Unreal
 */
/**
 * @function ObserveSurface016Nominal
 * @summary FTraceDatum.End defaults to zero and round-trips (0,0,0).
 * @covers WorldCollision.ftracedatum-end-defaults-zero
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
// uint32 FTraceHandle._Index;

bool ObserveSurface016Nominal()
{
	FTraceDatum Data;
	FVector DefaultEnd = Data.End;
	Data.End = FVector(0.0, 0.0, 0.0);
	FVector Written = Data.End;
	return DefaultEnd.IsNearlyZero() && Written.IsNearlyZero();
}
/** @end */
/**
 * @begin ftracedatum-rot-defaults-identity
 * @summary FTraceDatum.Rot defaults to identity and round-trips FQuat::Identity.
 * @topic Unreal
 */
/**
 * @function ObserveSurface017Nominal
 * @summary FTraceDatum.Rot defaults to identity and round-trips FQuat::Identity.
 * @covers WorldCollision.ftracedatum-rot-defaults-identity
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
// uint32 FTraceHandle._Index;

bool ObserveSurface017Nominal()
{
	FTraceDatum Data;
	FQuat DefaultRot = Data.Rot;
	Data.Rot = FQuat::Identity;
	FQuat Written = Data.Rot;
	return DefaultRot.IsIdentity() && Written.IsIdentity();
}
/** @end */
/**
 * @begin adding-fhitresult-grows-outhits
 * @summary Adding a default FHitResult grows OutHits to 1.
 * @topic Unreal
 */
/**
 * @function ObserveSurface018Nominal
 * @summary Adding a default FHitResult grows OutHits to 1.
 * @covers WorldCollision.adding-fhitresult-grows-outhits
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
// uint32 FTraceHandle._Index;

bool ObserveSurface018Nominal()
{
	FTraceDatum Data;
	int32 Before = Data.OutHits.Num();
	FHitResult Hit;
	Data.OutHits.Add(Hit);
	int32 After = Data.OutHits.Num();
	FHitResult First = Data.OutHits[0];
	return Before == 0 && After == 1 && !First.GetbBlockingHit();
}
/** @end */
/**
 * @begin WorldCollision-Behavior_02-container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface019Nominal
 * @summary Observe the container API.
 * @covers WorldCollision.container-api
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FOverlapDatum Data(); FVector FOverlapDatum.Pos; FQuat FOverlapDatum.Rot;
// TArray<FOverlapResult> FOverlapDatum.OutOverlaps;
// ECollisionChannel FOverlapDatum.TraceChannel; uint32 FOverlapDatum.UserData;
// Inputs: Default FTraceDatum/FOverlapDatum, EAsyncTraceType::Single,
// ECollisionChannel::WorldStatic, UserData 7/8, Pos (7,8,9), identity rotation,
// and one seeded FOverlapResult.
// Expected observations: Assigned TraceType/TraceChannel/UserData round-trip.
// Default OutOverlaps is empty. Adding an overlap grows the array. Pos/Rot
// assignment is visible on later reads.
// Boundary/ownership: OutOverlaps is value storage on the datum. Channel names
// use ECollisionChannel::WorldStatic, not ECC_WorldStatic.
// FTraceDatum.TraceType round-trips EAsyncTraceType::Single.
bool ObserveSurface019Nominal()
{
	FTraceDatum Data;
	Data.TraceType = EAsyncTraceType::Single;
	return Data.TraceType == EAsyncTraceType::Single;
}
/** @end */
/**
 * @begin ftracedatum-tracechannel-round-trips
 * @summary FTraceDatum.TraceChannel round-trips ECollisionChannel::WorldStatic.
 * @topic Unreal
 */
/**
 * @function ObserveSurface020Nominal
 * @summary FTraceDatum.TraceChannel round-trips ECollisionChannel::WorldStatic.
 * @covers WorldCollision.ftracedatum-tracechannel-round-trips
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface020Nominal()
{
	FTraceDatum Data;
	Data.TraceChannel = ECollisionChannel::WorldStatic;
	return Data.TraceChannel == ECollisionChannel::WorldStatic;
}
/** @end */
/**
 * @begin ftracedatum-userdata-defaults-0
 * @summary FTraceDatum.UserData defaults to 0 and round-trips 7.
 * @topic Unreal
 */
/**
 * @function ObserveSurface021Nominal
 * @summary FTraceDatum.UserData defaults to 0 and round-trips 7.
 * @covers WorldCollision.ftracedatum-userdata-defaults-0
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface021Nominal()
{
	FTraceDatum Data;
	uint32 DefaultUserData = Data.UserData;
	Data.UserData = 7;
	uint32 Written = Data.UserData;
	return DefaultUserData == 0 && Written == 7;
}
/** @end */
/**
 * @begin WorldCollision-Behavior_02-data
 * @summary Default FOverlapDatum OutOverlaps is empty.
 * @topic Unreal
 */
/**
 * @function ObserveDataNominal
 * @summary Default FOverlapDatum OutOverlaps is empty.
 * @covers WorldCollision.data
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveDataNominal()
{
	FOverlapDatum Data;
	FOverlapDatum Copied = Data;
	return Data.OutOverlaps.Num() == 0 && Copied.OutOverlaps.Num() == 0;
}
/** @end */
/**
 * @begin foverlapdatum-pos-defaults-zero
 * @summary FOverlapDatum.Pos defaults to zero and round-trips (7,8,9).
 * @topic Unreal
 */
/**
 * @function ObserveSurface024Nominal
 * @summary FOverlapDatum.Pos defaults to zero and round-trips (7,8,9).
 * @covers WorldCollision.foverlapdatum-pos-defaults-zero
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface024Nominal()
{
	FOverlapDatum Data;
	FVector DefaultPos = Data.Pos;
	Data.Pos = FVector(7.0, 8.0, 9.0);
	FVector Written = Data.Pos;
	return DefaultPos.IsNearlyZero() && Written.X == 7.0 && Written.Z == 9.0;
}
/** @end */
/**
 * @begin foverlapdatum-rot-defaults-identity
 * @summary FOverlapDatum.Rot defaults to identity and round-trips FQuat::Identity.
 * @topic Unreal
 */
/**
 * @function ObserveSurface025Nominal
 * @summary FOverlapDatum.Rot defaults to identity and round-trips FQuat::Identity.
 * @covers WorldCollision.foverlapdatum-rot-defaults-identity
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface025Nominal()
{
	FOverlapDatum Data;
	FQuat DefaultRot = Data.Rot;
	Data.Rot = FQuat::Identity;
	FQuat Written = Data.Rot;
	return DefaultRot.IsIdentity() && Written.IsIdentity();
}
/** @end */
/**
 * @begin adding-blocking-foverlapresult-grows
 * @summary Adding a blocking FOverlapResult grows OutOverlaps.
 * @topic Unreal
 */
/**
 * @function ObserveSurface026Nominal
 * @summary Adding a blocking FOverlapResult grows OutOverlaps.
 * @covers WorldCollision.adding-blocking-foverlapresult-grows
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface026Nominal()
{
	FOverlapDatum Data;
	int32 Before = Data.OutOverlaps.Num();
	FOverlapResult Overlap;
	Overlap.SetBlockingHit(true);
	Data.OutOverlaps.Add(Overlap);
	int32 After = Data.OutOverlaps.Num();
	bool bFirstBlocking = Data.OutOverlaps[0].GetbBlockingHit();
	UPrimitiveComponent FirstComponent = Data.OutOverlaps[0].GetComponent();
	return Before == 0 && After == 1 && bFirstBlocking && FirstComponent is null;
}
/** @end */
/**
 * @begin foverlapdatum-tracechannel-round-trips
 * @summary FOverlapDatum.TraceChannel round-trips ECollisionChannel::WorldDynamic.
 * @topic Unreal
 */
/**
 * @function ObserveSurface027Nominal
 * @summary FOverlapDatum.TraceChannel round-trips ECollisionChannel::WorldDynamic.
 * @covers WorldCollision.foverlapdatum-tracechannel-round-trips
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface027Nominal()
{
	FOverlapDatum Data;
	Data.TraceChannel = ECollisionChannel::WorldDynamic;
	return Data.TraceChannel == ECollisionChannel::WorldDynamic;
}
/** @end */
/**
 * @begin foverlapdatum-userdata-defaults-0
 * @summary FOverlapDatum.UserData defaults to 0 and round-trips 8.
 * @topic Unreal
 */
/**
 * @function ObserveSurface028Nominal
 * @summary FOverlapDatum.UserData defaults to 0 and round-trips 8.
 * @covers WorldCollision.foverlapdatum-userdata-defaults-0
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface028Nominal()
{
	FOverlapDatum Data;
	uint32 DefaultUserData = Data.UserData;
	Data.UserData = 8;
	uint32 Written = Data.UserData;
	return DefaultUserData == 0 && Written == 8;
}
/** @end */
/**
 * @begin easynctracetype-copy-equals-source
 * @summary EAsyncTraceType copy equals the source.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary EAsyncTraceType copy equals the source.
 * @covers WorldCollision.easynctracetype-copy-equals-source
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	EAsyncTraceType Test = EAsyncTraceType::Test;
	EAsyncTraceType Copied = Test;
	Copied = EAsyncTraceType::Single;
	return Copied == EAsyncTraceType::Single && Test == EAsyncTraceType::Test && Test != EAsyncTraceType::Multi;
}
/** @end */
/**
 * @begin ftracehandle-invalid
 * @summary Default FTraceHandle is invalid.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary Default FTraceHandle is invalid.
 * @covers WorldCollision.ftracehandle-invalid
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface005Nominal()
{
	FTraceHandle Handle;
	FTraceHandle Copied = Handle;
	uint64 PackedValue = 1;
	FTraceHandle Packed(PackedValue);
	Copied = Packed;
	return Copied == Packed && !Handle.IsValid() && Packed.IsValid();
}
/** @end */
/**
 * @begin ftracedatum-copy-keeps-empty
 * @summary FTraceDatum copy keeps empty OutHits.
 * @topic Unreal
 */
/**
 * @function ObserveSurface013Nominal
 * @summary FTraceDatum copy keeps empty OutHits.
 * @covers WorldCollision.ftracedatum-copy-keeps-empty
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface013Nominal()
{
	FTraceDatum Data;
	FTraceDatum Copied = Data;
	bool bCopiedEmptyHits = Copied.OutHits.Num() == 0;
	Data.Start = FVector(1.0, 2.0, 3.0);
	Copied = Data;
	return bCopiedEmptyHits && Copied.Start.X == 1.0 && Copied.Start.Y == 2.0 && Copied.Start.Z == 3.0;
}
/** @end */
/**
 * @begin foverlapdatum-copy-keeps-empty
 * @summary FOverlapDatum copy keeps empty OutOverlaps.
 * @topic Unreal
 */
/**
 * @function ObserveSurface022Nominal
 * @summary FOverlapDatum copy keeps empty OutOverlaps.
 * @covers WorldCollision.foverlapdatum-copy-keeps-empty
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface022Nominal()
{
	FOverlapDatum Data;
	FOverlapDatum Copied = Data;
	bool bCopiedEmptyOverlaps = Copied.OutOverlaps.Num() == 0;
	Data.Pos = FVector(4.0, 5.0, 6.0);
	Copied = Data;
	return bCopiedEmptyOverlaps && Copied.Pos.X == 4.0 && Copied.Pos.Y == 5.0 && Copied.Pos.Z == 6.0;
}
/** @end */
/**
 * @begin async-line-trace-by-channel
 * @summary by the caller after queueing.
 * @topic Unreal
 */
/**
 * @function ObserveAsyncLineTraceByChannelNominal
 * @summary by the caller after queueing.
 * @covers WorldCollision.async-line-trace-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsyncLineTraceByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FScriptTraceDelegate Delegate;
	FTraceHandle Defaulted = System::AsyncLineTraceByChannel(EAsyncTraceType::Test, Start, End, ECollisionChannel::WorldStatic);
	FTraceHandle Explicit = System::AsyncLineTraceByChannel(
		EAsyncTraceType::Single,
		Start,
		End,
		ECollisionChannel::Visibility,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam,
		Delegate,
		7);
	return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
}
/** @end */
/**
 * @begin async-line-trace-by-object-type
 * @summary by the caller after queueing.
 * @topic Unreal
 */
/**
 * @function ObserveAsyncLineTraceByObjectTypeNominal
 * @summary by the caller after queueing.
 * @covers WorldCollision.async-line-trace-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsyncLineTraceByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	FScriptTraceDelegate Delegate;
	FTraceHandle Defaulted = System::AsyncLineTraceByObjectType(EAsyncTraceType::Multi, Start, End, ObjectQueryParams);
	FTraceHandle Explicit = System::AsyncLineTraceByObjectType(
		EAsyncTraceType::Single,
		Start,
		End,
		ObjectQueryParams,
		FCollisionQueryParams::DefaultQueryParam,
		Delegate,
		7);
	return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
}
/** @end */
/**
 * @begin async-line-trace-by-profile
 * @summary by the caller after queueing.
 * @topic Unreal
 */
/**
 * @function ObserveAsyncLineTraceByProfileNominal
 * @summary by the caller after queueing.
 * @covers WorldCollision.async-line-trace-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsyncLineTraceByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FName ProfileName = n"BlockAll";
	FScriptTraceDelegate Delegate;
	FTraceHandle Defaulted = System::AsyncLineTraceByProfile(EAsyncTraceType::Test, Start, End, ProfileName);
	FTraceHandle Explicit = System::AsyncLineTraceByProfile(
		EAsyncTraceType::Single,
		Start,
		End,
		ProfileName,
		FCollisionQueryParams::DefaultQueryParam,
		Delegate,
		7);
	return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
}
/** @end */
/**
 * @begin async-sweep-by-channel
 * @summary by the caller after queueing.
 * @topic Unreal
 */
/**
 * @function ObserveAsyncSweepByChannelNominal
 * @summary by the caller after queueing.
 * @covers WorldCollision.async-sweep-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsyncSweepByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FScriptTraceDelegate Delegate;
	FTraceHandle Defaulted = System::AsyncSweepByChannel(
		EAsyncTraceType::Test,
		Start,
		End,
		FQuat::Identity,
		ECollisionChannel::WorldStatic,
		Sphere);
	FTraceHandle Explicit = System::AsyncSweepByChannel(
		EAsyncTraceType::Single,
		Start,
		End,
		FQuat::Identity,
		ECollisionChannel::WorldDynamic,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam,
		Delegate,
		7);
	return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
}
/** @end */
/**
 * @begin async-sweep-by-object-type
 * @summary by the caller after queueing.
 * @topic Unreal
 */
/**
 * @function ObserveAsyncSweepByObjectTypeNominal
 * @summary by the caller after queueing.
 * @covers WorldCollision.async-sweep-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsyncSweepByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	FScriptTraceDelegate Delegate;
	FTraceHandle Defaulted = System::AsyncSweepByObjectType(
		EAsyncTraceType::Multi,
		Start,
		End,
		FQuat::Identity,
		ObjectQueryParams,
		Sphere);
	FTraceHandle Explicit = System::AsyncSweepByObjectType(
		EAsyncTraceType::Single,
		Start,
		End,
		FQuat::Identity,
		ObjectQueryParams,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		Delegate,
		7);
	return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
}
/** @end */
/**
 * @begin async-sweep-by-profile
 * @summary by the caller after queueing.
 * @topic Unreal
 */
/**
 * @function ObserveAsyncSweepByProfileNominal
 * @summary by the caller after queueing.
 * @covers WorldCollision.async-sweep-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsyncSweepByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FName ProfileName = n"BlockAll";
	FScriptTraceDelegate Delegate;
	FTraceHandle Defaulted = System::AsyncSweepByProfile(
		EAsyncTraceType::Test,
		Start,
		End,
		FQuat::Identity,
		ProfileName,
		Sphere);
	FTraceHandle Explicit = System::AsyncSweepByProfile(
		EAsyncTraceType::Single,
		Start,
		End,
		FQuat::Identity,
		ProfileName,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		Delegate,
		7);
	return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
}
/** @end */
/**
 * @begin async-overlap-by-channel
 * @summary by the caller after queueing.
 * @topic Unreal
 */
/**
 * @function ObserveAsyncOverlapByChannelNominal
 * @summary by the caller after queueing.
 * @covers WorldCollision.async-overlap-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsyncOverlapByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FScriptOverlapDelegate Delegate;
	FTraceHandle Defaulted = System::AsyncOverlapByChannel(Start, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
	FTraceHandle Explicit = System::AsyncOverlapByChannel(
		Start,
		FQuat::Identity,
		ECollisionChannel::Visibility,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam,
		Delegate,
		7);
	return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
}
/** @end */
/**
 * @begin async-overlap-by-object-type
 * @summary by the caller after queueing.
 * @topic Unreal
 */
/**
 * @function ObserveAsyncOverlapByObjectTypeNominal
 * @summary by the caller after queueing.
 * @covers WorldCollision.async-overlap-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsyncOverlapByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	FScriptOverlapDelegate Delegate;
	FTraceHandle Defaulted = System::AsyncOverlapByObjectType(Start, FQuat::Identity, ObjectQueryParams, Sphere);
	FTraceHandle Explicit = System::AsyncOverlapByObjectType(
		Start,
		FQuat::Identity,
		ObjectQueryParams,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		Delegate,
		7);
	return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
}
/** @end */
/**
 * @begin async-overlap-by-profile
 * @summary by the caller after queueing.
 * @topic Unreal
 */
/**
 * @function ObserveAsyncOverlapByProfileNominal
 * @summary by the caller after queueing.
 * @covers WorldCollision.async-overlap-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsyncOverlapByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FName ProfileName = n"BlockAll";
	FScriptOverlapDelegate Delegate;
	FTraceHandle Defaulted = System::AsyncOverlapByProfile(Start, FQuat::Identity, ProfileName, Sphere);
	FTraceHandle Explicit = System::AsyncOverlapByProfile(
		Start,
		FQuat::Identity,
		ProfileName,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		Delegate,
		7);
	return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
}
/** @end */
/**
 * @begin easynctracetype-test-distinct-single
 * @summary EAsyncTraceType::Test is distinct from Single.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary EAsyncTraceType::Test is distinct from Single.
 * @covers WorldCollision.easynctracetype-test-distinct-single
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	return EAsyncTraceType::Test != EAsyncTraceType::Single;
}
/** @end */
/**
 * @begin easynctracetype-single-distinct-multi
 * @summary EAsyncTraceType::Single is distinct from Multi.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary EAsyncTraceType::Single is distinct from Multi.
 * @covers WorldCollision.easynctracetype-single-distinct-multi
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
{
	return EAsyncTraceType::Single != EAsyncTraceType::Multi;
}
/** @end */
/**
 * @begin easynctracetype-multi-distinct-test
 * @summary EAsyncTraceType::Multi is distinct from Test.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary EAsyncTraceType::Multi is distinct from Test.
 * @covers WorldCollision.easynctracetype-multi-distinct-test
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface004Nominal()
{
	return EAsyncTraceType::Multi != EAsyncTraceType::Test;
}
/** @end */
/**
 * @begin line-trace-test-by-channel
 * @summary LineTraceTestByChannel default WorldStatic vs explicit Visibility.
 * @topic Unreal
 */
/**
 * @function ObserveLineTraceTestByChannelNominal
 * @summary LineTraceTestByChannel default WorldStatic vs explicit Visibility.
 * @covers WorldCollision.line-trace-test-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLineTraceTestByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	bool bDefaulted = System::LineTraceTestByChannel(Start, End, ECollisionChannel::WorldStatic);
	bool bExplicit = System::LineTraceTestByChannel(
		Start,
		End,
		ECollisionChannel::Visibility,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin line-trace-test-by-object-type
 * @summary LineTraceTestByObjectType WorldStatic object query.
 * @topic Unreal
 */
/**
 * @function ObserveLineTraceTestByObjectTypeNominal
 * @summary LineTraceTestByObjectType WorldStatic object query.
 * @covers WorldCollision.line-trace-test-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLineTraceTestByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	bool bDefaulted = System::LineTraceTestByObjectType(Start, End, ObjectQueryParams);
	bool bExplicit = System::LineTraceTestByObjectType(Start, End, ObjectQueryParams, FCollisionQueryParams::DefaultQueryParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin line-trace-test-by-profile
 * @summary LineTraceTestByProfile BlockAll.
 * @topic Unreal
 */
/**
 * @function ObserveLineTraceTestByProfileNominal
 * @summary LineTraceTestByProfile BlockAll.
 * @covers WorldCollision.line-trace-test-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLineTraceTestByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FName ProfileName = n"BlockAll";
	bool bDefaulted = System::LineTraceTestByProfile(Start, End, ProfileName);
	bool bExplicit = System::LineTraceTestByProfile(Start, End, ProfileName, FCollisionQueryParams::DefaultQueryParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin line-trace-single-by-channel
 * @summary LineTraceSingleByChannel writes OutHit.
 * @topic Unreal
 */
/**
 * @function ObserveLineTraceSingleByChannelNominal
 * @summary LineTraceSingleByChannel writes OutHit.
 * @covers WorldCollision.line-trace-single-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLineTraceSingleByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
{
	bool bHit = System::LineTraceSingleByChannel(OutHit, Start, End, ECollisionChannel::WorldStatic);
	FHitResult ExplicitHit;
	bool bExplicit = System::LineTraceSingleByChannel(
		ExplicitHit,
		Start,
		End,
		ECollisionChannel::Visibility,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam);
	if (bExpectHit)
	{
		return bHit && OutHit.GetbBlockingHit() && bExplicit && ExplicitHit.GetbBlockingHit();
	}
	return !bHit && !OutHit.GetbBlockingHit() && !bExplicit && !ExplicitHit.GetbBlockingHit();
}
/** @end */
/**
 * @begin line-trace-single-by-object-type
 * @summary LineTraceSingleByObjectType writes OutHit.
 * @topic Unreal
 */
/**
 * @function ObserveLineTraceSingleByObjectTypeNominal
 * @summary LineTraceSingleByObjectType writes OutHit.
 * @covers WorldCollision.line-trace-single-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLineTraceSingleByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
{
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	bool bHit = System::LineTraceSingleByObjectType(OutHit, Start, End, ObjectQueryParams);
	FHitResult ExplicitHit;
	bool bExplicit = System::LineTraceSingleByObjectType(
		ExplicitHit,
		Start,
		End,
		ObjectQueryParams,
		FCollisionQueryParams::DefaultQueryParam);
	if (bExpectHit)
	{
		return bHit && OutHit.GetbBlockingHit() && bExplicit;
	}
	return !bHit && !OutHit.GetbBlockingHit() && !bExplicit;
}
/** @end */
/**
 * @begin line-trace-single-by-profile
 * @summary LineTraceSingleByProfile BlockAll writes OutHit.
 * @topic Unreal
 */
/**
 * @function ObserveLineTraceSingleByProfileNominal
 * @summary LineTraceSingleByProfile BlockAll writes OutHit.
 * @covers WorldCollision.line-trace-single-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLineTraceSingleByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
{
	FName ProfileName = n"BlockAll";
	bool bHit = System::LineTraceSingleByProfile(OutHit, Start, End, ProfileName);
	FHitResult ExplicitHit;
	bool bExplicit = System::LineTraceSingleByProfile(
		ExplicitHit,
		Start,
		End,
		ProfileName,
		FCollisionQueryParams::DefaultQueryParam);
	if (bExpectHit)
	{
		return bHit && OutHit.GetbBlockingHit() && bExplicit;
	}
	return !bHit && !OutHit.GetbBlockingHit() && !bExplicit;
}
/** @end */
/**
 * @begin line-trace-multi-by-channel
 * @summary LineTraceMultiByChannel appends OutHits.
 * @topic Unreal
 */
/**
 * @function ObserveLineTraceMultiByChannelNominal
 * @summary LineTraceMultiByChannel appends OutHits.
 * @covers WorldCollision.line-trace-multi-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLineTraceMultiByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
{
	int32 Before = OutHits.Num();
	bool bHit = System::LineTraceMultiByChannel(OutHits, Start, End, ECollisionChannel::WorldStatic);
	TArray<FHitResult> ExplicitHits;
	bool bExplicit = System::LineTraceMultiByChannel(
		ExplicitHits,
		Start,
		End,
		ECollisionChannel::Visibility,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam);
	if (bExpectHit)
	{
		return bHit && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
	}
	return !bHit && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
}
/** @end */
/**
 * @begin line-trace-multi-by-object-type
 * @summary caller-owned.
 * @topic Unreal
 */
/**
 * @function ObserveLineTraceMultiByObjectTypeNominal
 * @summary caller-owned.
 * @covers WorldCollision.line-trace-multi-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLineTraceMultiByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
{
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	int32 Before = OutHits.Num();
	bool bDefaulted = System::LineTraceMultiByObjectType(OutHits, Start, End, ObjectQueryParams);
	TArray<FHitResult> ExplicitHits;
	bool bExplicit = System::LineTraceMultiByObjectType(
		ExplicitHits,
		Start,
		End,
		ObjectQueryParams,
		FCollisionQueryParams::DefaultQueryParam);
	if (bExpectHit)
	{
		return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
	}
	return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
}
/** @end */
/**
 * @begin line-trace-multi-by-profile
 * @summary caller-owned.
 * @topic Unreal
 */
/**
 * @function ObserveLineTraceMultiByProfileNominal
 * @summary caller-owned.
 * @covers WorldCollision.line-trace-multi-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLineTraceMultiByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
{
	FName ProfileName = n"BlockAll";
	int32 Before = OutHits.Num();
	bool bDefaulted = System::LineTraceMultiByProfile(OutHits, Start, End, ProfileName);
	TArray<FHitResult> ExplicitHits;
	bool bExplicit = System::LineTraceMultiByProfile(
		ExplicitHits,
		Start,
		End,
		ProfileName,
		FCollisionQueryParams::DefaultQueryParam);
	if (bExpectHit)
	{
		return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
	}
	return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
}
/** @end */
/**
 * @begin sweep-test-by-channel
 * @summary caller-owned.
 * @topic Unreal
 */
/**
 * @function ObserveSweepTestByChannelNominal
 * @summary caller-owned.
 * @covers WorldCollision.sweep-test-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSweepTestByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	bool bDefaulted = System::SweepTestByChannel(Start, End, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
	bool bExplicit = System::SweepTestByChannel(
		Start,
		End,
		FQuat::Identity,
		ECollisionChannel::Visibility,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin sweep-test-by-object-type
 * @summary caller-owned.
 * @topic Unreal
 */
/**
 * @function ObserveSweepTestByObjectTypeNominal
 * @summary caller-owned.
 * @covers WorldCollision.sweep-test-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSweepTestByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	bool bDefaulted = System::SweepTestByObjectType(Start, End, FQuat::Identity, ObjectQueryParams, Sphere);
	bool bExplicit = System::SweepTestByObjectType(
		Start,
		End,
		FQuat::Identity,
		ObjectQueryParams,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin sweep-test-by-profile
 * @summary caller-owned.
 * @topic Unreal
 */
/**
 * @function ObserveSweepTestByProfileNominal
 * @summary caller-owned.
 * @covers WorldCollision.sweep-test-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSweepTestByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FName ProfileName = n"BlockAll";
	bool bDefaulted = System::SweepTestByProfile(Start, End, FQuat::Identity, ProfileName, Sphere);
	bool bExplicit = System::SweepTestByProfile(
		Start,
		End,
		FQuat::Identity,
		ProfileName,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin sweep-single-by-channel
 * @summary caller-owned.
 * @topic Unreal
 */
/**
 * @function ObserveSweepSingleByChannelNominal
 * @summary caller-owned.
 * @covers WorldCollision.sweep-single-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSweepSingleByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	bool bHit = System::SweepSingleByChannel(OutHit, Start, End, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
	FHitResult ExplicitHit;
	bool bExplicit = System::SweepSingleByChannel(
		ExplicitHit,
		Start,
		End,
		FQuat::Identity,
		ECollisionChannel::Visibility,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam);
	if (bExpectHit)
	{
		return bHit && OutHit.GetbBlockingHit() && bExplicit && ExplicitHit.GetbBlockingHit();
	}
	return !bHit && !OutHit.GetbBlockingHit() && !bExplicit && !ExplicitHit.GetbBlockingHit();
}
/** @end */
/**
 * @begin sweep-single-by-object-type
 * @summary caller-owned.
 * @topic Unreal
 */
/**
 * @function ObserveSweepSingleByObjectTypeNominal
 * @summary caller-owned.
 * @covers WorldCollision.sweep-single-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSweepSingleByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	bool bHit = System::SweepSingleByObjectType(OutHit, Start, End, FQuat::Identity, ObjectQueryParams, Sphere);
	FHitResult ExplicitHit;
	bool bExplicit = System::SweepSingleByObjectType(
		ExplicitHit,
		Start,
		End,
		FQuat::Identity,
		ObjectQueryParams,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	if (bExpectHit)
	{
		return bHit && OutHit.GetbBlockingHit() && bExplicit;
	}
	return !bHit && !OutHit.GetbBlockingHit() && !bExplicit;
}
/** @end */
/**
 * @begin sweep-single-by-profile
 * @summary caller-owned.
 * @topic Unreal
 */
/**
 * @function ObserveSweepSingleByProfileNominal
 * @summary caller-owned.
 * @covers WorldCollision.sweep-single-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSweepSingleByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FName ProfileName = n"BlockAll";
	bool bHit = System::SweepSingleByProfile(OutHit, Start, End, FQuat::Identity, ProfileName, Sphere);
	FHitResult ExplicitHit;
	bool bExplicit = System::SweepSingleByProfile(
		ExplicitHit,
		Start,
		End,
		FQuat::Identity,
		ProfileName,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	if (bExpectHit)
	{
		return bHit && OutHit.GetbBlockingHit() && bExplicit;
	}
	return !bHit && !OutHit.GetbBlockingHit() && !bExplicit;
}
/** @end */
/**
 * @begin sweep-multi-by-channel
 * @summary caller-owned.
 * @topic Unreal
 */
/**
 * @function ObserveSweepMultiByChannelNominal
 * @summary caller-owned.
 * @covers WorldCollision.sweep-multi-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSweepMultiByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	int32 Before = OutHits.Num();
	bool bHit = System::SweepMultiByChannel(OutHits, Start, End, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
	TArray<FHitResult> ExplicitHits;
	bool bExplicit = System::SweepMultiByChannel(
		ExplicitHits,
		Start,
		End,
		FQuat::Identity,
		ECollisionChannel::Visibility,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam);
	if (bExpectHit)
	{
		return bHit && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
	}
	return !bHit && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
}
/** @end */
/**
 * @begin sweep-multi-by-object-type
 * @summary caller-owned.
 * @topic Unreal
 */
/**
 * @function ObserveSweepMultiByObjectTypeNominal
 * @summary caller-owned.
 * @covers WorldCollision.sweep-multi-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSweepMultiByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	int32 Before = OutHits.Num();
	bool bHit = System::SweepMultiByObjectType(OutHits, Start, End, FQuat::Identity, ObjectQueryParams, Sphere);
	TArray<FHitResult> ExplicitHits;
	bool bExplicit = System::SweepMultiByObjectType(
		ExplicitHits,
		Start,
		End,
		FQuat::Identity,
		ObjectQueryParams,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	if (bExpectHit)
	{
		return bHit && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
	}
	return !bHit && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
}
/** @end */
/**
 * @begin sweep-multi-by-profile
 * @summary owned by the query.
 * @topic Unreal
 */
/**
 * @function ObserveSweepMultiByProfileNominal
 * @summary owned by the query.
 * @covers WorldCollision.sweep-multi-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSweepMultiByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FName ProfileName = n"BlockAll";
	int32 Before = OutHits.Num();
	bool bDefaulted = System::SweepMultiByProfile(OutHits, Start, End, FQuat::Identity, ProfileName, Sphere);
	TArray<FHitResult> ExplicitHits;
	bool bExplicit = System::SweepMultiByProfile(
		ExplicitHits,
		Start,
		End,
		FQuat::Identity,
		ProfileName,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	if (bExpectHit)
	{
		return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
	}
	return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
}
/** @end */
/**
 * @begin overlap-blocking-test-by-channel
 * @summary owned by the query.
 * @topic Unreal
 */
/**
 * @function ObserveOverlapBlockingTestByChannelNominal
 * @summary owned by the query.
 * @covers WorldCollision.overlap-blocking-test-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOverlapBlockingTestByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	bool bDefaulted = System::OverlapBlockingTestByChannel(Start, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
	bool bExplicit = System::OverlapBlockingTestByChannel(
		Start,
		FQuat::Identity,
		ECollisionChannel::Visibility,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin overlap-any-test-by-channel
 * @summary owned by the query.
 * @topic Unreal
 */
/**
 * @function ObserveOverlapAnyTestByChannelNominal
 * @summary owned by the query.
 * @covers WorldCollision.overlap-any-test-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOverlapAnyTestByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	bool bDefaulted = System::OverlapAnyTestByChannel(Start, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
	bool bExplicit = System::OverlapAnyTestByChannel(
		Start,
		FQuat::Identity,
		ECollisionChannel::Visibility,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin overlap-any-test-by-object-type
 * @summary owned by the query.
 * @topic Unreal
 */
/**
 * @function ObserveOverlapAnyTestByObjectTypeNominal
 * @summary owned by the query.
 * @covers WorldCollision.overlap-any-test-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOverlapAnyTestByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	bool bDefaulted = System::OverlapAnyTestByObjectType(Start, FQuat::Identity, ObjectQueryParams, Sphere);
	bool bExplicit = System::OverlapAnyTestByObjectType(
		Start,
		FQuat::Identity,
		ObjectQueryParams,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin overlap-blocking-test-by-profile
 * @summary owned by the query.
 * @topic Unreal
 */
/**
 * @function ObserveOverlapBlockingTestByProfileNominal
 * @summary owned by the query.
 * @covers WorldCollision.overlap-blocking-test-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOverlapBlockingTestByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FName ProfileName = n"BlockAll";
	bool bDefaulted = System::OverlapBlockingTestByProfile(Start, FQuat::Identity, ProfileName, Sphere);
	bool bExplicit = System::OverlapBlockingTestByProfile(
		Start,
		FQuat::Identity,
		ProfileName,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin overlap-any-test-by-profile
 * @summary owned by the query.
 * @topic Unreal
 */
/**
 * @function ObserveOverlapAnyTestByProfileNominal
 * @summary owned by the query.
 * @covers WorldCollision.overlap-any-test-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOverlapAnyTestByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FName ProfileName = n"BlockAll";
	bool bDefaulted = System::OverlapAnyTestByProfile(Start, FQuat::Identity, ProfileName, Sphere);
	bool bExplicit = System::OverlapAnyTestByProfile(
		Start,
		FQuat::Identity,
		ProfileName,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	return bDefaulted == bExpectHit && bExplicit == bExpectHit;
}
/** @end */
/**
 * @begin overlap-multi-by-channel
 * @summary owned by the query.
 * @topic Unreal
 */
/**
 * @function ObserveOverlapMultiByChannelNominal
 * @summary owned by the query.
 * @covers WorldCollision.overlap-multi-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOverlapMultiByChannelNominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FOverlapResult>& OutHits)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	int32 Before = OutHits.Num();
	bool bDefaulted = System::OverlapMultiByChannel(OutHits, Start, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
	TArray<FOverlapResult> ExplicitHits;
	bool bExplicit = System::OverlapMultiByChannel(
		ExplicitHits,
		Start,
		FQuat::Identity,
		ECollisionChannel::Visibility,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam,
		FCollisionResponseParams::DefaultResponseParam);
	if (bExpectHit)
	{
		return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
	}
	return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
}
/** @end */
/**
 * @begin overlap-multi-by-object-type
 * @summary owned by the query.
 * @topic Unreal
 */
/**
 * @function ObserveOverlapMultiByObjectTypeNominal
 * @summary owned by the query.
 * @covers WorldCollision.overlap-multi-by-object-type
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOverlapMultiByObjectTypeNominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FOverlapResult>& OutHits)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
	int32 Before = OutHits.Num();
	bool bDefaulted = System::OverlapMultiByObjectType(OutHits, Start, FQuat::Identity, ObjectQueryParams, Sphere);
	TArray<FOverlapResult> ExplicitHits;
	bool bExplicit = System::OverlapMultiByObjectType(
		ExplicitHits,
		Start,
		FQuat::Identity,
		ObjectQueryParams,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	if (bExpectHit)
	{
		return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
	}
	return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
}
/** @end */
/**
 * @begin overlap-multi-by-profile
 * @summary owned by the query.
 * @topic Unreal
 */
/**
 * @function ObserveOverlapMultiByProfileNominal
 * @summary owned by the query.
 * @covers WorldCollision.overlap-multi-by-profile
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOverlapMultiByProfileNominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FOverlapResult>& OutHits)
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FName ProfileName = n"BlockAll";
	int32 Before = OutHits.Num();
	bool bDefaulted = System::OverlapMultiByProfile(OutHits, Start, FQuat::Identity, ProfileName, Sphere);
	TArray<FOverlapResult> ExplicitHits;
	bool bExplicit = System::OverlapMultiByProfile(
		ExplicitHits,
		Start,
		FQuat::Identity,
		ProfileName,
		Sphere,
		FCollisionQueryParams::DefaultQueryParam);
	if (bExpectHit)
	{
		return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
	}
	return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
}
/** @end */
/**
 * @begin component-sweep-multi
 * @summary owned by the query.
 * @topic Unreal
 */
/**
 * @function ObserveComponentSweepMultiNominal
 * @summary owned by the query.
 * @covers WorldCollision.component-sweep-multi
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComponentSweepMultiNominal(UPrimitiveComponent PrimComp, const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
{
	if (PrimComp is null)
	{
		throw("TS_WorldCollision_NamespaceAndGlobalFunctions_03 setup: required PrimComp is null");
	}
	int32 Before = OutHits.Num();
	bool bSwept = System::ComponentSweepMulti(
		OutHits,
		PrimComp,
		Start,
		End,
		FQuat::Identity,
		FComponentQueryParams::DefaultComponentQueryParams);
	if (bExpectHit)
	{
		return bSwept && OutHits.Num() > Before;
	}
	return !bSwept && OutHits.Num() == Before;
}
/** @end */
/**
 * @begin WorldCollision-NamespaceAndGlobalFunctions_04-component-sweep-multi
 * @summary FixtureIsolated.
 * @topic Unreal
 */
/**
 * @function ObserveComponentSweepMultiNominal
 * @summary FixtureIsolated.
 * @covers WorldCollision.component-sweep-multi
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComponentSweepMultiNominal(UPrimitiveComponent PrimComp, const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
{
	if (PrimComp is null)
	{
		throw("TS_WorldCollision_NamespaceAndGlobalFunctions_04 setup: required PrimComp is null");
	}
	int32 Before = OutHits.Num();
	bool bSwept = System::ComponentSweepMulti(
		OutHits,
		PrimComp,
		Start,
		End,
		FRotator::ZeroRotator,
		FComponentQueryParams::DefaultComponentQueryParams);
	if (bExpectHit)
	{
		return bSwept && OutHits.Num() > Before;
	}
	return !bSwept && OutHits.Num() == Before;
}
/** @end */
/**
 * @begin component-sweep-multi-by-channel
 * @summary FixtureIsolated.
 * @topic Unreal
 */
/**
 * @function ObserveComponentSweepMultiByChannelNominal
 * @summary FixtureIsolated.
 * @covers WorldCollision.component-sweep-multi-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComponentSweepMultiByChannelNominal(UPrimitiveComponent PrimComp, const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
{
	if (PrimComp is null)
	{
		throw("TS_WorldCollision_NamespaceAndGlobalFunctions_04 setup: required PrimComp is null");
	}
	int32 Before = OutHits.Num();
	bool bQuat = System::ComponentSweepMultiByChannel(
		OutHits,
		PrimComp,
		Start,
		End,
		FQuat::Identity,
		ECollisionChannel::WorldStatic,
		FComponentQueryParams::DefaultComponentQueryParams);
	TArray<FHitResult> RotatorHits;
	bool bRotator = System::ComponentSweepMultiByChannel(
		RotatorHits,
		PrimComp,
		Start,
		End,
		FRotator::ZeroRotator,
		ECollisionChannel::Visibility,
		FComponentQueryParams::DefaultComponentQueryParams);
	if (bExpectHit)
	{
		return bQuat && OutHits.Num() > Before && bRotator && RotatorHits.Num() > 0;
	}
	return !bQuat && OutHits.Num() == Before && !bRotator && RotatorHits.Num() == 0;
}
/** @end */
/**
 * @begin component-overlap-multi
 * @summary FixtureIsolated.
 * @topic Unreal
 */
/**
 * @function ObserveComponentOverlapMultiNominal
 * @summary FixtureIsolated.
 * @covers WorldCollision.component-overlap-multi
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComponentOverlapMultiNominal(UPrimitiveComponent PrimComp, const FVector& Start, const FVector& End, bool bExpectHit, TArray<FOverlapResult>& OutHits)
{
	if (PrimComp is null)
	{
		throw("TS_WorldCollision_NamespaceAndGlobalFunctions_04 setup: required PrimComp is null");
	}
	int32 Before = OutHits.Num();
	bool bQuatDefaulted = System::ComponentOverlapMulti(OutHits, PrimComp, Start, FQuat::Identity);
	TArray<FOverlapResult> QuatExplicit;
	bool bQuatExplicit = System::ComponentOverlapMulti(
		QuatExplicit,
		PrimComp,
		Start,
		FQuat::Identity,
		FComponentQueryParams::DefaultComponentQueryParams,
		FCollisionObjectQueryParams::DefaultObjectQueryParam);
	TArray<FOverlapResult> RotatorHits;
	bool bRotatorDefaulted = System::ComponentOverlapMulti(RotatorHits, PrimComp, Start, FRotator::ZeroRotator);
	TArray<FOverlapResult> RotatorExplicit;
	bool bRotatorExplicit = System::ComponentOverlapMulti(
		RotatorExplicit,
		PrimComp,
		Start,
		FRotator::ZeroRotator,
		FComponentQueryParams::DefaultComponentQueryParams,
		FCollisionObjectQueryParams::DefaultObjectQueryParam);
	if (bExpectHit)
	{
		return bQuatDefaulted && OutHits.Num() > Before && bQuatExplicit && QuatExplicit.Num() > 0 && bRotatorDefaulted && RotatorHits.Num() > 0 && bRotatorExplicit && RotatorExplicit.Num() > 0;
	}
	return !bQuatDefaulted && OutHits.Num() == Before && !bQuatExplicit && QuatExplicit.Num() == 0 && !bRotatorDefaulted && RotatorHits.Num() == 0 && !bRotatorExplicit && RotatorExplicit.Num() == 0;
}
/** @end */
/**
 * @begin component-overlap-multi-by-channel
 * @summary FixtureIsolated.
 * @topic Unreal
 */
/**
 * @function ObserveComponentOverlapMultiByChannelNominal
 * @summary FixtureIsolated.
 * @covers WorldCollision.component-overlap-multi-by-channel
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComponentOverlapMultiByChannelNominal(UPrimitiveComponent PrimComp, const FVector& Start, const FVector& End, bool bExpectHit, TArray<FOverlapResult>& OutHits)
{
	if (PrimComp is null)
	{
		throw("TS_WorldCollision_NamespaceAndGlobalFunctions_04 setup: required PrimComp is null");
	}
	int32 Before = OutHits.Num();
	bool bQuatDefaulted = System::ComponentOverlapMultiByChannel(
		OutHits,
		PrimComp,
		Start,
		FQuat::Identity,
		ECollisionChannel::WorldStatic);
	TArray<FOverlapResult> QuatExplicit;
	bool bQuatExplicit = System::ComponentOverlapMultiByChannel(
		QuatExplicit,
		PrimComp,
		Start,
		FQuat::Identity,
		ECollisionChannel::WorldStatic,
		FComponentQueryParams::DefaultComponentQueryParams,
		FCollisionObjectQueryParams::DefaultObjectQueryParam);
	TArray<FOverlapResult> RotatorHits;
	bool bRotatorDefaulted = System::ComponentOverlapMultiByChannel(
		RotatorHits,
		PrimComp,
		Start,
		FRotator::ZeroRotator,
		ECollisionChannel::Visibility);
	TArray<FOverlapResult> RotatorExplicit;
	bool bRotatorExplicit = System::ComponentOverlapMultiByChannel(
		RotatorExplicit,
		PrimComp,
		Start,
		FRotator::ZeroRotator,
		ECollisionChannel::Visibility,
		FComponentQueryParams::DefaultComponentQueryParams,
		FCollisionObjectQueryParams::DefaultObjectQueryParam);
	if (bExpectHit)
	{
		return bQuatDefaulted && OutHits.Num() > Before && bQuatExplicit && QuatExplicit.Num() > 0 && bRotatorDefaulted && RotatorHits.Num() > 0 && bRotatorExplicit && RotatorExplicit.Num() > 0;
	}
	return !bQuatDefaulted && OutHits.Num() == Before && !bQuatExplicit && QuatExplicit.Num() == 0 && !bRotatorDefaulted && RotatorHits.Num() == 0 && !bRotatorExplicit && RotatorExplicit.Num() == 0;
}
/** @end */
/**
 * @begin equality
 * @summary state.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary state.
 * @covers WorldCollision.equality
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FTraceHandle Left;
	FTraceHandle Right;
	uint64 FirstValue = 1;
	uint64 SecondValue = 2;
	FTraceHandle First(FirstValue);
	FTraceHandle FirstCopy(FirstValue);
	FTraceHandle Second(SecondValue);
	return (Left == Right) && (First == FirstCopy) && !(First == Second) && !(Left == First);
}
/** @end */
/**
 * @begin is-valid
 * @summary frame-scoped.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary frame-scoped.
 * @covers WorldCollision.is-valid
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsValidNominal()
{
	FTraceHandle Invalid;
	uint64 PackedValue = 1;
	FTraceHandle Packed(PackedValue);
	return !Invalid.IsValid() && Packed.IsValid();
}
/** @end */
/**
 * @begin query-trace-data
 * @summary frame-scoped.
 * @topic Unreal
 */
/**
 * @function ObserveQueryTraceDataNominal
 * @summary frame-scoped.
 * @covers WorldCollision.query-trace-data
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveQueryTraceDataNominal(const FVector& Start, const FVector& End, bool bExpectHit, FTraceDatum& OutData)
{
	FTraceHandle Invalid;
	int32 HitsBefore = OutData.OutHits.Num();
	bool bInvalidReady = System::QueryTraceData(Invalid, OutData);
	int32 HitsAfterInvalid = OutData.OutHits.Num();
	FTraceHandle Queued = System::AsyncLineTraceByChannel(EAsyncTraceType::Single, Start, End, ECollisionChannel::WorldStatic);
	bool bQueuedReady = System::QueryTraceData(Queued, OutData);
	if (bExpectHit)
	{
		return !bInvalidReady && HitsAfterInvalid == HitsBefore && Queued.IsValid() && OutData.OutHits.Num() >= HitsAfterInvalid;
	}
	return !bInvalidReady && HitsAfterInvalid == HitsBefore && !Queued.IsValid() && !bQueuedReady;
}
/** @end */
/**
 * @begin query-overlap-data
 * @summary frame-scoped.
 * @topic Unreal
 */
/**
 * @function ObserveQueryOverlapDataNominal
 * @summary frame-scoped.
 * @covers WorldCollision.query-overlap-data
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveQueryOverlapDataNominal(const FVector& Start, const FVector& End, bool bExpectHit, FOverlapDatum& OutData)
{
	FTraceHandle Invalid;
	int32 OverlapsBefore = OutData.OutOverlaps.Num();
	bool bInvalidReady = System::QueryOverlapData(Invalid, OutData);
	int32 OverlapsAfterInvalid = OutData.OutOverlaps.Num();
	FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
	FTraceHandle Queued = System::AsyncOverlapByChannel(Start, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
	bool bQueuedReady = System::QueryOverlapData(Queued, OutData);
	if (bExpectHit)
	{
		return !bInvalidReady && OverlapsAfterInvalid == OverlapsBefore && Queued.IsValid() && OutData.OutOverlaps.Num() >= OverlapsAfterInvalid;
	}
	return !bInvalidReady && OverlapsAfterInvalid == OverlapsBefore && !Queued.IsValid() && !bQueuedReady;
}
/** @end */
/**
 * @begin is-trace-handle-valid
 * @summary frame-scoped.
 * @topic Unreal
 */
/**
 * @function ObserveIsTraceHandleValidNominal
 * @summary frame-scoped.
 * @covers WorldCollision.is-trace-handle-valid
 * @inputs WorldCollision values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsTraceHandleValidNominal(const FVector& Start, const FVector& End, bool bExpectHit)
{
	FTraceHandle Invalid;
	bool bInvalidTrace = System::IsTraceHandleValid(Invalid, false);
	bool bInvalidOverlap = System::IsTraceHandleValid(Invalid, true);
	FTraceHandle Line = System::AsyncLineTraceByChannel(EAsyncTraceType::Test, Start, End, ECollisionChannel::WorldStatic);
	bool bLineAsTrace = System::IsTraceHandleValid(Line, false);
	bool bLineAsOverlap = System::IsTraceHandleValid(Line, true);
	if (bExpectHit)
	{
		return !bInvalidTrace && !bInvalidOverlap && bLineAsTrace && !bLineAsOverlap;
	}
	return !bInvalidTrace && !bInvalidOverlap && !bLineAsTrace && !bLineAsOverlap;
}
/** @end */
