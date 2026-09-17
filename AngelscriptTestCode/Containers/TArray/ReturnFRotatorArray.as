/**
 * @version v1
 * @summary An entry returns TArray<FRotator> holding Zero, yaw 90, and (10,20,30).
 * @topic Containers
 *
 * ReturnFRotatorArray
 */
/**
 * @begin ReturnFRotatorArray
 * @summary An entry returns TArray<FRotator> holding Zero, yaw 90, and (10,20,30).
 * @topic Containers
 */
TArray<FRotator> ReturnFRotatorArray()
{
	TArray<FRotator> Values;
	Values.Add(FRotator::ZeroRotator);
	Values.Add(FRotator(0.0f, 90.0f, 0.0f));
	Values.Add(FRotator(10.0f, 20.0f, 30.0f));
	return Values;
}
/** @end */
