// Theme: Language.Preprocessor. Positive middle of the import chain (Shared imports Base).
// C++: AngelscriptPreprocessorImportTests.cpp::TopologicalOrderRespectsDependencyChain block 2
// sha256=8b76b432802ebf433f770c431a9fb88cf34dbb10d6aaa4eafcfaa391f51e1628; lines 431-437.
// Oracle: SharedValue() == BaseValue() + 3 == 5.
// Extra: provider BaseValue stays 2. DefaultSafe.

import Tests.Preprocessor.ImportTopology.Base;
int SharedValue()
{
	return BaseValue() + 3;
}

bool Observe_SharedValue_Nominal()
{
	return SharedValue() == 5;
}

bool Observe_SharedValue_BaseBoundary()
{
	return BaseValue() == 2 && SharedValue() == BaseValue() + 3;
}
