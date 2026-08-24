// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_InNonActorClass
// Expected diagnostic: DefaultComponent in non-Actor class should fail.
// C++ AssertFailsToCompile is currently #if 0 (#as-engine-behavior).
// DiagnosticOnly. Isolation=none.

struct FDefCompStruct
{
	UPROPERTY(DefaultComponent)
	USceneComponent Root;
}
