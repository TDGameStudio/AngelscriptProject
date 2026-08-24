// Theme: Language.Syntax.EdgeCases. Positive first compile-context payload.
// C++: AngelscriptCompilerEventsTests.cpp::CompilationContextIsScopedPerCompileRun block 1
// sha256=bd4a73e4104949e6f1fbb294a011facdf330ef482b6a786722d93fa63b8b7e9f; lines 726-731.
// Oracle: FirstEntry() returns 23. Extra: repeating FirstEntry stays 23.
// DefaultSafe.

int FirstEntry()
{
	return 23;
}

bool Observe_FirstContext_Nominal()
{
	return FirstEntry() == 23;
}

bool Observe_FirstContext_RepeatCall()
{
	int First = FirstEntry();
	int Second = FirstEntry();
	return First == 23 && Second == 23;
}
