// Theme: Language.Syntax.EdgeCases. C++ originally expected inherit-from-final failure.
// Live C++: Class_Negative block 9 is #if 0 (structural-validation-absent);
// AChildInheritActor : AFinalInheritActor compiles. CSV NegativeDiagnostic is not a compile-fail.
// sha256=74a3ccf165abb20eee4875e6e54300d3fe299a7b00f54aa1040a9a1d2983c6d5; lines 193-196.
// Oracle: child of a final actor is a usable type; default child handle is null.
// Extra: assigning aliases the same child handle.
// FixtureIsolated value oracle.

class AFinalInheritActor : AActor final
{
}

class AChildInheritActor : AFinalInheritActor
{
}

int Observe_InheritFinal_ChildIsFinalWhenSet()
{
	AChildInheritActor Child;
	if (Child is AFinalInheritActor)
	{
		return 1;
	}
	return 0;
}

int Observe_InheritFinal_EmptyChildDefaultNull()
{
	AChildInheritActor Child;
	if (Child is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_InheritFinal_AssignAliases()
{
	AChildInheritActor First;
	AChildInheritActor Second;
	First = Second;
	return First is Second;
}
