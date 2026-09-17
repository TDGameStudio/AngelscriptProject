/**
 * @version v1
 * @summary Observe ExpandBy, ShiftBy, and MoveTo box transforms.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe ExpandBy, ShiftBy, and MoveTo box transforms.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: FBox Box.ExpandBy(float64 W) const;
// FBox Box.ExpandBy(const FVector& V) const;
// FBox Box.ShiftBy(const FVector& Offset) const;
// FBox Box.MoveTo(const FVector& Destination) const;
// Inputs: Box (0,0,0)-(2,2,2), W=1, V=(1,0,0), Offset=(1,0,0), Destination
// (5,5,5), and W=0 as the empty expansion.
// Expected observations: ExpandBy(1) grows extent. ShiftBy moves both corners
// equally. MoveTo places the center at Destination. W=0 preserves the box.
// Boundary/ownership: These helpers return new boxes and do not mutate the
// receiver.

namespace TS_FBox_Behavior_02
{
	bool Observe_ExpandBy_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox Uniform = Box.ExpandBy(1.0);
		FBox Axis = Box.ExpandBy(FVector(1, 0, 0));
		FBox Zero = Box.ExpandBy(0.0);
		return Uniform.Min.X == -1.0 && Uniform.Max.X == 3.0 && Axis.Min.X == -1.0 && Axis.Max.Y == 2.0 && Zero == Box;
	}

	bool Observe_ShiftBy_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox Shifted = Box.ShiftBy(FVector(1, 0, 0));
		return Shifted.Min.X == 1.0 && Shifted.Max.X == 3.0 && Box.Min.X == 0.0;
	}

	bool Observe_MoveTo_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox Moved = Box.MoveTo(FVector(5, 5, 5));
		FVector Center = Moved.GetCenter();
		return Center.X == 5.0 && Center.Y == 5.0 && Center.Z == 5.0 && Box.GetCenter().X == 1.0;
	}
}
/** @end */
