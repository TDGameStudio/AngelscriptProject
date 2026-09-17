/**
 * @version v1
 * @summary A const&in TArray<FVector> reports unique AddUnique order.
 * @topic Containers
 *
 * ReadAddUniqueRejectsDuplicateFVector
 */
/**
 * @begin ReadAddUniqueRejectsDuplicateFVector
 * @summary A const&in TArray<FVector> reports unique AddUnique order.
 * @topic Containers
 */
bool ReadAddUniqueRejectsDuplicateFVector(const TArray<FVector>&in Values)
{
	return Values.Num() == 3
		&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[1].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values[2].Equals(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
