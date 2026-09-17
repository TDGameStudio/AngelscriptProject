/**
 * @version v1
 * @summary FString.ToInt is not exposed by this fork, so calling it is rejected. This file is the illegal program itself; do not substitute a conversion helper, since the missing method is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary FString.ToInt is not exposed by this fork, so calling it is rejected. This file is the illegal program itself; do not substitute a conversion helper, since the missing method is the point.
 * @topic Negative
 */
/** */
int TryStringToIntMethod()
{
	FString Value = "42";
	return Value.ToInt();
}
/** @end */
