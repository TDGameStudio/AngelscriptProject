// Theme: Language.Preprocessor. Positive base of the A→B→C import chain.
// C++: AngelscriptPreprocessorImportTests.cpp::TopologicalOrderRespectsDependencyChain block 1
// sha256=c768311d06e371947fc0d824bc63cbcd51222c2e54e79a6e18f4105546b50389; lines 424-429.
// Oracle: BaseValue() == 2; module order Base → Shared → Consumer.
// Extra: repeat stays 2. DefaultSafe.

int BaseValue()
{
	return 2;
}

bool Observe_BaseValue_Nominal()
{
	return BaseValue() == 2;
}

bool Observe_BaseValue_RepeatBoundary()
{
	return BaseValue() == 2 && BaseValue() == 2;
}
