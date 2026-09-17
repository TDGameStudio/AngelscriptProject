/**
 * @version v1
 * @summary Two default TObjectPtr values compare equal and are null.
 * @topic Containers
 *
 * NullEqualsNull
 */
/**
 * @begin NullEqualsNull
 * @summary Two default TObjectPtr values compare equal and are null.
 * @topic Containers
 */
bool NullEqualsNull()
{
	TObjectPtr<UObject> Left;
	TObjectPtr<UObject> Right;
	return Left == Right && Left.Get() == nullptr && Right.Get() == nullptr;
}
/** @end */
