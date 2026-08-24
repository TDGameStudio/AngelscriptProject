// Theme: Language.Syntax.EdgeCases. Positive compile-event payload.
// C++: AngelscriptCompilerEventsTests.cpp::NoListenerCompileIsSilentAndPreservesResult
// sha256=81eed953d9af0b5100bd07ff60186d5cd6d15a3d3cf5f49f90b6a9b7ee288fef; lines 206-211.
// Oracle: Entry() returns 7. Extra: repeating Entry stays 7. DefaultSafe.

int Entry()
{
	return 7;
}

bool Observe_NoListenerCompile_Nominal()
{
	return Entry() == 7;
}

bool Observe_NoListenerCompile_RepeatCall()
{
	int First = Entry();
	int Second = Entry();
	return First == 7 && Second == 7;
}
