/**
 * @version v1
 * @summary An entry returns TArray<FLinearColor> holding Red, (0.25,0.5,0.75,1), and Blue.
 * @topic Containers
 *
 * ReturnFLinearColorArray
 */
/**
 * @begin ReturnFLinearColorArray
 * @summary An entry returns TArray<FLinearColor> holding Red, (0.25,0.5,0.75,1), and Blue.
 * @topic Containers
 */
TArray<FLinearColor> ReturnFLinearColorArray()
{
	TArray<FLinearColor> Values;
	Values.Add(FLinearColor::Red);
	Values.Add(FLinearColor(0.25f, 0.5f, 0.75f, 1.0f));
	Values.Add(FLinearColor::Blue);
	return Values;
}
/** @end */
