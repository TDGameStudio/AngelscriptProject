/**
 * Legacy input priority surface: BindKey's consume flag in both states plus an
 * EnhancedInput debug-key bind. Priority and block-input stay native-owned; the
 * script only supplies the two consume-flagged bindings.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.LegacyInputPriorityAndConsumeSurface
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.LegacyInputPriorityAndConsumeSurface
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::LegacyInputPriorityAndConsumeSurface
 * @Provenance sha256=63e3318b1d49d02335caf3993e268739e705cd3a913f8ac6a3859adad22cde5d; lines 2042-2067.
 * @Provenance Oracle after Configure: InputComponent Priority 17 and bBlockInput stay native-owned;
 * @Provenance two BindKey entries, [0].bConsumeInput false, [1].bConsumeInput true.
 * @Provenance Extra: unbound local actor has no input component side effects.
 * @Provenance FixtureIsolated. n"OnDebug" bind name. ConfigureDebug is the EnhancedInput sibling.
 */

UCLASS()
class ALegacyInputPriorityActor : AActor
{
	/**
	 * Binds two keys with opposite consume flags.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an input component to configure
	 * @Return nothing; two bindings with differing consume flags exist
	 * @Param InputComponent the component receiving the bindings
	 */
	UFUNCTION()
	void Configure(UInputComponent InputComponent)
	{
		FInputActionHandlerDynamicSignature Delegate;
		InputComponent.BindKey(EKeys::One, EInputEvent::IE_Pressed, Delegate, false);
		InputComponent.BindKey(EKeys::Two, EInputEvent::IE_Pressed, Delegate, true);
	}

	/**
	 * The debug-key handler bound through EnhancedInput.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key and action value
	 * @Return nothing
	 * @Param Key the triggering key
	 * @Param Value the action value
	 */
	UFUNCTION()
	void OnDebug(FKey Key, FInputActionValue Value)
	{
	}

	/**
	 * Binds a debug key through EnhancedInput.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an enhanced input component to configure
	 * @Return nothing; the debug-key binding exists
	 * @Param InputComponent the component receiving the binding
	 */
	UFUNCTION()
	void ConfigureDebug(UEnhancedInputComponent InputComponent)
	{
		FInputDebugKeyHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, n"OnDebug");
		InputComponent.BindDebugKey(FInputChord(EKeys::Three), EInputEvent::IE_Pressed, Delegate, false);
	}

	/**
	 * Observe that a locally constructed actor has no input component effects.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a locally constructed actor
	 * @Return true once construction completes
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool LegacyInputPriorityLocalConstruct()
	{
		ALegacyInputPriorityActor Actor;
		return true;
	}
}
