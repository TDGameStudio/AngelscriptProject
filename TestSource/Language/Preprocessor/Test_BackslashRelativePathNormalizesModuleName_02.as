// Theme: Language.Preprocessor. Positive consumer: dotted import resolves the backslash provider.
// C++: AngelscriptPreprocessorPathTests.cpp::BackslashRelativePathNormalizesModuleName block 2
// sha256=3a4f60ba4e605995367debc19847e450c3bf5000f949800f8455cfcbad1d7b1b; lines 50-56.
// Oracle: UseShared() == SharedValue() == 11.
// Extra: provider value is 11. DefaultSafe.

import Tests.Preprocessor.PathNormalization.WinShared;
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
