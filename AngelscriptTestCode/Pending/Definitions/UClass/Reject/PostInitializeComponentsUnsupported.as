/**
 * @version v1
 * @summary BlueprintOverride of PostInitializeComponents on AActor is rejected. That method does not exist in the script-visible Actor superclass.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintOverride of PostInitializeComponents on AActor is rejected. That method does not exist in the script-visible Actor superclass.
 * @topic Negative
 */
UCLASS()
class APostInitializeComponentsUnsupportedActor : AActor
{
	/**
	 * Illegal BlueprintOverride of PostInitializeComponents.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Inputs PostInitializeComponents override on AActor
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void PostInitializeComponents()
	{
	}
}
/** @end */
