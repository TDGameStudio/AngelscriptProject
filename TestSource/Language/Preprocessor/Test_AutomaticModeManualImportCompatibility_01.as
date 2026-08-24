// Theme: Language.Preprocessor. Positive provider for automatic-mode manual import.
// C++: AngelscriptPreprocessorImportTests.cpp::AutomaticModeManualImportCompatibility block 1
// sha256=f880eb6df76ea8c4f924ea48603c24e2b6313dfd0a5c0170c4eff1908d272f66; lines 108-113.
// Oracle: SharedValue() == 11; preprocess emits no errors.
// Extra: repeated calls stay 11. DefaultSafe. Source owns locals.

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
