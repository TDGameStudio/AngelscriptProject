/**
 * BindDynamic is a C++ macro name, not a script API, so this program is
 * rejected. Script binds unicast handlers with BindUFunction.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.BindDynamicUnsupported
 * @Harness CompileReject
 * @Tag Feature.Delegates.BindDynamicUnsupported
 * @Kind CompileReject
 * @Covers Delegates.DynamicMacro
 * @Inputs Single.BindDynamic(this, n"Handler")
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail.
 * @Provenance C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicMacroNamesAreNotScriptAPIs block 1
 * @Provenance CSV WorldStory is wrong: C++ CompileAndExpectFailure.
 * @Provenance Expected diagnostic: No matching signatures to 'FCoverageDynamicMacroSingle::BindDynamic
 * @Provenance C++ module ASCoverageDynamicDelegate_BindDynamicUnsupported.
 * @Provenance DiagnosticOnly. Isolation=none.
 */

/**
 * A void unicast used only to name BindDynamic.
 *
 * @Kind CompileReject
 * @Covers Delegates.DynamicMacro
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FCoverageDynamicMacroSingle();

UCLASS()
class ACoverageBindDynamicMacroActor : AActor
{
	UPROPERTY()
	FCoverageDynamicMacroSingle Single;

	/**
	 * A named handler that is not reachable through BindDynamic.
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
	 * The isolated failing program: BindDynamic is not a script API.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.DynamicMacro
	 * @Inputs none
	 * @Return does not compile; BindDynamic has no matching signature
	 */
	UFUNCTION()
	void TryBindDynamic()
	{
		Single.BindDynamic(this, n"Handler");
	}
}
