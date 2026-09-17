/**
 * @version v1
 * @summary FRange host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FRange
 *
 * bound
 * range
 * interval
 * difference
 * get-value
 */
/**
 * @begin bound
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveBoundNominal
 * @summary Observe the container API.
 * @covers FRange.bound
 * @inputs FRange values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FFloatRange Range(float32 Lower, float32 Upper);
// FFloatInterval Interval(float32 Min, float32 Max);
// Inputs: Bound 4, range [1,5), interval [2,6], inverted range [5,1), and
// zero interval [0,0].
// Expected observations: Bound GetValue is 4. Range contains 1 and not 5.
// Interval contains both endpoints and Size is 4. Inverted range is empty.
// Boundary/ownership: Range(Lower, Upper) is half-open [Lower, Upper).
// Interval is inclusive. GetValue on an open bound is native-undefined.
bool ObserveBoundNominal()
{
	FFloatRangeBound Bound(4.0);
	return Bound.IsClosed() && Bound.IsInclusive() && Bound.GetValue() == 4.0;
}
/** @end */
/**
 * @begin range
 * @summary Interval is inclusive.
 * @topic Unreal
 */
/**
 * @function ObserveRangeNominal
 * @summary Interval is inclusive.
 * @covers FRange.range
 * @inputs FRange values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveRangeNominal()
{
	FFloatRange Range(1.0, 5.0);
	FFloatRange Inverted(5.0, 1.0);
	return Range.Contains(1.0) && !Range.Contains(5.0) && Range.Contains(4.0) && Inverted.IsEmpty();
}
/** @end */
/**
 * @begin interval
 * @summary Interval is inclusive.
 * @topic Unreal
 */
/**
 * @function ObserveIntervalNominal
 * @summary Interval is inclusive.
 * @covers FRange.interval
 * @inputs FRange values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIntervalNominal()
{
	FFloatInterval Interval(2.0, 6.0);
	FFloatInterval Zero(0.0, 0.0);
	return Interval.Contains(2.0) && Interval.Contains(6.0) && Interval.Size() == 4.0 && Zero.Size() == 0.0 && Zero.Contains(0.0);
}
/** @end */
/**
 * @begin difference
 * @summary B.
 * @topic Unreal
 */
/**
 * @function ObserveDifferenceNominal
 * @summary B.
 * @covers FRange.difference
 * @inputs FRange values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDifferenceNominal()
{
	FFloatRange Whole(0.0, 10.0);
	FFloatRange Hole(2.0, 4.0);
	TArray<FFloatRange> Pieces = FFloatRange::Difference(Whole, Hole);
	TArray<FFloatRange> Covered = FFloatRange::Difference(Whole, FFloatRange(-1.0, 11.0));
	TArray<FFloatRange> Identical = FFloatRange::Difference(Whole, FFloatRange(0.0, 10.0));
	return Pieces.Num() == 2 && (Pieces[0].Contains(1.0) || Pieces[1].Contains(1.0)) && (Pieces[0].Contains(8.0) || Pieces[1].Contains(8.0)) && !Pieces[0].Contains(3.0) && !Pieces[1].Contains(3.0) && Covered.Num() == 0 && Identical.Num() == 0;
}
/** @end */
/**
 * @begin get-value
 * @summary violate UE's native precondition and are not invoked here.
 * @topic Unreal
 */
/**
 * @function ObserveGetValueNominal
 * @summary violate UE's native precondition and are not invoked here.
 * @covers FRange.get-value
 * @inputs FRange values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetValueNominal()
{
	FFloatRangeBound Positive(5.0);
	FFloatRangeBound Negative(-2.0);
	FFloatRangeBound Zero(0.0);
	return Positive.IsClosed() && Negative.IsClosed() && Zero.IsClosed() && Positive.GetValue() == 5.0 && Negative.GetValue() == -2.0 && Zero.GetValue() == 0.0;
}
/** @end */
