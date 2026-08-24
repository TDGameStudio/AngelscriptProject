// Theme: Language.Syntax.EdgeCases. Positive compile-event payload.
// C++: AngelscriptCompilerEventsTests.cpp::RegisteredListenerReceivesValueStyleCompileEvents
// sha256=82721f24863ef39d151bc5fb579a10048fffa649d5426d5249305d54349bc68b; lines 262-267.
// Oracle: Entry() returns 11. Extra: repeating Entry stays 11. DefaultSafe.

int Entry()
{
	return 11;
}

bool Observe_RegisteredListenerCompile_Nominal()
{
	return Entry() == 11;
}

bool Observe_RegisteredListenerCompile_RepeatCall()
{
	int First = Entry();
	int Second = Entry();
	return First == 11 && Second == 11;
}
