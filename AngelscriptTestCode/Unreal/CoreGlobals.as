/**
 * @version v1
 * @summary CoreGlobals host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic CoreGlobals
 *
 * is-running-cook-commandlet
 * is-running-dlc-cook-commandlet
 * get-running-commandlet-class
 */
/**
 * @begin is-running-cook-commandlet
 * @summary or own a commandlet instance.
 * @topic Unreal
 */
/**
 * @function ObserveIsRunningCookCommandletNominal
 * @summary or own a commandlet instance.
 * @covers CoreGlobals.is-running-cook-commandlet
 * @inputs CoreGlobals values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsRunningCookCommandletNominal(bool bExpectCookCommandlet)
{
	bool bCooking = IsRunningCookCommandlet();
	bool bImpliesCommandlet = !bCooking || IsRunningCommandlet();
	return bCooking == bExpectCookCommandlet && bImpliesCommandlet;
}
/** @end */
/**
 * @begin is-running-dlc-cook-commandlet
 * @summary or own a commandlet instance.
 * @topic Unreal
 */
/**
 * @function ObserveIsRunningDLCCookCommandletNominal
 * @summary or own a commandlet instance.
 * @covers CoreGlobals.is-running-dlc-cook-commandlet
 * @inputs CoreGlobals values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsRunningDLCCookCommandletNominal(bool bExpectDlcCookCommandlet)
{
	bool bDlcCook = IsRunningDLCCookCommandlet();
	bool bImpliesCook = !bDlcCook || IsRunningCookCommandlet();
	return bDlcCook == bExpectDlcCookCommandlet && bImpliesCook;
}
/** @end */
/**
 * @begin get-running-commandlet-class
 * @summary or own a commandlet instance.
 * @topic Unreal
 */
/**
 * @function ObserveGetRunningCommandletClassNominal
 * @summary or own a commandlet instance.
 * @covers CoreGlobals.get-running-commandlet-class
 * @inputs CoreGlobals values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetRunningCommandletClassNominal(bool bExpectCommandlet)
{
	UClass CommandletClass = GetRunningCommandletClass();
	if (bExpectCommandlet)
	{
		return IsRunningCommandlet() && CommandletClass != nullptr;
	}
	return !IsRunningCommandlet() && CommandletClass is null;
}
/** @end */
