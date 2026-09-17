/**
 * @version v1
 * @summary Converting a bool to an FString with an explicit conversion is rejected: formatting a bool as text is not a conversion constructor here. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Converting a bool to an FString with an explicit conversion is rejected: formatting a bool as text is not a conversion constructor here. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	bool B = true;
	FString S = FString(B);
}
/** @end */
