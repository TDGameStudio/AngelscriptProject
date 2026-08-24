// Theme: Language.Syntax.EdgeCases. Positive default-argument execution.
// C++: AngelscriptCompilerEndToEndTests.cpp::ModuleFunctionInspection
// sha256=bebb61ef07f01e28d274ee8a9751aabe9fa28af0d6cb9eedda9fe7b1bf5a014a; lines 253-263.
// Oracle: Entry() omits both defaults so 21+21 == 42. Extra: explicit zeros
// are a boundary; repeating Entry is stable. DefaultSafe.

int SumWithDefault(int Value = 21, int Extra = 21)
{
	return Value + Extra;
}

int Entry()
{
	return SumWithDefault();
}

bool Observe_ModuleFunctionInspection_Nominal()
{
	return Entry() == 42 && SumWithDefault() == 42 && SumWithDefault(21, 21) == 42;
}

bool Observe_ModuleFunctionInspection_ExplicitZerosBoundary()
{
	return SumWithDefault(0, 0) == 0;
}

bool Observe_ModuleFunctionInspection_RepeatCall()
{
	int First = Entry();
	int Second = Entry();
	return First == 42 && Second == 42;
}
