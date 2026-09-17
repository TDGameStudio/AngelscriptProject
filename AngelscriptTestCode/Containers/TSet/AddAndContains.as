/**
 * @version v1
 * @summary Add inserts a member that Contains then reports as present.
 * @topic Containers
 *
 * AddAndContains
 */
/**
 * @begin AddAndContains
 * @summary Add inserts a member that Contains then reports as present.
 * @topic Containers
 */
bool AddAndContains()
{
	TSet<int> Values;
	Values.Add(10);
	return Values.Num() == 1 && Values.Contains(10);
}
/** @end */
