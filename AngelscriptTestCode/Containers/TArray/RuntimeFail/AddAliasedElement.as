/**
 * @version v1
 * @summary Add an element by reference from the same array throws Cannot Add an element from the same array by reference.
 * @topic Containers
 *
 * AddAliasedElement
 */
/**
 * @begin AddAliasedElement
 * @summary Add an element by reference from the same array throws Cannot Add an element from the same array by reference.
 * @topic Containers
 */
void AddAliasedElement()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(Values[0]);
}
/** @end */
