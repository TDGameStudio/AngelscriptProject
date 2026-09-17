/**
 * @version v1
 * @summary Insert at an index shifts following FString elements and default Insert prepends.
 * @topic Containers
 *
 * InsertShiftsFollowingFString
 */
/**
 * @begin InsertShiftsFollowingFString
 * @summary Insert at an index shifts following FString elements and default Insert prepends.
 * @topic Containers
 */
bool InsertShiftsFollowingFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("gamma");
	Values.Insert("beta", 1);
	bool bInsertedAtOne = Values.Num() == 3 && Values[0] == "alpha" && Values[1] == "beta" && Values[2] == "gamma";
	Values.Insert("head");
	return bInsertedAtOne && Values[0] == "head" && Values.Num() == 4;
}
/** @end */
