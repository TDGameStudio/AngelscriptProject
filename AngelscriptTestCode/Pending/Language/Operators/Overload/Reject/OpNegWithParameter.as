/**
 * @version v1
 * @summary opNeg is unary, so declaring it with a parameter is rejected. This file is the illegal program itself; do not drop the parameter, since the extra one is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary opNeg is unary, so declaring it with a parameter is rejected. This file is the illegal program itself; do not drop the parameter, since the extra one is the point.
 * @topic Negative
 */
struct FVecNegParam
{
	int X = 0;

	/**
	 * Takes a parameter where a unary operator owes none.
	 */
	FVecNegParam opNeg(int Dummy) const
	{
		return FVecNegParam();
	}
}
/** @end */
