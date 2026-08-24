// Purpose: Observe FKeyEvent command, platform user, device, key, character,
// and key-code queries plus FPointerEvent repeat/shift.
// AS-facing API: bool KeyEvent.IsCommandDown() const;
// bool KeyEvent.IsLeftCommandDown() const; bool KeyEvent.IsRightCommandDown() const;
// FPlatformUserId KeyEvent.GetPlatformUserid() const;
// FInputDeviceId KeyEvent.GetInputDeviceId() const;
// FKey KeyEvent.GetKey() const; uint32 KeyEvent.GetCharacter() const;
// uint32 KeyEvent.GetKeyCode() const; bool PointerEvent.IsRepeat() const;
// bool PointerEvent.IsShiftDown() const;
// Inputs: Default FKeyEvent and FPointerEvent as empty receivers.
// Expected observations: Command bits are false. Platform user and device ids
// match a second read of the same empty event. GetKey is invalid. Character
// and key code are 0. Pointer repeat and shift are false.
// Boundary/ownership: Returned FKey is a copy. Platform user and device ids
// identify the event source and do not own hardware.

namespace TS_InputEvents_Queries_03
{
	bool Observe_IsCommandDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsCommandDown();
	}

	bool Observe_IsLeftCommandDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsLeftCommandDown();
	}

	bool Observe_IsRightCommandDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsRightCommandDown();
	}

	bool Observe_GetPlatformUserid_Nominal()
	{
		FKeyEvent KeyEvent;
		FPlatformUserId PlatformUser = KeyEvent.GetPlatformUserid();
		FPlatformUserId Again = KeyEvent.GetPlatformUserid();
		return PlatformUser == Again;
	}

	bool Observe_GetInputDeviceId_Nominal()
	{
		FKeyEvent KeyEvent;
		FInputDeviceId InputDevice = KeyEvent.GetInputDeviceId();
		FInputDeviceId Again = KeyEvent.GetInputDeviceId();
		return InputDevice == Again;
	}

	bool Observe_GetKey_Nominal()
	{
		FKeyEvent KeyEvent;
		FKey Key = KeyEvent.GetKey();
		return !Key.IsValid() && Key == FKey();
	}

	bool Observe_GetCharacter_Nominal()
	{
		FKeyEvent KeyEvent;
		return KeyEvent.GetCharacter() == 0;
	}

	bool Observe_GetKeyCode_Nominal()
	{
		FKeyEvent KeyEvent;
		return KeyEvent.GetKeyCode() == 0;
	}

	bool Observe_IsRepeat_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsRepeat();
	}

	bool Observe_IsShiftDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsShiftDown();
	}
}
