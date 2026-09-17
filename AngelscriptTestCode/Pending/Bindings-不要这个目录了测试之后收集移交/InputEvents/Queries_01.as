/**
 * @version v1
 * @summary Observe FKey validity, device class, axis rank, display label, and stable name queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FKey validity, device class, axis rank, display label, and stable name queries.
 * @topic Baseline
 */
// bool Key.IsGamepadKey() const; bool Key.IsTouch() const;
// bool Key.IsMouseButton() const; bool Key.IsAxis1D() const;
// bool Key.IsAxis2D() const; bool Key.IsAxis3D() const;
// FText Key.GetDisplayName(bool bLongDisplayName = true) const;
// FName Key.GetKeyName() const;
// Inputs: Default FKey and EKeys::Invalid as empty keys, EKeys::AnyKey,
// EKeys::SpaceBar, EKeys::LeftShift, EKeys::Gamepad_FaceButton_Bottom,
// FKey(n"Touch"), EKeys::Steam_Touch_0, EKeys::LeftMouseButton,
// EKeys::MouseX, EKeys::Mouse2D, EKeys::Tilt, and GetDisplayName default plus
// bLongDisplayName false.
// Expected observations: SpaceBar and AnyKey are valid. Invalid and default
// keys are not. LeftShift is a modifier. Gamepad face button is a gamepad key.
// Left mouse is a mouse button. MouseX is 1D, Mouse2D is 2D, Tilt is 3D.
// SpaceBar name is n"SpaceBar". Display names are consumed for long and short.
// Boundary/ownership: Queries do not mutate the key. Display text is a new
// FText; the key remains the stable identity.

namespace TS_InputEvents_Queries_01
{
	bool Observe_IsValid_Nominal()
	{
		FKey Empty;
		return !Empty.IsValid() && !EKeys::Invalid.IsValid() && EKeys::SpaceBar.IsValid() && EKeys::AnyKey.IsValid();
	}

	bool Observe_IsModifierKey_Nominal()
	{
		FKey Empty;
		return EKeys::LeftShift.IsModifierKey() && !EKeys::SpaceBar.IsModifierKey() && !Empty.IsModifierKey();
	}

	bool Observe_IsGamepadKey_Nominal()
	{
		FKey Empty;
		return EKeys::Gamepad_FaceButton_Bottom.IsGamepadKey() && !EKeys::SpaceBar.IsGamepadKey() && !Empty.IsGamepadKey();
	}

	bool Observe_IsTouch_Nominal()
	{
		FKey NamedTouch(n"Touch");
		FKey Touch1(n"Touch1");
		FKey Empty;
		return !NamedTouch.IsValid() &&
			!NamedTouch.IsTouch() &&
			Touch1.IsValid() &&
			Touch1.IsTouch() &&
			!EKeys::SpaceBar.IsTouch() &&
			!Empty.IsTouch() &&
			!EKeys::Steam_Touch_0.IsTouch();
	}

	bool Observe_IsMouseButton_Nominal()
	{
		FKey Empty;
		return EKeys::LeftMouseButton.IsMouseButton() && !EKeys::SpaceBar.IsMouseButton() && !Empty.IsMouseButton();
	}

	bool Observe_IsAxis1D_Nominal()
	{
		FKey Empty;
		return EKeys::MouseX.IsAxis1D() && EKeys::Gamepad_LeftX.IsAxis1D() && !EKeys::SpaceBar.IsAxis1D() && !Empty.IsAxis1D();
	}

	bool Observe_IsAxis2D_Nominal()
	{
		FKey Empty;
		return EKeys::Mouse2D.IsAxis2D() && EKeys::Gamepad_Left2D.IsAxis2D() && !EKeys::SpaceBar.IsAxis2D() && !Empty.IsAxis2D();
	}

	bool Observe_IsAxis3D_Nominal()
	{
		FKey Empty;
		return EKeys::Tilt.IsAxis3D() && EKeys::Gravity.IsAxis3D() && !EKeys::SpaceBar.IsAxis3D() && !Empty.IsAxis3D();
	}

	bool Observe_GetDisplayName_Nominal()
	{
		FString LongText = EKeys::SpaceBar.GetDisplayName().ToString();
		FString ShortText = EKeys::SpaceBar.GetDisplayName(false).ToString();
		FString EmptyText = FKey().GetDisplayName().ToString();
		return LongText.Contains("Space") && ShortText.Contains("Space") && EmptyText == "None";
	}

	bool Observe_GetKeyName_Nominal()
	{
		return EKeys::SpaceBar.GetKeyName() == n"SpaceBar" && FKey().GetKeyName().IsNone() && EKeys::Invalid.GetKeyName().IsNone();
	}
}
/** @end */
