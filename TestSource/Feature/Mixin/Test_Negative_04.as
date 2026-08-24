// Theme: Feature.Mixin. NegativeDiagnostic: the same mixin applied twice.
// C++: AngelscriptSyntaxMixinTests.cpp::Negative block 4 AssertFailsToCompile.
// Expected diagnostic: "Duplicate mixin application should fail".
// Isolate this failing program. DiagnosticOnly.

mixin class UHealthMixinDup
{
	int Health = 100;
}

class AMixDupActor : AActor
{
	mixin UHealthMixinDup;
	mixin UHealthMixinDup;
}
