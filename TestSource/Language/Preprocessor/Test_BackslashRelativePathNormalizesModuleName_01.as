// Theme: Language.Preprocessor. Positive provider loaded from a backslash relative path.
// C++: AngelscriptPreprocessorPathTests.cpp::BackslashRelativePathNormalizesModuleName block 1
// sha256=f880eb6df76ea8c4f924ea48603c24e2b6313dfd0a5c0170c4eff1908d272f66; lines 43-48.
// Oracle: SharedValue() == 11; dotted module Tests.Preprocessor.PathNormalization.WinShared.
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
