/**
 * @version v1
 * @summary Declaring opAdd twice in one type is rejected: the operator would have no single definition. This file is the illegal program itself; do not drop either overload or rename one, since the duplication is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaring opAdd twice in one type is rejected: the operator would have no single definition. This file is the illegal program itself; do not drop either overload or rename one, since the duplication is the point.
 * @topic Negative
 */
struct FVecDupAdd
{
	int X = 0;

	/**
	 * The first of two identical opAdd declarations.
	 */
	FVecDupAdd opAdd(const FVecDupAdd&in Other) const
	{
		return FVecDupAdd();
	}

	/**
	 * The second of two identical opAdd declarations.
	 */
	FVecDupAdd opAdd(const FVecDupAdd&in Other) const
	{
		return FVecDupAdd();
	}
}
/** @end */
