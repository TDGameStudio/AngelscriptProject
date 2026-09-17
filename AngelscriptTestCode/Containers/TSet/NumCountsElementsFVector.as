/**
 * @version v1
 * @summary Num counts unique FVector members and ignores a duplicate Add.
 * @topic Containers
 *
 * NumCountsElementsFVector
 */
/**
 * @begin NumCountsElementsFVector
 * @summary Num counts unique FVector members and ignores a duplicate Add.
 * @topic Containers
 */
bool NumCountsElementsFVector()
{
	TSet<FVector> Empty;
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
