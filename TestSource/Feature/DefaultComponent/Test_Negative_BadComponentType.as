// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_BadComponentType
// Expected diagnostic: DefaultComponent on non-UActorComponent type should fail.
// DiagnosticOnly. Isolation=none.

class ADefCompBadTypeActor : AActor
{
	UPROPERTY(DefaultComponent)
	AActor SubActor;
}
