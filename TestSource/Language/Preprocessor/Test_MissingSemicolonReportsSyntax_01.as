// Theme: Language.Preprocessor. Provider body is valid; the paired consumer is the syntax failure.
// C++: AngelscriptPreprocessorImportTests.cpp::MissingSemicolonReportsSyntax block 1
// sha256=f880eb6df76ea8c4f924ea48603c24e2b6313dfd0a5c0170c4eff1908d272f66; lines 188-193.
// CSV NegativeDiagnostic applies to the pair; this file compiles and SharedValue() == 11.
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
