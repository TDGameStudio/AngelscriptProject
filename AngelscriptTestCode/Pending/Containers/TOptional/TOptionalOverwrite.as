/**
 * @version v1
 * @summary Set then Set again keeps the last value.
 * @topic Containers
 */
/**
 * @version root
 * @summary Set then Set again keeps the last value.
 * @topic Baseline
 */
namespace TOptionalTest
{
	/**
	 * Observe Set overwrite: the second Set replaces the first value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Set
	 * @Inputs TOptional<int> Set(1); Set(2)
	 * @Return true when IsSet() is true and GetValue() is 2
	 */
	UFUNCTION()
	bool OverwriteSetReplacesStoredValue()
	{
		TOptional<int> Opt;
		Opt.Set(1);
		if (!Opt.IsSet() || Opt.GetValue() != 1)
		{
			return false;
		}

		Opt.Set(2);
		return Opt.IsSet() && Opt.GetValue() == 2;
	}
}
/** @end */
