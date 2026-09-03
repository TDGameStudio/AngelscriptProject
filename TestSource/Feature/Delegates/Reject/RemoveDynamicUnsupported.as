/**
 * RemoveDynamic is a C++ macro name, not a script API, so this program is
 * rejected. Script removes multicast listeners with Unbind by object and name.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.RemoveDynamicUnsupported
 * @Harness CompileReject
 * @Tag Feature.Delegates.RemoveDynamicUnsupported
 * @Kind CompileReject
 * @Covers Delegates.DynamicMacro
 * @Inputs Multi.RemoveDynamic(this, n"Handler")
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: C++ RemoveDynamic macro is not an AS API.
 * @Provenance C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicMacroNamesAreNotScriptAPIs block 3
 * @Provenance CompileAndExpectFailure: "No matching signatures to 'FCoverageDynamicMacroEvent::RemoveDynamic".
 * @Provenance C++ module ASCoverageDynamicDelegate_RemoveDynamicUnsupported.
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly. FixtureIsolated.
 */

/**
 * A void multicast used only to name RemoveDynamic.
 *
 * @Kind CompileReject
 * @Covers Delegates.DynamicMacro
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageDynamicMacroEvent();

UCLASS()
class ACoverageRemoveDynamicMacroActor : AActor
{
	UPROPERTY()
	FCoverageDynamicMacroEvent Multi;

	/**
	 * A named handler that is not reachable through RemoveDynamic.
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
	 * The isolated failing program: RemoveDynamic is not a script API.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.DynamicMacro
	 * @Inputs none
	 * @Return does not compile; RemoveDynamic has no matching signature
	 */
	UFUNCTION()
	void TryRemoveDynamic()
	{
		Multi.RemoveDynamic(this, n"Handler");
	}
}
