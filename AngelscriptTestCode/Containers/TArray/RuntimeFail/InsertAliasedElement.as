/**
 * @version v1
 * @summary Insert an element by reference from the same array throws Cannot Insert an element from the same array by reference.
 * @topic Containers
 *
 * InsertAliasedElement
 */
/**
 * @begin InsertAliasedElement
 * @summary Insert an element by reference from the same array throws Cannot Insert an element from the same array by reference.
 * @topic Containers
 */
void InsertAliasedElement()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Insert(Values[0], 1);
}
/** @end */
