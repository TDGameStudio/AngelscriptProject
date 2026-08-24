// Theme: Language.Syntax.EdgeCases. Positive parse-event payload.
// C++: AngelscriptCompilerEventsTests.cpp::ParseEventsAreBroadcastFromMainThreadInDeterministicOrder
// sha256=fc0a82cd3ac483e0459e3f94584455fbfc88663a6e50efc9073d17e7d1e14dd0; lines 650-655.
// Oracle: Entry() returns 19. Extra: repeating Entry stays 19. DefaultSafe.

int Entry()
{
	return 19;
}

bool Observe_ParseEvents_Nominal()
{
	return Entry() == 19;
}

bool Observe_ParseEvents_RepeatCall()
{
	int First = Entry();
	int Second = Entry();
	return First == 19 && Second == 19;
}
