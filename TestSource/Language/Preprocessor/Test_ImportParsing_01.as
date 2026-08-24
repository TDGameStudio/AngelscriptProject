// Theme: Language.Preprocessor. Positive: imported SharedValue provider.
// C++: AngelscriptPreprocessorBasicTests.cpp::ImportParsing Shared.as
// lines 121-126;
// sha256=f880eb6df76ea8c4f924ea48603c24e2b6313dfd0a5c0170c4eff1908d272f66.
// Oracle: SharedValue() == 11.
// Extra: 11 is the sole return; no empty branch.
// DefaultSafe. Source owns locals.

int SharedValue()
{
	return 11;
}

bool Observe_SharedValue_Nominal()
{
	return SharedValue() == 11;
}
