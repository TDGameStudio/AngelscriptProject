// Theme: Language.Preprocessor. Positive: #if / #elif / #else / #endif branches.
// C++: AngelscriptCoveragePreprocessorTests.cpp::IfElifElseEndifBranches
// lines 163-174;
// sha256=fd285765d180c673511bba0650cea2159393f1a5b369615dbc8d8aba793f8120.
// Oracle: FIRST_BRANCH=false, SECOND_BRANCH=true => Entry()==2.
// Second preprocess: both flags false => Entry()==3.
// Extra: FIRST_BRANCH true would return 1; that path is excluded in C++.
// DefaultSafe. Observe uses the first C++ flag vector (elif / 2).

int Entry()
{
#if FIRST_BRANCH
	return 1;
#elif SECOND_BRANCH
	return 2;
#else
	return 3;
#endif
}

bool Observe_Entry_SecondBranch()
{
	// C++ ElifResult: FIRST_BRANCH=false, SECOND_BRANCH=true.
	return Entry() == 2;
}
