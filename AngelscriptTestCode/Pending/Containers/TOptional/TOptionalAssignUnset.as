/**
 * @version v1
 * @summary Assigning an unset TOptional unsets a previously set target.
 * @topic Containers
 */
/**
 * @version root
 * @summary Assigning an unset TOptional unsets a previously set target.
 * @topic Baseline
 */
namespace TOptionalTest
{
	/**
	 * Observe optional-to-optional assign of unset: the target becomes unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Target Set(42); assign a default-constructed unset TOptional<int>
	 * @Return true when the target IsSet() is false
	 */
	UFUNCTION()
	bool AssignUnsetOptionalPropagatesUnset()
	{
		TOptional<int> Target;
		Target.Set(42);
		if (!Target.IsSet())
		{
			return false;
		}

		TOptional<int> Unset;
		Target = Unset;
		return !Target.IsSet();
	}
}
/** @end */
