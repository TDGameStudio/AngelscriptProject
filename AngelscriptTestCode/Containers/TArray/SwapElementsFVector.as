/**
 * @version v1
 * @summary Swap(0, 2) exchanges FVector ends while the middle value stays.
 * @topic Containers
 *
 * SwapElementsFVector
 */
/**
 * @begin SwapElementsFVector
 * @summary Swap(0, 2) exchanges FVector ends while the middle value stays.
 * @topic Containers
 */
bool SwapElementsFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
	Values.Swap(0, 2);
	Values.Swap(1, 1);
	return Values[0].Equals(FVector(0.0f, 0.0f, 1.0f))
		&& Values[2].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[1].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values.Num() == 3;
}
/** @end */
