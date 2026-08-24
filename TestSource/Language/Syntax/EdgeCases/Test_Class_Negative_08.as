// Theme: Language.Syntax.EdgeCases. C++ originally expected multi-base failure.
// Live C++: Class_Negative block 8 is #if 0 (structural-validation-absent);
// AActor, APawn comma bases compile. CSV NegativeDiagnostic is not a compile-fail.
// sha256=c77f9737749d79f563c0f348c0b0307f066652309f903afe285c980f09c83227; lines 184-186.
// Oracle: AClassMultiBaseActor is declared; default handle is null.
// Extra: assigning aliases the same handle.
// FixtureIsolated value oracle.

class AClassMultiBaseActor : AActor, APawn
{
}

int Observe_MultiBase_IsAActorWhenSet()
{
	AClassMultiBaseActor Actor;
	if (Actor is AActor)
	{
		return 1;
	}
	return 0;
}

int Observe_MultiBase_EmptyDefaultIsNull()
{
	AClassMultiBaseActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_MultiBase_AssignAliases()
{
	AClassMultiBaseActor First;
	AClassMultiBaseActor Second;
	First = Second;
	return First is Second;
}
