/**
 * @version v1
 * @summary Insert at an index shifts following bool elements and default Insert prepends.
 * @topic Containers
 *
 * InsertShiftsFollowingBool
 */
/**
 * @begin InsertShiftsFollowingBool
 * @summary Insert at an index shifts following bool elements and default Insert prepends.
 * @topic Containers
 */
bool InsertShiftsFollowingBool()
{
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	Values.Insert(true, 1);
	bool bInsertedAtOne = Values.Num() == 3 && Values[0] == false && Values[1] == true && Values[2] == true;
	Values.Insert(false);
	return bInsertedAtOne && Values[0] == false && Values.Num() == 4;
}
/** @end */
