// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_AttachToSelf
// Expected diagnostic: DefaultComponent attaching to self should fail.
// C++ AssertFailsToCompile is currently #if 0 (#as-engine-behavior).
// DiagnosticOnly. Isolation=none.

class ADefCompSelfActor : AActor
{
	UPROPERTY(DefaultComponent, Attach = Myself)
	USceneComponent Myself;
}
