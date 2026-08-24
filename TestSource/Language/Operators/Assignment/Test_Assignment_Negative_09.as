// Theme: Language.Operators.Assignment. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
// sha256=223bc510bde708c6ae0bbbf89514ef640e18c74dd635481148d7136a4dfd4b72; lines 549-551.
// Expected compile failure: "Mod-assign on float".
// C++ currently #if 0 this case (#as-engine-behavior: float %= is allowed).
// DiagnosticOnly. Isolated failing program.

void Test()
{
	float X = 1.0f;
	X %= 2.0f;
}
