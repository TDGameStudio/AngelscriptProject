/**
 * @version v1
 * @summary Append copies the other float array onto the end and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherArrayFloat
 */
/**
 * @begin AppendOtherArrayFloat
 * @summary Append copies the other float array onto the end and leaves the source unchanged.
 * @topic Containers
 */
bool AppendOtherArrayFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	TArray<float> Other;
	Other.Add(2.0f);
	Other.Add(3.0f);
	Values.Append(Other);
	TArray<float> EmptyOther;
	Values.Append(EmptyOther);
	return Values.Num() == 3 && Values[1] == 2.0f && Values[2] == 3.0f && Other.Num() == 2;
}
/** @end */
