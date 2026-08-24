// Theme: Gameplay.Debug. Positive: DebugBreak is script-facing and automation-safe.
// C++: AngelscriptCoverageDebugTests.cpp::DebugBreakBindingCanBeDisabledForAutomation
// ExecuteAndExpectInt TriggerDebugBreak == 7. Extra: the return is independent of
// DebugBreak being a no-op under the C++ override. DefaultSafe.

int TriggerDebugBreak()
{
	DebugBreak();
	return 7;
}

bool Observe_TriggerDebugBreak_Nominal()
{
	return TriggerDebugBreak() == 7;
}

int Observe_TriggerDebugBreak_DefaultBeforeCall()
{
	int Score = 0;
	return Score;
}
