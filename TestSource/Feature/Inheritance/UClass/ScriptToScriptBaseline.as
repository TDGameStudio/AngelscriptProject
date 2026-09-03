/**
 * Empty-actor baseline (Before) of the ScriptToScript reload pair. C++ compiles
 * ATestInheritanceBaseline before AnalyzeReloadFromMemory of the After program.
 * The observer checks that a spawned instance is an AActor.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.ScriptToScriptBaseline
 * @Harness UClass
 * @Tag Feature.Inheritance.ScriptToScriptBaseline
 * @Provenance Theme: Feature.Inheritance. WorldStory ScriptToScript baseline (Before) empty actor.
 * @Provenance C++: AngelscriptInheritanceFunctionalTests.cpp::ScriptToScript CompileAnnotatedModuleFromMemory.
 * @Provenance Oracle: baseline ATestInheritanceBaseline compiles before reload analysis.
 * @Provenance Extra: empty handle null. FixtureIsolated. Retained: empty actor. Replaced later by ScriptToScriptOverrideRejected.
 */

UCLASS()
class ATestInheritanceBaseline : AActor
{
	/**
	 * Observe that a spawned baseline instance is an AActor.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptToScriptBaseline
	 * @Inputs IsA(AActor::StaticClass())
	 * @Return true when the instance is an AActor
	 */
	UFUNCTION()
	bool SpawnedIsActor()
	{
		return IsA(AActor::StaticClass());
	}
}
