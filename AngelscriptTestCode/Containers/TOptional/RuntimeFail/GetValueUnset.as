/**
 * @version v1
 * @summary GetValue on an unset optional throws GetValue() called on Optional when not set! Check the optional with IsSet() first.
 * @topic Containers
 *
 * GetValueUnset
 */
/**
 * @begin GetValueUnset
 * @summary GetValue on an unset optional throws GetValue() called on Optional when not set! Check the optional with IsSet() first.
 * @topic Containers
 */
void GetValueUnset()
{
	TOptional<int32> Optional;
	Optional.GetValue();
}
/** @end */
