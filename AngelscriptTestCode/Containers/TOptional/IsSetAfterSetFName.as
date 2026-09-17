/**
 * @version v1
 * @summary IsSet is false when unset and true after Set on TOptional<FName>.
 * @topic Containers
 *
 * IsSetAfterSetFName
 */
/**
 * @begin IsSetAfterSetFName
 * @summary IsSet is false when unset and true after Set on TOptional<FName>.
 * @topic Containers
 */
bool IsSetAfterSetFName()
{
	TOptional<FName> Empty;
	TOptional<FName> SetValue;
	SetValue.Set(n"Red");
	return !Empty.IsSet() && SetValue.IsSet();
}
/** @end */
