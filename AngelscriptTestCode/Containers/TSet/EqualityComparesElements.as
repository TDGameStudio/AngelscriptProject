/**
 * @version v1
 * @summary Equality compares membership, not insertion order.
 * @topic Containers
 *
 * EqualityComparesElements
 */
/**
 * @begin EqualityComparesElements
 * @summary Equality compares membership, not insertion order.
 * @topic Containers
 */
bool EqualityComparesElements()
{
	TSet<int32> Left;
	Left.Add(1);
	Left.Add(2);
	TSet<int32> Right;
	Right.Add(2);
	Right.Add(1);
	TSet<int32> EmptyLeft;
	TSet<int32> EmptyRight;
	TSet<int32> Different;
	Different.Add(1);
	return Left == Right
		&& EmptyLeft == EmptyRight
		&& !(Left == EmptyLeft)
		&& !(Left == Different);
}
/** @end */
