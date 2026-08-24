// Theme: Gameplay.Net. WorldStory PlayerController connection query mask.
// C++: AngelscriptCoverageNetworkingTests.cpp::PlayerControllerConnectionSurfaceCompiles
// Oracle: class compiles; QueryControllerConnection has 2 object params and int return.
// Bits: IsLocalController 1, IsPlayerController 2, IsLocalPlayerController 4,
// GetPlayerState==nullptr 8, GetLocalPlayer==nullptr 16.
// Extra: both null returns Mask 0. FixtureIsolated.

UCLASS()
class ACoverageNetworkingPlayerControllerConnectionSurface : AActor
{
	UFUNCTION()
	int QueryControllerConnection(AController Controller, APlayerController PlayerController)
	{
		int Mask = 0;

		if (Controller != nullptr)
		{
			if (Controller.IsLocalController())
				Mask |= 1;
			if (Controller.IsPlayerController())
				Mask |= 2;
			if (Controller.IsLocalPlayerController())
				Mask |= 4;
		}

		if (PlayerController != nullptr)
		{
			if (PlayerController.GetPlayerState() == nullptr)
				Mask |= 8;
			if (PlayerController.GetLocalPlayer() == nullptr)
				Mask |= 16;
		}

		return Mask;
	}
}

bool Observe_ControllerConnection_BothNull(ACoverageNetworkingPlayerControllerConnectionSurface Actor)
{
	if (Actor is null)
	{
		throw("Test_PlayerControllerConnectionSurfaceCompiles setup: required Actor is null");
	}
	return Actor.QueryControllerConnection(nullptr, nullptr) == 0;
}
