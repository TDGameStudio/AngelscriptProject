/**
 * @version v1
 * @summary An &out TMap<int, FVector> is filled so GetValues can list stored values.
 * @topic Containers
 *
 * FillByGetValuesListsStoredValuesFVector
 */
/**
 * @begin FillByGetValuesListsStoredValuesFVector
 * @summary An &out TMap<int, FVector> is filled so GetValues can list stored values.
 * @topic Containers
 */
void FillByGetValuesListsStoredValuesFVector(TMap<int, FVector>&out Result)
{
	Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
	Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
