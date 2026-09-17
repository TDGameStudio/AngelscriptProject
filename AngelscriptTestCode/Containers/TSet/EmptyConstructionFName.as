/**
 * @version v1
 * @summary Default TSet<FName> is empty.
 * @topic Containers
 *
 * EmptyConstructionFName
 */
/**
 * @begin EmptyConstructionFName
 * @summary Default TSet<FName> is empty.
 * @topic Containers
 */
bool EmptyConstructionFName()
{
	TSet<FName> Names;
	return Names.IsEmpty() && Names.Num() == 0;
}
/** @end */
