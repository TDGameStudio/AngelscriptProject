/**
 * @version v1
 * @summary A const&in TSet<FName> reports membership after a missing Remove.
 * @topic Containers
 *
 * ReadRemoveMissingFName
 */
/**
 * @begin ReadRemoveMissingFName
 * @summary A const&in TSet<FName> reports membership after a missing Remove.
 * @topic Containers
 */
bool ReadRemoveMissingFName(const TSet<FName>&in Values)
{
	return Values.Num() == 1 && Values.Contains(n"Red");
}
/** @end */
