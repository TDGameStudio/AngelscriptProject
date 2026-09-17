/**
 * @version v1
 * @summary Insert at an index shifts following float elements and default Insert prepends.
 * @topic Containers
 *
 * InsertShiftsFollowingFloat
 */
/**
 * @begin InsertShiftsFollowingFloat
 * @summary Insert at an index shifts following float elements and default Insert prepends.
 * @topic Containers
 */
bool InsertShiftsFollowingFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	Values.Add(3.0f);
	Values.Insert(9.0f, 1);
	bool bInsertedAtOne = Values.Num() == 3 && Values[0] == 1.0f && Values[1] == 9.0f && Values[2] == 3.0f;
	Values.Insert(0.0f);
	return bInsertedAtOne && Values[0] == 0.0f && Values.Num() == 4;
}
/** @end */
