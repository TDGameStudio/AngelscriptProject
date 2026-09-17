/**
 * @version v1
 * @summary A default statement targeting a property that does not exist is rejected. This file is the illegal program itself; do not declare NonExistentProp.
 * @topic Feature
 */
/**
 * @version root
 * @summary A default statement targeting a property that does not exist is rejected. This file is the illegal program itself; do not declare NonExistentProp.
 * @topic Negative
 */
class AAttrNonExistActor : AActor
{
	default NonExistentProp = 42;
}
/** @end */
