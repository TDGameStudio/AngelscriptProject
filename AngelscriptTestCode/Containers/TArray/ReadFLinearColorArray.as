/**
 * @version v1
 * @summary A const&in TArray<FLinearColor> reports Red, (0.25,0.5,0.75,1), and Blue.
 * @topic Containers
 *
 * ReadFLinearColorArray
 */
/**
 * @begin ReadFLinearColorArray
 * @summary A const&in TArray<FLinearColor> reports Red, (0.25,0.5,0.75,1), and Blue.
 * @topic Containers
 */
bool ReadFLinearColorArray(const TArray<FLinearColor>&in Values)
{
	return Values.Num() == 3
		&& Values[0] == FLinearColor::Red
		&& Values[1].Equals(FLinearColor(0.25f, 0.5f, 0.75f, 1.0f), 0.001f)
		&& Values[2] == FLinearColor::Blue;
}
/** @end */
