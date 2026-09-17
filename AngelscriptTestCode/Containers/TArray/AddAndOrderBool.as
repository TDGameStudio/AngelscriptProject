/**
 * @version v1
 * @summary Add appends bool values in insertion order.
 * @topic Containers
 *
 * AddAndOrderBool
 */
/**
 * @begin AddAndOrderBool
 * @summary Add appends bool values in insertion order.
 * @topic Containers
 */
bool AddAndOrderBool()
{
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	return Values.Num() == 2 && Values[0] == false && Values[1] == true;
}
/** @end */
