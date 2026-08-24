// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_DefaultComponentOnNonUPROPERTY
// Expected diagnostic: DefaultComponent on non-UPROPERTY field should fail.
// DiagnosticOnly. Isolation=none.

class ADefCompNoUPropActor : AActor
{
	USceneComponent Root;
	default Root = DefaultComponent;
}
