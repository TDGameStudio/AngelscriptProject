// Theme: Language.Preprocessor. Positive consumer: import lives inside #ifdef USESHARED.
// C++: AngelscriptPreprocessorImportTests.cpp::ImportInsideConditionalBranch block 2
// sha256=e04fc9ed7dadaa43dea81b0b87ed5e46d6a57d2395e4385a2a748ae74d8949d3; lines 623-635.
// Oracle without define: Entry() == 99 (else branch). With USESHARED: Entry() == SharedValue() == 42.
// Extra: else-branch 99 is the default-empty define path. DefaultSafe.

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
