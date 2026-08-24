// Theme: Language.Preprocessor. Positive: shared provider for USE_SHARED import.
// C++: AngelscriptCoveragePreprocessorTests.cpp::ImportDependencyAndConditionalBranches
// Shared.as fixture; lines 43-48;
// sha256=c5419628d8f609446ed0eaecf55f612ca7eb737f22d3ba130c4862b8767fc1f2.
// Oracle: SharedValue() == 40. C++ orders this module before the consumer.
// Extra: 40 is the only return; no empty branch in this provider file.
// DefaultSafe. Source owns locals.

int SharedValue()
{
	return 40;
}

bool Observe_SharedValue_Nominal()
{
	return SharedValue() == 40;
}
