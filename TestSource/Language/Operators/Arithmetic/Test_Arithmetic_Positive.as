// Theme: Language.Operators.Arithmetic. Positive: int/float arithmetic, unary, inc/dec, mixed types.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Positive ExpectGlobalInts.
// sha256=45eacff5c1220e86168b9062e080f6fbbd30b666774f93d1a65a60a8f0cceef3; lines 50-64.
// Oracle: AddInt 3; SubInt 2; MulInt 6; DivInt 5; ModInt 1; AddFloat 35;
// UnaryNeg -5; PreInc 1; PostInc 1; PreDec 4; PostDec 4; CompoundExpr 8; MixedTypes 30.
// Extra: 0 + 0 == 0; PreInc starts at the zero boundary.
// DefaultSafe. Integer division truncates toward zero.

int AddInt()
{
	return 1 + 2;
}

int SubInt()
{
	return 5 - 3;
}

int MulInt()
{
	return 2 * 3;
}

int DivInt()
{
	return 10 / 2;
}

int ModInt()
{
	return 10 % 3;
}

int AddFloat()
{
	float X = 1.0f + 2.5f;
	return int(X * 10);
}

int UnaryNeg()
{
	int X = 5;
	return -X;
}

int PreInc()
{
	int X = 0;
	++X;
	return X;
}

int PostInc()
{
	int X = 0;
	X++;
	return X;
}

int PreDec()
{
	int X = 5;
	--X;
	return X;
}

int PostDec()
{
	int X = 5;
	X--;
	return X;
}

int CompoundExpr()
{
	return (1 + 2) * 3 - 4 / 2 + 7 % 3;
}

int MixedTypes()
{
	float X = 1 + 2.0f;
	return int(X * 10);
}

bool Observe_Arithmetic_Nominal()
{
	return AddInt() == 3
		&& SubInt() == 2
		&& MulInt() == 6
		&& DivInt() == 5
		&& ModInt() == 1
		&& AddFloat() == 35
		&& UnaryNeg() == -5
		&& PreInc() == 1
		&& PostInc() == 1
		&& PreDec() == 4
		&& PostDec() == 4
		&& CompoundExpr() == 8
		&& MixedTypes() == 30;
}

int Observe_AddInt_ZeroBoundary()
{
	return 0 + 0;
}
