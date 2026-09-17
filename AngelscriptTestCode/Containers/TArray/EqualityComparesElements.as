/**
 * @version v1
 * @summary Equality compares element sequences; empty arrays are equal and differing contents are not.
 * @topic Containers
 *
 * EqualityComparesElements
 */
/**
 * @begin EqualityComparesElements
 * @summary Equality compares element sequences; empty arrays are equal and differing contents are not.
 * @topic Containers
 */
bool EqualityComparesElements()
{
	TArray<int32> Left;
	Left.Add(1);
	Left.Add(2);
	TArray<int32> Right;
	Right.Add(1);
	Right.Add(2);
	TArray<int32> EmptyLeft;
	TArray<int32> EmptyRight;
	TArray<int32> Different;
	Different.Add(1);
	return Left == Right && EmptyLeft == EmptyRight && !(Left == EmptyLeft) && !(Left == Different);
}
/** @end */
