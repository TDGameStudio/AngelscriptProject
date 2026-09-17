/**
 * @version v1
 * @summary Set then Reset leaves TOptional unset.
 * @topic Containers
 */
/**
 * @version root
 * @summary Set then Reset leaves TOptional unset.
 * @topic Baseline
 */
namespace TOptionalTest
{
	/**
	 * Observe Reset after Set: presence is cleared.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs TOptional<int> Set(1); Reset()
	 * @Return true when IsSet() is false after Reset
	 */
	UFUNCTION()
	bool ResetAfterSetReportsUnset()
	{
		TOptional<int> Opt;
		Opt.Set(1);
		if (!Opt.IsSet())
		{
			return false;
		}

		Opt.Reset();
		return !Opt.IsSet();
	}
}
/** @end */
