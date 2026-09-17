/**
 * @version v1
 * @summary A script parent whose defaults a Blueprint child must preserve on both the CDO and any instance. C++ reads the counter, toggle and label off both classes.
 * @topic World
 */
/**
 * @version root
 * @summary A script parent whose defaults a Blueprint child must preserve on both the CDO and any instance. C++ reads the counter, toggle and label off both classes.
 * @topic Baseline
 */
UCLASS()
class ATestBPChildDefaultPreservationParent : AActor
{
	UPROPERTY()
	int DefaultCounter = 23;

	UPROPERTY()
	bool bDefaultToggle = true;

	UPROPERTY()
	FString DefaultLabel = "ScriptParentDefault";
}

/**
 * The sibling holding the emptied defaults, which C++ uses as the empty boundary.
 * Its UPROPERTYs are part of the fixture and must be kept.
 *
 * @Covers Blueprint.DefaultPreservation
 * @Inputs none
 * @Return an actor identical in shape but with a zeroed counter, a clear toggle and an empty label
 * @Boundary emptied defaults
 */
UCLASS()
class ATestBPChildDefaultPreservationParentEmpty : AActor
{
	UPROPERTY()
	int DefaultCounter = 0;

	UPROPERTY()
	bool bDefaultToggle = false;

	UPROPERTY()
	FString DefaultLabel = "";
}
/** @end */
