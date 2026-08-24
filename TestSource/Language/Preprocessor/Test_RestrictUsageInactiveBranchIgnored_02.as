// Theme: Language.Preprocessor. Positive compile/execute of the same inactive #restrict fixture.
// C++: AngelscriptPreprocessorNamespaceTests.cpp::RestrictUsageInactiveBranchIgnored block 2
// sha256=02dd97721230db2f8f2f550eedcd6ff664d0734d799b066aa4c4a5f29b573f6f; lines 204-212.
// Oracle: Entry() == 7 through the preprocessor pipeline with no diagnostics.
// Extra: repeat stays 7. DefaultSafe.

#if !EDITOR
#restrict usage disallow Runtime.*
#endif
int Entry()
{
	return 7;
}

bool Observe_Entry_Nominal()
{
	return Entry() == 7;
}

bool Observe_Entry_RepeatBoundary()
{
	return Entry() == 7 && Entry() == 7;
}
