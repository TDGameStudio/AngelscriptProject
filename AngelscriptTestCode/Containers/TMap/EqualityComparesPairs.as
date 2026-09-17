/**
 * @version v1
 * @summary Equality compares pairs regardless of insertion order.
 * @topic Containers
 *
 * EqualityComparesPairs
 */
/**
 * @begin EqualityComparesPairs
 * @summary Equality compares pairs regardless of insertion order.
 * @topic Containers
 */
bool EqualityComparesPairs()
{
	TMap<FName, int32> Left;
	Left.Add(n"Alpha", 1);
	Left.Add(n"Beta", 2);
	TMap<FName, int32> Right;
	Right.Add(n"Beta", 2);
	Right.Add(n"Alpha", 1);
	TMap<FName, int32> EmptyLeft;
	TMap<FName, int32> EmptyRight;
	TMap<FName, int32> Different;
	Different.Add(n"Alpha", 1);
	return Left == Right && EmptyLeft == EmptyRight && !(Left == EmptyLeft) && !(Left == Different);
}
/** @end */
