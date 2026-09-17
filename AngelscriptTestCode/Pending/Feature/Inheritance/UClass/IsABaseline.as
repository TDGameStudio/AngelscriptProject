/**
 * @version v1
 * @summary Empty-actor baseline (Before) of the IsA reload pair. C++ compiles ATestInheritanceIsABaseline before AnalyzeReloadFromMemory of the After program. The observer checks that a spawned instance is an AActor.
 * @topic Feature
 */
/**
 * @version root
 * @summary Empty-actor baseline (Before) of the IsA reload pair. C++ compiles ATestInheritanceIsABaseline before AnalyzeReloadFromMemory of the After program. The observer checks that a spawned instance is an AActor.
 * @topic Baseline
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
/** @end */
