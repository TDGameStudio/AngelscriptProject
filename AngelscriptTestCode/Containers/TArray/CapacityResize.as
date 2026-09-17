/**
 * @version v1
 * @summary Shrink after Reserve(64) drops Max back toward Num while keeping the element.
 * @topic Containers
 *
 * CapacityResize
 */
/**
 * @begin CapacityResize
 * @summary Shrink after Reserve(64) drops Max back toward Num while keeping the element.
 * @topic Containers
 */
bool CapacityResize()
{
	TArray<int32> Values;
	Values.Reserve(64);
	Values.Add(1);

	if (Values.Max() < 64)
	{
		return false;
	}

	Values.Shrink();
	return Values.Num() == 1 && Values.Max() < 64;
}
/** @end */
