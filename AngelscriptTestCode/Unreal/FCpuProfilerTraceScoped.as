/**
 * @version v1
 * @summary FCpuProfilerTraceScoped host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FCpuProfilerTraceScoped
 *
 * event
 */
/**
 * @begin event
 * @summary the scope.
 * @topic Unreal
 */
/**
 * @function ObserveEventNominal
 * @summary the scope.
 * @covers FCpuProfilerTraceScoped.event
 * @inputs FCpuProfilerTraceScoped values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEventNominal()
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
/** @end */
