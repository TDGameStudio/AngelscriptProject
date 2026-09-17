/**
 * @version v1
 * @summary TSubclassOf of a non-UObject type is rejected. This file is the illegal program itself; do not replace int with a UObject-derived class.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TSubclassOf of a non-UObject type is rejected. This file is the illegal program itself; do not replace int with a UObject-derived class.
 * @topic Negative
 */
class AUPropSubNonObjActor : AActor
{
	UPROPERTY()
	TSubclassOf<int> BadClass;
}
/** @end */
