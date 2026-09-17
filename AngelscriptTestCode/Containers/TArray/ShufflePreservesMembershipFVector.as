/**
 * @version v1
 * @summary Shuffle keeps Num and membership of every original FVector.
 * @topic Containers
 *
 * ShufflePreservesMembershipFVector
 */
/**
 * @begin ShufflePreservesMembershipFVector
 * @summary Shuffle keeps Num and membership of every original FVector.
 * @topic Containers
 */
bool ShufflePreservesMembershipFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
	Values.Shuffle();
	return Values.Num() == 3
		&& Values.Contains(FVector(1.0f, 0.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 1.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
