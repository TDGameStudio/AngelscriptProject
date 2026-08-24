// Theme: Optional.GAS. WorldStory: ATestGASActor subclasses AAngelscriptGASActor.
// C++: AngelscriptGASBaseClassTests.cpp::ScriptSubclassInheritsASCFromGASActor
// Oracle: IsChildOf(AAngelscriptGASActor); ImplementsInterface(UAbilitySystemInterface).
// Extra: nullptr handle; empty sibling actor; two handles stay distinct.
// Isolation=none. Optional GAS plugin fixture. Do not spawn from script.

UCLASS()
class ATestGASActor : AAngelscriptGASActor
{
}

UCLASS()
class ATestGASActorEmpty : AAngelscriptGASActor
{
}

bool Observe_ATestGASActor_NullDefault()
{
	ATestGASActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_ATestGASActor_EmptySiblingNull()
{
	ATestGASActorEmpty Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_ATestGASActor_TwoHandlesIndependent(ATestGASActor First, ATestGASActor Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
