/**
 * @version v1
 * @summary An &out TArray<FLinearColor> is filled with Red, (0.25,0.5,0.75,1), and Blue.
 * @topic Containers
 *
 * FillByFLinearColorArray
 */
/**
 * @begin FillByFLinearColorArray
 * @summary An &out TArray<FLinearColor> is filled with Red, (0.25,0.5,0.75,1), and Blue.
 * @topic Containers
 */
void FillByFLinearColorArray(TArray<FLinearColor>&out Result)
{
	Result.Add(FLinearColor::Red);
	Result.Add(FLinearColor(0.25f, 0.5f, 0.75f, 1.0f));
	Result.Add(FLinearColor::Blue);
}
/** @end */
