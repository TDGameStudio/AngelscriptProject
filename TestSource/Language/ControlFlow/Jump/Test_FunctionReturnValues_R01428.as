// Theme: Language.ControlFlow.Jump. Positive value oracle from FunctionReturnValues.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionReturnValues
// sha256=bfad12d482e0b547f33b7f2f4ee531f7153ed226dea8e93393bd0d8ee81dd9e4; lines 501-541.
// Oracle: int8 -42; int16 30000; int 123456; int64 10000000000; uint8 255; uint16 60000; uint 3000000000; uint64 18000000000000000000.
// Extra: default integer locals are 0; signed vs unsigned extrema stay distinct.
// DefaultSafe. Source owns locals.

int8 ReturnInt8()
{
	return -42;
}

int16 ReturnInt16()
{
	return 30000;
}

int ReturnInt()
{
	return 123456;
}

int64 ReturnInt64()
{
	return 10000000000;
}

uint8 ReturnUInt8()
{
	return 255;
}

uint16 ReturnUInt16()
{
	return 60000;
}

uint ReturnUInt()
{
	return 3000000000;
}

uint64 ReturnUInt64()
{
	return 18000000000000000000;
}

bool Observe_IntReturnValues_Nominal()
{
	return ReturnInt8() == -42
		&& ReturnInt16() == 30000
		&& ReturnInt() == 123456
		&& ReturnInt64() == 10000000000
		&& ReturnUInt8() == 255
		&& ReturnUInt16() == 60000
		&& ReturnUInt() == 3000000000
		&& ReturnUInt64() == 18000000000000000000;
}

bool Observe_IntReturnValues_ZeroDefault()
{
	int8 Empty8;
	int16 Empty16;
	int EmptyInt;
	int64 Empty64;
	uint8 EmptyU8;
	uint16 EmptyU16;
	uint EmptyU;
	uint64 EmptyU64;
	return Empty8 == 0
		&& Empty16 == 0
		&& EmptyInt == 0
		&& Empty64 == 0
		&& EmptyU8 == 0
		&& EmptyU16 == 0
		&& EmptyU == 0
		&& EmptyU64 == 0
		&& ReturnInt8() != Empty8
		&& ReturnUInt8() != EmptyU8;
}

bool Observe_IntReturnValues_WidthBoundary()
{
	return ReturnInt8() < 0
		&& ReturnUInt8() == 255
		&& ReturnInt64() > ReturnInt()
		&& ReturnUInt64() > uint64(ReturnUInt());
}
