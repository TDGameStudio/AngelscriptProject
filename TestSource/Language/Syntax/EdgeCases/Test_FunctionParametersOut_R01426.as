// Theme: Language.Syntax.EdgeCases. Positive &out writes across the int family.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionParametersOut
// sha256=6648a45d372a96fbec12e0488bfc43d21f48822b84cf4494e51c684b2b17f6b4; lines 291-337.
// Oracle: WriteInt8 -> 127; WriteInt16 -> 30000; WriteInt -> 42; WriteInt64 -> 10000000000;
// WriteUInt8 -> 255; WriteUInt16 -> 60000; WriteUInt -> 3000000000;
// WriteUInt64 -> 18000000000000000000; MultipleOut a=10 b=20.
// Extra: out from a non-zero seed still overwrites; MultipleOut zeros are independent.
// DefaultSafe. &out owns the callee write.

void WriteInt8(int8&out x)
{
	x = 127;
}

void WriteInt16(int16&out x)
{
	x = 30000;
}

void WriteInt(int&out x)
{
	x = 42;
}

void WriteInt64(int64&out x)
{
	x = 10000000000;
}

void WriteUInt8(uint8&out x)
{
	x = 255;
}

void WriteUInt16(uint16&out x)
{
	x = 60000;
}

void WriteUInt(uint&out x)
{
	x = 3000000000;
}

void WriteUInt64(uint64&out x)
{
	x = 18000000000000000000;
}

void MultipleOut(int&out a, int&out b)
{
	a = 10;
	b = 20;
}

bool Observe_FunctionParametersOut_Nominal()
{
	int8 I8 = 0;
	int16 I16 = 0;
	int I = 0;
	int64 I64 = 0;
	uint8 U8 = 0;
	uint16 U16 = 0;
	uint U = 0;
	uint64 U64 = 0;
	int A = 0;
	int B = 0;
	WriteInt8(I8);
	WriteInt16(I16);
	WriteInt(I);
	WriteInt64(I64);
	WriteUInt8(U8);
	WriteUInt16(U16);
	WriteUInt(U);
	WriteUInt64(U64);
	MultipleOut(A, B);
	return I8 == 127
		&& I16 == 30000
		&& I == 42
		&& I64 == 10000000000
		&& U8 == 255
		&& U16 == 60000
		&& U == 3000000000
		&& U64 == 18000000000000000000
		&& A == 10
		&& B == 20;
}

bool Observe_FunctionParametersOut_OverwriteSeed()
{
	int Seed = -99;
	WriteInt(Seed);
	return Seed == 42;
}

bool Observe_FunctionParametersOut_MultipleIndependent()
{
	int A = 1;
	int B = 2;
	MultipleOut(A, B);
	return A == 10 && B == 20;
}
