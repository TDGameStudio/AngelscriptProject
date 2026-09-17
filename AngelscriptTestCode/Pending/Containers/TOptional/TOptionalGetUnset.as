/**
 * @version v1
 * @summary Get() on an unset TOptional returns the fallback and does not throw.
 * @topic Containers
 */
/**
 * @version root
 * @summary Get() on an unset TOptional returns the fallback and does not throw.
 * @topic Baseline
 */
namespace TOptionalTest
{
	/**
	 * Observe Get on unset: the fallback is returned and the optional stays unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs Default-constructed TOptional<int>; Get(7)
	 * @Return true when Get(7) is 7 and IsSet() is still false
	 */
	UFUNCTION()
	bool GetUnsetReturnsFallbackAndStaysUnset()
	{
		TOptional<int> Opt;
		return Opt.Get(7) == 7 && !Opt.IsSet();
	}
}
/** @end */
