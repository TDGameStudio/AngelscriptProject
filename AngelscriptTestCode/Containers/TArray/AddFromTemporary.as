/**
 * @version v1
 * @summary Add of a temporary copy of Values[0] appends that value without aliasing storage.
 * @topic Containers
 *
 * AddFromTemporary
 */
/**
 * @begin AddFromTemporary
 * @summary Add of a temporary copy of Values[0] appends that value without aliasing storage.
 * @topic Containers
 */
bool AddFromTemporary()
{
	TArray<int32> Values;
	Values.Add(10);
	int32 Copy = Values[0];
	Values.Add(Copy);
	return Values.Num() == 2 && Values[0] == 10 && Values[1] == 10;
}
/** @end */
