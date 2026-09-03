/**
 * AddDynamic is a C++ macro name, not a script API, so this program is
 * rejected. Script adds multicast listeners with AddUFunction.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.AddDynamicUnsupported
 * @Harness CompileReject
 * @Tag Feature.Delegates.AddDynamicUnsupported
 * @Kind CompileReject
 * @Covers Delegates.DynamicMacro
 * @Inputs Multi.AddDynamic(this, n"Handler")
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail.
 * @Provenance C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicMacroNamesAreNotScriptAPIs block 2
 * @Provenance CSV WorldStory is wrong: C++ CompileAndExpectFailure.
 * @Provenance Expected diagnostic: No matching signatures to 'FCoverageDynamicMacroEvent::AddDynamic
 * @Provenance C++ module ASCoverageDynamicDelegate_AddDynamicUnsupported.
 * @Provenance DiagnosticOnly. Isolation=none.
 */

/**
 * A void multicast used only to name AddDynamic.
 *
 * @Kind CompileReject
 * @Covers Delegates.DynamicMacro
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageDynamicMacroEvent();

UCLASS()
class ACoverageAddDynamicMacroActor : AActor
{
	UPROPERTY()
	FCoverageDynamicMacroEvent Multi;

	/**
	 * A named handler that is not reachable through AddDynamic.
	 *
	 * @Covers Delegates.DynamicMacro
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void Handler()
	{
	}

	/**
	 * The isolated failing program: AddDynamic is not a script API.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.DynamicMacro
	 * @Inputs none
	 * @Return does not compile; AddDynamic has no matching signature
	 */
	UFUNCTION()
	void TryAddDynamic()
	{
		Multi.AddDynamic(this, n"Handler");
	}
}
