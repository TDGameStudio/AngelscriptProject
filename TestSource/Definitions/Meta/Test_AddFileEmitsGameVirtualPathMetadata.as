// Theme: Definitions.Meta. Positive: preprocessor AddFile emits one game virtual-path code section.
// C++: AngelscriptVirtualScriptPathPreprocessorTests.cpp::AddFileEmitsGameVirtualPathMetadata
// Oracle: Entry() == 9. Extra: repeating Entry is stable. DefaultSafe.

int Entry()
{
	return 9;
}

int Observe_AddFile_EntryNominal()
{
	return Entry();
}

bool Observe_AddFile_RepeatCall()
{
	return Entry() == 9 && Entry() == 9;
}
