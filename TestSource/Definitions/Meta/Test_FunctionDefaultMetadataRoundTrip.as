// Theme: Definitions.Meta. Positive default-argument metadata round-trip.
// C++: AngelscriptCompilerFunctionDefaultTests.cpp::FunctionDefaultMetadataRoundTrip
// Oracle: Entry() uses omitted defaults Value=21 Extra=7 so 14+21+7 == 42.
// Extra: explicit zeros are a boundary; repeating Entry is stable.
// DefaultSafe.

int SumWithDefaults(int Required, int Value = 21, int Extra = 7)
{
	return Required + Value + Extra;
}

int Entry()
{
	return SumWithDefaults(14);
}

bool Observe_FunctionDefault_Nominal()
{
	return Entry() == 42 && SumWithDefaults(14, 21, 7) == 42;
}

bool Observe_FunctionDefault_ExplicitZerosBoundary()
{
	return SumWithDefaults(14, 0, 0) == 14;
}

bool Observe_FunctionDefault_RepeatCall()
{
	return Entry() == Entry();
}
