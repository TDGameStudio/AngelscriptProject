/**
 * @version v1
 * @summary Observe UPlayerInput mixin add/remove of action and axis mappings, including null player-controller/player-input receivers.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UPlayerInput mixin add/remove of action and axis mappings, including null player-controller/player-input receivers.
 * @topic Baseline
 */
// void PlayerInput.AddAxisMapping(const FInputAxisKeyMapping& Mapping);
// void PlayerInput.RemoveActionMapping(const FInputActionKeyMapping& Mapping);
// void PlayerInput.RemoveAxisMapping(const FInputAxisKeyMapping& Mapping);
// Inputs: A null APlayerController, its null UPlayerInput, a Jump/SpaceBar
// action mapping, a MoveForward/W axis mapping with Scale 1.0, and a second
// add/remove pair as repeated-call behavior.
// Expected observations: GetPlayerInput on a null controller is null. Mixin
// calls on a null PlayerInput return without owning the mapping. Mapping
// values remain independent after the calls.
// Boundary/ownership: Mixins no-op on a null PlayerInput. Mapping structs are
// borrowed and not retained by a null receiver.

namespace TS_InputComponentScriptMixins_MutationAndLifecycle_01
{
	bool Observe_AddActionMapping_Nominal()
	{
		APlayerController PlayerController;
		UPlayerInput PlayerInput;
		FInputActionKeyMapping Mapping;
		Mapping.ActionName = n"Jump";
		Mapping.Key = n"SpaceBar";
		PlayerInput.AddActionMapping(Mapping);
		PlayerInput.AddActionMapping(Mapping);
		return PlayerController is null && PlayerInput is null && Mapping.ActionName == n"Jump";
	}

	bool Observe_AddAxisMapping_Nominal()
	{
		UPlayerInput PlayerInput;
		FInputAxisKeyMapping Mapping;
		Mapping.AxisName = n"MoveForward";
		Mapping.Key = n"W";
		Mapping.Scale = 1.0;
		PlayerInput.AddAxisMapping(Mapping);
		PlayerInput.AddAxisMapping(Mapping);
		return PlayerInput is null && Mapping.AxisName == n"MoveForward" && Mapping.Scale == 1.0;
	}

	bool Observe_RemoveActionMapping_Nominal()
	{
		UPlayerInput PlayerInput;
		FInputActionKeyMapping Mapping;
		Mapping.ActionName = n"Jump";
		Mapping.Key = n"SpaceBar";
		PlayerInput.AddActionMapping(Mapping);
		PlayerInput.RemoveActionMapping(Mapping);
		PlayerInput.RemoveActionMapping(Mapping);
		return PlayerInput is null && Mapping.ActionName == n"Jump";
	}

	bool Observe_RemoveAxisMapping_Nominal()
	{
		UPlayerInput PlayerInput;
		FInputAxisKeyMapping Mapping;
		Mapping.AxisName = n"MoveForward";
		Mapping.Key = n"W";
		Mapping.Scale = 1.0;
		PlayerInput.AddAxisMapping(Mapping);
		PlayerInput.RemoveAxisMapping(Mapping);
		PlayerInput.RemoveAxisMapping(Mapping);
		return PlayerInput is null && Mapping.AxisName == n"MoveForward";
	}
}
/** @end */
