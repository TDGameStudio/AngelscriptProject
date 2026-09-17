/**
 * @version v1
 * @summary APlayerController host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic APlayerController
 *
 * set-control-rotation
 * set-player
 * set-view-target-with-blend
 * add-movement-input
 * add-controller-yaw-input
 * add-controller-pitch-input
 * get-pawn
 * get-character
 * is-local-controller
 * is-player-controller
 * is-local-player-controller
 * get-control-rotation
 * get-local-player
 * get-player-state
 * get-player-camera-manager
 * get-controller
 * get-player-controller
 * is-locally-controlled
 * is-player-controlled
 * is-bot-controlled
 * APlayerController-Queries_02-get-player-state
 */
/**
 * @begin set-control-rotation
 * @summary check.
 * @topic Unreal
 */
/**
 * @function ObserveSetControlRotationNominal
 * @summary check.
 * @covers APlayerController.set-control-rotation
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetControlRotationNominal(APlayerController Controller)
{
	if (Controller is null)
	{
		throw("TS_APlayerController_MutationAndLifecycle_01 setup: required Controller is null");
	}
	FRotator Before = Controller.GetControlRotation();
	FRotator NewRotation(0.0, 90.0, 0.0);
	Controller.SetControlRotation(NewRotation);
	FRotator After = Controller.GetControlRotation();
	Controller.SetControlRotation(Before);
	return After.Equals(NewRotation, 0.01);
}
/** @end */
/**
 * @begin set-player
 * @summary check.
 * @topic Unreal
 */
/**
 * @function ObserveSetPlayerNominal
 * @summary check.
 * @covers APlayerController.set-player
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetPlayerNominal(APlayerController Controller)
{
	if (Controller is null)
	{
		throw("TS_APlayerController_MutationAndLifecycle_01 setup: required Controller is null");
	}
	ULocalPlayer Before = Controller.GetLocalPlayer();
	UPlayer NullPlayer;
	Controller.SetPlayer(NullPlayer);
	ULocalPlayer After = Controller.GetLocalPlayer();
	if (Before != nullptr)
	{
		Controller.SetPlayer(Before);
	}
	return After is null;
}
/** @end */
/**
 * @begin set-view-target-with-blend
 * @summary check.
 * @topic Unreal
 */
/**
 * @function ObserveSetViewTargetWithBlendNominal
 * @summary check.
 * @covers APlayerController.set-view-target-with-blend
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetViewTargetWithBlendNominal(APlayerController Controller, AActor ViewTarget)
{
	if (Controller is null)
	{
		throw("TS_APlayerController_MutationAndLifecycle_01 setup: required Controller is null");
	}
	if (ViewTarget is null)
	{
		throw("TS_APlayerController_MutationAndLifecycle_01 setup: required ViewTarget is null");
	}
	APlayerCameraManager Manager = Controller.GetPlayerCameraManager();
	Controller.SetViewTargetWithBlend(ViewTarget);
	Controller.SetViewTargetWithBlend(ViewTarget, 0.1);
	Controller.SetViewTargetWithBlend(ViewTarget, 0.1, EViewTargetBlendFunction::VTBlend_Linear);
	Controller.SetViewTargetWithBlend(ViewTarget, 0.1, EViewTargetBlendFunction::VTBlend_Linear, 0.0);
	Controller.SetViewTargetWithBlend(ViewTarget, 0.1, EViewTargetBlendFunction::VTBlend_Linear, 0.0, false);
	Controller.SetViewTargetWithBlend(ViewTarget, 0.0, EViewTargetBlendFunction::VTBlend_Linear, 2.0, true);
	AActor NullTarget;
	Controller.SetViewTargetWithBlend(NullTarget);
	return ViewTarget.IsActorInitialized() && Controller.GetPlayerCameraManager() == Manager;
}
/** @end */
/**
 * @begin add-movement-input
 * @summary check.
 * @topic Unreal
 */
/**
 * @function ObserveAddMovementInputNominal
 * @summary check.
 * @covers APlayerController.add-movement-input
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddMovementInputNominal(APawn Pawn)
{
	if (Pawn is null)
	{
		throw("TS_APlayerController_MutationAndLifecycle_01 setup: required Pawn is null");
	}
	FVector Before = Pawn.GetActorLocation();
	Pawn.AddMovementInput(FVector(1.0, 0.0, 0.0));
	Pawn.AddMovementInput(FVector(0.0, 1.0, 0.0), 0.5);
	Pawn.AddMovementInput(FVector::ZeroVector, 1.0, false);
	Pawn.AddMovementInput(FVector(1.0, 0.0, 0.0), 1.0, true);
	FVector After = Pawn.GetActorLocation();
	return After.Equals(Before) && Pawn.IsActorInitialized();
}
/** @end */
/**
 * @begin add-controller-yaw-input
 * @summary check.
 * @topic Unreal
 */
