// Theme: Language.Syntax.EdgeCases. WorldStory: Abstract UCLASS compiles.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 5 AssertCompiles.
// sha256=c3914ea40925bf350d8ef2f52d785f95c419099fe3199af6f1d5398527445887; lines 87-90.
// Oracle: AMyAbstract is declared Abstract; default handle is null.
// Extra: concrete child EmptyFlag defaults to 0; writing the child does not require spawning the abstract type.
// FixtureIsolated.

UCLASS(Abstract)
class AMyAbstract : AActor
{
}

UCLASS()
class AMyAbstractConcrete : AMyAbstract
{
	int EmptyFlag = 0;
}

int Observe_MyAbstract_DefaultHandleIsNull()
{
	AMyAbstract Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

int Observe_MyAbstract_ConcreteEmptyDefault(AMyAbstractConcrete Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_05 setup: required Actor is null");
	}
	return Actor.EmptyFlag;
}

int Observe_MyAbstract_ConcreteBoundary(AMyAbstractConcrete Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_05 setup: required Actor is null");
	}
	Actor.EmptyFlag = 1;
	return Actor.EmptyFlag;
}
