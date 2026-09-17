/**
 * @version v1
 * @summary IsSet is false when unset and true after Set of false.
 * @topic Containers
 *
 * IsSetAfterSetBool
 */
/**
 * @begin IsSetAfterSetBool
 * @summary IsSet is false when unset and true after Set of false.
 * @topic Containers
 */
bool IsSetAfterSetBool()
{
	TOptional<bool> Empty;
	TOptional<bool> SetValue;
	SetValue.Set(false);
	return !Empty.IsSet() && SetValue.IsSet();
}
/** @end */
