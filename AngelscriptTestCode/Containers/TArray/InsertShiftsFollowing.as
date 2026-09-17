/**
 * @version v1
 * @summary Insert at an index shifts following elements and default Insert prepends.
 * @topic Containers
 *
 * InsertShiftsFollowing
 */
/**
 * @begin InsertShiftsFollowing
 * @summary Insert at an index shifts following elements and default Insert prepends.
 * @topic Containers
 */
bool InsertShiftsFollowing()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(3);
	Values.Insert(9, 1);
	bool bInsertedAtOne = Values.Num() == 3 && Values[0] == 1 && Values[1] == 9 && Values[2] == 3;
	Values.Insert(0);
	return bInsertedAtOne && Values[0] == 0 && Values.Num() == 4;
}
/** @end */
