// Theme: Language.Preprocessor. Positive provider for duplicate-import dedup.
// C++: AngelscriptPreprocessorImportTests.cpp::DuplicateStatementsDeduplicateDependency block 1
// sha256=a2140293b37314ebc535fab1cfe914a9140c36ee1e57efb19da59fcd6aa1c8d7; lines 328-333.
// Oracle: SharedValue() == 17; topological order Shared before Consumer.
// Extra: repeat stays 17. DefaultSafe.

int SharedValue()
{
	return 17;
}

bool Observe_SharedValue_Nominal()
{
	return SharedValue() == 17;
}

bool Observe_SharedValue_RepeatBoundary()
{
	return SharedValue() == 17 && SharedValue() == 17;
}
