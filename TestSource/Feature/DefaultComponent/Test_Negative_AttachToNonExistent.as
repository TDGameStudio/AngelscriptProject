// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_AttachToNonExistent
// Expected diagnostic: Attach to non-existent component should fail.
// DiagnosticOnly. Isolation=none.

class ADefCompBadAttachActor : AActor
{
	UPROPERTY(DefaultComponent, Attach = NonExistent)
	USceneComponent Child;
}
