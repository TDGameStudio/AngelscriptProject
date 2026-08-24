// Theme: Language.Preprocessor. CSV SourceShape is NegativeDiagnostic, but the
// C++ method compiles this first file: Preprocess() succeeds with Entry()==7.
// The failure is the C++ API contract (late AddFile / second Preprocess),
// not this script. Follow the C++ method: value oracle.
// C++: AngelscriptPreprocessorBasicTests.cpp::PreprocessIsSingleUse First.as
// lines 275-280;
// sha256=64706dfe8cdbb585689bc2f3cb3da74470da6c314cff3f03363ee5e0233b24b0.
// Oracle: Entry() == 7. First Preprocess emits one module.
// Extra: 7 is the sole return.
// DefaultSafe. Source owns locals.

int Entry()
{
	return 7;
}

bool Observe_Entry_Nominal()
{
	return Entry() == 7;
}
