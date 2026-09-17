/**
 * @version v1
 * @summary Shrink reduces slack of a reserved array and does not revive emptied elements.
 * @topic Containers
 *
 * ShrinkReleasesSlack
 */
/**
 * @begin ShrinkReleasesSlack
 * @summary Shrink reduces slack of a reserved array and does not revive emptied elements.
 * @topic Containers
 */
bool ShrinkReleasesSlack()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Reserve(16);
	int SlackBefore = Values.GetSlack();
	Values.Shrink();
	int SlackAfter = Values.GetSlack();
	bool bPopulatedShrink = Values.Num() == 1 && Values[0] == 1 && SlackAfter <= SlackBefore;
	Values.Empty(16);
	Values.Shrink();
	return bPopulatedShrink && Values.IsEmpty();
}
/** @end */
