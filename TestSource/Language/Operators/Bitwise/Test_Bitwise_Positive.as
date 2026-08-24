// Theme: Language.Operators.Bitwise. Positive value oracle from Bitwise_Positive.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Positive
// sha256=a081c1ffe830d651286fbdf62b7053aa0d0dae0bb281ee5e2950cb62adb424a2; lines 191-199.
// Oracle: BitAnd 15; BitOr 255; BitXor 240; BitNot 255; ShiftLeft 16; ShiftRight 4; Compound 255.
// Extra: empty mask 0x00 & 0x0F is 0; 0xFF ^ 0xFF is 0.
// DefaultSafe. Source owns locals.

int BitAnd()
{
	return 0xFF & 0x0F;
}

int BitOr()
{
	return 0xF0 | 0x0F;
}

int BitXor()
{
	return 0xFF ^ 0x0F;
}

int BitNot()
{
	return ~0 & 0xFF;
}

int ShiftLeft()
{
	return 1 << 4;
}

int ShiftRight()
{
	return 16 >> 2;
}

int Compound()
{
	return (0xFF & 0x0F) | (0xF0 ^ 0x0F);
}

bool Observe_Bitwise_Nominal()
{
	return BitAnd() == 15
		&& BitOr() == 255
		&& BitXor() == 240
		&& BitNot() == 255
		&& ShiftLeft() == 16
		&& ShiftRight() == 4
		&& Compound() == 255;
}

bool Observe_Bitwise_EmptyDefault()
{
	return (0x00 & 0x0F) == 0 && (0x00 | BitAnd()) == BitAnd();
}

bool Observe_Bitwise_FullMaskBoundary()
{
	return (~0 & 0xFF) == BitNot() && (0xFF ^ 0xFF) == 0;
}
