/**
 * @version v1
 * @summary opAdd must take the right-hand operand, so declaring it with no parameter is rejected. This file is the illegal program itself; do not add the parameter, since the missing one is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary opAdd must take the right-hand operand, so declaring it with no parameter is rejected. This file is the illegal program itself; do not add the parameter, since the missing one is the point.
 * @topic Negative
 */
struct FVecBadParams
{
	int X = 0;

	/**
	 * Takes no operand, where a binary operator owes one.
	 */
	FVecBadParams opAdd() const
	{
		return FVecBadParams();
	}
}
/** @end */
