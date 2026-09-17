/**
 * @version v1
 * @summary FCString::Atof is not exposed by this fork, so calling it is rejected. This file is the illegal program itself; do not substitute a conversion helper, since the missing function is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary FCString::Atof is not exposed by this fork, so calling it is rejected. This file is the illegal program itself; do not substitute a conversion helper, since the missing function is the point.
 * @topic Negative
 */
/** */
float TryFCStringAtof()
{
	FString Value = "3.14";
	return FCString::Atof(Value);
}
/** @end */
