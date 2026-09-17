/**
 * @version v1
 * @summary Observe FEventReply handled/unhandled factories and every published EKeys table entry plus Virtual_Accept and Virtual_Back.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FEventReply handled/unhandled factories and every published EKeys table entry plus Virtual_Accept and Virtual_Back.
 * @topic Baseline
 */
// FEventReply Reply = FEventReply::Unhandled();
// const FKey EKeys::<Key>;
// Inputs: Handled and Unhandled factories with no arguments. Every BIND_EKEYS
// token from Bind_InputEvents plus Virtual_Accept, Virtual_Back, and Invalid.
// Expected observations: Handled and Unhandled replies are distinct values that
// can be mutated independently. Canonical keys such as SpaceBar, LeftMouseButton,
// and Gamepad_FaceButton_Bottom are valid. EKeys::Invalid is not valid.
// Virtual_Accept and Virtual_Back are consumed platform virtual keys.
// Boundary/ownership: EKeys entries are shared constants, not owned copies.
// Handled/Unhandled return new reply values.

namespace TS_InputEvents_NamespaceAndGlobalFunctions_01
{
	// FEventReply::Handled() returns a reply that accepts fluent PreventThrottling/ReleaseMouseCapture aliases.
	bool Observe_Handled_Nominal()
	{
		FEventReply Reply = FEventReply::Handled();
		FEventReply& Alias = Reply.PreventThrottling();
		Alias.ReleaseMouseCapture();
		return true;
	}

	// FEventReply::Unhandled() is independently mutable from Handled() via ReleaseMouseLock.
	bool Observe_Unhandled_Nominal()
	{
		FEventReply Reply = FEventReply::Unhandled();
		FEventReply Handled = FEventReply::Handled();
		Reply.ReleaseMouseLock();
		return true;
	}

