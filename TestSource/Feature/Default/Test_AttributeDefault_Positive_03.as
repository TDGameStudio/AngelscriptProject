// Theme: Feature.Default. WorldStory default statement on a Replicated bool.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Positive AssertCompiles
// ASSyntaxDS_AttrReplicated. Oracle: bReplicates==true after default bReplicates = true.
// Extra: empty handle is null; copy independence. Keep bReplicates.
// FixtureIsolated.

class AAttrRepActor : AActor
{
	UPROPERTY(Replicated)
	bool bReplicates = false;

	default bReplicates = true;
}

bool Observe_AttrRep_EmptyDefaultIsNull()
{
	AAttrRepActor Actor;
	return Actor == nullptr;
}

bool Observe_AttrRep_DefaultTrue(AAttrRepActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0305 setup: required AAttrRepActor is null");
	}
	return Actor.bReplicates;
}

bool Observe_AttrRep_CopyIndependent(AAttrRepActor First, AAttrRepActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0305 setup: required AAttrRepActor pair is null");
	}
	First.bReplicates = false;
	return Second.bReplicates;
}
