/**
 * @version v1
 * @summary Observe ULocalPlayer game-instance and controller-id queries on a runner-owned local-player handle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe ULocalPlayer game-instance and controller-id queries on a runner-owned local-player handle.
 * @topic Baseline
 */
// int32 LocalPlayer.GetControllerId() const;
// Inputs: Runner-owned ULocalPlayer, expected UGameInstance, and expected
// controller id.
// Expected observations: GetGameInstance matches ExpectedInstance.
// GetControllerId equals ExpectedControllerId and FindLocalPlayerFromControllerId
// round-trips to the same player.
// Boundary/ownership: GetGameInstance does not transfer ownership. Controller
// id is the platform/controller identifier, not a net GUID. Null LocalPlayer
// is setup failure. SetupOwner=Runner. CleanupOwner=Runner.

namespace TS_ULocalPlayer_Queries_01
{
	bool Observe_GetGameInstance_Nominal(ULocalPlayer LocalPlayer, UGameInstance ExpectedInstance)
	{
		if (LocalPlayer is null)
		{
			throw("TS_ULocalPlayer_Queries_01 setup: required LocalPlayer is null");
		}
		return LocalPlayer.GetGameInstance() == ExpectedInstance;
	}

	bool Observe_GetControllerId_Nominal(ULocalPlayer LocalPlayer, int32 ExpectedControllerId)
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
}
/** @end */
