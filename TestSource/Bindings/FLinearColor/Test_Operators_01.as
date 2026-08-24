// Purpose: Observe exact FLinearColor equality.
// AS-facing API: bool bEqual = Left == Right;
// Inputs: Identical (0.2,0.4,0.6,1), Black, and an alpha-only difference.
// Expected observations: Identical copies compare true. Black vs red is
// false. Alpha difference is false.
// Boundary/ownership: Equality is exact channel comparison, unlike Equals
// with tolerance.

namespace TS_FLinearColor_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FLinearColor Left(0.2, 0.4, 0.6, 1.0);
		FLinearColor Right(0.2, 0.4, 0.6, 1.0);
		FLinearColor Alpha(0.2, 0.4, 0.6, 0.0);
		return (Left == Right) && !(Left == FLinearColor::Black) && !(Left == Alpha);
	}
}
