/**
 * @version v1
 * @summary A const&in TOptional<FVector> still reports set before Reset.
 * @topic Containers
 *
 * ReadResetClearsFVector
 */
/**
 * @begin ReadResetClearsFVector
 * @summary A const&in TOptional<FVector> still reports set before Reset.
 * @topic Containers
 */
bool ReadResetClearsFVector(const TOptional<FVector>&in Value)
{
	return Value.IsSet() && Value.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
