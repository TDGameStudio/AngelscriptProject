// Theme: Feature.Mixin. NegativeDiagnostic: UPROPERTY mixin on a plain class.
// C++: AngelscriptSyntaxMixinTests.cpp::Negative block 8 AssertFailsToCompile.
// Expected diagnostic: "Mixin with UPROPERTY on non-actor should fail".
// Isolate this failing program. DiagnosticOnly.

mixin class UHealthMixinUPropN
{
	UPROPERTY()
	int Health = 100;
}

class FMyPlainClass
{
	mixin UHealthMixinUPropN;
}
