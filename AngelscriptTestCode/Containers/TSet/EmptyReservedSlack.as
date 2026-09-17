/**
 * @version v1
 * @summary Empty(Slack) clears members; Max is unbound so only Num and IsEmpty are observed.
 * @topic Containers
 *
 * EmptyReservedSlack
 */
/**
 * @begin EmptyReservedSlack
 * @summary Empty(Slack) clears members; Max is unbound so only Num and IsEmpty are observed.
 * @topic Containers
 */
bool EmptyReservedSlack()
{
	TSet<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Empty(4);
	bool bCleared = Values.IsEmpty() && Values.Num() == 0;
	Values.Add(3);
	return bCleared && Values.Num() == 1 && Values.Contains(3) && !Values.Contains(1);
}
/** @end */
