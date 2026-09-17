/**
 * @version v1
 * @summary SetNum grows, shrinks, and default SetNum() clears Num to 0.
 * @topic Containers
 *
 * SetNumGrowsAndShrinks
 */
/**
 * @begin SetNumGrowsAndShrinks
 * @summary SetNum grows, shrinks, and default SetNum() clears Num to 0.
 * @topic Containers
 */
bool SetNumGrowsAndShrinks()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.SetNum(3);
	bool bGrew = Values.Num() == 3 && Values[0] == 1;
	Values.SetNum(1);
	bool bShrunk = Values.Num() == 1 && Values[0] == 1;
	Values.SetNum();
	return bGrew && bShrunk && Values.Num() == 0;
}
/** @end */
