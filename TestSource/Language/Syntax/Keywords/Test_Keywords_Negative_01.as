// Theme: Language.Syntax.Keywords. NegativeDiagnostic: this outside a class.
// C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Negative block 1 AssertFailsToCompile.
// sha256=ab6b0688e98283e61eeb8924445366b21acd4e99f12bd7fd76b30e5d540261d1; lines 178-180.
// Expected diagnostic: "this outside class should fail". Isolate this failing program.
// DiagnosticOnly.

void Test()
{
	auto X = this;
}
