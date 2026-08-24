// Theme: Language.Syntax.EdgeCases. Positive memory-source payload.
// C++: AngelscriptCompilerVirtualScriptPathTests.cpp::MemorySourceCompilesWithFullVirtualPathIdentity
// sha256=42498c1eba2a986514152c0129417abb247ed4f45aa1100e6e135b040347d8b2; lines 30-35.
// Oracle: Entry() returns 37. Extra: repeating Entry stays 37. DefaultSafe.

int Entry()
{
	return 37;
}

bool Observe_MemorySource_Nominal()
{
	return Entry() == 37;
}

bool Observe_MemorySource_RepeatCall()
{
	int First = Entry();
	int Second = Entry();
	return First == 37 && Second == 37;
}
