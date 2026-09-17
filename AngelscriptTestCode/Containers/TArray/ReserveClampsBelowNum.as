/**
 * @version v1
 * @summary Reserve below Num clamps to the current Num and does not drop elements.
 * @topic Containers
 *
 * ReserveClampsBelowNum
 */
/**
 * @begin ReserveClampsBelowNum
 * @summary Reserve below Num clamps to the current Num and does not drop elements.
 * @topic Containers
 */
bool ReserveClampsBelowNum()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	Values.Reserve(1);
	return Values.Num() == 2 && Values.Max() >= 2 && Values[0] == 10 && Values[1] == 20;
}
/** @end */
