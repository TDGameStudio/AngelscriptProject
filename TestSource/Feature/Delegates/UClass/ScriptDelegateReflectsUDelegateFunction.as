/**
 * A script delegate materializes a UDelegateFunction. FCoverageMacroSignal is
 * single-cast; Signal is an FDelegateProperty whose signature exposes int Value.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.ScriptDelegateReflectsUDelegateFunction
 * @Harness UClass
 * @Tag Feature.Delegates.ScriptDelegateReflectsUDelegateFunction
 * @Provenance Theme: Feature.Delegates. WorldStory: script delegate materializes UDelegateFunction.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::ScriptDelegateReflectsUDelegateFunction
 * @Provenance Compile + reflection oracle: FCoverageMacroSignal is single-cast; Signal is FDelegateProperty;
 * @Provenance signature exposes int Value.
 * @Provenance Extra: default-constructed actor non-null; nullptr assignment is the null boundary.
 * @Provenance Keep Signal. FixtureIsolated.
 */

/**
 * A unicast that carries an int payload.
 *
 * @Covers Delegates.Declaration
 * @Inputs Value
 * @Return nothing when executed
 */
delegate void FCoverageMacroSignal(int Value);

UCLASS()
class ACoverageMacrosDelegateActor : AActor
{
	UPROPERTY()
	FCoverageMacroSignal Signal;

	/**
	 * Observe that a default-constructed actor handle is non-null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local ACoverageMacrosDelegateActor
	 * @Return true when the handle is non-null
	 * @Boundary default construct
	 */
	UFUNCTION()
	bool DefaultNonNull()
	{
		ACoverageMacrosDelegateActor Actor;
		return Actor != nullptr;
	}

	/**
	 * Observe that assigning nullptr yields a null handle.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary nullptr assignment
	 */
	UFUNCTION()
	bool NullBoundary()
	{
		ACoverageMacrosDelegateActor Actor = nullptr;
		return Actor == nullptr;
	}
}
