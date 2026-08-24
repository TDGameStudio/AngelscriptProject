// Theme: Language.Syntax.EdgeCases. Positive existing native t.MaxFPS smoke.
// C++: AngelscriptCoverageCVarTests.cpp::ExistingEngineCVarSmokePreservesAndRestoresValues
// sha256=6180652d6ecfb45a45a33100c28567ca9b84cbab73396ca2e058781a8ce3da42; lines 520-533.
// Oracle: ReadExistingMaxFPS returns the native baseline (not script 12.0);
// WriteExistingMaxFPS returns 83.0. Extra: script default 12.0 is not applied
// to an existing native. DefaultSafe (mutates t.MaxFPS until restored).

float ReadExistingMaxFPS()
{
	FConsoleVariable MaxFPS("t.MaxFPS", 12.0f, "Script default should not replace native t.MaxFPS");
	return MaxFPS.GetFloat();
}

float WriteExistingMaxFPS()
{
	FConsoleVariable MaxFPS("t.MaxFPS", 12.0f, "Script default should not replace native t.MaxFPS");
	MaxFPS.SetFloat(83.0f);
	return MaxFPS.GetFloat();
}

bool Observe_ExistingMaxFPS_ReadNotScriptDefault()
{
	return !Math::IsNearlyEqual(ReadExistingMaxFPS(), 12.0f, 0.001f);
}

bool Observe_ExistingMaxFPS_WriteNominal()
{
	return Math::IsNearlyEqual(WriteExistingMaxFPS(), 83.0f, 0.001f);
}

bool Observe_ExistingMaxFPS_ReadExpected(float32 ExpectedNative)
{
	return Math::IsNearlyEqual(ReadExistingMaxFPS(), ExpectedNative, 0.001f);
}
