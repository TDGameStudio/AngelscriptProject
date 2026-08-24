// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_OnNonComponentType
// Expected diagnostic: DefaultComponent on non-component type should fail.
// DiagnosticOnly. Isolation=none.

class ADefCompNonCompActor : AActor
{
	UPROPERTY(DefaultComponent)
	int X;
}
