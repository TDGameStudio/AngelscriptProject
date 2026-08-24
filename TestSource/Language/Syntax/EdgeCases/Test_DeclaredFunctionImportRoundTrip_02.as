// Theme: Language.Syntax.EdgeCases. Positive import consumer round-trip.
// C++: AngelscriptCompilerImportTests.cpp::DeclaredFunctionImportRoundTrip block 2
// sha256=ee7033f0ccd7227ff6498719ac24f9a0139862c8a48bb3254ec1a514d92af07e; lines 133-140.
// Oracle: Entry() returns the imported SharedValue (77 from the provider).
// Extra: repeating Entry is stable. DefaultSafe.

import int SharedValue() from "Tests.Compiler.ImportSource";

int Entry()
{
	return SharedValue();
}

bool Observe_ImportConsumer_Nominal()
{
	return Entry() == 77;
}

bool Observe_ImportConsumer_RepeatCall()
{
	int First = Entry();
	int Second = Entry();
	return First == 77 && Second == 77;
}
