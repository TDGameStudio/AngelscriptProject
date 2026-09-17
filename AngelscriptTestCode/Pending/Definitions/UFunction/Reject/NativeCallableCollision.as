/**
 * @version v1
 * @summary A BlueprintCallable UFUNCTION may not collide with a native AActor method. SetActorHiddenInGame is already specified on AActor. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A BlueprintCallable UFUNCTION may not collide with a native AActor method. SetActorHiddenInGame is already specified on AActor. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionNativeCollisionActor : AActor
{
	/**
	 * Illegal BlueprintCallable that collides with a native AActor method.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs bool bNewHidden
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintCallable)
	void SetActorHiddenInGame(bool bNewHidden)
	{
	}
}
/** @end */
