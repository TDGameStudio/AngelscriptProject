// Theme: Feature.Default. Positive default statement calling inherited SetReplicates.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Positive AssertCompiles
// ASSyntaxDS_AttrInherited. Oracle: GetIsReplicated() is true.
// Extra: empty handle is null; two spawned pawns remain distinct.
// DefaultSafe.

class AMyPawn : APawn
{
	default SetReplicates(true);
}

bool Observe_AttrInherited_EmptyDefaultIsNull()
{
	AMyPawn Pawn;
	return Pawn == nullptr;
}

bool Observe_AttrInherited_SetReplicatesTrue(AMyPawn Pawn)
{
	if (Pawn == nullptr)
	{
		throw("TS-FEAT-0306 setup: required AMyPawn is null");
	}
	return Pawn.GetIsReplicated();
}

bool Observe_AttrInherited_TwoHandlesIndependent(AMyPawn First, AMyPawn Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0306 setup: required AMyPawn pair is null");
	}
	return First != Second;
}
