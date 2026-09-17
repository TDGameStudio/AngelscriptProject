/**
 * @version v1
 * @summary Mutating a TSet passed by value is rejected.
 * @topic Containers
 *
 * ByValueMutation
 */
/**
 * @begin ByValueMutation
 * @summary Mutating a TSet passed by value is rejected.
 * @topic Containers
 */
int ByValueMutation(TSet<int> Values)
{
	Values.Add(1);
	return Values.Num();
}
/** @end */
