// Theme: Language.Syntax.EdgeCases. Positive &inout in-place mutation across the int family.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionParametersInOut
// sha256=7fb75093f157e3d04b51d8bed9cd1b3b35ac5c12f7129df27713ba90d107b599; lines 421-461.
// Oracle: DoubleInt(21)->42; IncrementInt64(9999999000)->10000000000; DecrementUInt(3000000050)->3000000000.
// Extra: DoubleInt8(0) stays 0 empty; DoubleInt8(-2)->-4 signed boundary.
// DefaultSafe. &inout owns the caller local.

void DoubleInt8(int8&inout x)
{
	x *= 2;
}

void DoubleInt16(int16&inout x)
{
	x *= 2;
}

void DoubleInt(int&inout x)
{
	x *= 2;
}

void IncrementInt64(int64&inout x)
{
	x += 1000;
}

void DoubleUInt8(uint8&inout x)
{
	x *= 2;
}

void DoubleUInt16(uint16&inout x)
{
	x *= 2;
}

void DecrementUInt(uint&inout x)
{
	x -= 50;
}

void IncrementUInt64(uint64&inout x)
{
	x += 1000;
}

bool Observe_FunctionParametersInOut_Nominal()
{
	int Value = 21;
	int64 Wide = 9999999000;
	uint Unsigned = 3000000050;
	DoubleInt(Value);
	IncrementInt64(Wide);
	DecrementUInt(Unsigned);
	return Value == 42 && Wide == 10000000000 && Unsigned == 3000000000;
}

int8 Observe_FunctionParametersInOut_EmptyZero()
{
	int8 Zero = 0;
	DoubleInt8(Zero);
	return Zero;
}

int8 Observe_FunctionParametersInOut_NegativeBoundary()
{
	int8 Neg = -2;
	DoubleInt8(Neg);
	return Neg;
}
