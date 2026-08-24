// Theme: Language.Syntax.EdgeCases. WorldStory: BindKey consume flags and debug-key bind.
// C++: AngelscriptCoverageInputTests.cpp::LegacyInputPriorityAndConsumeSurface
// sha256=63e3318b1d49d02335caf3993e268739e705cd3a913f8ac6a3859adad22cde5d; lines 2042-2067.
// Oracle after Configure: InputComponent Priority 17 and bBlockInput stay native-owned;
// two BindKey entries, [0].bConsumeInput false, [1].bConsumeInput true.
// Extra: unbound local actor has no input component side effects.
// FixtureIsolated. n"OnDebug" bind name. ConfigureDebug is the EnhancedInput sibling.

UCLASS()
class ALegacyInputPriorityActor : AActor
{
	UFUNCTION()
	void Configure(UInputComponent InputComponent)
	{
		FInputActionHandlerDynamicSignature Delegate;
		InputComponent.BindKey(EKeys::One, EInputEvent::IE_Pressed, Delegate, false);
		InputComponent.BindKey(EKeys::Two, EInputEvent::IE_Pressed, Delegate, true);
	}

	UFUNCTION()
	void OnDebug(FKey Key, FInputActionValue Value)
	{
	}

	UFUNCTION()
	void ConfigureDebug(UEnhancedInputComponent InputComponent)
	{
		FInputDebugKeyHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, n"OnDebug");
		InputComponent.BindDebugKey(FInputChord(EKeys::Three), EInputEvent::IE_Pressed, Delegate, false);
	}
}

void Observe_LegacyInputPriority_LocalConstruct()
{
	ALegacyInputPriorityActor Actor;
}
