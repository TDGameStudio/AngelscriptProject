/**
 * APlayerController.ClientTravel is not exposed to script, so this program is
 * rejected. C++ compiles it as the module ASCoverageNetworking_ClientTravelUnsupported
 * and expects the diagnostic to name ClientTravel. The CSV Positive label is wrong;
 * C++ does not compile this.
 *
 * @Theme Gameplay.Net
 * @Subject Net.ClientTravelUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Net.ClientTravelUnsupported
 * @Provenance Theme: Gameplay.Net. Isolated compile-fail: APlayerController.ClientTravel is not script-facing.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::NetworkConsoleAndClientTravelBoundaries
 * @Provenance CompileAndExpectFailure diagnostic ClientTravel.
 * @Provenance CSV Positive; C++ does not compile. Do not drop ClientTravel.
 */

/**
 * The isolated failing program: APlayerController.ClientTravel has no script-facing
 * signature.
 *
 * @Kind CompileReject
 * @Covers Net.ClientTravelUnsupported
 * @Inputs a player controller whose ClientTravel is invoked
 * @Return does not compile; ClientTravel is a native UFUNCTION boundary
 * @Param Controller the player controller used to invoke ClientTravel
 */
void TryClientTravel(APlayerController Controller)
{
	Controller.ClientTravel("/Game/Maps/NetworkingCoverage", ETravelType::TRAVEL_Absolute);
}
