/**
 * @version v1
 * @summary Observe world tick/startup/teardown, game instance, persistent level, and ULevel actor-array queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe world tick/startup/teardown, game instance, persistent level, and ULevel actor-array queries.
 * @topic Baseline
 */
// Runner owns the World fixture. A null World or PersistentLevel is setup
// failure. Do not call ServerTravel.
// AS-facing API: float32 UWorld.GetDeltaSeconds() const;
// bool UWorld.IsStartingUp() const;
// bool UWorld.IsTearingDown() const;
// UGameInstance UWorld.GetGameInstance() const;
// ALevelScriptActor UWorld.GetLevelScriptActor() const;
// ULevel UWorld.GetPersistentLevel() const;
// ALevelScriptActor ULevel.GetLevelScriptActor() const;
// bool ULevel.IsVisible() const;
// bool ULevel.IsBeingRemoved() const;
// const TArray<AActor>& ULevel.GetActors() const;
// Inputs: Runner-owned UWorld, expected startup/teardown/visibility flags,
// expected game-instance presence, and a follow-up Num() read on the returned
// actor array reference.
// Expected observations: returned bool is the exact comparison. GetActors
// Num is stable across two aliasing reads.
// Boundary/ownership: GetActors aliases level storage; entries may be null.
// GetGameInstance does not transfer ownership. SetupOwner=Runner.

namespace TS_UWorld_Queries_02
{
	bool Observe_GetDeltaSeconds_Nominal(UWorld World, float32 ExpectedMinimum)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_02 setup: required World is null");
		}
		return World.GetDeltaSeconds() >= ExpectedMinimum;
	}

	bool Observe_IsStartingUp_Nominal(UWorld World, bool bExpectStartingUp)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_02 setup: required World is null");
		}
		return World.IsStartingUp() == bExpectStartingUp;
	}

	bool Observe_IsTearingDown_Nominal(UWorld World, bool bExpectTearingDown)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_02 setup: required World is null");
		}
		return World.IsTearingDown() == bExpectTearingDown;
	}

	bool Observe_GetGameInstance_Nominal(UWorld World, bool bExpectInstance)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_02 setup: required World is null");
		}
		UGameInstance GameInstance = World.GetGameInstance();
		if (bExpectInstance)
		{
			return GameInstance != nullptr;
		}
		return GameInstance is null;
	}

	bool Observe_GetLevelScriptActor_Nominal(UWorld World, bool bExpectWorldScript, bool bExpectLevelScript)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_02 setup: required World is null");
		}
		ULevel PersistentLevel = World.GetPersistentLevel();
		if (PersistentLevel is null)
		{
			throw("TS_UWorld_Queries_02 setup: required PersistentLevel is null");
		}
		ALevelScriptActor WorldLevelScript = World.GetLevelScriptActor();
		ALevelScriptActor LevelScript = PersistentLevel.GetLevelScriptActor();
		if (bExpectWorldScript)
		{
			if (WorldLevelScript is null)
			{
				return false;
			}
		}
		else if (WorldLevelScript != nullptr)
		{
			return false;
		}
		if (bExpectLevelScript)
		{
			return LevelScript != nullptr;
		}
		return LevelScript is null;
	}

	bool Observe_GetPersistentLevel_Nominal(UWorld World)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_02 setup: required World is null");
		}
		ULevel PersistentLevel = World.GetPersistentLevel();
		return PersistentLevel != nullptr;
	}

	bool Observe_IsVisible_Nominal(UWorld World, bool bExpectVisible)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_02 setup: required World is null");
		}
		ULevel PersistentLevel = World.GetPersistentLevel();
		if (PersistentLevel is null)
		{
			throw("TS_UWorld_Queries_02 setup: required PersistentLevel is null");
		}
		return PersistentLevel.IsVisible() == bExpectVisible;
	}

	bool Observe_IsBeingRemoved_Nominal(UWorld World, bool bExpectBeingRemoved)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_02 setup: required World is null");
		}
		ULevel PersistentLevel = World.GetPersistentLevel();
		if (PersistentLevel is null)
		{
			throw("TS_UWorld_Queries_02 setup: required PersistentLevel is null");
		}
		return PersistentLevel.IsBeingRemoved() == bExpectBeingRemoved;
	}

	bool Observe_GetActors_Nominal(UWorld World)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_02 setup: required World is null");
		}
		ULevel PersistentLevel = World.GetPersistentLevel();
		if (PersistentLevel is null)
		{
			throw("TS_UWorld_Queries_02 setup: required PersistentLevel is null");
		}
		const TArray<AActor>& Actors = PersistentLevel.GetActors();
		int32 FirstNum = Actors.Num();
		const TArray<AActor>& Alias = PersistentLevel.GetActors();
		int32 SecondNum = Alias.Num();
		return FirstNum == SecondNum && (FirstNum == 0 || Actors[0] == Alias[0]);
	}
}
/** @end */
