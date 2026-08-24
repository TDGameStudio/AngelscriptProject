// Purpose: Observe controller/player-controller pawn, locality, rotation,
// local player, player state, camera manager, and pawn controller queries.
// Runner owns live Controller/Pawn fixtures and teardown. A null required
// fixture is setup failure.
// AS-facing API: APawn Controller.GetPawn() const;
// ACharacter Controller.GetCharacter() const;
// bool Controller.IsLocalController() const;
// bool Controller.IsPlayerController() const;
// bool Controller.IsLocalPlayerController() const;
// FRotator Controller.GetControlRotation() const;
// ULocalPlayer PlayerController.GetLocalPlayer() const;
// APlayerState PlayerController.GetPlayerState() const;
// APlayerCameraManager PlayerController.GetPlayerCameraManager() const;
// AController Pawn.GetController() const;
// Inputs: Runner-supplied APlayerController/APawn plus CDO negative state.
// Expected observations: returned bool is the exact comparison against the
// runner-supplied expected handle or flag. APlayerController.IsPlayerController
// is true; AController CDO is false.
// Boundary/ownership: SetupOwner=Runner. CleanupOwner=Runner. Handles are
// borrowed. Do not mutate CDOs.

namespace TS_APlayerController_Queries_01
{
	bool Observe_GetPawn_Nominal(APlayerController Controller, APawn Expected)
	{
		if (Controller is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller is null");
		}
		TSubclassOf<APlayerController> ControllerClass = APlayerController::StaticClass();
		APlayerController Cdo = ControllerClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller CDO is null");
		}
		return Cdo.GetPawn() is null && Controller.GetPawn() == Expected;
	}

	bool Observe_GetCharacter_Nominal(APlayerController Controller, ACharacter Expected)
	{
		if (Controller is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller is null");
		}
		TSubclassOf<APlayerController> ControllerClass = APlayerController::StaticClass();
		APlayerController Cdo = ControllerClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller CDO is null");
		}
		return Cdo.GetCharacter() is null && Controller.GetCharacter() == Expected;
	}

	bool Observe_IsLocalController_Nominal(APlayerController Controller, bool bExpectLocal)
	{
		if (Controller is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller is null");
		}
		TSubclassOf<APlayerController> ControllerClass = APlayerController::StaticClass();
		APlayerController Cdo = ControllerClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller CDO is null");
		}
		return !Cdo.IsLocalController() && Controller.IsLocalController() == bExpectLocal;
	}

	bool Observe_IsPlayerController_Nominal(APlayerController Controller)
	{
		if (Controller is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller is null");
		}
		TSubclassOf<AController> ControllerClass = AController::StaticClass();
		AController Cdo = ControllerClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller CDO is null");
		}
		return Controller.IsPlayerController() && !Cdo.IsPlayerController();
	}

	bool Observe_IsLocalPlayerController_Nominal(APlayerController Controller, bool bExpectLocalPlayer)
	{
		if (Controller is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller is null");
		}
		TSubclassOf<AController> ControllerClass = AController::StaticClass();
		AController Cdo = ControllerClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller CDO is null");
		}
		return !Cdo.IsLocalPlayerController() && Controller.IsLocalPlayerController() == bExpectLocalPlayer;
	}

	bool Observe_GetControlRotation_Nominal(APlayerController Controller, const FRotator& Expected)
	{
		if (Controller is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller is null");
		}
		return Controller.GetControlRotation().Equals(Expected, 0.01);
	}

	bool Observe_GetLocalPlayer_Nominal(APlayerController Controller, ULocalPlayer Expected)
	{
		if (Controller is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller is null");
		}
		TSubclassOf<APlayerController> ControllerClass = APlayerController::StaticClass();
		APlayerController Cdo = ControllerClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller CDO is null");
		}
		return Cdo.GetLocalPlayer() is null && Controller.GetLocalPlayer() == Expected;
	}

	bool Observe_GetPlayerState_Nominal(APlayerController Controller, APlayerState Expected)
	{
		if (Controller is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller is null");
		}
		TSubclassOf<APlayerController> ControllerClass = APlayerController::StaticClass();
		APlayerController Cdo = ControllerClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller CDO is null");
		}
		return Cdo.GetPlayerState() is null && Controller.GetPlayerState() == Expected;
	}

	bool Observe_GetPlayerCameraManager_Nominal(APlayerController Controller, APlayerCameraManager Expected)
	{
		if (Controller is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller is null");
		}
		TSubclassOf<APlayerController> ControllerClass = APlayerController::StaticClass();
		APlayerController Cdo = ControllerClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Controller CDO is null");
		}
		return Cdo.GetPlayerCameraManager() is null && Controller.GetPlayerCameraManager() == Expected;
	}

	bool Observe_GetController_Nominal(APawn Pawn, AController Expected)
	{
		if (Pawn is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Pawn is null");
		}
		TSubclassOf<APawn> PawnClass = APawn::StaticClass();
		APawn Cdo = PawnClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_01 setup: required Pawn CDO is null");
		}
		return Cdo.GetController() is null && Pawn.GetController() == Expected;
	}
}
