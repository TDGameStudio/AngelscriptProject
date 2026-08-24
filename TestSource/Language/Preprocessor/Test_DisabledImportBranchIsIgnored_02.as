// Theme: Language.Preprocessor. Positive: disabled USE_SHARED import is ignored.
// C++: AngelscriptCoveragePreprocessorTests.cpp::DisabledImportBranchIsIgnored
// DisabledConsumer.as; lines 117-130; preprocess flags USE_SHARED=false.
// sha256=90eb196cb3954a086399551d9a1f73affbfb6e8a3020e64a18a4a28f19e375b1.
// Oracle: Entry() == 7; import count 0; processed code has return 7, not SharedValue.
// Extra: USE_SHARED true would return SharedValue() from UnusedShared (40).
// DefaultSafe. Planned SharedValue stays in the skipped #ifdef branch.

#ifdef USE_SHARED
import Tests.Coverage.Preprocessor.UnusedShared;
#endif

int Entry()
{
#ifdef USE_SHARED
	return SharedValue();
#else
	return 7;
#endif
}

bool Observe_Entry_DisabledSharedFlag()
{
	// C++ preprocess sets USE_SHARED false.
	return Entry() == 7;
}
