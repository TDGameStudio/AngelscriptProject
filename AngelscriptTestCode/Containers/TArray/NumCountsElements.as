/**
 * @version v1
 * @summary Num counts elements: empty is 0 and two Adds yield 2.
 * @topic Containers
 *
 * NumCountsElements
 */
/**
 * @begin NumCountsElements
 * @summary Num counts elements: empty is 0 and two Adds yield 2.
 * @topic Containers
 */
bool NumCountsElements()
{
	TArray<int32> Empty;
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
