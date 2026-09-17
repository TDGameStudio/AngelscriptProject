/**
 * @version v1
 * @summary Equality compares set state first, then the stored value.
 * @topic Containers
 *
 * EqualityComparesValue
 */
/**
 * @begin EqualityComparesValue
 * @summary Equality compares set state first, then the stored value.
 * @topic Containers
 */
bool EqualityComparesValue()
{
	TOptional<int32> UnsetLeft;
	TOptional<int32> UnsetRight;
	TOptional<int32> Seven(7);
	TOptional<int32> SevenOther(7);
	TOptional<int32> Nine(9);
	return UnsetLeft == UnsetRight && Seven == SevenOther
		&& !(Seven == Nine) && !(UnsetLeft == Seven);
}
/** @end */
