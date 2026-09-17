/**
 * @version v1
 * @summary opCmp must return int, so declaring it with a float return is rejected. This file is the illegal program itself; do not change the return type, since the wrong return type is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary opCmp must return int, so declaring it with a float return is rejected. This file is the illegal program itself; do not change the return type, since the wrong return type is the point.
 * @topic Negative
 */
struct FValCmpWrongRet
{
	int Value = 0;

	/**
	 * Returns a float where opCmp owes an int.
	 */
	float opCmp(const FValCmpWrongRet&in Other) const
	{
		return 0.0f;
	}
}
/** @end */
