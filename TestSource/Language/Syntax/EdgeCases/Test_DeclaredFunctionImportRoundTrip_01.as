// Theme: Language.Syntax.EdgeCases. Positive import-provider round-trip.
// C++: AngelscriptCompilerImportTests.cpp::DeclaredFunctionImportRoundTrip block 1
// sha256=29850b93b0e0abd46f844f1dac594f2491b23234659e73552d642526804c2960; lines 126-131.
// Oracle: SharedValue() returns 77. Extra: repeating SharedValue stays 77.
// DefaultSafe.

int SharedValue()
{
	return 77;
}

bool Observe_ImportProvider_Nominal()
{
	return SharedValue() == 77;
}

bool Observe_ImportProvider_RepeatCall()
{
	int First = SharedValue();
	int Second = SharedValue();
	return First == 77 && Second == 77;
}
