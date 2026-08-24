// Purpose: Observe closest-point projection onto a finite segment and onto
// the unbounded line through the same endpoints.
// AS-facing API: Math::ClosestPointOnLine; Math::ClosestPointOnInfiniteLine.
// Inputs: Line (0,0,0)-(10,0,0); interior query (5,5,0); past-end query
// (15,5,0); a repeated call of the same arguments.
// Expected observations: Interior closest point is (5,0,0). Finite segment
// clamps past-end to (10,0,0). Infinite line extends to (15,0,0). A second
// call returns the same point.
// Boundary/ownership: Both functions return a new FVector. The input line
// endpoints are not mutated.

namespace TS_FMath_MutationAndLifecycle_01
{
	bool Observe_ClosestPointOnLine_Nominal()
	{
		FVector LineStart(0.0, 0.0, 0.0);
		FVector LineEnd(10.0, 0.0, 0.0);
		FVector Interior = Math::ClosestPointOnLine(LineStart, LineEnd, FVector(5.0, 5.0, 0.0));
		FVector PastEnd = Math::ClosestPointOnLine(LineStart, LineEnd, FVector(15.0, 5.0, 0.0));
		FVector Repeated = Math::ClosestPointOnLine(LineStart, LineEnd, FVector(5.0, 5.0, 0.0));
		return Interior.Equals(FVector(5.0, 0.0, 0.0), KINDA_SMALL_NUMBER) &&
			PastEnd.Equals(FVector(10.0, 0.0, 0.0), KINDA_SMALL_NUMBER) &&
			Repeated.Equals(Interior, KINDA_SMALL_NUMBER);
	}

	bool Observe_ClosestPointOnInfiniteLine_Nominal()
	{
		FVector LineStart(0.0, 0.0, 0.0);
		FVector LineEnd(10.0, 0.0, 0.0);
		FVector Interior = Math::ClosestPointOnInfiniteLine(LineStart, LineEnd, FVector(5.0, 5.0, 0.0));
		FVector PastEnd = Math::ClosestPointOnInfiniteLine(LineStart, LineEnd, FVector(15.0, 5.0, 0.0));
		FVector Repeated = Math::ClosestPointOnInfiniteLine(LineStart, LineEnd, FVector(15.0, 5.0, 0.0));
		return Interior.Equals(FVector(5.0, 0.0, 0.0), KINDA_SMALL_NUMBER) &&
			PastEnd.Equals(FVector(15.0, 0.0, 0.0), KINDA_SMALL_NUMBER) &&
			Repeated.Equals(PastEnd, KINDA_SMALL_NUMBER);
	}
}
