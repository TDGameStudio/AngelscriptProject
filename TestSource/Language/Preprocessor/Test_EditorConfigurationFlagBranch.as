// Theme: Language.Preprocessor. Positive: EDITOR configuration flag.
// C++: AngelscriptCoveragePreprocessorTests.cpp::EditorConfigurationFlagBranch
// lines 219-228; preprocess flags EDITOR=true.
// sha256=74ccb2a9729b80b8fd23e46e1d4ed9e677ee57ac4f742e7890413c4c54349e39.
// Oracle: Entry() == 11. The #else return -11 is stripped.
// Extra: EDITOR false is the -11 boundary, not the C++ run.
// DefaultSafe. Source owns locals.

int Entry()
{
#if EDITOR
	return 11;
#else
	return -11;
#endif
}

bool Observe_Entry_EditorFlag()
{
	// C++ preprocess sets EDITOR true.
	return Entry() == 11;
}
