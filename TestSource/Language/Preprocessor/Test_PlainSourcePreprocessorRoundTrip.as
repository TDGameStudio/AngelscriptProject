// Theme: Language.Preprocessor. Positive: plain source round-trip compiles
// and executes Entry.
// C++: AngelscriptCompilerExecutionTests.cpp::PlainSourcePreprocessorRoundTrip
// CompileModuleWithSummary + ExecuteIntFunction; lines 118-123;
// sha256=dfc2a901d4a7cff773938db25445810403dcfd6f709134de4c99e23cf9218b74.
// Oracle: Entry() == 42. Summary.bCompileSucceeded, diagnostics empty.
// Extra: constant return has no empty/false branch; 42 is the sole value.
// DefaultSafe. Source owns locals.

int Entry()
{
	return 42;
}

bool Observe_Entry_Nominal()
{
	return Entry() == 42;
}
