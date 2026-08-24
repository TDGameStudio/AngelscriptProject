// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_OutsideClass
// Expected diagnostic: DefaultComponent at global scope should fail.
// DiagnosticOnly. Isolation=none. PlannedSymbols empty.

UPROPERTY(DefaultComponent) USceneComponent Root;
