// Purpose: Observe control-rotation, player assignment, view-target blend,
// and pawn movement/yaw/pitch input mutations.
// Runner owns Controller, ViewTarget, and Pawn fixtures and teardown.
// AS-facing API: void Controller.SetControlRotation(const FRotator& NewRotation);
// void PlayerController.SetPlayer(UPlayer InPlayer);
// void PlayerController.SetViewTargetWithBlend(AActor NewViewTarget, float32 BlendTime = 0.0, EViewTargetBlendFunction BlendFunc = EViewTargetBlendFunction::VTBlend_Linear, float32 BlendExp = 0.0, bool bLockOutgoing = false);
// void Pawn.AddMovementInput(FVector WorldDirection, float32 ScaleValue = 1.0, bool bForce = false);
// void Pawn.AddControllerYawInput(float32 Val);
// void Pawn.AddControllerPitchInput(float32 Val);
// Inputs: Runner-owned APlayerController, FRotator(0,90,0), null UPlayer,
// runner-owned AActor view target, BlendTime 0 and 0.1, VTBlend_Linear,
// BlendExp 0, bLockOutgoing false/true, runner-owned APawn, WorldDirection
// (1,0,0), ScaleValue 1 and 0.5, bForce true/false, yaw 1.5, pitch -0.5.
// Expected observations: SetControlRotation writes GetControlRotation.
// SetPlayer(null) clears GetLocalPlayer. SetViewTargetWithBlend is issued
// with defaults and with every optional argument. Movement/yaw/pitch input
// calls complete on a live pawn; yaw/pitch change control rotation.
// Boundary/ownership: SetupOwner=Runner. CleanupOwner=Runner. BlendFunc
// selects the interpolation curve. bForce bypasses the pawn input-disabled
// check. Optional arguments may be omitted. Null required fixtures throw.

namespace TS_APlayerController_MutationAndLifecycle_01
{
	bool Observe_SetControlRotation_Nominal(APlayerController Controller)
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

	bool Observe_SetPlayer_Nominal(APlayerController Controller)
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

	bool Observe_SetViewTargetWithBlend_Nominal(APlayerController Controller, AActor ViewTarget)
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

	bool Observe_AddMovementInput_Nominal(APawn Pawn)
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

	bool Observe_AddControllerYawInput_Nominal(APawn Pawn)
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

	bool Observe_AddControllerPitchInput_Nominal(APawn Pawn)
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
}
