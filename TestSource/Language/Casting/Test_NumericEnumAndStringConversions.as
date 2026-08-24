// Theme: Language.Casting. Positive numeric widening, explicit casts, enum, and FString formatting.
// C++: AngelscriptCoverageTypeConversionTests.cpp::NumericEnumAndStringConversions
// Oracle: ImplicitWidening 250; ExplicitIntToFloat 42; ExplicitFloatToInt 9; EnumToInt 3;
// IntToEnumComparison true; IntToString "42"; IntStringRoundTrip true; FloatStringRoundTrip true.
// Extra: uint8 0 widens to 0; enum None is 0; FromInt(0) is "0".
// DefaultSafe. Source owns locals.

enum ECoverageConversionState
{
	None = 0,
	Ready = 3
}

int ImplicitWidening()
{
	uint8 Small = 250;
	int Wider = Small;
	return Wider;
}

float ExplicitIntToFloat()
{
	int Value = 42;
	return float(Value);
}

int ExplicitFloatToInt()
{
	float Value = 9.75f;
	return int(Value);
}

int EnumToInt()
{
	return int(ECoverageConversionState::Ready);
}

bool IntToEnumComparison()
{
	ECoverageConversionState State = ECoverageConversionState(3);
	return State == ECoverageConversionState::Ready;
}

FString IntToString()
{
	return FString::FromInt(42);
}

bool IntStringRoundTrip()
{
	return FString::FromInt(123) == "123" && FString::FromInt(-456) == "-456";
}

bool FloatStringRoundTrip()
{
	FString Value = FString::SanitizeFloat(12.5);
	return Value.StartsWith("12.5");
}

bool Observe_NumericEnumAndString_Nominal()
{
	return ImplicitWidening() == 250
		&& ExplicitIntToFloat() == 42.0
		&& ExplicitFloatToInt() == 9
		&& EnumToInt() == 3
		&& IntToEnumComparison()
		&& IntToString() == "42"
		&& IntStringRoundTrip()
		&& FloatStringRoundTrip();
}

int Observe_ImplicitWidening_ZeroDefault()
{
	uint8 Small = 0;
	int Wider = Small;
	return Wider;
}

int Observe_EnumToInt_NoneBoundary()
{
	return int(ECoverageConversionState::None);
}
