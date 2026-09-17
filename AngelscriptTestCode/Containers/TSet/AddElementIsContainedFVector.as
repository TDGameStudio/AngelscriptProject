/**
 * @version v1
 * @summary Add grows Num for new FVector members only.
 * @topic Containers
 *
 * AddElementIsContainedFVector
 */
/**
 * @begin AddElementIsContainedFVector
 * @summary Add grows Num for new FVector members only.
 * @topic Containers
 */
bool AddElementIsContainedFVector()
{
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	return Values.Num() == 2
		&& Values.Contains(FVector(1.0f, 0.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
