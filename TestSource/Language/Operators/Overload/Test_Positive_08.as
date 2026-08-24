// Theme: Language.Operators.Overload. Positive: in-place += via opAddAssign.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive AssertCompiles
// ASSyntaxOOAddAssign; lines 164-177;
// sha256=b01668f1e289faef9b420678ef37c585105ea6e295e6ebd538d8cee0b7a2afab.
// Oracle: (1, 2) += (3, 4) yields (4, 6); opAddAssign returns this.
// Extra: default (0, 0) += default stays (0, 0); repeat += accumulates.
// DefaultSafe. Source owns locals.

struct FVecAddAssign
{
	int X = 0;
	int Y = 0;

	FVecAddAssign& opAddAssign(const FVecAddAssign& Other)
	{
		X += Other.X;
		Y += Other.Y;
		return this;
	}
}

bool Observe_AddAssign_Nominal()
{
	FVecAddAssign Left;
	FVecAddAssign Right;
	Left.X = 1;
	Left.Y = 2;
	Right.X = 3;
	Right.Y = 4;
	Left += Right;
	return Left.X == 4 && Left.Y == 6;
}

bool Observe_AddAssign_DefaultEmpty()
{
	FVecAddAssign Left;
	FVecAddAssign Right;
	Left += Right;
	return Left.X == 0 && Left.Y == 0;
}

bool Observe_AddAssign_RepeatAccumulates()
{
	FVecAddAssign Left;
	FVecAddAssign Step;
	Step.X = 1;
	Step.Y = 2;
	Left += Step;
	Left += Step;
	return Left.X == 2 && Left.Y == 4 && Step.X == 1 && Step.Y == 2;
}
