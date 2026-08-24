// Theme: Gameplay.Debug. Positive: FCpuProfilerTraceScoped is script-facing.
// C++: AngelscriptCoverageDebugTests.cpp::CpuProfilerScopedEventIsScriptFacing
// ExecuteAndExpectInt ScopedCpuProfilerEvent == 1. n"" event name.
// Extra: empty/default is returning 1 after the scope exits. DefaultSafe.

int ScopedCpuProfilerEvent()
{
	FCpuProfilerTraceScoped Scope(n"CoverageDebugCpuProfiler");
	return 1;
}

bool Observe_ScopedCpuProfilerEvent_Nominal()
{
	return ScopedCpuProfilerEvent() == 1;
}

int Observe_ScopedCpuProfilerEvent_DefaultBeforeScope()
{
	int Score = 0;
	return Score;
}
