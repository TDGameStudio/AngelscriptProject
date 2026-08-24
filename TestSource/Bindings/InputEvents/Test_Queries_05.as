// Purpose: Observe remaining FPointerEvent command, platform, position, delta,
// button, and wheel queries.
// AS-facing API: bool PointerEvent.IsRightCommandDown() const;
// FPlatformUserId PointerEvent.GetPlatformUserid() const;
// FInputDeviceId PointerEvent.GetInputDeviceId() const;
// FVector2D PointerEvent.GetScreenSpacePosition() const;
// FVector2D PointerEvent.GetLastScreenSpacePosition() const;
// FVector2D PointerEvent.GetCursorDelta() const;
// FVector2D PointerEvent.GetGestureDelta() const;
// bool PointerEvent.IsMouseButtonDown(FKey MouseButton) const;
// FKey PointerEvent.GetEffectingButton() const;
// float32 PointerEvent.GetWheelDelta() const;
// Inputs: Default FPointerEvent, EKeys::LeftMouseButton as a held-button lookup,
// EKeys::Invalid as the empty lookup, and a second read for identity.
// Expected observations: Right command is false. Position and last position are
// consumed 2D values. Cursor and gesture deltas are (0,0) on the empty event.
// IsMouseButtonDown is false for LeftMouseButton and Invalid. Effecting button
// is invalid. Wheel delta is 0.
// Boundary/ownership: Positions are desktop-space Slate units. Queries do not
// mutate the pointer event. IsMouseButtonDown borrows MouseButton by value.

namespace TS_InputEvents_Queries_05
{
	bool Observe_IsRightCommandDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsRightCommandDown();
	}

	bool Observe_GetPlatformUserid_Nominal()
	{
		FPointerEvent PointerEvent;
		FPlatformUserId PlatformUser = PointerEvent.GetPlatformUserid();
		FPlatformUserId Again = PointerEvent.GetPlatformUserid();
		return PlatformUser == Again;
	}

	bool Observe_GetInputDeviceId_Nominal()
	{
		FPointerEvent PointerEvent;
		FInputDeviceId InputDevice = PointerEvent.GetInputDeviceId();
		FInputDeviceId Again = PointerEvent.GetInputDeviceId();
		return InputDevice == Again;
	}

	bool Observe_GetScreenSpacePosition_Nominal()
	{
		FPointerEvent PointerEvent;
		FVector2D Position = PointerEvent.GetScreenSpacePosition();
		return Position.X == 0.0 && Position.Y == 0.0;
	}

	bool Observe_GetLastScreenSpacePosition_Nominal()
	{
		FPointerEvent PointerEvent;
		FVector2D LastPosition = PointerEvent.GetLastScreenSpacePosition();
		return LastPosition.X == 0.0 && LastPosition.Y == 0.0;
	}

	bool Observe_GetCursorDelta_Nominal()
	{
		FPointerEvent PointerEvent;
		FVector2D Delta = PointerEvent.GetCursorDelta();
		return Delta.X == 0.0 && Delta.Y == 0.0;
	}

	bool Observe_GetGestureDelta_Nominal()
	{
		FPointerEvent PointerEvent;
		FVector2D Gesture = PointerEvent.GetGestureDelta();
		return Gesture.X == 0.0 && Gesture.Y == 0.0;
	}

	bool Observe_IsMouseButtonDown_Nominal()
	{
		FPointerEvent PointerEvent;
		FKey Empty;
		return !PointerEvent.IsMouseButtonDown(EKeys::LeftMouseButton) &&
			!PointerEvent.IsMouseButtonDown(EKeys::Invalid) &&
			!PointerEvent.IsMouseButtonDown(Empty);
	}

	bool Observe_GetEffectingButton_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.GetEffectingButton().IsValid();
	}

	bool Observe_GetWheelDelta_Nominal()
	{
		FPointerEvent PointerEvent;
		return PointerEvent.GetWheelDelta() == 0.0;
	}
}
