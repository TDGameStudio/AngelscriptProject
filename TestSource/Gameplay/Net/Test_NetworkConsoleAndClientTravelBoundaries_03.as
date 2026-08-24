// Theme: Gameplay.Net. Isolated compile-fail: APlayerController.ClientTravel is not script-facing.
// C++: AngelscriptCoverageNetworkingTests.cpp::NetworkConsoleAndClientTravelBoundaries
// CompileAndExpectFailure diagnostic ClientTravel.
// CSV Positive; C++ does not compile. Do not drop ClientTravel.

void TryClientTravel(APlayerController Controller)
{
	Controller.ClientTravel("/Game/Maps/NetworkingCoverage", ETravelType::TRAVEL_Absolute);
}
