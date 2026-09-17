/**
 * @version v1
 * @summary An &out TSet<FString> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumFString
 */
/**
 * @begin FillByEmptyClearsNumFString
 * @summary An &out TSet<FString> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumFString(TSet<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	Result.Empty();
}
/** @end */
