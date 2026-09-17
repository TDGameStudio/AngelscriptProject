/**
 * @version v1
 * @summary Observe remaining FTraceDatum async-mode fields and FOverlapDatum construction plus overlap result storage.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining FTraceDatum async-mode fields and FOverlapDatum construction plus overlap result storage.
 * @topic Baseline
 */
// ECollisionChannel FTraceDatum.TraceChannel; uint32 FTraceDatum.UserData;
// FOverlapDatum Data(); FVector FOverlapDatum.Pos; FQuat FOverlapDatum.Rot;
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

namespace TS_WorldCollision_Behavior_02
{
	// FTraceDatum.TraceType round-trips EAsyncTraceType::Single.
	bool Observe_Surface019_Nominal()
	{
		FTraceDatum Data;
		Data.TraceType = EAsyncTraceType::Single;
		return Data.TraceType == EAsyncTraceType::Single;
	}

	// FTraceDatum.TraceChannel round-trips ECollisionChannel::WorldStatic.
	bool Observe_Surface020_Nominal()
	{
		FTraceDatum Data;
		Data.TraceChannel = ECollisionChannel::WorldStatic;
		return Data.TraceChannel == ECollisionChannel::WorldStatic;
	}

	// FTraceDatum.UserData defaults to 0 and round-trips 7.
	bool Observe_Surface021_Nominal()
	{
		FTraceDatum Data;
		uint32 DefaultUserData = Data.UserData;
		Data.UserData = 7;
		uint32 Written = Data.UserData;
		return DefaultUserData == 0 && Written == 7;
	}

	// Default FOverlapDatum OutOverlaps is empty; copy preserves emptiness.
	bool Observe_Data_Nominal()
	{
		FOverlapDatum Data;
		FOverlapDatum Copied = Data;
		return Data.OutOverlaps.Num() == 0 && Copied.OutOverlaps.Num() == 0;
	}

	// FOverlapDatum.Pos defaults to zero and round-trips (7,8,9).
	bool Observe_Surface024_Nominal()
	{
		FOverlapDatum Data;
		FVector DefaultPos = Data.Pos;
		Data.Pos = FVector(7.0, 8.0, 9.0);
		FVector Written = Data.Pos;
		return DefaultPos.IsNearlyZero() && Written.X == 7.0 && Written.Z == 9.0;
	}

	// FOverlapDatum.Rot defaults to identity and round-trips FQuat::Identity.
	bool Observe_Surface025_Nominal()
	{
		FOverlapDatum Data;
		FQuat DefaultRot = Data.Rot;
		Data.Rot = FQuat::Identity;
		FQuat Written = Data.Rot;
		return DefaultRot.IsIdentity() && Written.IsIdentity();
	}

	// Adding a blocking FOverlapResult grows OutOverlaps; GetComponent is null.
	bool Observe_Surface026_Nominal()
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

	// FOverlapDatum.TraceChannel round-trips ECollisionChannel::WorldDynamic.
	bool Observe_Surface027_Nominal()
	{
		FOverlapDatum Data;
		Data.TraceChannel = ECollisionChannel::WorldDynamic;
		return Data.TraceChannel == ECollisionChannel::WorldDynamic;
	}

	// FOverlapDatum.UserData defaults to 0 and round-trips 8.
	bool Observe_Surface028_Nominal()
	{
		FOverlapDatum Data;
		uint32 DefaultUserData = Data.UserData;
		Data.UserData = 8;
		uint32 Written = Data.UserData;
		return DefaultUserData == 0 && Written == 8;
	}
}
/** @end */
