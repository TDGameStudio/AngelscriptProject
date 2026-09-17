/**
 * @version v1
 * @summary Observe FFrameNumber and FFrameTime construction, including a zero frame and a fractional sub-frame in [0,1).
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FFrameNumber and FFrameTime construction, including a zero frame and a fractional sub-frame in [0,1).
 * @topic Baseline
 */
// FFrameTime Time(FFrameNumber Frame, float32 SubFrame);
// Inputs: Frame 0, Frame 24, SubFrame 0.0 and 0.5.
// Expected observations: Constructed frame numbers store Value. SubFrame 0
// produces a whole-frame time. SubFrame 0.5 is a fractional offset.
// Boundary/ownership: SubFrame is specified in [0,1). These are value types.

namespace TS_FFrameTime_Behavior_01
{
	bool Observe_Frame_Nominal()
	{
		FFrameNumber Zero(0);
		FFrameNumber TwentyFour(24);
		return Zero.Value == 0 && TwentyFour.Value == 24;
	}

	bool Observe_Time_Nominal()
	{
		FFrameNumber Frame(24);
		FFrameTime Whole(Frame, 0.0);
		FFrameTime Fractional(Frame, 0.5);
		FFrameTime ZeroTime(FFrameNumber(0), 0.0);
		return Whole.GetFrame().Value == 24 && Whole.GetSubFrame() == 0.0 && Fractional.GetSubFrame() == 0.5 && Fractional.AsDecimal() == 24.5 && ZeroTime.AsDecimal() == 0.0;
	}
}
/** @end */
