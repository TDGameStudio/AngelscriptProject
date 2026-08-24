// Theme: Language.Preprocessor. Positive fan-out B imports Root.
// C++: AngelscriptPreprocessorImportTests.cpp::WideImportGraph block 3
// sha256=3e62d32d4a7b28bf1345e6d886cb466e8e99c91873b0cb17f9de6e0a1d9a8e30; lines 747-753.
// Oracle: ValueB() == RootValue() + 20 == 21.
// Extra: RootValue stays 1. DefaultSafe.

import Tests.Preprocessor.WideGraph.Root;
int ValueB()
{
	return RootValue() + 20;
}

bool Observe_ValueB_Nominal()
{
	return ValueB() == 21;
}

bool Observe_ValueB_RootBoundary()
{
	return RootValue() == 1 && ValueB() == RootValue() + 20;
}
