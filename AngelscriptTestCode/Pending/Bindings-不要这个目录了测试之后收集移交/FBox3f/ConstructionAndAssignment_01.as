/**
 * @version v1
 * @summary Observe FBox3f type declaration, in-place union with boxes/points, and string append of the box. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBox3f type declaration, in-place union with boxes/points, and string append of the box. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// text "box:".
// Expected observations: += OtherBox grows Max to 2. += Point grows Max to 3.
// Text += Box increases length. OtherBox is unchanged.
// Boundary/ownership: += mutates Box. FBox3f is a value type of FVector3f
// corners.

namespace TS_FBox3f_ConstructionAndAssignment_01
{
	// struct FBox3f constructed as (0,0,0)-(1,1,1). Oracle: Max.X==1. Value type declaration.
	bool Observe_Surface001_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
		return Box.Max.X == 1.0;
	}

	// Box += OtherBox then += Point then Text += Box. Oracle: Max grows 1->2->3 and text length > 4. Mutates Box; Other unchanged.
	bool Observe_AddAssign_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
		FBox3f Other(FVector3f(1, 1, 1), FVector3f(2, 2, 2));
		Box += Other;
		FVector3f Point(3, 3, 3);
		Box += Point;
		FString Text = "box:";
		Text += Box;
		return Box.Max.X == 3.0 && Other.Max.X == 2.0 && Text.Len() > 4;
	}
}
/** @end */
