/**
 * @version v1
 * @summary ReplicatedUsing without a notify function name is rejected. This file is the illegal program itself; do not add OnRep_X.
 * @topic Definitions
 */
/**
 * @version root
 * @summary ReplicatedUsing without a notify function name is rejected. This file is the illegal program itself; do not add OnRep_X.
 * @topic Negative
 */
class AUPropRepNoFuncActor : AActor
{
	UPROPERTY(ReplicatedUsing)
	int X = 0;
}
/** @end */
