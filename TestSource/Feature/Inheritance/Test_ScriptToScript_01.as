// Theme: Feature.Inheritance. WorldStory ScriptToScript baseline (Before) empty actor.
// C++: AngelscriptInheritanceFunctionalTests.cpp::ScriptToScript CompileAnnotatedModuleFromMemory.
// Oracle: baseline ATestInheritanceBaseline compiles before reload analysis.
// Extra: empty handle null. FixtureIsolated. Retained: empty actor. Replaced later by _02.

UCLASS()
class ATestInheritanceBaseline : AActor
{
}

bool Observe_ScriptToScriptBaseline_EmptyHandleIsNull()
{
	ATestInheritanceBaseline Actor;
	return Actor == nullptr;
}

bool Observe_ScriptToScriptBaseline_SpawnedIsActor(ATestInheritanceBaseline Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0212 setup: required ATestInheritanceBaseline is null");
	}
	return Actor.IsA(AActor::StaticClass());
}
