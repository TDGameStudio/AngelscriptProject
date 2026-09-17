/**
 * @version v1
 * @summary UE aliases Find, FindLast, Reverse, and RemoveAll are not bound.
 * @topic Containers
 *
 * UnsupportedApiAliases
 */
/**
 * @begin UnsupportedApiAliases
 * @summary UE aliases Find, FindLast, Reverse, and RemoveAll are not bound.
 * @topic Containers
 */
void UnsupportedApiAliases()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Find(1);
	Values.FindLast(1);
	Values.Reverse();
	Values.RemoveAll(1);
}
/** @end */
