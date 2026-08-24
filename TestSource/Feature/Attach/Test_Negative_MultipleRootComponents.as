// Theme: Feature.Attach. NegativeDiagnostic: more than one RootComponent on an actor.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_MultipleRootComponents.
// AssertFailsToCompile is currently #if 0 (#as-engine-behavior structural-validation-absent).
// Expected diagnostic: "Multiple RootComponents should fail".
// Isolate the failing program. DiagnosticOnly.

class ADefCompMultiRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root1;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root2;
}
