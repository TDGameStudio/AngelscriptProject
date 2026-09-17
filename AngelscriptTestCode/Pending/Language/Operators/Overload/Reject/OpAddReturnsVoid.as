/**
 * @version v1
 * @summary opAdd must return the combined value, so declaring it void is rejected. This file is the illegal program itself; do not give it a return type, since the void return is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary opAdd must return the combined value, so declaring it void is rejected. This file is the illegal program itself; do not give it a return type, since the void return is the point.
 * @topic Negative
 */
struct FVecAddVoid
{
	int X = 0;

	/**
	 * Returns nothing where a binary operator owes a result.
	 */
	void opAdd(const FVecAddVoid&in Other) const
	{
	}
}
/** @end */
