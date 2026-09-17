/**
 * @version v1
 * @summary Reserve grows Max without changing Num or existing elements.
 * @topic Containers
 *
 * ReserveGrowsSlack
 */
/**
 * @begin ReserveGrowsSlack
 * @summary Reserve grows Max without changing Num or existing elements.
 * @topic Containers
 */
bool ReserveGrowsSlack()
{
	TArray<int32> Values;
	Values.Add(1);
	int CountBefore = Values.Num();
	Values.Reserve(8);
	Values.Reserve();
	return Values.Num() == CountBefore && Values.Max() >= 8 && Values[0] == 1;
}
/** @end */
