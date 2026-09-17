/**
 * @version v1
 * @summary A default statement whose value does not match the property type is rejected. This file is the illegal program itself; do not change the string literal to an int.
 * @topic Feature
 */
/**
 * @version root
 * @summary A default statement whose value does not match the property type is rejected. This file is the illegal program itself; do not change the string literal to an int.
 * @topic Negative
 */
class AAttrTypeMismatchActor : AActor
{
	UPROPERTY()
	int Health = 0;

	default Health = "hello";
}
/** @end */
