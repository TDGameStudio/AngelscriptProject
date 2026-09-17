/**
 * @version v1
 * @summary A script parent that C++ matches to the Blueprint asset by its marker value.
 * @topic World
 */
/**
 * @version root
 * @summary A script parent that C++ matches to the Blueprint asset by its marker value.
 * @topic Baseline
 */
UCLASS()
class ATestBPImpactScriptParentMatch : AActor
{
	UPROPERTY()
	int Marker = 1;
}

/**
 * The sibling holding the zeroed marker, which C++ uses as the empty boundary. Its
 * UPROPERTY is part of the fixture and must be kept.
 *
 * @Covers Blueprint.ScriptParentMatch
 * @Inputs none
 * @Return an actor identical in shape but with Marker 0
 * @Boundary zeroed marker
 */
UCLASS()
class ATestBPImpactScriptParentMatchEmpty : AActor
{
	UPROPERTY()
	int Marker = 0;
}
/** @end */
