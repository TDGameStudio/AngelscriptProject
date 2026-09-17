/**
 * @version v1
 * @summary FCString::Atoi is not exposed by this fork, so calling it is rejected. This file is the illegal program itself; do not substitute a conversion helper, since the missing function is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary FCString::Atoi is not exposed by this fork, so calling it is rejected. This file is the illegal program itself; do not substitute a conversion helper, since the missing function is the point.
 * @topic Negative
 */
/** */
int TryFCStringAtoi()
{
	FString Value = "42";
	return FCString::Atoi(Value);
}
/** @end */
