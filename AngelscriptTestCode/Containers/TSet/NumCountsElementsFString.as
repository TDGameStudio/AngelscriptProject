/**
 * @version v1
 * @summary Num counts unique FString members and ignores a duplicate Add.
 * @topic Containers
 *
 * NumCountsElementsFString
 */
/**
 * @begin NumCountsElementsFString
 * @summary Num counts unique FString members and ignores a duplicate Add.
 * @topic Containers
 */
bool NumCountsElementsFString()
{
	TSet<FString> Empty;
	TSet<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("alpha");
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
