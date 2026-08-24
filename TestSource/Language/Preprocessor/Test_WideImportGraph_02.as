// Theme: Language.Preprocessor. Positive fan-out A imports Root.
// C++: AngelscriptPreprocessorImportTests.cpp::WideImportGraph block 2
// sha256=7baa2ff7e4e523ba01c1d7af407a759585404427b2c68165e5ffb7053a79e3cc; lines 739-745.
// Oracle: ValueA() == RootValue() + 10 == 11.
// Extra: RootValue stays 1. DefaultSafe.

import Tests.Preprocessor.WideGraph.Root;
int ValueA()
{
	return RootValue() + 10;
}

bool Observe_ValueA_Nominal()
{
	return ValueA() == 11;
}

bool Observe_ValueA_RootBoundary()
{
	return RootValue() == 1 && ValueA() == RootValue() + 10;
}
