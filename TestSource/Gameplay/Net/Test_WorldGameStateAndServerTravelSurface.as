// Theme: Gameplay.Net. Positive compile surface: UWorld.GetGameState and ServerTravel.
// C++: AngelscriptCoverageNetworkingTests.cpp::WorldGameStateAndServerTravelSurface
// Oracle: module compiles; QueryWorldGameState and QueryServerTravelSurface exist.
// Extra: World null returns false. DefaultSafe.

bool QueryWorldGameState(UWorld World)
{
	if (World == null)
		return false;

	AGameStateBase GameState = World.GetGameState();
	return GameState == World.GetGameState();
}

bool QueryServerTravelSurface(UWorld World)
{
	if (World == null)
		return false;

	return World.ServerTravel("/Game/Maps/NetworkingCoverage", false, true);
}

bool Observe_QueryWorldGameState_NullWorld()
{
	return QueryWorldGameState(null) == false;
}

bool Observe_QueryServerTravelSurface_NullWorld()
{
	return QueryServerTravelSurface(null) == false;
}
