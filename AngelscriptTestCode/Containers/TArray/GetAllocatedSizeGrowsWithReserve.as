/**
 * @version v1
 * @summary GetAllocatedSize is non-negative and grows after Reserve.
 * @topic Containers
 *
 * GetAllocatedSizeGrowsWithReserve
 */
/**
 * @begin GetAllocatedSizeGrowsWithReserve
 * @summary GetAllocatedSize is non-negative and grows after Reserve.
 * @topic Containers
 */
bool GetAllocatedSizeGrowsWithReserve()
{
	TArray<int32> Empty;
	TArray<int32> Values;
	Values.Add(1);
	Values.Reserve(8);
	int64 EmptyBytes = Empty.GetAllocatedSize();
	int64 PopulatedBytes = Values.GetAllocatedSize();
	return EmptyBytes >= 0 && PopulatedBytes >= EmptyBytes;
}
/** @end */
