/**
 * @version v1
 * @summary A const&in TArray<float> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumFloat
 */
/**
 * @begin ReadEmptyClearsNumFloat
 * @summary A const&in TArray<float> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumFloat(const TArray<float>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
