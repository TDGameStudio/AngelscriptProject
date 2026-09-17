/**
 * @version v1
 * @summary An &inout TArray<FLinearColor> keeps existing slots and Add appends Blue.
 * @topic Containers
 *
 * MutateFLinearColorArray
 */
/**
 * @begin MutateFLinearColorArray
 * @summary An &inout TArray<FLinearColor> keeps existing slots and Add appends Blue.
 * @topic Containers
 */
void MutateFLinearColorArray(TArray<FLinearColor>&inout Values)
{
	Values.Add(FLinearColor::Blue);
}
/** @end */
