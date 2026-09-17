/**
 * @version v1
 * @summary Empty clears every FVector member so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNumFVector
 */
/**
 * @begin EmptyClearsNumFVector
 * @summary Empty clears every FVector member so Num is 0.
 * @topic Containers
 */
bool EmptyClearsNumFVector()
{
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Empty();
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
