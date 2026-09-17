/**
 * @version v1
 * @summary Num counts FVector elements: empty is 0 and two Adds yield 2.
 * @topic Containers
 *
 * NumCountsElementsFVector
 */
/**
 * @begin NumCountsElementsFVector
 * @summary Num counts FVector elements: empty is 0 and two Adds yield 2.
 * @topic Containers
 */
bool NumCountsElementsFVector()
{
	TArray<FVector> Empty;
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	return Empty.Num() == 0 && Values.Num() == 2
		&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[1].Equals(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
