/**
 * @version v1
 * @summary An operator overload whose name is not a recognised operator is rejected. This file is the illegal program itself; do not rename opInvalid to a real operator, since the invalid name is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary An operator overload whose name is not a recognised operator is rejected. This file is the illegal program itself; do not rename opInvalid to a real operator, since the invalid name is the point.
 * @topic Negative
 */
struct FVecInvalid
{
	int X = 0;

	/**
	 * Not a recognised operator name, which is what the case is about.
	 */
	FVecInvalid opInvalid(const FVecInvalid&in Other) const
	{
		return FVecInvalid();
	}
}
/** @end */
