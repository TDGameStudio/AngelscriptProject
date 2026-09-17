/**
 * @version v1
 * @summary FCpuProfilerTraceScoped is reachable from script, so a named profiler scope can be opened and closed around a block. C++ executes the entrypoint and expects 1 once the scope has exited.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary FCpuProfilerTraceScoped is reachable from script, so a named profiler scope can be opened and closed around a block. C++ executes the entrypoint and expects 1 once the scope has exited.
 * @topic Baseline
 */
namespace DebugTest
{
	/**
	 * Observe that a profiler scope can be opened with a named event and closed again.
	 *
	 * @Kind Observe
	 * @Covers Debug.CpuProfilerScopedEventIsScriptFacing
	 * @Inputs none
	 * @Return 1 once the scope has exited
	 */
	UFUNCTION()
	int ScopedCpuProfilerEvent()
	{
		FCpuProfilerTraceScoped Scope(n"CoverageDebugCpuProfiler");
		return 1;
	}

	/**
	 * Observe that driving the scoped profiler event reports success.
	 *
	 * @Kind Observe
	 * @Covers Debug.CpuProfilerScopedEventIsScriptFacing
	 * @Inputs none
	 * @Return true when the entrypoint returned 1
	 */
	UFUNCTION()
	bool ScopedCpuProfilerEventNominal()
	{
		return ScopedCpuProfilerEvent() == 1;
	}

	/**
	 * Observe the baseline score before any scope is opened.
	 *
	 * @Kind Observe
	 * @Covers Debug.CpuProfilerScopedEventIsScriptFacing
	 * @Inputs none
	 * @Return 0, the score before any work is done
	 * @Boundary before scope
	 */
	UFUNCTION()
	int DefaultBeforeScope()
	{
		int Score = 0;
		return Score;
	}
}
/** @end */
