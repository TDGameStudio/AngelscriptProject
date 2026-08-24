// Theme: Language.Syntax.EdgeCases. Positive &in parameters across the int family.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionParametersIn
// sha256=0eef9b0666244cce48dd7a062f08342db9e81a8346a3b5f30ad8f64b9756d152; lines 171-211.
// Oracle: AcceptInt8In(5)==15; AcceptInt16In(200)==300; AcceptIntIn(14)==42;
// AcceptInt64In(9999999999)==10000000000; AcceptUInt8In(10)==15; AcceptUInt16In(1000)==1050;
// AcceptUIntIn(3000000042)==2999999942; AcceptUInt64In(99999)==100999.
// Extra: AcceptIntIn(0)==0 empty; AcceptInt8In(-10)==0 signed boundary.
// DefaultSafe. &in does not write the caller local.

int8 AcceptInt8In(int8&in x)
{
	return x + 10;
}

int16 AcceptInt16In(int16&in x)
{
	return x + 100;
}

int AcceptIntIn(int&in x)
{
	return x * 3;
}

int64 AcceptInt64In(int64&in x)
{
	return x + 1;
}

uint8 AcceptUInt8In(uint8&in x)
{
	return x + 5;
}

uint16 AcceptUInt16In(uint16&in x)
{
	return x + 50;
}

uint AcceptUIntIn(uint&in x)
{
	return x - 100;
}

uint64 AcceptUInt64In(uint64&in x)
{
	return x + 1000;
}

bool Observe_FunctionParametersIn_Nominal()
{
	int8 I8 = 5;
	int16 I16 = 200;
	int I = 14;
	int64 I64 = 9999999999;
	uint8 U8 = 10;
	uint16 U16 = 1000;
	uint U = 3000000042;
	uint64 U64 = 99999;
	return AcceptInt8In(I8) == 15
		&& AcceptInt16In(I16) == 300
		&& AcceptIntIn(I) == 42
		&& AcceptInt64In(I64) == 10000000000
		&& AcceptUInt8In(U8) == 15
		&& AcceptUInt16In(U16) == 1050
		&& AcceptUIntIn(U) == 2999999942
		&& AcceptUInt64In(U64) == 100999
		&& I8 == 5
		&& I == 14;
}

int Observe_FunctionParametersIn_EmptyZero()
{
	int Zero = 0;
	return AcceptIntIn(Zero);
}

int8 Observe_FunctionParametersIn_NegativeBoundary()
{
	int8 Neg = -10;
	return AcceptInt8In(Neg);
}
