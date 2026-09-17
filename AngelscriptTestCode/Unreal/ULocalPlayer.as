/**
 * @version v1
 * @summary ULocalPlayer host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic ULocalPlayer
 *
 * get-game-instance
 * get-controller-id
 */
/**
 * @begin get-game-instance
 * @summary is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetGameInstanceNominal
 * @summary is setup failure.
 * @covers ULocalPlayer.get-game-instance
 * @inputs ULocalPlayer values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetGameInstanceNominal(ULocalPlayer LocalPlayer, UGameInstance ExpectedInstance)
{
	if (LocalPlayer is null)
	{
		throw("TS_ULocalPlayer_Queries_01 setup: required LocalPlayer is null");
	}
	return LocalPlayer.GetGameInstance() == ExpectedInstance;
}
/** @end */
/**
 * @begin get-controller-id
 * @summary is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetControllerIdNominal
 * @summary is setup failure.
 * @covers ULocalPlayer.get-controller-id
 * @inputs ULocalPlayer values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetControllerIdNominal(ULocalPlayer LocalPlayer, int32 ExpectedControllerId)
{
	if (LocalPlayer is null)
	{
		throw("TS_ULocalPlayer_Queries_01 setup: required LocalPlayer is null");
	}
	int32 ControllerId = LocalPlayer.GetControllerId();
	UGameInstance GameInstance = LocalPlayer.GetGameInstance();
	if (GameInstance is null)
	{
		throw("TS_ULocalPlayer_Queries_01 setup: required GameInstance is null");
	}
	ULocalPlayer ByController = GameInstance.FindLocalPlayerFromControllerId(ControllerId);
	return ControllerId == ExpectedControllerId && ByController == LocalPlayer;
}
/** @end */
