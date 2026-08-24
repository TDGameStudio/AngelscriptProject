// Theme: Feature.Delegates. Isolated compile-fail.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicMacroNamesAreNotScriptAPIs block 1
// CSV WorldStory is wrong: C++ CompileAndExpectFailure.
// Expected diagnostic: No matching signatures to 'FCoverageDynamicMacroSingle::BindDynamic
// DiagnosticOnly. Isolation=none.

delegate void FCoverageDynamicMacroSingle();

UCLASS()
class ACoverageBindDynamicMacroActor : AActor
{
	UPROPERTY()
	FCoverageDynamicMacroSingle Single;

	UFUNCTION()
	void Handler()
	{
	}

	UFUNCTION()
	void TryBindDynamic()
	{
		Single.BindDynamic(this, n"Handler");
	}
}
