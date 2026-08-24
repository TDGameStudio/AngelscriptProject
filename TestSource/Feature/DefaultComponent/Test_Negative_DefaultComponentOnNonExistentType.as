// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_DefaultComponentOnNonExistentType
// Expected diagnostic: DefaultComponent with non-existent component type should fail.
// DiagnosticOnly. Isolation=none.

class ADefCompBadTypeNameActor : AActor
{
	UPROPERTY(DefaultComponent)
	UNonExistentComponent Comp;
}
