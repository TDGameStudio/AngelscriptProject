/**
 * @version v1
 * @summary Observe navigation type/genesis, analog magnitude, analog key identity, focus cause/user, and character-event repeat.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe navigation type/genesis, analog magnitude, analog key identity, focus cause/user, and character-event repeat.
 * @topic Baseline
 */
// ENavigationGenesis NavigationEvent.GetNavigationGenesis() const;
// float32 AnalogInputEvent.GetAnalogValue() const;
// FPlatformUserId AnalogInputEvent.GetPlatformUserid() const;
// FInputDeviceId AnalogInputEvent.GetInputDeviceId() const;
// FKey AnalogInputEvent.GetKey() const; uint32 AnalogInputEvent.GetKeyCode() const;
// EFocusCause FocusEvent.GetCause() const; uint32 FocusEvent.GetUser() const;
// bool CharacterEvent.IsRepeat() const;
// Inputs: Default FNavigationEvent, FAnalogInputEvent, FFocusEvent, and
// FCharacterEvent as empty receivers.
// Expected observations: Navigation type and genesis are consumed enums.
// Analog value and key code are 0. Analog key is invalid. Focus user is 0.
// Character repeat is false.
// Boundary/ownership: These queries do not mutate the events. Analog magnitude
// is a scalar, not a 2D stick vector.

namespace TS_InputEvents_Queries_08
{
	bool Observe_GetNavigationType_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return NavigationEvent.GetNavigationType() == EUINavigation::Invalid;
	}

	bool Observe_GetNavigationGenesis_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return NavigationEvent.GetNavigationGenesis() == ENavigationGenesis::User;
	}

	bool Observe_GetAnalogValue_Nominal()
	{
		FAnalogInputEvent AnalogInputEvent;
		return AnalogInputEvent.GetAnalogValue() == 0.0;
	}

	bool Observe_GetPlatformUserid_Nominal()
	{
		FAnalogInputEvent AnalogInputEvent;
		FPlatformUserId PlatformUser = AnalogInputEvent.GetPlatformUserid();
		FPlatformUserId Again = AnalogInputEvent.GetPlatformUserid();
		return PlatformUser == Again;
	}

	bool Observe_GetInputDeviceId_Nominal()
	{
		FAnalogInputEvent AnalogInputEvent;
		FInputDeviceId InputDevice = AnalogInputEvent.GetInputDeviceId();
		FInputDeviceId Again = AnalogInputEvent.GetInputDeviceId();
		return InputDevice == Again;
	}

	bool Observe_GetKey_Nominal()
	{
		FAnalogInputEvent AnalogInputEvent;
		return !AnalogInputEvent.GetKey().IsValid();
	}

	bool Observe_GetKeyCode_Nominal()
	{
		FAnalogInputEvent AnalogInputEvent;
		return AnalogInputEvent.GetKeyCode() == 0;
	}

	bool Observe_GetCause_Nominal()
	{
		FFocusEvent FocusEvent;
		return FocusEvent.GetCause() == EFocusCause::SetDirectly;
	}

	bool Observe_GetUser_Nominal()
	{
		FFocusEvent FocusEvent;
		return FocusEvent.GetUser() == 0;
	}

	bool Observe_IsRepeat_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsRepeat();
	}
}
/** @end */
