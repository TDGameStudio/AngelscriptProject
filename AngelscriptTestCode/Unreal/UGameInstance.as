/**
 * @version v1
 * @summary UGameInstance host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UGameInstance
 *
 * get-local-player-by-index
 * create-initial-player
 * create-local-player
 * add-local-player
 * remove-local-player
 * get-num-local-players
 * get-first-local-player-controller
 * find-local-player-from-controller-id
 * find-local-player-from-unique-net-id
 * get-first-game-player
 */
/**
 * @begin get-local-player-by-index
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveGetLocalPlayerByIndexNominal
 * @summary Expected
 * @covers UGameInstance.get-local-player-by-index
 * @inputs UGameInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: GetLocalPlayerByIndex(Index) equals Expected.
// Identity of index 0 matches GetFirstGamePlayer when that player exists.
// Boundary/ownership: The returned ULocalPlayer is not owned by the caller.
// Invalid Index is the expected-failure path. SetupOwner=Runner.
bool ObserveGetLocalPlayerByIndexNominal(UGameInstance GameInstance, int32 Index, ULocalPlayer Expected)
{
	if (GameInstance is null)
	{
		throw("TS_UGameInstance_IndexAndIteration_01 setup: required GameInstance is null");
	}
	ULocalPlayer AtIndex = GameInstance.GetLocalPlayerByIndex(Index);
	ULocalPlayer FirstGame = GameInstance.GetFirstGamePlayer();
	if (Index == 0)
	{
		return AtIndex == Expected && AtIndex == FirstGame;
	}
	return AtIndex == Expected;
}
/** @end */
/**
 * @begin create-initial-player
 * @summary RemoveLocalPlayer does not delete the UObject immediately.
 * @topic Unreal
 */
/**
 * @function ObserveCreateInitialPlayerNominal
 * @summary RemoveLocalPlayer does not delete the UObject immediately.
 * @covers UGameInstance.create-initial-player
 * @inputs UGameInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCreateInitialPlayerNominal(UGameInstance GameInstance, bool bExpectPlayer)
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
/** @end */
/**
 * @begin create-local-player
 * @summary RemoveLocalPlayer does not delete the UObject immediately.
 * @topic Unreal
 */
/**
 * @function ObserveCreateLocalPlayerNominal
 * @summary RemoveLocalPlayer does not delete the UObject immediately.
 * @covers UGameInstance.create-local-player
 * @inputs UGameInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCreateLocalPlayerNominal(UGameInstance GameInstance, bool bExpectPlayer)
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
/** @end */
/**
 * @begin add-local-player
 * @summary RemoveLocalPlayer does not delete the UObject immediately.
 * @topic Unreal
 */
/**
 * @function ObserveAddLocalPlayerNominal
 * @summary RemoveLocalPlayer does not delete the UObject immediately.
 * @covers UGameInstance.add-local-player
 * @inputs UGameInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddLocalPlayerNominal(UGameInstance GameInstance)
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
/** @end */
/**
 * @begin remove-local-player
 * @summary RemoveLocalPlayer does not delete the UObject immediately.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveLocalPlayerNominal
 * @summary RemoveLocalPlayer does not delete the UObject immediately.
 * @covers UGameInstance.remove-local-player
 * @inputs UGameInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRemoveLocalPlayerNominal(UGameInstance GameInstance)
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
/** @end */
/**
 * @begin get-num-local-players
 * @summary is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveGetNumLocalPlayersNominal
 * @summary is the expected-failure path.
 * @covers UGameInstance.get-num-local-players
 * @inputs UGameInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNumLocalPlayersNominal(UGameInstance GameInstance, int32 ExpectedCount)
{
	if (GameInstance is null)
	{
		throw("TS_UGameInstance_Queries_01 setup: required GameInstance is null");
	}
	return GameInstance.GetNumLocalPlayers() == ExpectedCount;
}
/** @end */
/**
 * @begin get-first-local-player-controller
 * @summary is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveGetFirstLocalPlayerControllerNominal
 * @summary is the expected-failure path.
 * @covers UGameInstance.get-first-local-player-controller
 * @inputs UGameInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetFirstLocalPlayerControllerNominal(UGameInstance GameInstance, UWorld World, APlayerController Expected)
{
	if (GameInstance is null)
	{
		throw("TS_UGameInstance_Queries_01 setup: required GameInstance is null");
	}
	APlayerController DefaultWorld = GameInstance.GetFirstLocalPlayerController();
	APlayerController ExplicitWorld = GameInstance.GetFirstLocalPlayerController(World);
	return DefaultWorld == Expected && ExplicitWorld == Expected;
}
/** @end */
/**
 * @begin find-local-player-from-controller-id
 * @summary is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveFindLocalPlayerFromControllerIdNominal
 * @summary is the expected-failure path.
 * @covers UGameInstance.find-local-player-from-controller-id
 * @inputs UGameInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFindLocalPlayerFromControllerIdNominal(UGameInstance GameInstance, int32 ControllerId, ULocalPlayer Expected)
{
	if (GameInstance is null)
	{
		throw("TS_UGameInstance_Queries_01 setup: required GameInstance is null");
	}
	ULocalPlayer Found = GameInstance.FindLocalPlayerFromControllerId(ControllerId);
	ULocalPlayer Missing = GameInstance.FindLocalPlayerFromControllerId(99);
	return Found == Expected && Missing is null;
}
/** @end */
/**
 * @begin find-local-player-from-unique-net-id
 * @summary is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveFindLocalPlayerFromUniqueNetIdNominal
 * @summary is the expected-failure path.
 * @covers UGameInstance.find-local-player-from-unique-net-id
 * @inputs UGameInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFindLocalPlayerFromUniqueNetIdNominal(UGameInstance GameInstance)
{
	if (GameInstance is null)
	{
		throw("TS_UGameInstance_Queries_01 setup: required GameInstance is null");
	}
	FUniqueNetIdRepl UniqueNetId;
	ULocalPlayer EmptyId = GameInstance.FindLocalPlayerFromUniqueNetId(UniqueNetId);
	return EmptyId is null;
}
/** @end */
/**
 * @begin get-first-game-player
 * @summary is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveGetFirstGamePlayerNominal
 * @summary is the expected-failure path.
 * @covers UGameInstance.get-first-game-player
 * @inputs UGameInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetFirstGamePlayerNominal(UGameInstance GameInstance, ULocalPlayer Expected)
{
	if (GameInstance is null)
	{
		throw("TS_UGameInstance_Queries_01 setup: required GameInstance is null");
	}
	ULocalPlayer First = GameInstance.GetFirstGamePlayer();
	ULocalPlayer IndexZero = GameInstance.GetLocalPlayerByIndex(0);
	return First == Expected && First == IndexZero;
}
/** @end */
