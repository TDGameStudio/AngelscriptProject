// Theme: Language.Preprocessor. Positive fan-out C imports Root.
// C++: AngelscriptPreprocessorImportTests.cpp::WideImportGraph block 4
// sha256=62973240d8d1521a435d4752b1be89097735da0f80bba042fb31872c016143f1; lines 755-761.
// Oracle: ValueC() == RootValue() + 30 == 31.
// Extra: RootValue stays 1. DefaultSafe.

import Tests.Preprocessor.WideGraph.Root;
int ValueC()
{
	return RootValue() + 30;
}

bool Observe_ValueC_Nominal()
{
	return ValueC() == 31;
}

bool Observe_ValueC_RootBoundary()
{
	return RootValue() == 1 && ValueC() == RootValue() + 30;
}
