// Theme: Language.Syntax.EdgeCases. Positive second compile-context payload.
// C++: AngelscriptCompilerEventsTests.cpp::CompilationContextIsScopedPerCompileRun block 2
// sha256=842caff1543059e874ff652ef4c8b89b277f7609bc6613ca1bc1a05c267ef241; lines 743-748.
// Oracle: SecondEntry() returns 29. Extra: repeating SecondEntry stays 29.
// DefaultSafe.

int SecondEntry()
{
	return 29;
}

bool Observe_SecondContext_Nominal()
{
	return SecondEntry() == 29;
}

bool Observe_SecondContext_RepeatCall()
{
	int First = SecondEntry();
	int Second = SecondEntry();
	return First == 29 && Second == 29;
}
