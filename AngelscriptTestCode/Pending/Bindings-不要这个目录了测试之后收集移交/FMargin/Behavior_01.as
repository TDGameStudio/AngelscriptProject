/**
 * @version v1
 * @summary Observe every FMargin constructor overload.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe every FMargin constructor overload.
 * @topic Baseline
 */
// (1,2,3,4), and uniform 0.
// Expected observations: Uniform desired size is (8,8). HV horizontal total
// is 4. LTRB top-left is (1,2). Vector constructors match the matching HV/LTRB
// forms.
// Boundary/ownership: FVector2D is (Horizontal, Vertical). FVector4 is
// (Left, Top, Right, Bottom).

namespace TS_FMargin_Behavior_01
{
	bool Observe_Margin_Nominal()
	{
		FMargin Uniform(4.0);
		FMargin HV(2.0, 3.0);
		FMargin FromVector2D(FVector2D(2.0, 3.0));
		FMargin LTRB(1.0, 2.0, 3.0, 4.0);
		FMargin FromVector4(FVector4(1.0, 2.0, 3.0, 4.0));
		FMargin Zero(0.0);
		return Uniform.GetDesiredSize().X == 8.0 &&
			HV == FromVector2D &&
			HV.GetTotalSpaceAlongHorizontal() == 4.0 &&
			LTRB.GetTopLeft().X == 1.0 &&
			LTRB == FromVector4 &&
			Zero.GetDesiredSize().X == 0.0;
	}
}
/** @end */
