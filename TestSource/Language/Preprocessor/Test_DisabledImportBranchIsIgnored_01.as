// Theme: Language.Preprocessor. Positive: unused shared provider (flag off).
// C++: AngelscriptCoveragePreprocessorTests.cpp::DisabledImportBranchIsIgnored
// UnusedShared.as; lines 108-113;
// sha256=c5419628d8f609446ed0eaecf55f612ca7eb737f22d3ba130c4862b8767fc1f2.
// Oracle: SharedValue() == 40. C++ does not import this module (USE_SHARED=false).
// Extra: provider still returns 40 if compiled on its own.
// DefaultSafe. Source owns locals.

int SharedValue()
{
	return 40;
}

bool Observe_SharedValue_Nominal()
{
	return SharedValue() == 40;
}
