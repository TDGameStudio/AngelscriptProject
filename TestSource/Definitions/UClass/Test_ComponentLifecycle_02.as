// Theme: Definitions.UClass. NegativeDiagnostic: native-only component BlueprintOverride callbacks.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::ComponentLifecycle CompileAndExpectFailure.
// Expected diagnostic: BlueprintOverride method OnComponentCreated / InitializeComponent /
// OnComponentDestroyed does not exist in the superclass.
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ULifecycleComponentNativeCallbacksUnsupported : UActorComponent
{
	UFUNCTION(BlueprintOverride)
	void OnComponentCreated()
	{
	}

	UFUNCTION(BlueprintOverride)
	void InitializeComponent()
	{
	}

	UFUNCTION(BlueprintOverride)
	void OnComponentDestroyed(bool bDestroyingHierarchy)
	{
	}
}
