// Theme: Feature.Delegates. Isolated compile-fail: C++ RemoveDynamic macro is not an AS API.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicMacroNamesAreNotScriptAPIs block 3
// CompileAndExpectFailure: "No matching signatures to 'FCoverageDynamicMacroEvent::RemoveDynamic".
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly. FixtureIsolated.

event void FCoverageDynamicMacroEvent();

UCLASS()
class ACoverageRemoveDynamicMacroActor : AActor
{
	UPROPERTY()
	FCoverageDynamicMacroEvent Multi;

	UFUNCTION()
	void Handler()
	{
	}

	UFUNCTION()
	void TryRemoveDynamic()
	{
		Multi.RemoveDynamic(this, n"Handler");
	}
}
