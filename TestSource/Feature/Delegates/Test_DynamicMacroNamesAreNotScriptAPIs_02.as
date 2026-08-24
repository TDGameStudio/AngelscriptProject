// Theme: Feature.Delegates. Isolated compile-fail.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicMacroNamesAreNotScriptAPIs block 2
// CSV WorldStory is wrong: C++ CompileAndExpectFailure.
// Expected diagnostic: No matching signatures to 'FCoverageDynamicMacroEvent::AddDynamic
// DiagnosticOnly. Isolation=none.

event void FCoverageDynamicMacroEvent();

UCLASS()
class ACoverageAddDynamicMacroActor : AActor
{
	UPROPERTY()
	FCoverageDynamicMacroEvent Multi;

	UFUNCTION()
	void Handler()
	{
	}

	UFUNCTION()
	void TryAddDynamic()
	{
		Multi.AddDynamic(this, n"Handler");
	}
}
