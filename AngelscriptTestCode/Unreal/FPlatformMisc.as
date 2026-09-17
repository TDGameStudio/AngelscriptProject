/**
 * @version v1
 * @summary FPlatformMisc host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FPlatformMisc
 *
 * request-exit
 * get-environment-variable
 */
/**
 * @begin request-exit
 * @summary Missing allow-flag is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveRequestExitNominal
 * @summary Missing allow-flag is setup failure.
 * @covers FPlatformMisc.request-exit
 * @inputs FPlatformMisc values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRequestExitNominal(bool bAllowHostExit)
{
	if (!bAllowHostExit)
	{
		throw("TS_FPlatformMisc_NamespaceAndGlobalFunctions_01 setup: RequestExit requires SubprocessOnly host");
	}
	FPlatformMisc::RequestExit(false);
	FString EmptyCallSite;
	FPlatformMisc::RequestExit(false, EmptyCallSite);
	FPlatformMisc::RequestExit(false, "TS_FPlatformMisc_NamespaceAndGlobalFunctions_01");
	return true;
}
/** @end */
/**
 * @begin get-environment-variable
 * @summary environment state and does not own the variable.
 * @topic Unreal
 */
/**
 * @function ObserveGetEnvironmentVariableNominal
 * @summary environment state and does not own the variable.
 * @covers FPlatformMisc.get-environment-variable
 * @inputs FPlatformMisc values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetEnvironmentVariableNominal()
{
	FString PathEnv = FPlatformMisc::GetEnvironmentVariable("PATH");
	FString Missing = FPlatformMisc::GetEnvironmentVariable("TestSource_MissingEnvironmentVariable");
	FString EmptyName = FPlatformMisc::GetEnvironmentVariable("");
	return PathEnv.Len() > 0 && Missing.IsEmpty() && EmptyName.IsEmpty();
}
/** @end */
