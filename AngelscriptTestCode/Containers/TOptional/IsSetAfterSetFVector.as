/**
 * @version v1
 * @summary IsSet is false when unset and true after Set on TOptional<FVector>.
 * @topic Containers
 *
 * IsSetAfterSetFVector
 */
/**
 * @begin IsSetAfterSetFVector
 * @summary IsSet is false when unset and true after Set on TOptional<FVector>.
 * @topic Containers
 */
bool IsSetAfterSetFVector()
{
	TOptional<FVector> Empty;
	TOptional<FVector> SetValue;
	SetValue.Set(FVector(0.0f, 0.0f, 0.0f));
	return !Empty.IsSet() && SetValue.IsSet();
}
/** @end */
