// Theme: Feature.Default. WorldStory default statement overrides a bool initializer.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Positive AssertCompiles
// ASSyntaxDS_AttrBool. Oracle: bEnabled is false after default bEnabled = false.
// Extra: empty handle is null; mutating First does not write Second. Keep bEnabled.
// FixtureIsolated.

class AAttrBoolActor : AActor
{
	UPROPERTY()
	bool bEnabled = true;

	default bEnabled = false;
}

bool Observe_AttrBool_EmptyDefaultIsNull()
{
	AAttrBoolActor Actor;
	return Actor == nullptr;
}

bool Observe_AttrBool_DefaultFalse(AAttrBoolActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0303 setup: required AAttrBoolActor is null");
	}
	return !Actor.bEnabled;
}

bool Observe_AttrBool_CopyIndependent(AAttrBoolActor First, AAttrBoolActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0303 setup: required AAttrBoolActor pair is null");
	}
	First.bEnabled = true;
	return !Second.bEnabled;
}
