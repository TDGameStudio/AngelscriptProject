/**
 * @version v1
 * @summary GetValue after assigning unset throws GetValue() called on Optional when not set! Check the optional with IsSet() first.
 * @topic Containers
 *
 * GetValueAfterAssignUnset
 */
/**
 * @begin GetValueAfterAssignUnset
 * @summary GetValue after assigning unset throws GetValue() called on Optional when not set! Check the optional with IsSet() first.
 * @topic Containers
 */
void GetValueAfterAssignUnset()
{
	TOptional<int32> Target;
	Target.Set(42);
	TOptional<int32> Unset;
	Target = Unset;
	Target.GetValue();
}
/** @end */
