// Purpose: Observe exact four-channel equality of FColor values.
// AS-facing API: bool bEqual = Color == ColorB;
// Inputs: Identical (255, 128, 64, 255) operands, a zero Black operand, and
// a boundary color that differs only in alpha.
// Expected observations: Same channels compare true. Black versus Red is
// false. Alpha-only difference is false. Equality does not mutate operands.
// Boundary/ownership: Comparison is by value of the four bytes. This operator
// returns a bool and is not the mutating += path.

namespace TS_FColor_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FColor Color(255, 128, 64, 255);
		FColor ColorB(255, 128, 64, 255);
		FColor AlphaBoundary(255, 128, 64, 0);
		return Color == ColorB && !(Color == FColor::Black) && !(Color == AlphaBoundary);
	}
}
