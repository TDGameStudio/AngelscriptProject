/**
 * @version v1
 * @summary Comparing an FString against an integer is rejected: the two sides have no common comparison. This file is the illegal program itself; do not convert either side, since the unsupported comparison is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Comparing an FString against an integer is rejected: the two sides have no common comparison. This file is the illegal program itself; do not convert either side, since the unsupported comparison is the point.
 * @topic Negative
 */
/** */
void Test()
{
	FString S = "5";
	bool B = (S == 5);
}
/** @end */
