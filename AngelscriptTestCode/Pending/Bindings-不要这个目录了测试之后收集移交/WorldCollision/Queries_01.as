/**
 * @version v1
 * @summary Observe FTraceHandle.IsValid and System query helpers for completed async trace/overlap data, including invalid handles.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTraceHandle.IsValid and System query helpers for completed async trace/overlap data, including invalid handles.
 * @topic Baseline
 */
// Runner supplies Start/End and bExpectHit so queued vs invalid handles are
// exact.
// AS-facing API: bool FTraceHandle.IsValid() const;
// bool System::QueryTraceData(const FTraceHandle& Handle, FTraceDatum& OutData);
// bool System::QueryOverlapData(const FTraceHandle& Handle, FOverlapDatum& OutData);
// bool System::IsTraceHandleValid(const FTraceHandle& Handle, bool bOverlapTrace);
// Inputs: Default invalid handle, a packed non-zero handle, empty FTraceDatum
// and FOverlapDatum writebacks, bOverlapTrace false then true, and runner-owned
// Start/End/bExpectHit.
// Expected observations: Default IsValid is false; packed 1 is valid.
// QueryTraceData/QueryOverlapData return false for an invalid handle.
// IsTraceHandleValid is false for both query kinds on a default handle.
// Queued handles match bExpectHit.
// Boundary/ownership: OutData is a caller-owned writeback. A valid handle is
// frame-scoped. FixtureIsolated. SetupOwner=Runner.

namespace TS_WorldCollision_Queries_01
{
	bool Observe_IsValid_Nominal()
	{
		FTraceHandle Invalid;
		uint64 PackedValue = 1;
		FTraceHandle Packed(PackedValue);
		return !Invalid.IsValid() && Packed.IsValid();
	}

	bool Observe_QueryTraceData_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, FTraceDatum& OutData)
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

	bool Observe_QueryOverlapData_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, FOverlapDatum& OutData)
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

	bool Observe_IsTraceHandleValid_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
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
}
/** @end */
