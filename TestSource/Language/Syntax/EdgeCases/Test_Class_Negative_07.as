// Theme: Language.Syntax.EdgeCases. C++ originally expected A-prefix failure.
// Live C++: Class_Negative block 7 is #if 0 (naming-convention-unenforced);
// class MyActor : AActor compiles. CSV NegativeDiagnostic is not a compile-fail.
// sha256=538d503fbfcf4bd1125c258d2c8bb5aef7c1dc78393a4259d55e89c6ffa83a2e; lines 175-177.
// Oracle: MyActor is an AActor subclass; default handle is null.
// Extra: assigning aliases the same handle.
// FixtureIsolated value oracle.

class MyActor : AActor
{
}

int Observe_MyActor_IsAActorWhenSet()
{
	MyActor Actor;
	if (Actor is AActor)
	{
		return 1;
	}
	return 0;
}

int Observe_MyActor_EmptyDefaultIsNull()
{
	MyActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_MyActor_AssignAliases()
{
	MyActor First;
	MyActor Second;
	First = Second;
	return First is Second;
}
