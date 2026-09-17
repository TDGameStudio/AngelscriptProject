/**
 * @version v1
 * @summary GetValue after Reset throws GetValue() called on Optional when not set! Check the optional with IsSet() first.
 * @topic Containers
 *
 * GetValueAfterReset
 */
/**
 * @begin GetValueAfterReset
 * @summary GetValue after Reset throws GetValue() called on Optional when not set! Check the optional with IsSet() first.
 * @topic Containers
 */
void GetValueAfterReset()
{
	TOptional<int32> Optional;
	Optional.Set(7);
	Optional.Reset();
	Optional.GetValue();
}
/** @end */
