/**
 * @version v1
 * @summary opEquals must return bool, so declaring it with an int return is rejected. This file is the illegal program itself; do not change the return type, since the wrong return type is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary opEquals must return bool, so declaring it with an int return is rejected. This file is the illegal program itself; do not change the return type, since the wrong return type is the point.
 * @topic Negative
 */
struct FVecEqWrongRet
{
	int X = 0;

	/**
	 * Returns an int where opEquals owes a bool.
	 */
	int opEquals(const FVecEqWrongRet&in Other) const
	{
		return 0;
	}
}
/** @end */
