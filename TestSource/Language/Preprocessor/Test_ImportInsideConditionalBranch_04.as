// Theme: Language.Preprocessor. Positive consumer compiled by C++ with USESHARED=true.
// C++: AngelscriptPreprocessorImportTests.cpp::ImportInsideConditionalBranch block 4
// sha256=e04fc9ed7dadaa43dea81b0b87ed5e46d6a57d2395e4385a2a748ae74d8949d3; lines 646-658.
// Oracle as written (define off): Entry() == 99. C++ active branch: SharedValue() == 42.
// Extra: else 99 is the empty-define path. DefaultSafe.

#ifdef USESHARED
import Tests.Preprocessor.ImportConditional.Shared;
#endif
int Entry()
{
#ifdef USESHARED
	return SharedValue();
#else
	return 99;
#endif
}

bool Observe_Entry_UndefinedDefault()
{
	return Entry() == 99;
}

bool Observe_Entry_ElseSentinel()
{
	return Entry() == 99 && Entry() != 0;
}
