// Theme: Gameplay.Debug. ThrowIf false continues; true raises a script exception.
// C++: AngelscriptCoverageErrorHandlingTests.cpp::ThrowIfReportsScriptException
// CSV NegativeDiagnostic; C++ compiles. ExecuteAndExpectInt ThrowIfFalseContinues == 11.
// TriggerThrowIf raises CoverageThrowIfTriggered. Extra: false path is the no-throw
// default. Do not wrap TriggerThrowIf in Observe. DefaultSafe.

int ThrowIfFalseContinues()
{
	ThrowIf(false, "CoverageThrowIfSkipped");
	return 11;
}

void TriggerThrowIf()
{
	ThrowIf(true, "CoverageThrowIfTriggered");
}

bool Observe_ThrowIfFalseContinues_Nominal()
{
	return ThrowIfFalseContinues() == 11;
}
