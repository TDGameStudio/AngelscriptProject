/**
 * UWorld.GetGameState and UWorld.ServerTravel as a compile-visible surface. C++
 * compiles the module and looks up QueryWorldGameState and QueryServerTravelSurface
 * by name, so those names are part of the contract and are kept verbatim. The
 * observers cover a null world.
 *
 * @Theme Gameplay.Net
 * @Subject Net.WorldGameStateAndServerTravelSurface
 * @Harness Function
 * @Tag Gameplay.Net.WorldGameStateAndServerTravelSurface
 * @Namespace NetTest
 * @Provenance Theme: Gameplay.Net. Positive compile surface: UWorld.GetGameState and ServerTravel.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::WorldGameStateAndServerTravelSurface
 * @Provenance Oracle: module compiles; QueryWorldGameState and QueryServerTravelSurface exist.
 * @Provenance Extra: World null returns false. DefaultSafe.
 */

namespace NetTest
{
	/**
	 * Read GameState twice from a world and compare the two handles.
	 *
	 * @Kind Observe
	 * @Covers Net.WorldGameStateAndServerTravelSurface
	 * @Inputs a world, which may be null
	 * @Return false when World is null, otherwise whether the two GetGameState results agree
	 * @Param World the world to query
	 */
	UFUNCTION()
	bool QueryWorldGameState(UWorld World)
	{
		if (World == null)
		{
			return false;
		}

		AGameStateBase GameState = World.GetGameState();
		return GameState == World.GetGameState();
	}

	/**
	 * Invoke ServerTravel on a world.
	 *
	 * @Kind Observe
	 * @Covers Net.WorldGameStateAndServerTravelSurface
	 * @Inputs a world, which may be null
	 * @Return false when World is null, otherwise the ServerTravel result
	 * @Param World the world to travel
	 */
	UFUNCTION()
	bool QueryServerTravelSurface(UWorld World)
	{
		if (World == null)
		{
			return false;
		}

		return World.ServerTravel("/Game/Maps/NetworkingCoverage", false, true);
	}

	/**
	 * Observe that a null world is refused by the GameState query.
	 *
	 * @Kind Observe
	 * @Covers Net.WorldGameStateAndServerTravelSurface
	 * @Inputs a null world
	 * @Return true when QueryWorldGameState of null is false
	 * @Boundary null world
	 */
	UFUNCTION()
	bool NullWorldGameState()
	{
		return QueryWorldGameState(null) == false;
	}

	/**
	 * Observe that a null world is refused by the ServerTravel query.
	 *
	 * @Kind Observe
	 * @Covers Net.WorldGameStateAndServerTravelSurface
	 * @Inputs a null world
	 * @Return true when QueryServerTravelSurface of null is false
	 * @Boundary null world
	 */
	UFUNCTION()
	bool NullWorldServerTravel()
	{
		return QueryServerTravelSurface(null) == false;
	}
}
