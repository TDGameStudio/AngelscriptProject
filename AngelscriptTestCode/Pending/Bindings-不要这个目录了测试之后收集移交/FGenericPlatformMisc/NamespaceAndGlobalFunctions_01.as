/**
 * @version v1
 * @summary Observe FGenericPlatformMisc::RequestExit returning after a graceful shutdown request. This file is not default-executable.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FGenericPlatformMisc::RequestExit returning after a graceful shutdown request. This file is not default-executable.
 * @topic Baseline
 */
// request. Force true is the immediate-exit boundary and is not invoked.
// Expected observations: RequestExit(false) returns to the caller. The
// boolean argument is consumed as the graceful rather than immediate path.
// Boundary/ownership: SubprocessOnly. SetupOwner=Runner. CleanupOwner=None.
// Immediate Force=true is not called. Missing allow-flag is setup failure.

namespace TS_FGenericPlatformMisc_NamespaceAndGlobalFunctions_01
{
	bool Observe_RequestExit_Nominal(bool bAllowHostExit)
	{
		if (!bAllowHostExit)
		{
			throw("TS_FGenericPlatformMisc_NamespaceAndGlobalFunctions_01 setup: RequestExit requires SubprocessOnly host");
		}
		FGenericPlatformMisc::RequestExit(false);
		return true;
	}
}
/** @end */
