/**
 * @version v1
 * @summary Observe UGameInstance.GetLocalPlayerByIndex for empty, first, last, and invalid-index access.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UGameInstance.GetLocalPlayerByIndex for empty, first, last, and invalid-index access.
 * @topic Baseline
 */
// Runner owns the GameInstance fixture. Null GameInstance is setup failure.
// AS-facing API: ULocalPlayer UGameInstance.GetLocalPlayerByIndex(const int32 Index) const;
// Inputs: Runner-owned game instance, requested Index, and Expected local
// player. Index -1 is the invalid-index diagnostic.
// Expected observations: GetLocalPlayerByIndex(Index) equals Expected.
// Identity of index 0 matches GetFirstGamePlayer when that player exists.
// Boundary/ownership: The returned ULocalPlayer is not owned by the caller.
// Invalid Index is the expected-failure path. SetupOwner=Runner.

namespace TS_UGameInstance_IndexAndIteration_01
{
	bool Observe_GetLocalPlayerByIndex_Nominal(UGameInstance GameInstance, int32 Index, ULocalPlayer Expected)
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

	void ExerciseExpectedFailure()
	{
		UWorld World = GetCurrentWorld();
		UGameInstance GameInstance = World.GetGameInstance();
		ULocalPlayer Invalid = GameInstance.GetLocalPlayerByIndex(-1);
	}
}
/** @end */
