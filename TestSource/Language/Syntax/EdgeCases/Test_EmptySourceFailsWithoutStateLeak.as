// Theme: Language.Syntax.EdgeCases. C++ compiles this recovery body after the
// empty-source failure and executes Entry. CSV NegativeDiagnostic describes
// the empty prelude, not this file. Follow the C++ method: value oracle.
// C++: AngelscriptCompilerFailureTests.cpp::EmptySourceFailsWithoutStateLeak
// sha256=8df2f95142a195a1f51d69ffab0949f5a3367f160efb4d971a6339527be75300; lines 109-114.
// Oracle: Entry() returns 42. Extra: repeating Entry stays 42. DefaultSafe.

int Entry()
{
	return 42;
}

bool Observe_EmptySourceRecovery_Nominal()
{
	return Entry() == 42;
}

bool Observe_EmptySourceRecovery_RepeatCall()
{
	int First = Entry();
	int Second = Entry();
	return First == 42 && Second == 42;
}