/**
 * @function ObserveAddControllerYawInputNominal
 * @summary check.
 * @covers APlayerController.add-controller-yaw-input
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddControllerYawInputNominal(APawn Pawn)
{
	if (Pawn is null)
	{
		throw("TS_APlayerController_MutationAndLifecycle_01 setup: required Pawn is null");
	}
	AController Controller = Pawn.GetController();
	if (Controller is null)
	{
		throw("TS_APlayerController_MutationAndLifecycle_01 setup: required Controller is null");
	}
	FRotator Before = Controller.GetControlRotation();
	Pawn.AddControllerYawInput(1.5);
	FRotator AfterPositive = Controller.GetControlRotation();
	Pawn.AddControllerYawInput(0.0);
	FRotator AfterZero = Controller.GetControlRotation();
	Pawn.AddControllerYawInput(-1.5);
	FRotator AfterNegative = Controller.GetControlRotation();
	Controller.SetControlRotation(Before);
	return !AfterPositive.Equals(Before, 0.01) && AfterZero.Equals(AfterPositive, 0.01) && !AfterNegative.Equals(AfterPositive, 0.01);
}
/** @end */
/**
 * @begin add-controller-pitch-input
 * @summary check.
 * @topic Unreal
 */
/**
 * @function ObserveAddControllerPitchInputNominal
 * @summary check.
 * @covers APlayerController.add-controller-pitch-input
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddControllerPitchInputNominal(APawn Pawn)
{
	if (Pawn is null)
	{
		throw("TS_APlayerController_MutationAndLifecycle_01 setup: required Pawn is null");
	}
	AController Controller = Pawn.GetController();
	if (Controller is null)
	{
		throw("TS_APlayerController_MutationAndLifecycle_01 setup: required Controller is null");
	}
	FRotator Before = Controller.GetControlRotation();
	Pawn.AddControllerPitchInput(-0.5);
	FRotator AfterNegative = Controller.GetControlRotation();
	Pawn.AddControllerPitchInput(0.0);
	FRotator AfterZero = Controller.GetControlRotation();
	Pawn.AddControllerPitchInput(0.5);
	FRotator AfterPositive = Controller.GetControlRotation();
	Controller.SetControlRotation(Before);
	return !AfterNegative.Equals(Before, 0.01) && AfterZero.Equals(AfterNegative, 0.01) && !AfterPositive.Equals(AfterNegative, 0.01);
}
/** @end */
/**
 * @begin get-pawn
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveGetPawnNominal
 * @summary borrowed.
 * @covers APlayerController.get-pawn
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPawnNominal(APlayerController Controller, APawn Expected)
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
/** @end */
/**
 * @begin get-character
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveGetCharacterNominal
 * @summary borrowed.
 * @covers APlayerController.get-character
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetCharacterNominal(APlayerController Controller, ACharacter Expected)
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
/** @end */
/**
 * @begin is-local-controller
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveIsLocalControllerNominal
 * @summary borrowed.
 * @covers APlayerController.is-local-controller
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLocalControllerNominal(APlayerController Controller, bool bExpectLocal)
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
/** @end */
/**
 * @begin is-player-controller
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveIsPlayerControllerNominal
 * @summary borrowed.
 * @covers APlayerController.is-player-controller
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsPlayerControllerNominal(APlayerController Controller)
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
/** @end */
/**
 * @begin is-local-player-controller
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveIsLocalPlayerControllerNominal
 * @summary borrowed.
 * @covers APlayerController.is-local-player-controller
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLocalPlayerControllerNominal(APlayerController Controller, bool bExpectLocalPlayer)
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
/** @end */
/**
 * @begin get-control-rotation
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveGetControlRotationNominal
 * @summary borrowed.
 * @covers APlayerController.get-control-rotation
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetControlRotationNominal(APlayerController Controller, const FRotator& Expected)
{
	if (Controller is null)
	{
		throw("TS_APlayerController_Queries_01 setup: required Controller is null");
	}
	return Controller.GetControlRotation().Equals(Expected, 0.01);
}
/** @end */
/**
 * @begin get-local-player
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveGetLocalPlayerNominal
 * @summary borrowed.
 * @covers APlayerController.get-local-player
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetLocalPlayerNominal(APlayerController Controller, ULocalPlayer Expected)
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
/** @end */
/**
 * @begin get-player-state
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveGetPlayerStateNominal
 * @summary borrowed.
 * @covers APlayerController.get-player-state
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPlayerStateNominal(APlayerController Controller, APlayerState Expected)
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
/** @end */
/**
 * @begin get-player-camera-manager
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveGetPlayerCameraManagerNominal
 * @summary borrowed.
 * @covers APlayerController.get-player-camera-manager
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPlayerCameraManagerNominal(APlayerController Controller, APlayerCameraManager Expected)
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
/** @end */
/**
 * @begin get-controller
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveGetControllerNominal
 * @summary borrowed.
 * @covers APlayerController.get-controller
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetControllerNominal(APawn Pawn, AController Expected)
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
/** @end */
/**
 * @begin get-player-controller
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveGetPlayerControllerNominal
 * @summary borrowed.
 * @covers APlayerController.get-player-controller
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPlayerControllerNominal(APawn Pawn, APlayerController Expected)
{
	if (Pawn is null)
	{
		throw("TS_APlayerController_Queries_02 setup: required Pawn is null");
	}
	TSubclassOf<APawn> PawnClass = APawn::StaticClass();
	APawn Cdo = PawnClass.GetDefaultObject();
	if (Cdo is null)
	{
		throw("TS_APlayerController_Queries_02 setup: required Pawn CDO is null");
	}
	return Cdo.GetPlayerController() is null && Pawn.GetPlayerController() == Expected;
}
/** @end */
/**
 * @begin is-locally-controlled
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveIsLocallyControlledNominal
 * @summary borrowed.
 * @covers APlayerController.is-locally-controlled
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLocallyControlledNominal(APawn Pawn, bool bExpectLocal)
{
	if (Pawn is null)
	{
		throw("TS_APlayerController_Queries_02 setup: required Pawn is null");
	}
	TSubclassOf<APawn> PawnClass = APawn::StaticClass();
	APawn Cdo = PawnClass.GetDefaultObject();
	if (Cdo is null)
	{
		throw("TS_APlayerController_Queries_02 setup: required Pawn CDO is null");
	}
	return !Cdo.IsLocallyControlled() && Pawn.IsLocallyControlled() == bExpectLocal;
}
/** @end */
/**
 * @begin is-player-controlled
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveIsPlayerControlledNominal
 * @summary borrowed.
 * @covers APlayerController.is-player-controlled
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsPlayerControlledNominal(APawn Pawn, bool bExpectPlayerControlled)
{
	if (Pawn is null)
	{
		throw("TS_APlayerController_Queries_02 setup: required Pawn is null");
	}
	TSubclassOf<APawn> PawnClass = APawn::StaticClass();
	APawn Cdo = PawnClass.GetDefaultObject();
	if (Cdo is null)
	{
		throw("TS_APlayerController_Queries_02 setup: required Pawn CDO is null");
	}
	return !Cdo.IsPlayerControlled() && Pawn.IsPlayerControlled() == bExpectPlayerControlled;
}
/** @end */
/**
 * @begin is-bot-controlled
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveIsBotControlledNominal
 * @summary borrowed.
 * @covers APlayerController.is-bot-controlled
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsBotControlledNominal(APawn Pawn, bool bExpectBotControlled)
{
	if (Pawn is null)
	{
		throw("TS_APlayerController_Queries_02 setup: required Pawn is null");
	}
	TSubclassOf<APawn> PawnClass = APawn::StaticClass();
	APawn Cdo = PawnClass.GetDefaultObject();
	if (Cdo is null)
	{
		throw("TS_APlayerController_Queries_02 setup: required Pawn CDO is null");
	}
	return !Cdo.IsBotControlled() && Pawn.IsBotControlled() == bExpectBotControlled;
}
/** @end */
/**
 * @begin APlayerController-Queries_02-get-player-state
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveGetPlayerStateNominal
 * @summary borrowed.
 * @covers APlayerController.get-player-state
 * @inputs APlayerController values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPlayerStateNominal(APawn Pawn, APlayerState Expected)
{
	if (Pawn is null)
	{
		throw("TS_APlayerController_Queries_02 setup: required Pawn is null");
	}
	TSubclassOf<APawn> PawnClass = APawn::StaticClass();
	APawn Cdo = PawnClass.GetDefaultObject();
	if (Cdo is null)
	{
		throw("TS_APlayerController_Queries_02 setup: required Pawn CDO is null");
	}
	return Cdo.GetPlayerState() is null && Pawn.GetPlayerState() == Expected;
}
/** @end */
