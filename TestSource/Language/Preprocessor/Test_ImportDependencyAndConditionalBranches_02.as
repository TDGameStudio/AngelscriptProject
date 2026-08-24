// Theme: Language.Preprocessor. Positive: consumer with USE_SHARED import branch.
// C++: AngelscriptCoveragePreprocessorTests.cpp::ImportDependencyAndConditionalBranches
// Consumer.as; lines 52-65; preprocess flags USE_SHARED=true.
// sha256=bcb991d88afe14e241f1f2899311646884fcc44c751d3685ae53777861eec20e.
// Oracle: with USE_SHARED, Entry() == SharedValue() + 2 == 42; import kept.
// Without USE_SHARED, Entry() == -1 (the #else). C++ keeps the +2 path.
// Extra: -1 is the disabled-import false path recorded in the source.
// DefaultSafe. Import identity: Tests.Coverage.Preprocessor.Shared.

#ifdef USE_SHARED
import Tests.Coverage.Preprocessor.Shared;
#endif

int Entry()
{
#ifdef USE_SHARED
	return SharedValue() + 2;
#else
	return -1;
#endif
}

bool Observe_Entry_WithSharedFlag()
{
	// C++ preprocess sets USE_SHARED true; SharedValue()+2 == 42.
	return Entry() == 42;
}
