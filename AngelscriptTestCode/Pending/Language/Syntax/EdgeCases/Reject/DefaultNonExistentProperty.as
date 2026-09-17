/**
 * @version v1
 * @summary A `default` statement naming a property that does not exist is rejected. This file is the illegal program itself; do not declare the missing property, since the unknown name is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A `default` statement naming a property that does not exist is rejected. This file is the illegal program itself; do not declare the missing property, since the unknown name is the point.
 * @topic Negative
 */
UCLASS()
class UDefaultNonExistentCarrier : UObject
{
	default NoSuchProperty = 1;
}
/** @end */
