// Theme: Language.Preprocessor. Positive provider for automatic-import warning config.
// C++: AngelscriptPreprocessorImportTests.cpp::AutomaticWarningRespectsConfig block 1
// sha256=f880eb6df76ea8c4f924ea48603c24e2b6313dfd0a5c0170c4eff1908d272f66; lines 541-546.
// Oracle: SharedValue() == 11; preprocess succeeds with 0 errors regardless of warning policy.
// Extra: repeat stays 11. DefaultSafe.

int SharedValue()
{
	return 11;
}

bool Observe_SharedValue_Nominal()
{
	return SharedValue() == 11;
}

bool Observe_SharedValue_RepeatBoundary()
{
	return SharedValue() == 11 && SharedValue() == 11;
}
