/**
 * Empty-actor baseline (Before) of the Super reload pair. C++ compiles
 * ATestInheritanceSuperBaseline before AnalyzeReloadFromMemory of the After
 * program. The observer checks that a spawned instance is an AActor.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.SuperBaseline
 * @Harness UClass
 * @Tag Feature.Inheritance.SuperBaseline
 * @Provenance Theme: Feature.Inheritance. WorldStory Super baseline (Before) empty actor.
 * @Provenance C++: AngelscriptInheritanceFunctionalTests.cpp::Super CompileAnnotatedModuleFromMemory.
 * @Provenance Oracle: ATestInheritanceSuperBaseline compiles before reload analysis.
 * @Provenance Extra: empty handle null. FixtureIsolated. Retained: empty actor. Replaced later by SuperCallRejected.
 */

UCLASS()
class ATestInheritanceSuperBaseline : AActor
{
	/**
	 * Observe that a spawned baseline instance is an AActor.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.SuperBaseline
	 * @Inputs IsA(AActor::StaticClass())
	 * @Return true when the instance is an AActor
	 */
	UFUNCTION()
	bool SpawnedIsActor()
	{
		return IsA(AActor::StaticClass());
	}
}
