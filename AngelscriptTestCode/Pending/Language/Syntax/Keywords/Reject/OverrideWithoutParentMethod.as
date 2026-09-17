/**
 * @version v1
 * @summary The override keyword requires a matching method on the parent. Declaring it on a method the parent does not have is rejected.
 * @topic Language
 */
/**
 * @version root
 * @summary The override keyword requires a matching method on the parent. Declaring it on a method the parent does not have is rejected.
 * @topic Negative
 */
/**
 * A class declaring an override that no parent method matches.
 *
 * @Covers Syntax.Keywords
 * @Inputs none
 * @Return does not compile
 */
class AActorOvrdNoParent : AActor
{
	/**
	 * Attempt to override a method the parent does not declare.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs none
	 * @Return does not compile
	 */
	void NonExistentMethod() override
	{
	}
}
/** @end */
