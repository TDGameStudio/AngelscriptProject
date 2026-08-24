// Theme: Language.Preprocessor. Positive consumer: import of Shared2 is in a dead #ifdef branch.
// C++: AngelscriptPreprocessorImportTests.cpp::ImportInsideConditionalBranch block 6
// sha256=64c563786fd00f5ecdef071527c55ad8cf38a8e67b42735c7a797c9984987579; lines 687-699.
// Oracle: Entry() == 99; import Tests.Preprocessor.ImportConditional.Shared2 is ignored; SharedValue is stripped.
// Extra: 99 is the empty-define else path. DefaultSafe.

#ifdef USESHARED
import Tests.Preprocessor.ImportConditional.Shared2;
#endif
int Entry()
{
#ifdef USESHARED
	return SharedValue();
#else
	return 99;
#endif
}

bool Observe_Entry_DeadBranchDefault()
{
	return Entry() == 99;
}

bool Observe_Entry_ElseSentinel()
{
	return Entry() == 99 && Entry() != 0;
}
