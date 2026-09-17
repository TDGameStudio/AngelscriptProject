/**
 * @version v1
 * @summary opIndex must yield the indexed element, so declaring it void is rejected. This file is the illegal program itself; do not give it a return type, since the void return is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary opIndex must yield the indexed element, so declaring it void is rejected. This file is the illegal program itself; do not give it a return type, since the void return is the point.
 * @topic Negative
 */
struct FContainerBadRet
{
	TArray<int> Data;

	/**
	 * Returns nothing where an index operator owes the element.
	 */
	void opIndex(int Index) const
	{
	}
}
/** @end */
