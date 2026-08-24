// Theme: Feature.Mixin. NegativeDiagnostic: mixin of a non-mixin class.
// C++: AngelscriptSyntaxMixinTests.cpp::Negative block 6 AssertFailsToCompile.
// Expected diagnostic: "Using non-mixin class as mixin should fail".
// Isolate this failing program. DiagnosticOnly.

class ABaseMixN : AActor
{
}

class AChildMixN : AActor
{
	mixin ABaseMixN;
}
