/**
 * @version v1
 * @summary Observe scoped CPU profiler events that begin on construction and end when the value leaves scope.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe scoped CPU profiler events that begin on construction and end when the value leaves scope.
 * @topic Baseline
 */
// name boundary, and a short loop as the work performed inside the scope.
// Expected observations: Construction with a named event compiles and the
// inner loop still produces Sum == 45. A second scope with NAME_None still
// runs to completion.
// Boundary/ownership: The scoped value owns the native trace event. Ending
// the block ends the event; the FName is copied and does not need to outlive
// the scope.

namespace TS_FCpuProfilerTraceScoped_Behavior_01
{
	bool Observe_Event_Nominal()
	{
		int Sum = 0;
		{
			FCpuProfilerTraceScoped Event(n"TestSource.CpuProfiler.Nominal");
			for (int I = 0; I < 10; I++)
			{
				Sum += I;
			}
		}

		int EmptyScopeMarker = 0;
		{
			FCpuProfilerTraceScoped EmptyEvent(NAME_None);
			EmptyScopeMarker = 1;
		}
		return Sum == 45 && EmptyScopeMarker == 1;
	}
}
/** @end */
