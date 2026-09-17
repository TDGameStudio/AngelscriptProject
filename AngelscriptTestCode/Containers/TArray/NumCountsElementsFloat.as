/**
 * @version v1
 * @summary Num counts float elements: empty is 0 and two Adds yield 2.
 * @topic Containers
 *
 * NumCountsElementsFloat
 */
/**
 * @begin NumCountsElementsFloat
 * @summary Num counts float elements: empty is 0 and two Adds yield 2.
 * @topic Containers
 */
bool NumCountsElementsFloat()
{
	TArray<float> Empty;
	TArray<float> Values;
	Values.Add(10.0f);
	Values.Add(20.0f);
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
