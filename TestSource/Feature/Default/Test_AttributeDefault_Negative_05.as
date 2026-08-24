// Theme: Feature.Default. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile in #if 0
// (#as-engine-behavior: structural-validation-absent) so a valueless default currently compiles.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative ASSyntaxDS_AttrNoValue.
// Oracle: X stays 0. Extra: empty handle is null; write 1 then restore. Keep X.
// FixtureIsolated.

class AAttrNoValActor : AActor
{
	UPROPERTY()
	int X = 0;

	default X;
}

bool Observe_AttrNoVal_EmptyDefaultIsNull()
{
	AAttrNoValActor Actor;
	return Actor == nullptr;
}

int Observe_AttrNoVal_XStaysZero(AAttrNoValActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0312 setup: required AAttrNoValActor is null");
	}
	return Actor.X;
}

int Observe_AttrNoVal_WriteBoundary(AAttrNoValActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0312 setup: required AAttrNoValActor is null");
	}
	int Saved = Actor.X;
	Actor.X = 1;
	int After = Actor.X;
	Actor.X = Saved;
	return After;
}
