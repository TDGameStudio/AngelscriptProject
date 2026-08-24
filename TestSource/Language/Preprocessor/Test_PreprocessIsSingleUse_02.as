// Theme: Language.Preprocessor. CSV SourceShape is NegativeDiagnostic, but this
// Second.as body is a valid program. C++ never materializes it: late AddFile
// after Preprocess() does not emit a second module (Ensure !bIsPreprocessed).
// Follow the C++ method for the script itself: value oracle Entry()==11.
// C++: AngelscriptPreprocessorBasicTests.cpp::PreprocessIsSingleUse Second.as
// lines 282-287;
// sha256=67ea2d9af957d972b12b6de4d51839f0c9a39bf5f620f0c8a1b36ce3e9a5ddcb.
// Oracle: Entry() == 11 if compiled alone. C++ asserts the late module is absent.
// Extra: 11 is the sole return.
// DefaultSafe. Source owns locals.

int Entry()
{
	return 11;
}

bool Observe_Entry_Nominal()
{
	return Entry() == 11;
}
