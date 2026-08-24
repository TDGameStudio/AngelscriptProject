// Theme: Language.Syntax.EdgeCases. Positive UCLASS compiles BindKey across keyboard EKeys.
// C++: AngelscriptCoverageInputTests.cpp::KeyboardKeys CompileScriptModule.
// sha256=4762823eeff8ab32b5461717ba7d023fe8806172fe1ad5f02beae48d1e056d4a; lines 536-653.
// Oracle: AKeyboardInputPawn class compiles. Extra: handlers are empty; BindPressedKey is the
// shared owner of FInputActionHandlerDynamicSignature. DefaultSafe.

UCLASS()
class AKeyboardInputPawn : APawn
{
	UFUNCTION()
	void SetupInput(UInputComponent PlayerInputComponent)
	{
		BindPressedKey(PlayerInputComponent, EKeys::W, n"OnW");
		BindPressedKey(PlayerInputComponent, EKeys::A, n"OnA");
		BindPressedKey(PlayerInputComponent, EKeys::S, n"OnS");
		BindPressedKey(PlayerInputComponent, EKeys::D, n"OnD");

		BindPressedKey(PlayerInputComponent, EKeys::SpaceBar, n"OnSpace");
		BindPressedKey(PlayerInputComponent, EKeys::LeftShift, n"OnShift");
		BindPressedKey(PlayerInputComponent, EKeys::LeftControl, n"OnCtrl");
		BindPressedKey(PlayerInputComponent, EKeys::LeftAlt, n"OnAlt");

		BindPressedKey(PlayerInputComponent, EKeys::Tab, n"OnTab");
		BindPressedKey(PlayerInputComponent, EKeys::Escape, n"OnEscape");
		BindPressedKey(PlayerInputComponent, EKeys::Enter, n"OnEnter");

		BindPressedKey(PlayerInputComponent, EKeys::One, n"OnOne");
		BindPressedKey(PlayerInputComponent, EKeys::Two, n"OnTwo");
		BindPressedKey(PlayerInputComponent, EKeys::Nine, n"OnNine");

		BindPressedKey(PlayerInputComponent, EKeys::F1, n"OnF1");
		BindPressedKey(PlayerInputComponent, EKeys::F12, n"OnF12");
	}

	UFUNCTION()
	void BindPressedKey(UInputComponent PlayerInputComponent, FKey Key, FName FunctionName)
	{
		FInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, FunctionName);
		PlayerInputComponent.BindKey(Key, EInputEvent::IE_Pressed, Delegate);
	}

	UFUNCTION()
	void OnW(FKey Key)
	{
	}

	UFUNCTION()
	void OnA(FKey Key)
	{
	}

	UFUNCTION()
	void OnS(FKey Key)
	{
	}

	UFUNCTION()
	void OnD(FKey Key)
	{
	}

	UFUNCTION()
	void OnSpace(FKey Key)
	{
	}

	UFUNCTION()
	void OnShift(FKey Key)
	{
	}

	UFUNCTION()
	void OnCtrl(FKey Key)
	{
	}

	UFUNCTION()
	void OnAlt(FKey Key)
	{
	}

	UFUNCTION()
	void OnTab(FKey Key)
	{
	}

	UFUNCTION()
	void OnEscape(FKey Key)
	{
	}

	UFUNCTION()
	void OnEnter(FKey Key)
	{
	}

	UFUNCTION()
	void OnOne(FKey Key)
	{
	}

	UFUNCTION()
	void OnTwo(FKey Key)
	{
	}

	UFUNCTION()
	void OnNine(FKey Key)
	{
	}

	UFUNCTION()
	void OnF1(FKey Key)
	{
	}

	UFUNCTION()
	void OnF12(FKey Key)
	{
	}
}
