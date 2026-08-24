// Theme: Language.Operators.Overload. Isolated compile-fail: global opAdd.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOGlobal
// lines 271-273;
// sha256=e0fac472b0f80e7aeaac47f6b1335e47b0f289cd5d459c7fa41e366c08053e94.
// Expected diagnostic: operator overload at global scope should fail.
// C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
// DiagnosticOnly. Isolated failing program.

int opAdd(int A, int B)
{
	return A + B;
}
