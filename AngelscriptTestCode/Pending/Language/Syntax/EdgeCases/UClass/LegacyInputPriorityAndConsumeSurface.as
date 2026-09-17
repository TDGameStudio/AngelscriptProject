/**
 * @version v1
 * @summary Legacy input priority surface: BindKey's consume flag in both states plus an EnhancedInput debug-key bind. Priority and block-input stay native-owned; the script only supplies the two consume-flagged bindings.
 * @topic Language
 */
/**
 * @version root
 * @summary Legacy input priority surface: BindKey's consume flag in both states plus an EnhancedInput debug-key bind. Priority and block-input stay native-owned; the script only supplies the two consume-flagged bindings.
 * @topic Baseline
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
/** @end */
