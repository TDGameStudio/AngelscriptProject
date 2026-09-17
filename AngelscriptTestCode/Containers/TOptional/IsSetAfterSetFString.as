/**
 * @version v1
 * @summary IsSet is false when unset and true after Set on TOptional<FString>.
 * @topic Containers
 *
 * IsSetAfterSetFString
 */
/**
 * @begin IsSetAfterSetFString
 * @summary IsSet is false when unset and true after Set on TOptional<FString>.
 * @topic Containers
 */
bool IsSetAfterSetFString()
{
	TOptional<FString> Empty;
	TOptional<FString> SetValue;
	SetValue.Set("alpha");
	TOptional<FString> EmptyText;
	EmptyText.Set("");
	return !Empty.IsSet() && SetValue.IsSet() && EmptyText.IsSet();
}
/** @end */
