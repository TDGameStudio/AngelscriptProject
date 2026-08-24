// Theme: Language.Preprocessor. Positive: #restrict in a dead #if !EDITOR branch is ignored.
// C++: AngelscriptPreprocessorNamespaceTests.cpp::RestrictUsageInactiveBranchIgnored block 1
// sha256=02dd97721230db2f8f2f550eedcd6ff664d0734d799b066aa4c4a5f29b573f6f; lines 156-164.
// Oracle: Entry() == 7; EDITOR context records zero usage restrictions.
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
