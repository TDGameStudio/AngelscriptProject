// Theme: Gameplay.Net. Positive compile surface: UWorld.GetNetMode.
// C++: AngelscriptCoverageNetworkingTests.cpp::WorldNetModeQueryIsVisible
// Oracle: module compiles; IsNetMode exists.
// Extra: World null returns false. DefaultSafe.

bool IsNetMode(UWorld World, ENetMode ExpectedMode)
{
	return World != null && World.GetNetMode() == ExpectedMode;
}

bool Observe_IsNetMode_NullWorld()
{
	return IsNetMode(null, ENetMode::NM_Standalone) == false;
}

bool Observe_IsNetMode_NullClientBoundary()
{
	return IsNetMode(null, ENetMode::NM_Client) == false;
}
