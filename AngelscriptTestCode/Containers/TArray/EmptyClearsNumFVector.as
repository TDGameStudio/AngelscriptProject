/**
 * @version v1
 * @summary Empty clears FVector Num to 0 and Empty(8) retains Max of at least 8.
 * @topic Containers
 *
 * EmptyClearsNumFVector
 */
/**
 * @begin EmptyClearsNumFVector
 * @summary Empty clears FVector Num to 0 and Empty(8) retains Max of at least 8.
 * @topic Containers
 */
bool EmptyClearsNumFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Empty();
	bool bDefaultEmpty = Values.IsEmpty() && Values.Num() == 0;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Empty(8);
	return bDefaultEmpty && Values.IsEmpty() && Values.Max() >= 8;
}
/** @end */
