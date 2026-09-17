/**
 * @version v1
 * @summary A reference type is not a UPROPERTY type. This file is the illegal program itself; do not replace int& with a value type.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A reference type is not a UPROPERTY type. This file is the illegal program itself; do not replace int& with a value type.
 * @topic Negative
 */
class AUPropRefTypeActor : AActor
{
	UPROPERTY()
	int& RefProp;
}
/** @end */
