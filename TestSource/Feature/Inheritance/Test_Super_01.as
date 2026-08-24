// Theme: Feature.Inheritance. WorldStory Super baseline (Before) empty actor.
// C++: AngelscriptInheritanceFunctionalTests.cpp::Super CompileAnnotatedModuleFromMemory.
// Oracle: ATestInheritanceSuperBaseline compiles before reload analysis.
// Extra: empty handle null. FixtureIsolated. Retained: empty actor. Replaced later by _02.

UCLASS()
class ATestInheritanceSuperBaseline : AActor
{
}

bool Observe_SuperBaseline_EmptyHandleIsNull()
{
	ATestInheritanceSuperBaseline Actor;
	return Actor == nullptr;
}

bool Observe_SuperBaseline_SpawnedIsActor(ATestInheritanceSuperBaseline Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0214 setup: required ATestInheritanceSuperBaseline is null");
	}
	return Actor.IsA(AActor::StaticClass());
}
