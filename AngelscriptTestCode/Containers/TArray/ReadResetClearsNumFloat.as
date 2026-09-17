/**
 * @version v1
 * @summary A const&in TArray<float> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumFloat
 */
/**
 * @begin ReadResetClearsNumFloat
 * @summary A const&in TArray<float> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumFloat(const TArray<float>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
