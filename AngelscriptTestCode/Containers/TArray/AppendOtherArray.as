/**
 * @version v1
 * @summary Append copies the other array onto the end and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherArray
 */
/**
 * @begin AppendOtherArray
 * @summary Append copies the other array onto the end and leaves the source unchanged.
 * @topic Containers
 */
bool AppendOtherArray()
{
	TArray<int32> Values;
	Values.Add(1);
	TArray<int32> Other;
	Other.Add(2);
	Other.Add(3);
	Values.Append(Other);
	TArray<int32> EmptyOther;
	Values.Append(EmptyOther);
	return Values.Num() == 3 && Values[1] == 2 && Values[2] == 3 && Other.Num() == 2;
}
/** @end */
