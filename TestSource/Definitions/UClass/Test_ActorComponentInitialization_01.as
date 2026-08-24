// Theme: Definitions.UClass. NegativeDiagnostic: PostInitializeComponents BlueprintOverride.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::ActorComponentInitialization CompileAndExpectFailure.
// Expected diagnostic: BlueprintOverride method PostInitializeComponents does not exist in superclass Actor.
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class APostInitializeComponentsUnsupportedActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void PostInitializeComponents()
	{
	}
}
