// Theme: Language.Preprocessor. Positive consumer: manual import while automatic mode is on.
// C++: AngelscriptPreprocessorImportTests.cpp::AutomaticModeManualImportCompatibility block 2
// sha256=01784478e8cac7e64dfe5c331169797be8edcd39e70ecf61b6b0aea8bb19d482; lines 115-121.
// Oracle: UseShared() == SharedValue() == 11; import Tests.Preprocessor.AutomaticImportCompat.Shared is tracked then stripped.
// Extra: provider 11 is the only live value. DefaultSafe.

import Tests.Preprocessor.AutomaticImportCompat.Shared;
int UseShared()
{
	return SharedValue();
}

bool Observe_UseShared_Nominal()
{
	return UseShared() == 11;
}

bool Observe_UseShared_MatchesProvider()
{
	return UseShared() == SharedValue();
}
