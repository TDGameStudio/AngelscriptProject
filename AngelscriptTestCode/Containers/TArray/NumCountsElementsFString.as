/**
 * @version v1
 * @summary Num counts FString elements: empty is 0 and two Adds yield 2.
 * @topic Containers
 *
 * NumCountsElementsFString
 */
/**
 * @begin NumCountsElementsFString
 * @summary Num counts FString elements: empty is 0 and two Adds yield 2.
 * @topic Containers
 */
bool NumCountsElementsFString()
{
	TArray<FString> Empty;
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
