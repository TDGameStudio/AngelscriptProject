/**
 * @version v1
 * @summary Observe local-player create/add/remove lifecycle, including OutError writeback on both CreateLocalPlayer overloads.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe local-player create/add/remove lifecycle, including OutError writeback on both CreateLocalPlayer overloads.
 * @topic Baseline
 */
// Runner owns the GameInstance fixture. Null GameInstance is setup failure.
// AS-facing API: ULocalPlayer UGameInstance.CreateInitialPlayer(FString& OutError);
// ULocalPlayer UGameInstance.CreateLocalPlayer(int32 ControllerId, FString& OutError, bool bSpawnPlayerController);
// ULocalPlayer UGameInstance.CreateLocalPlayer(FPlatformUserId UserId, FString& OutError, bool bSpawnPlayerController);
// int32 UGameInstance.AddLocalPlayer(ULocalPlayer NewPlayer, FPlatformUserId UserId);
// bool UGameInstance.RemoveLocalPlayer(ULocalPlayer ExistingPlayer);
// Inputs: Runner-owned game instance, empty OutError, controller id 7,
// default FPlatformUserId, bSpawnPlayerController false, and a null
// instance as the diagnostic path.
// Expected observations: Successful create matches bExpectPlayer and grows
// GetNumLocalPlayers when a player is returned. RemoveLocalPlayer is true
// after a successful add of that created player, false for a null player.
// Created players are removed before return when this file added them.
// Boundary/ownership: Created players are owned by the game instance.
// RemoveLocalPlayer does not delete the UObject immediately. SetupOwner=Runner.

namespace TS_UGameInstance_MutationAndLifecycle_01
{
	bool Observe_CreateInitialPlayer_Nominal(UGameInstance GameInstance, bool bExpectPlayer)
	{
		if (GameInstance is null)
		{
			throw("TS_UGameInstance_MutationAndLifecycle_01 setup: required GameInstance is null");
		}
		int32 Before = GameInstance.GetNumLocalPlayers();
		FString OutError;
		ULocalPlayer Initial = GameInstance.CreateInitialPlayer(OutError);
		int32 After = GameInstance.GetNumLocalPlayers();
		bool bCreated = Initial != nullptr;
		if (After > Before && Initial != nullptr)
		{
			GameInstance.RemoveLocalPlayer(Initial);
		}
		return bCreated == bExpectPlayer;
	}

	bool Observe_CreateLocalPlayer_Nominal(UGameInstance GameInstance, bool bExpectPlayer)
	{
		if (GameInstance is null)
		{
			throw("TS_UGameInstance_MutationAndLifecycle_01 setup: required GameInstance is null");
		}
		FString ControllerError;
		ULocalPlayer FromController = GameInstance.CreateLocalPlayer(7, ControllerError, false);
		bool bCreated = FromController != nullptr;
		if (FromController != nullptr)
		{
			GameInstance.RemoveLocalPlayer(FromController);
		}

		FString SpawnError;
		ULocalPlayer SpawnedController = GameInstance.CreateLocalPlayer(8, SpawnError, true);
		if (SpawnedController != nullptr)
		{
			GameInstance.RemoveLocalPlayer(SpawnedController);
		}

		FPlatformUserId UserId;
		FString UserError;
		ULocalPlayer FromUser = GameInstance.CreateLocalPlayer(UserId, UserError, false);
		if (FromUser != nullptr)
		{
			GameInstance.RemoveLocalPlayer(FromUser);
		}
		ULocalPlayer FromUserSpawned = GameInstance.CreateLocalPlayer(UserId, UserError, true);
		if (FromUserSpawned != nullptr)
		{
			GameInstance.RemoveLocalPlayer(FromUserSpawned);
		}

		return bCreated == bExpectPlayer;
	}

	bool Observe_AddLocalPlayer_Nominal(UGameInstance GameInstance)
	{
		if (GameInstance is null)
		{
			throw("TS_UGameInstance_MutationAndLifecycle_01 setup: required GameInstance is null");
		}
		FString OutError;
		int32 Before = GameInstance.GetNumLocalPlayers();
		ULocalPlayer Created = GameInstance.CreateLocalPlayer(9, OutError, false);
		FPlatformUserId UserId;
		int32 AddedIndex = GameInstance.AddLocalPlayer(Created, UserId);
		int32 NullIndex = GameInstance.AddLocalPlayer(nullptr, UserId);
		if (Created != nullptr)
		{
			GameInstance.RemoveLocalPlayer(Created);
		}
		if (Created is null)
		{
			return NullIndex < 0;
		}
		return AddedIndex >= 0 && NullIndex < 0 && GameInstance.GetNumLocalPlayers() == Before;
	}

	bool Observe_RemoveLocalPlayer_Nominal(UGameInstance GameInstance)
	{
		if (GameInstance is null)
		{
			throw("TS_UGameInstance_MutationAndLifecycle_01 setup: required GameInstance is null");
		}
		FString OutError;
		ULocalPlayer Created = GameInstance.CreateLocalPlayer(10, OutError, false);
		bool bRemovedCreated = false;
		if (Created != nullptr)
		{
			bRemovedCreated = GameInstance.RemoveLocalPlayer(Created);
		}
		bool bRemovedNull = GameInstance.RemoveLocalPlayer(nullptr);
		if (Created is null)
		{
			return !bRemovedNull;
		}
		return bRemovedCreated && !bRemovedNull;
	}

	void ExerciseExpectedFailure()
	{
		UGameInstance NullInstance;
		FString OutError;
		ULocalPlayer Created = NullInstance.CreateInitialPlayer(OutError);
	}
}
/** @end */
