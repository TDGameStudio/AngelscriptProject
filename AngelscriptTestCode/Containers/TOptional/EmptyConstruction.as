/**
 * @version v1
 * @summary Default TOptional<int32> and TOptional<FName> are unset.
 * @topic Containers
 *
 * EmptyConstruction
 */
/**
 * @begin EmptyConstruction
 * @summary Default TOptional<int32> and TOptional<FName> are unset.
 * @topic Containers
 */
bool EmptyConstruction()
{
	TOptional<int32> Number;
	TOptional<FName> Name;
	return !Number.IsSet() && !Name.IsSet();
}
/** @end */
