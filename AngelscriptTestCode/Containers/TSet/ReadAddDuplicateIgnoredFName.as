/**
 * @version v1
 * @summary A const&in TSet<FName> reports a single unique member after duplicate Add.
 * @topic Containers
 *
 * ReadAddDuplicateIgnoredFName
 */
/**
 * @begin ReadAddDuplicateIgnoredFName
 * @summary A const&in TSet<FName> reports a single unique member after duplicate Add.
 * @topic Containers
 */
bool ReadAddDuplicateIgnoredFName(const TSet<FName>&in Values)
{
	return Values.Num() == 1 && Values.Contains(n"Red");
}
/** @end */
