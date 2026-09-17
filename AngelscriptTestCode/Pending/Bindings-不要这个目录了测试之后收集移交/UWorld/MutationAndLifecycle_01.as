/**
 * @version v1
 * @summary Observe UWorld.SetGameInstance assigning the associated game instance, including restore of the original handle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UWorld.SetGameInstance assigning the associated game instance, including restore of the original handle.
 * @topic Baseline
 */
// Runner owns World and GameInstance fixtures.
// AS-facing API: void UWorld.SetGameInstance(UGameInstance NewGI);
// Inputs: Runner-owned UWorld, runner-owned UGameInstance, a repeated set of
// that instance, and restore after the write.
// Expected observations: SetGameInstance is visible on GetGameInstance.
// Restoring the captured handle returns the world to its prior association.
// Boundary/ownership: The world does not uniquely own the game instance.
// Missing World or GameInstance is setup failure. SetupOwner=Runner.

namespace TS_UWorld_MutationAndLifecycle_01
{
	bool Observe_SetGameInstance_Nominal(UWorld World, UGameInstance GameInstance)
	{
		if (World is null)
		{
			throw("TS_UWorld_MutationAndLifecycle_01 setup: required World is null");
		}
		if (GameInstance is null)
		{
			throw("TS_UWorld_MutationAndLifecycle_01 setup: required GameInstance is null");
		}
		UGameInstance Original = World.GetGameInstance();
		World.SetGameInstance(GameInstance);
		UGameInstance After = World.GetGameInstance();
		World.SetGameInstance(Original);
		UGameInstance Restored = World.GetGameInstance();
		return After == GameInstance && Restored == Original;
	}
}
/** @end */
