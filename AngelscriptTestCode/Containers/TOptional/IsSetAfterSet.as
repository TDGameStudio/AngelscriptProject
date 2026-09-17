/**
 * @version v1
 * @summary IsSet is false when unset and true after Set.
 * @topic Containers
 *
 * IsSetAfterSet
 */
/**
 * @begin IsSetAfterSet
 * @summary IsSet is false when unset and true after Set.
 * @topic Containers
 */
bool IsSetAfterSet()
{
	TOptional<int32> Empty;
	TOptional<int32> SetValue;
	SetValue.Set(7);
	return !Empty.IsSet() && SetValue.IsSet();
}
/** @end */
