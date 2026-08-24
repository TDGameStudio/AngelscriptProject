// Purpose: Observe FBox2D point containment.
// The bool return is the runner-readable oracle.
// AS-facing API: bool FBox2D.IsInside(const FVector2D& Point) const;
// Inputs: Box (0,0)-(2,2), interior (1,1), exterior (3,1), and on-edge (0,1).
// Expected observations: Interior is true. Exterior is false. On-edge min is
// excluded because native IsInside is open on both bounds.
// Boundary/ownership: IsInside does not mutate the box.

namespace TS_FBox2D_Queries_01
{
	bool Observe_IsInside_Nominal()
	{
		FBox2D Box(FVector2D(0, 0), FVector2D(2, 2));
		return Box.IsInside(FVector2D(1, 1)) && !Box.IsInside(FVector2D(3, 1)) && !Box.IsInside(FVector2D(0, 1));
	}
}
