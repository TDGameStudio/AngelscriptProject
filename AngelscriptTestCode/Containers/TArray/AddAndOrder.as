/**
 * @version v1
 * @summary Add appends int32 values in insertion order.
 * @topic Containers
 *
 * AddAndOrder
 */
/**
 * @begin AddAndOrder
 * @summary Add appends int32 values in insertion order.
 * @topic Containers
 */
bool AddAndOrder()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	return Values.Num() == 2 && Values[0] == 10 && Values[1] == 20;
}
/** @end */
