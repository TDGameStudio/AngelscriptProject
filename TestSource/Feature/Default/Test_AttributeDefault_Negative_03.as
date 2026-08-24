// Theme: Feature.Default. Isolated compile-fail: default statement at global scope.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
// ASSyntaxDS_AttrGlobal. Expected diagnostic: "Default statement at global scope should fail".
// DiagnosticOnly. PlannedSymbols is empty. Do not wrap this in a class.

default SomeVar = 5;
