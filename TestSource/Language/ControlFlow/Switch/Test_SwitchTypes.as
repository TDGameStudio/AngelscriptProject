// Theme: Language.ControlFlow.Switch. Positive value oracle from SwitchTypes.
// C++: AngelscriptCoverageConditionalTests.cpp::SwitchTypes
// sha256=1e8aec80a2040653416b580045eb1763baf8425f618c244c2c813fd9f76b1b69; lines 641-711.
// CSV SourceShape is NegativeDiagnostic; C++ still ExpectGlobalReturn after a 64-bit truncate warning.
// Oracle: SwitchInt8(1) 10; SwitchInt16(100) 1; SwitchInt64(1000) 1; SwitchUInt8(5) 50; SwitchUInt(42) 1.
// Extra: unmatched defaults 0; remaining listed cases.
// DefaultSafe value oracle. Source owns locals.

int SwitchInt8(int8 Value)
{
	switch (Value)
	{
		case 1:
			return 10;
		case 2:
			return 20;
		default:
			return 0;
	}
}

int SwitchInt16(int16 Value)
{
	switch (Value)
	{
		case 100:
			return 1;
		case 200:
			return 2;
		default:
			return 0;
	}
}

int SwitchInt64(int64 Value)
{
	switch (Value)
	{
		case 1000:
			return 1;
		case 2000:
			return 2;
		default:
			return 0;
	}
}

int SwitchUInt8(uint8 Value)
{
	switch (Value)
	{
		case 5:
			return 50;
		case 10:
			return 100;
		default:
			return 0;
	}
}

int SwitchUInt(uint Value)
{
	switch (Value)
	{
		case 42:
			return 1;
		case 100:
			return 2;
		default:
			return 0;
	}
}

bool Observe_SwitchTypes_Nominal()
{
	return SwitchInt8(1) == 10
		&& SwitchInt16(100) == 1
		&& SwitchInt64(1000) == 1
		&& SwitchUInt8(5) == 50
		&& SwitchUInt(42) == 1;
}

bool Observe_SwitchTypes_ZeroDefault()
{
	return SwitchInt8(0) == 0
		&& SwitchInt16(0) == 0
		&& SwitchInt64(0) == 0
		&& SwitchUInt8(0) == 0
		&& SwitchUInt(0) == 0;
}

bool Observe_SwitchTypes_RemainingCases()
{
	return SwitchInt8(2) == 20
		&& SwitchInt16(200) == 2
		&& SwitchInt64(2000) == 2
		&& SwitchUInt8(10) == 100
		&& SwitchUInt(100) == 2;
}
