// Theme: Language.Operators.Overload. Isolated compile-fail: + without opAdd.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative AssertFailsToCompile
// ASSyntaxOONoOp; lines 278-290;
// sha256=d4f5a63e96fec4aeb1ba329b0ebb15c5e5e444ef94f3bfdc045c112914943ad8.
// Expected diagnostic: using + without opAdd overload should fail.
// Do not add opAdd or other declarations that would make this compile.
// DiagnosticOnly.

struct FMyType
{
	int X = 0;
}

void Test()
{
	FMyType A;
	FMyType B;
	FMyType C = A + B;
}
