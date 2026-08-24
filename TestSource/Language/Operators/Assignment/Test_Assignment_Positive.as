// Theme: Language.Operators.Assignment. Positive value oracle from Assignment_Positive.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Positive
// sha256=c95b169b05b2a79e3bd42ddcde359961fa47fc5e1e575c0e91ac1f98e2096f00; lines 447-459.
// Oracle: SimpleAssign 5; AddAssign 5; SubAssign 7; MulAssign 6; DivAssign 5;
// ModAssign 1; BitAndAssign 15; BitOrAssign 255; BitXorAssign 240;
// ShiftLAssign 16; ShiftRAssign 4.
// Extra: SimpleAssign/AddAssign start from 0; BitAndAssign masks to nibble; ModAssign remainder 1.
// DefaultSafe. Source owns locals.

int SimpleAssign()
{
	int X = 0;
	X = 5;
	return X;
}

int AddAssign()
{
	int X = 0;
	X += 5;
	return X;
}

int SubAssign()
{
	int X = 10;
	X -= 3;
	return X;
}

int MulAssign()
{
	int X = 2;
	X *= 3;
	return X;
}

int DivAssign()
{
	int X = 10;
	X /= 2;
	return X;
}

int ModAssign()
{
	int X = 10;
	X %= 3;
	return X;
}

int BitAndAssign()
{
	int X = 0xFF;
	X &= 0x0F;
	return X;
}

int BitOrAssign()
{
	int X = 0xF0;
	X |= 0x0F;
	return X;
}

int BitXorAssign()
{
	int X = 0xFF;
	X ^= 0x0F;
	return X;
}

int ShiftLAssign()
{
	int X = 1;
	X <<= 4;
	return X;
}

int ShiftRAssign()
{
	int X = 16;
	X >>= 2;
	return X;
}

bool Observe_Assignment_Nominal()
{
	return SimpleAssign() == 5
		&& AddAssign() == 5
		&& SubAssign() == 7
		&& MulAssign() == 6
		&& DivAssign() == 5
		&& ModAssign() == 1
		&& BitAndAssign() == 15
		&& BitOrAssign() == 255
		&& BitXorAssign() == 240
		&& ShiftLAssign() == 16
		&& ShiftRAssign() == 4;
}

bool Observe_Assignment_EmptyDefaultThenWrite()
{
	return SimpleAssign() == 5 && AddAssign() == 5;
}

bool Observe_Assignment_MaskAndRemainderBoundary()
{
	return BitAndAssign() == 15 && ModAssign() == 1 && BitXorAssign() == 240;
}
