// Theme: Feature.Mixin. NegativeDiagnostic: mixin statement at global scope.
// C++: AngelscriptSyntaxMixinTests.cpp::Negative block 5 AssertFailsToCompile.
// Expected diagnostic: "Mixin at global scope should fail".
// Isolate this failing program. DiagnosticOnly.

mixin class UHealthMixinGlobal
{
	int Health = 100;
}

mixin UHealthMixinGlobal;
