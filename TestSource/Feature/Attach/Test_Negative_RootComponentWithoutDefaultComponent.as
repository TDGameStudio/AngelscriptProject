// Theme: Feature.Attach. NegativeDiagnostic: RootComponent without DefaultComponent.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_RootComponentWithoutDefaultComponent.
// AssertFailsToCompile is currently #if 0 (#as-engine-behavior structural-validation-absent).
// Expected diagnostic: "RootComponent without DefaultComponent should fail".
// Isolate the failing program. DiagnosticOnly.

class ADefCompRootOnlyActor : AActor
{
	UPROPERTY(RootComponent)
	USceneComponent Root;
}
