// Purpose: Observe FFloatRangeBound.GetValue on closed inclusive bounds.
// AS-facing API: float32 Bound.GetValue() const;
// Inputs: Inclusive closed bounds 5, -2, and 0. IsClosed() is checked first.
// Expected observations: GetValue returns 5, -2, and 0. IsClosed is true for
// each constructed inclusive bound.
// Boundary/ownership: GetValue is valid only on closed bounds. Open bounds
// violate UE's native precondition and are not invoked here.

namespace TS_FRange_Queries_01
{
	bool Observe_GetValue_Nominal()
	{
		FFloatRangeBound Positive(5.0);
		FFloatRangeBound Negative(-2.0);
		FFloatRangeBound Zero(0.0);
		return Positive.IsClosed() && Negative.IsClosed() && Zero.IsClosed() && Positive.GetValue() == 5.0 && Negative.GetValue() == -2.0 && Zero.GetValue() == 0.0;
	}
}
