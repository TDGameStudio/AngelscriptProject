// Theme: Language.Preprocessor. Positive consumer: manual import under warning-on/off config.
// C++: AngelscriptPreprocessorImportTests.cpp::AutomaticWarningRespectsConfig block 2
// sha256=fff50464d8d20bdec4d6367d599bd516d5faee92ed9f60129f5c5a1572d72aa1; lines 548-554.
// Oracle: Entry() == SharedValue() == 11; warning text "Automatic imports are active, import statements will be ignored."
// Extra: provider value is 11. DefaultSafe.

import Tests.Preprocessor.ImportMode.Shared;
int Entry()
{
	return SharedValue();
}

bool Observe_Entry_Nominal()
{
	return Entry() == 11;
}

bool Observe_Entry_MatchesProvider()
{
	return Entry() == SharedValue();
}
