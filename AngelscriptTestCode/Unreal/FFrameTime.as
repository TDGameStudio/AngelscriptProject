/**
 * @version v1
 * @summary FFrameTime host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FFrameTime
 *
 * frame
 * time
 */
/**
 * @begin frame
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveFrameNominal
 * @summary Observe the container API.
 * @covers FFrameTime.frame
 * @inputs FFrameTime values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FFrameTime Time(FFrameNumber Frame, float32 SubFrame);
// Inputs: Frame 0, Frame 24, SubFrame 0.0 and 0.5.
// Expected observations: Constructed frame numbers store Value. SubFrame 0
// produces a whole-frame time. SubFrame 0.5 is a fractional offset.
// Boundary/ownership: SubFrame is specified in [0,1). These are value types.
bool ObserveFrameNominal()
{
	FFrameNumber Zero(0);
	FFrameNumber TwentyFour(24);
	return Zero.Value == 0 && TwentyFour.Value == 24;
}
/** @end */
/**
 * @begin time
 * @summary Boundary/ownership: SubFrame is specified in [0,1).
 * @topic Unreal
 */
/**
 * @function ObserveTimeNominal
 * @summary Boundary/ownership: SubFrame is specified in [0,1).
 * @covers FFrameTime.time
 * @inputs FFrameTime values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTimeNominal()
{
	FFrameNumber Frame(24);
	FFrameTime Whole(Frame, 0.0);
	FFrameTime Fractional(Frame, 0.5);
	FFrameTime ZeroTime(FFrameNumber(0), 0.0);
	return Whole.GetFrame().Value == 24 && Whole.GetSubFrame() == 0.0 && Fractional.GetSubFrame() == 0.5 && Fractional.AsDecimal() == 24.5 && ZeroTime.AsDecimal() == 0.0;
}
/** @end */
