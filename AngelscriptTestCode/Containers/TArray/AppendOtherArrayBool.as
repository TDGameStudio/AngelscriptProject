/**
 * @version v1
 * @summary Append copies the other bool array onto the end and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherArrayBool
 */
/**
 * @begin AppendOtherArrayBool
 * @summary Append copies the other bool array onto the end and leaves the source unchanged.
 * @topic Containers
 */
bool AppendOtherArrayBool()
{
	TArray<bool> Values;
	Values.Add(false);
	TArray<bool> Other;
	Other.Add(true);
	Other.Add(false);
	Values.Append(Other);
	TArray<bool> EmptyOther;
	Values.Append(EmptyOther);
	return Values.Num() == 3 && Values[1] == true && Values[2] == false && Other.Num() == 2;
}
/** @end */
