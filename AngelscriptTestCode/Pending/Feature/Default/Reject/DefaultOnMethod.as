/**
 * @version v1
 * @summary A default statement targeting a method is rejected. Defaults apply to properties, not functions. This file is the illegal program itself; do not replace Foo with a property.
 * @topic Feature
 */
/**
 * @version root
 * @summary A default statement targeting a method is rejected. Defaults apply to properties, not functions. This file is the illegal program itself; do not replace Foo with a property.
 * @topic Negative
 */
class AAttrOnMethodActor : AActor
{
	/**
	 * A method that is not a valid default-statement target.
	 *
	 * @Kind CompileReject
	 * @Covers Default.Attribute
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void Foo()
	{
	}

	default Foo = 0;
}
/** @end */
