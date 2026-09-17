/**
 * @version v1
 * @summary Observe local-player count and lookup queries on a runner-owned game instance, including missing keys.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe local-player count and lookup queries on a runner-owned game instance, including missing keys.
 * @topic Baseline
 */
// APlayerController UGameInstance.GetFirstLocalPlayerController(const UWorld World = nullptr) const;
// ULocalPlayer UGameInstance.FindLocalPlayerFromControllerId(const int32 ControllerId) const;
// ULocalPlayer UGameInstance.FindLocalPlayerFromUniqueNetId(const FUniqueNetIdRepl& UniqueNetId) const;
// ULocalPlayer UGameInstance.GetFirstGamePlayer() const;
// Inputs: Runner-owned GameInstance and World, expected count/controller/
// player handles, controller id 0, empty FUniqueNetIdRepl, and a missing
// controller id.
// Expected observations: GetNumLocalPlayers equals ExpectedCount.
// GetFirstLocalPlayerController with omitted world and with the current world
// both equal ExpectedController. Empty unique-net-id lookup is null.
// GetFirstGamePlayer equals index 0.
// Boundary/ownership: Lookups do not add players. Default World argument uses
// the game instance's own world resolution. Invalid lookup on a null instance
// is the expected-failure path. SetupOwner=Runner.

namespace TS_UGameInstance_Queries_01
{
	bool Observe_GetNumLocalPlayers_Nominal(UGameInstance GameInstance, int32 ExpectedCount)
	{
		if (GameInstance is null)
		{
			throw("TS_UGameInstance_Queries_01 setup: required GameInstance is null");
		}
		return GameInstance.GetNumLocalPlayers() == ExpectedCount;
	}

	bool Observe_GetFirstLocalPlayerController_Nominal(UGameInstance GameInstance, UWorld World, APlayerController Expected)
	{
		if (GameInstance is null)
		{
			throw("TS_UGameInstance_Queries_01 setup: required GameInstance is null");
		}
		APlayerController DefaultWorld = GameInstance.GetFirstLocalPlayerController();
		APlayerController ExplicitWorld = GameInstance.GetFirstLocalPlayerController(World);
		return DefaultWorld == Expected && ExplicitWorld == Expected;
	}

	bool Observe_FindLocalPlayerFromControllerId_Nominal(UGameInstance GameInstance, int32 ControllerId, ULocalPlayer Expected)
	{
		if (GameInstance is null)
		{
			throw("TS_UGameInstance_Queries_01 setup: required GameInstance is null");
		}
		ULocalPlayer Found = GameInstance.FindLocalPlayerFromControllerId(ControllerId);
		ULocalPlayer Missing = GameInstance.FindLocalPlayerFromControllerId(99);
		return Found == Expected && Missing is null;
	}

	bool Observe_FindLocalPlayerFromUniqueNetId_Nominal(UGameInstance GameInstance)
	{
		if (GameInstance is null)
		{
			throw("TS_UGameInstance_Queries_01 setup: required GameInstance is null");
		}
		FUniqueNetIdRepl UniqueNetId;
		ULocalPlayer EmptyId = GameInstance.FindLocalPlayerFromUniqueNetId(UniqueNetId);
		return EmptyId is null;
	}

	bool Observe_GetFirstGamePlayer_Nominal(UGameInstance GameInstance, ULocalPlayer Expected)
	{
		if (GameInstance is null)
		{
			throw("TS_UGameInstance_Queries_01 setup: required GameInstance is null");
		}
		ULocalPlayer First = GameInstance.GetFirstGamePlayer();
		ULocalPlayer IndexZero = GameInstance.GetLocalPlayerByIndex(0);
		return First == Expected && First == IndexZero;
	}

	void ExerciseExpectedFailure()
	{
		UGameInstance NullInstance;
		APlayerController Missing = NullInstance.GetFirstLocalPlayerController();
	}
}
/** @end */
