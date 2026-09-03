/**
 * Native-only component BlueprintOverride callbacks are rejected.
 * OnComponentCreated, InitializeComponent, and OnComponentDestroyed do not
 * exist in the script-visible superclass.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ComponentNativeCallbacksUnsupported
 * @Harness CompileReject
 * @Tag Definitions.UClass.ComponentNativeCallbacksUnsupported
 * @Kind CompileReject
 * @Covers UClass.BlueprintOverride
 * @Inputs OnComponentCreated, InitializeComponent, OnComponentDestroyed BlueprintOverride methods
 * @Return does not compile; diagnostic "BlueprintOverride method OnComponentCreated / InitializeComponent / OnComponentDestroyed does not exist in the superclass"
 * @Provenance Theme: Definitions.UClass. NegativeDiagnostic: native-only component BlueprintOverride callbacks.
 * @Provenance C++: AngelscriptCoverageClassLifecycleTests.cpp::ComponentLifecycle CompileAndExpectFailure.
 * @Provenance Expected diagnostic: BlueprintOverride method OnComponentCreated / InitializeComponent /
 * @Provenance OnComponentDestroyed does not exist in the superclass.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class ULifecycleComponentNativeCallbacksUnsupported : UActorComponent
{
	/**
	 * Illegal BlueprintOverride of OnComponentCreated.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Inputs OnComponentCreated override on UActorComponent
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void OnComponentCreated()
	{
	}

	/**
	 * Illegal BlueprintOverride of InitializeComponent.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Inputs InitializeComponent override on UActorComponent
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void InitializeComponent()
	{
	}

	/**
	 * Illegal BlueprintOverride of OnComponentDestroyed.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Param bDestroyingHierarchy Native destroy flag
	 * @Inputs OnComponentDestroyed override on UActorComponent
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void OnComponentDestroyed(bool bDestroyingHierarchy)
	{
	}
}
