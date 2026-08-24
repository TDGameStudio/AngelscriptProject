// Theme: Language.Operators.Assignment. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
// sha256=7daf23899fba46c66b91f4b1456804a63bdf1a09b812dadf14b19ffba41174a2; lines 504-506.
// Expected compile failure: "String assigned to int".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = 0;
	X = "hello";
}
