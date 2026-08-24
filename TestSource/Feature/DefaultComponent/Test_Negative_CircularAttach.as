// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_CircularAttach
// Expected diagnostic: Circular attachment should fail.
// C++ AssertFailsToCompile is currently #if 0 (#as-engine-behavior).
// DiagnosticOnly. Isolation=none.

class ADefCompCircularActor : AActor
{
	UPROPERTY(DefaultComponent, Attach = CompB)
	USceneComponent CompA;

	UPROPERTY(DefaultComponent, Attach = CompA)
	USceneComponent CompB;
}
