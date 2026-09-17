/**
 * @version v1
 * @summary GetSlack equals Max minus Num after Reserve.
 * @topic Containers
 *
 * GetSlackEqualsMaxMinusNum
 */
/**
 * @begin GetSlackEqualsMaxMinusNum
 * @summary GetSlack equals Max minus Num after Reserve.
 * @topic Containers
 */
bool GetSlackEqualsMaxMinusNum()
{
	TArray<int32> Empty;
	TArray<int32> Values;
	Values.Add(1);
	Values.Reserve(8);
	int Slack = Values.GetSlack();
	return Empty.GetSlack() >= 0 && Slack == Values.Max() - Values.Num() && Slack >= 0;
}
/** @end */
