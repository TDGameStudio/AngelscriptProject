// Theme: Definitions.UProperty. Isolated compile-fail: UPROPERTY at global scope.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
// UPropSN_GlobalScope; lines 243-245;
// sha256=256c73781ffc837923bf85556761fab857fec4ac5609c028d8332b1cfc68d339.
// Expected diagnostic: UPROPERTY at global scope should fail.
// DiagnosticOnly. Isolated failing program.

UPROPERTY() int GlobalVar = 0;
