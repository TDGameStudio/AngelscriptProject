/**
 * @version v1
 * @summary PlayerController connection queries packed into a bitmask. C++ compiles the class and checks QueryControllerConnection, so that name is part of the contract and is kept verbatim. The observer covers both arguments being.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary PlayerController connection queries packed into a bitmask. C++ compiles the class and checks QueryControllerConnection, so that name is part of the contract and is kept verbatim. The observer covers both arguments being.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingPlayerControllerConnectionSurface : AActor
{
	/**
	 * Collect controller and player-controller connection queries into one bitmask.
	 *
	 * @Kind Observe
	 * @Covers Net.PlayerControllerConnectionSurfaceCompiles
	 * @Inputs a controller and a player controller, either of which may be null
	 * @Return the mask, with a bit per query that reports true or a null identity
	 * @Param Controller the controller to query
	 * @Param PlayerController the player controller to query
	 */
	UFUNCTION()
	int QueryControllerConnection(AController Controller, APlayerController PlayerController)
	{
		int Mask = 0;

		if (Controller != nullptr)
		{
			if (Controller.IsLocalController())
			{
				Mask |= 1;
			}
			if (Controller.IsPlayerController())
			{
				Mask |= 2;
			}
			if (Controller.IsLocalPlayerController())
			{
				Mask |= 4;
			}
		}

		if (PlayerController != nullptr)
		{
			if (PlayerController.GetPlayerState() == nullptr)
			{
				Mask |= 8;
			}
			if (PlayerController.GetLocalPlayer() == nullptr)
			{
				Mask |= 16;
			}
		}

		return Mask;
	}

	/**
	 * Observe that two null arguments produce mask 0.
	 *
	 * @Kind Observe
	 * @Covers Net.PlayerControllerConnectionSurfaceCompiles
	 * @Inputs two null arguments
	 * @Return true when QueryControllerConnection of null, null is 0
	 * @Boundary both null
	 */
	UFUNCTION()
	bool BothNull()
	{
		return QueryControllerConnection(nullptr, nullptr) == 0;
	}
}
/** @end */
