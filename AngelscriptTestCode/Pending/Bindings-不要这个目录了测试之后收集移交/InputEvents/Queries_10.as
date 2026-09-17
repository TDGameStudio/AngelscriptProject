/**
 * @version v1
 * @summary Observe remaining FCharacterEvent command, platform-user, device, character-code, and one-character string queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining FCharacterEvent command, platform-user, device, character-code, and one-character string queries.
 * @topic Baseline
 */
// bool CharacterEvent.IsRightCommandDown() const;
// FPlatformUserId CharacterEvent.GetPlatformUserid() const;
// FInputDeviceId CharacterEvent.GetInputDeviceId() const;
// uint16 CharacterEvent.GetCharacter() const;
// FString CharacterEvent.GetString() const;
// Inputs: A default-constructed FCharacterEvent as the empty receiver.
// Expected observations: Left/right command are false. Platform user and
// device ids match a second read. Character code is 0. GetString is a
// one-character string whose length is 1 even for the NUL empty event.
// Boundary/ownership: GetString returns a new FString and does not retain the
// event. The character code is uint16, unlike FKeyEvent.GetCharacter.

namespace TS_InputEvents_Queries_10
{
	bool Observe_IsLeftCommandDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsLeftCommandDown();
	}

	bool Observe_IsRightCommandDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsRightCommandDown();
	}

	bool Observe_GetPlatformUserid_Nominal()
	{
		FCharacterEvent CharacterEvent;
		FPlatformUserId PlatformUser = CharacterEvent.GetPlatformUserid();
		FPlatformUserId Again = CharacterEvent.GetPlatformUserid();
		return PlatformUser == Again;
	}

	bool Observe_GetInputDeviceId_Nominal()
	{
		FCharacterEvent CharacterEvent;
		FInputDeviceId InputDevice = CharacterEvent.GetInputDeviceId();
		FInputDeviceId Again = CharacterEvent.GetInputDeviceId();
		return InputDevice == Again;
	}

	bool Observe_GetCharacter_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return CharacterEvent.GetCharacter() == 0;
	}

	bool Observe_GetString_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return CharacterEvent.GetString().Len() == 1;
	}
}
/** @end */
