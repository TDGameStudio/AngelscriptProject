// Purpose: Observe EAsyncTraceType plus FTraceHandle, FTraceDatum, and
// FOverlapDatum default construction, copy, and assignment.
// AS-facing API: enum EAsyncTraceType; struct FTraceHandle;
// struct FTraceDatum; struct FOverlapDatum;
// Inputs: Default handle/data values, a packed uint64 handle, copied data, and
// assignment of Single over Test.
// Expected observations: Default FTraceHandle is invalid. Copied handles
// compare equal. Copied FTraceDatum/FOverlapDatum keep Start/Pos and empty
// OutHits/OutOverlaps. Assigned EAsyncTraceType::Single differs from Test.
// Boundary/ownership: These are value types. Copying duplicates completed
// hit/overlap arrays rather than aliasing the async query.

namespace TS_WorldCollision_ConstructionAndAssignment_01
{
	// EAsyncTraceType copy equals the source; assigning Single leaves Test unchanged.
	bool Observe_Surface001_Nominal()
	{
		EAsyncTraceType Test = EAsyncTraceType::Test;
		EAsyncTraceType Copied = Test;
		Copied = EAsyncTraceType::Single;
		return Copied == EAsyncTraceType::Single && Test == EAsyncTraceType::Test && Test != EAsyncTraceType::Multi;
	}

	// Default FTraceHandle is invalid; copy equals default; assignment copies a packed handle.
	bool Observe_Surface005_Nominal()
	{
		FTraceHandle Handle;
		FTraceHandle Copied = Handle;
		uint64 PackedValue = 1;
		FTraceHandle Packed(PackedValue);
		Copied = Packed;
		return Copied == Packed && !Handle.IsValid() && Packed.IsValid();
	}

	// FTraceDatum copy keeps empty OutHits; assigned Start X is 1.
	bool Observe_Surface013_Nominal()
	{
		FTraceDatum Data;
		FTraceDatum Copied = Data;
		bool bCopiedEmptyHits = Copied.OutHits.Num() == 0;
		Data.Start = FVector(1.0, 2.0, 3.0);
		Copied = Data;
		return bCopiedEmptyHits && Copied.Start.X == 1.0 && Copied.Start.Y == 2.0 && Copied.Start.Z == 3.0;
	}

	// FOverlapDatum copy keeps empty OutOverlaps; assigned Pos X is 4.
	bool Observe_Surface022_Nominal()
	{
		FOverlapDatum Data;
		FOverlapDatum Copied = Data;
		bool bCopiedEmptyOverlaps = Copied.OutOverlaps.Num() == 0;
		Data.Pos = FVector(4.0, 5.0, 6.0);
		Copied = Data;
		return bCopiedEmptyOverlaps && Copied.Pos.X == 4.0 && Copied.Pos.Y == 5.0 && Copied.Pos.Z == 6.0;
	}
}
