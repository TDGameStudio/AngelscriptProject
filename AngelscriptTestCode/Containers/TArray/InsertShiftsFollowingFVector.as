/**
 * @version v1
 * @summary Insert at an index shifts following FVector elements and default Insert prepends.
 * @topic Containers
 *
 * InsertShiftsFollowingFVector
 */
/**
 * @begin InsertShiftsFollowingFVector
 * @summary Insert at an index shifts following FVector elements and default Insert prepends.
 * @topic Containers
 */
bool InsertShiftsFollowingFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
	Values.Insert(FVector(0.0f, 1.0f, 0.0f), 1);
	bool bInsertedAtOne = Values.Num() == 3
		&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[1].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values[2].Equals(FVector(0.0f, 0.0f, 1.0f));
	Values.Insert(FVector(0.0f, 0.0f, 0.0f));
	return bInsertedAtOne && Values[0].Equals(FVector(0.0f, 0.0f, 0.0f)) && Values.Num() == 4;
}
/** @end */