	// Every BIND_EKEYS token plus Virtual_Accept/Virtual_Back is valid; EKeys::Invalid is not.
	bool Observe_Surface127_Nominal()
	{
		bool bAny = EKeys::AnyKey.IsValid();

		bool bMouse =
			EKeys::MouseX.IsAxis1D() &&
			EKeys::MouseY.IsAxis1D() &&
			EKeys::Mouse2D.IsAxis2D() &&
			EKeys::MouseScrollUp.IsValid() &&
			EKeys::MouseScrollDown.IsValid() &&
			EKeys::MouseWheelAxis.IsValid() &&
			EKeys::LeftMouseButton.IsMouseButton() &&
			EKeys::RightMouseButton.IsMouseButton() &&
			EKeys::MiddleMouseButton.IsMouseButton() &&
			EKeys::ThumbMouseButton.IsMouseButton() &&
			EKeys::ThumbMouseButton2.IsMouseButton();

		bool bTyping =
			EKeys::BackSpace.IsValid() &&
			EKeys::Tab.IsValid() &&
			EKeys::Enter.IsValid() &&
			EKeys::Pause.IsValid() &&
			EKeys::CapsLock.IsValid() &&
			EKeys::Escape.IsValid() &&
			EKeys::SpaceBar.GetKeyName() == n"SpaceBar" &&
			EKeys::PageUp.IsValid() &&
			EKeys::PageDown.IsValid() &&
			EKeys::End.IsValid() &&
			EKeys::Home.IsValid() &&
			EKeys::Left.IsValid() &&
			EKeys::Up.IsValid() &&
			EKeys::Right.IsValid() &&
			EKeys::Down.IsValid() &&
			EKeys::Insert.IsValid() &&
			EKeys::Delete.IsValid();

		bool bDigits =
			EKeys::Zero.IsValid() &&
			EKeys::One.IsValid() &&
			EKeys::Two.IsValid() &&
			EKeys::Three.IsValid() &&
			EKeys::Four.IsValid() &&
			EKeys::Five.IsValid() &&
			EKeys::Six.IsValid() &&
			EKeys::Seven.IsValid() &&
			EKeys::Eight.IsValid() &&
			EKeys::Nine.IsValid();

		bool bLetters =
			EKeys::A.IsValid() &&
			EKeys::B.IsValid() &&
			EKeys::C.IsValid() &&
			EKeys::D.IsValid() &&
			EKeys::E.IsValid() &&
			EKeys::F.IsValid() &&
			EKeys::G.IsValid() &&
			EKeys::H.IsValid() &&
			EKeys::I.IsValid() &&
			EKeys::J.IsValid() &&
			EKeys::K.IsValid() &&
			EKeys::L.IsValid() &&
			EKeys::M.IsValid() &&
			EKeys::N.IsValid() &&
			EKeys::O.IsValid() &&
			EKeys::P.IsValid() &&
			EKeys::Q.IsValid() &&
			EKeys::R.IsValid() &&
			EKeys::S.IsValid() &&
			EKeys::T.IsValid() &&
			EKeys::U.IsValid() &&
			EKeys::V.IsValid() &&
			EKeys::W.IsValid() &&
			EKeys::X.IsValid() &&
			EKeys::Y.IsValid() &&
			EKeys::Z.IsValid();

		bool bNumPad =
			EKeys::NumPadZero.IsValid() &&
			EKeys::NumPadOne.IsValid() &&
			EKeys::NumPadTwo.IsValid() &&
			EKeys::NumPadThree.IsValid() &&
			EKeys::NumPadFour.IsValid() &&
			EKeys::NumPadFive.IsValid() &&
			EKeys::NumPadSix.IsValid() &&
			EKeys::NumPadSeven.IsValid() &&
			EKeys::NumPadEight.IsValid() &&
			EKeys::NumPadNine.IsValid() &&
			EKeys::Multiply.IsValid() &&
			EKeys::Add.IsValid() &&
			EKeys::Subtract.IsValid() &&
			EKeys::Decimal.IsValid() &&
			EKeys::Divide.IsValid();

		bool bFunction =
			EKeys::F1.IsValid() &&
			EKeys::F2.IsValid() &&
			EKeys::F3.IsValid() &&
			EKeys::F4.IsValid() &&
			EKeys::F5.IsValid() &&
			EKeys::F6.IsValid() &&
			EKeys::F7.IsValid() &&
			EKeys::F8.IsValid() &&
			EKeys::F9.IsValid() &&
			EKeys::F10.IsValid() &&
			EKeys::F11.IsValid() &&
			EKeys::F12.IsValid() &&
			EKeys::NumLock.IsValid() &&
			EKeys::ScrollLock.IsValid();

		bool bModifiers =
			EKeys::LeftShift.IsModifierKey() &&
			EKeys::RightShift.IsModifierKey() &&
			EKeys::LeftControl.IsModifierKey() &&
			EKeys::RightControl.IsModifierKey() &&
			EKeys::LeftAlt.IsModifierKey() &&
			EKeys::RightAlt.IsModifierKey() &&
			EKeys::LeftCommand.IsModifierKey() &&
			EKeys::RightCommand.IsModifierKey();

		bool bPunctuation =
			EKeys::Semicolon.IsValid() &&
			EKeys::Equals.IsValid() &&
			EKeys::Comma.IsValid() &&
			EKeys::Underscore.IsValid() &&
			EKeys::Hyphen.IsValid() &&
			EKeys::Period.IsValid() &&
			EKeys::Slash.IsValid() &&
			EKeys::Tilde.IsValid() &&
			EKeys::LeftBracket.IsValid() &&
			EKeys::Backslash.IsValid() &&
			EKeys::RightBracket.IsValid() &&
			EKeys::Apostrophe.IsValid() &&
			EKeys::Ampersand.IsValid() &&
			EKeys::Asterix.IsValid() &&
			EKeys::Caret.IsValid() &&
			EKeys::Colon.IsValid() &&
			EKeys::Dollar.IsValid() &&
			EKeys::Exclamation.IsValid() &&
			EKeys::LeftParantheses.IsValid() &&
			EKeys::RightParantheses.IsValid() &&
			EKeys::Quote.IsValid() &&
			EKeys::A_AccentGrave.IsValid() &&
			EKeys::E_AccentGrave.IsValid() &&
			EKeys::E_AccentAigu.IsValid() &&
			EKeys::C_Cedille.IsValid() &&
			EKeys::Section.IsValid() &&
			EKeys::Platform_Delete.IsValid();

		bool bGamepad =
			EKeys::Gamepad_Left2D.IsAxis2D() &&
			EKeys::Gamepad_LeftX.IsAxis1D() &&
			EKeys::Gamepad_LeftY.IsAxis1D() &&
			EKeys::Gamepad_Right2D.IsAxis2D() &&
			EKeys::Gamepad_RightX.IsAxis1D() &&
			EKeys::Gamepad_RightY.IsAxis1D() &&
			EKeys::Gamepad_LeftTriggerAxis.IsValid() &&
			EKeys::Gamepad_RightTriggerAxis.IsValid() &&
			EKeys::Gamepad_LeftThumbstick.IsGamepadKey() &&
			EKeys::Gamepad_RightThumbstick.IsGamepadKey() &&
			EKeys::Gamepad_Special_Left.IsGamepadKey() &&
			EKeys::Gamepad_Special_Left_X.IsValid() &&
			EKeys::Gamepad_Special_Left_Y.IsValid() &&
			EKeys::Gamepad_Special_Right.IsGamepadKey() &&
			EKeys::Gamepad_FaceButton_Bottom.IsGamepadKey() &&
			EKeys::Gamepad_FaceButton_Right.IsGamepadKey() &&
			EKeys::Gamepad_FaceButton_Left.IsGamepadKey() &&
			EKeys::Gamepad_FaceButton_Top.IsGamepadKey() &&
			EKeys::Gamepad_LeftShoulder.IsGamepadKey() &&
			EKeys::Gamepad_RightShoulder.IsGamepadKey() &&
			EKeys::Gamepad_LeftTrigger.IsGamepadKey() &&
			EKeys::Gamepad_RightTrigger.IsGamepadKey() &&
			EKeys::Gamepad_DPad_Up.IsGamepadKey() &&
			EKeys::Gamepad_DPad_Down.IsGamepadKey() &&
			EKeys::Gamepad_DPad_Right.IsGamepadKey() &&
			EKeys::Gamepad_DPad_Left.IsGamepadKey() &&
			EKeys::Gamepad_LeftStick_Up.IsValid() &&
			EKeys::Gamepad_LeftStick_Down.IsValid() &&
			EKeys::Gamepad_LeftStick_Right.IsValid() &&
			EKeys::Gamepad_LeftStick_Left.IsValid() &&
			EKeys::Gamepad_RightStick_Up.IsValid() &&
			EKeys::Gamepad_RightStick_Down.IsValid() &&
			EKeys::Gamepad_RightStick_Right.IsValid() &&
			EKeys::Gamepad_RightStick_Left.IsValid();

		bool bMotion =
			EKeys::Tilt.IsAxis3D() &&
			EKeys::RotationRate.IsAxis3D() &&
			EKeys::Gravity.IsAxis3D() &&
			EKeys::Acceleration.IsAxis3D() &&
			EKeys::Gesture_Pinch.IsValid() &&
			EKeys::Gesture_Flick.IsValid() &&
			EKeys::Gesture_Rotate.IsValid();

		bool bPlatform =
			EKeys::Steam_Touch_0.IsValid() &&
			EKeys::Steam_Touch_1.IsValid() &&
			EKeys::Steam_Touch_2.IsValid() &&
			EKeys::Steam_Touch_3.IsValid() &&
			EKeys::Steam_Back_Left.IsValid() &&
			EKeys::Steam_Back_Right.IsValid() &&
			EKeys::Global_Menu.IsValid() &&
			EKeys::Global_View.IsValid() &&
			EKeys::Global_Pause.IsValid() &&
			EKeys::Global_Play.IsValid() &&
			EKeys::Global_Back.IsValid() &&
			EKeys::Android_Back.IsValid() &&
			EKeys::Android_Volume_Up.IsValid() &&
			EKeys::Android_Volume_Down.IsValid() &&
			EKeys::Android_Menu.IsValid() &&
			EKeys::Virtual_Accept.IsValid() &&
			EKeys::Virtual_Back.IsValid();

		bool bInvalid = !EKeys::Invalid.IsValid();
		return bAny &&
			bMouse &&
			bTyping &&
			bDigits &&
			bLetters &&
			bNumPad &&
			bFunction &&
			bModifiers &&
			bPunctuation &&
			bGamepad &&
			bMotion &&
			bPlatform &&
			bInvalid;
	}
}
/** @end */
