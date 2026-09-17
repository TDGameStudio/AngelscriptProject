/**
 * @version v1
 * @summary Two parentless begin cases.
 * @topic Language
 *
 * alpha   // first case
 * beta    // second case
 */
/**
 * @begin alpha
 * @summary First parentless case.
 * @topic Casting
 *
 * alpha
 */
/**
 * @function AlphaValue
 * @summary Returns the alpha constant.
 * @inputs none
 * @return 1
 */
int AlphaValue()
{
	return /** @range-begin alpha-const */1/** @range-end alpha-const */;
}
/** @end */
/**
 * @begin beta
 * @summary Second parentless case.
 */
int Beta = 2;
/** @end */
