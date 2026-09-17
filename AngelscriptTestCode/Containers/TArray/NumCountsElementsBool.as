/**
 * @version v1
 * @summary Num counts bool elements: empty is 0 and two Adds yield 2.
 * @topic Containers
 *
 * NumCountsElementsBool
 */
/**
 * @begin NumCountsElementsBool
 * @summary Num counts bool elements: empty is 0 and two Adds yield 2.
 * @topic Containers
 */
bool NumCountsElementsBool()
{
	TArray<bool> Empty;
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
