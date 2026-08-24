// Theme: Feature.Inheritance. WorldStory IsA baseline (Before) empty actor.
// C++: AngelscriptInheritanceFunctionalTests.cpp::IsA CompileAnnotatedModuleFromMemory.
// Oracle: ATestInheritanceIsABaseline compiles before reload analysis.
// Extra: empty handle null. FixtureIsolated. Retained: empty actor. Replaced later by _02.

UCLASS()
class ATestInheritanceIsABaseline : AActor
{
}

bool Observe_IsABaseline_EmptyHandleIsNull()
{
	ATestInheritanceIsABaseline Actor;
	return Actor == nullptr;
}

bool Observe_IsABaseline_SpawnedIsActor(ATestInheritanceIsABaseline Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0216 setup: required ATestInheritanceIsABaseline is null");
	}
	return Actor.IsA(AActor::StaticClass());
}
