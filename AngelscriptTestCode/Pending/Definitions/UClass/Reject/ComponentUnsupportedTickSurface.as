/**
 * @version v1
 * @summary Direct TickComponent override plus PrimaryComponentTick.bCanEverTick is rejected. ELevelTick is not a script data type and bCanEverTick is not a member of FActorComponentTickFunction.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Direct TickComponent override plus PrimaryComponentTick.bCanEverTick is rejected. ELevelTick is not a script data type and bCanEverTick is not a member of FActorComponentTickFunction.
 * @topic Negative
 */
UCLASS()
class ULifecycleComponentUnsupportedTickSurface : UActorComponent
{
	default PrimaryComponentTick.bCanEverTick = true;

	/**
	 * Illegal BlueprintOverride of TickComponent using ELevelTick.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Param DeltaSeconds Tick delta
	 * @Param TickType Unsupported ELevelTick
	 * @Param ThisTickFunction Tick function
	 * @Inputs TickComponent override on UActorComponent
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void TickComponent(float DeltaSeconds, ELevelTick TickType, FActorComponentTickFunction&in ThisTickFunction)
	{
	}
}
/** @end */
