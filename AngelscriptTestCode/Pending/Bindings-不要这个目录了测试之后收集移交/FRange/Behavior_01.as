/**
 * @version v1
 * @summary Observe inclusive closed float bounds, half-open ranges, inclusive intervals, and the open-bound GetValue diagnostic path.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe inclusive closed float bounds, half-open ranges, inclusive intervals, and the open-bound GetValue diagnostic path.
 * @topic Baseline
 */
// FFloatRange Range(float32 Lower, float32 Upper);
// FFloatInterval Interval(float32 Min, float32 Max);
// Inputs: Bound 4, range [1,5), interval [2,6], inverted range [5,1), and
// zero interval [0,0].
// Expected observations: Bound GetValue is 4. Range contains 1 and not 5.
// Interval contains both endpoints and Size is 4. Inverted range is empty.
// Boundary/ownership: Range(Lower, Upper) is half-open [Lower, Upper).
// Interval is inclusive. GetValue on an open bound is native-undefined.

namespace TS_FRange_Behavior_01
{
	bool Observe_Bound_Nominal()
	{
		FFloatRangeBound Bound(4.0);
		return Bound.IsClosed() && Bound.IsInclusive() && Bound.GetValue() == 4.0;
	}

	bool Observe_Range_Nominal()
	{
		FFloatRange Range(1.0, 5.0);
		FFloatRange Inverted(5.0, 1.0);
		return Range.Contains(1.0) && !Range.Contains(5.0) && Range.Contains(4.0) && Inverted.IsEmpty();
	}

	bool Observe_Interval_Nominal()
	{
		FFloatInterval Interval(2.0, 6.0);
		FFloatInterval Zero(0.0, 0.0);
		return Interval.Contains(2.0) && Interval.Contains(6.0) && Interval.Size() == 4.0 && Zero.Size() == 0.0 && Zero.Contains(0.0);
	}

	void ExerciseExpectedFailure()
	{
		FFloatRangeBound Open = FFloatRangeBound::Open();
		float32 Invalid = Open.GetValue();
	}
}
/** @end */
