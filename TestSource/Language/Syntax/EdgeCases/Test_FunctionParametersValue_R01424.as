// Theme: Language.Syntax.EdgeCases. Positive value-parameter round trip across the int family.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionParametersValue
// sha256=1146094fffcb2f2d500e9395e103126068f0a834136c0c47cc33d06ddeb2c59e; lines 63-103.
// Oracle: AcceptInt8(41)==42; AcceptInt16(29900)==30000; AcceptInt(21)==42;
// AcceptInt64(9000000000)==9001000000; AcceptUInt8(254)==255; AcceptUInt16(59000)==60000;
// AcceptUInt(2999999900)==3000000000; AcceptUInt64(12000000000000)==13000000000000.
// Extra: AcceptInt8(0)==1 empty; AcceptInt(-1)==-2 signed boundary.
// DefaultSafe. Source owns locals.

int8 AcceptInt8(int8 x)
{
	return x + 1;
}

int16 AcceptInt16(int16 x)
{
	return x + 100;
}

int AcceptInt(int x)
{
	return x * 2;
}

int64 AcceptInt64(int64 x)
{
	return x + 1000000;
}

uint8 AcceptUInt8(uint8 x)
{
	return x + 1;
}

uint16 AcceptUInt16(uint16 x)
{
	return x + 1000;
}

uint AcceptUInt(uint x)
{
	return x + 100;
}

uint64 AcceptUInt64(uint64 x)
{
	return x + 1000000000000;
}

bool Observe_FunctionParametersValue_Nominal()
{
	return AcceptInt8(41) == 42
		&& AcceptInt16(29900) == 30000
		&& AcceptInt(21) == 42
		&& AcceptInt64(9000000000) == 9001000000
		&& AcceptUInt8(254) == 255
		&& AcceptUInt16(59000) == 60000
		&& AcceptUInt(2999999900) == 3000000000
		&& AcceptUInt64(12000000000000) == 13000000000000;
}

int8 Observe_FunctionParametersValue_EmptyZero()
{
	return AcceptInt8(0);
}

int Observe_FunctionParametersValue_NegativeBoundary()
{
	return AcceptInt(-1);
}
