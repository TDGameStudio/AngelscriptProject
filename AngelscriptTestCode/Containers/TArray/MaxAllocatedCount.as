/**
 * @version v1
 * @summary Max is at least Num and Reserve(8) makes Max at least 8.
 * @topic Containers
 *
 * MaxAllocatedCount
 */
/**
 * @begin MaxAllocatedCount
 * @summary Max is at least Num and Reserve(8) makes Max at least 8.
 * @topic Containers
 */
bool MaxAllocatedCount()
{
	TArray<int32> Empty;
	TArray<int32> Values;
	Values.Add(1);
	Values.Reserve(8);
	int ReservedMax = Values.Max();
	return Empty.Max() >= 0 && ReservedMax >= 8 && ReservedMax >= Values.Num();
}
/** @end */
