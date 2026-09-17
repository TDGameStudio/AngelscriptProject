/**
 * @version v1
 * @summary FGenericPlatformMisc host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FGenericPlatformMisc
 *
 * request-exit
 */
/**
 * @begin request-exit
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveRequestExitNominal
 * @summary Expected
 * @covers FGenericPlatformMisc.request-exit
 * @inputs FGenericPlatformMisc values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: RequestExit(false) returns to the caller. The
// boolean argument is consumed as the graceful rather than immediate path.
// Boundary/ownership: SubprocessOnly. SetupOwner=Runner. CleanupOwner=None.
// Immediate Force=true is not called. Missing allow-flag is setup failure.
bool ObserveRequestExitNominal(bool bAllowHostExit)
{
	if (!bAllowHostExit)
	{
		throw("TS_FGenericPlatformMisc_NamespaceAndGlobalFunctions_01 setup: RequestExit requires SubprocessOnly host");
	}
	FGenericPlatformMisc::RequestExit(false);
	return true;
}
/** @end */
