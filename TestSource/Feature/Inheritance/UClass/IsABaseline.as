/**
 * Empty-actor baseline (Before) of the IsA reload pair. C++ compiles
 * ATestInheritanceIsABaseline before AnalyzeReloadFromMemory of the After
 * program. The observer checks that a spawned instance is an AActor.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.IsABaseline
 * @Harness UClass
 * @Tag Feature.Inheritance.IsABaseline
 * @Provenance Theme: Feature.Inheritance. WorldStory IsA baseline (Before) empty actor.
 * @Provenance C++: AngelscriptInheritanceFunctionalTests.cpp::IsA CompileAnnotatedModuleFromMemory.
 * @Provenance Oracle: ATestInheritanceIsABaseline compiles before reload analysis.
 * @Provenance Extra: empty handle null. FixtureIsolated. Retained: empty actor. Replaced later by IsADerivedCast.
 */

UCLASS()
class ATestInheritanceIsABaseline : AActor
{
	/**
	 * Observe that a spawned baseline instance is an AActor.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.IsABaseline
	 * @Inputs IsA(AActor::StaticClass())
	 * @Return true when the instance is an AActor
	 */
	UFUNCTION()
	bool SpawnedIsActor()
	{
		return IsA(AActor::StaticClass());
	}
}
